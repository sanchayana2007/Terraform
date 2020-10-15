/*
#enable the service before using it 
#This property is having a abug in terraform 
#and Not being resolved yet depends on cloudresoursemanager apis (Creates, reads, and updates metadata for Google Cloud Platform resource contain#ers.) 
resource "google_project_service" "cloudbuild" {
  service   = "cloudbuild.googleapis.com"
  depends_on = [var.gcp_project]
  disable_on_destroy  = false
}


resource "google_service_account" "sa" {
  account_id   = "serviceAccount:${google_service_account.sa.email}"
  display_name = "A service account that only Jane can interact with"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.account_id
  role               = "roles/owner"
  members             = ["serviceAccount:${google_service_account.sa.email}",]
}

*/

############################################ API Enabling  ########################
resource "google_project_service" "runtime_project" {
 project = var.gcp_project
 service =   "iam.googleapis.com"
}


resource "google_project_service" "runtime_project0" {
 project = var.gcp_project
 service =   "oslogin.googleapis.com"
 disable_dependent_services=true
}


resource "google_project_service" "runtime_project1" {
 project = var.gcp_project
 service =   "storage-api.googleapis.com"
 disable_dependent_services=true
}


resource "google_project_service" "runtime_project2" {
 project = var.gcp_project
 service =   "storage-api.googleapis.com"
 disable_dependent_services=true
}


resource "google_project_service" "runtime_project3" {
 project = var.gcp_project
 service =   "dataflow.googleapis.com"
 disable_dependent_services=true
}
resource "google_project_service" "runtime_project4" {
 project = var.gcp_project
 service =   "bigquery.googleapis.com"
 disable_dependent_services=true
}
resource "google_project_service" "runtime_project5" {
 project = var.gcp_project
 service =   "cloudfunctions.googleapis.com"
 disable_dependent_services=true
}
resource "google_project_service" "runtime_project6" {
 project = var.gcp_project
 service =   "composer.googleapis.com"
 disable_dependent_services=true
}



############################################ composer Enviroment ########################
#Create a Composer Basic enviroment its a distributed Airflow running on 3 nodes by default
resource "google_composer_environment" "test" {
  name   = "sanch-composer2"
  region = "us-central1"
  config {
    node_count = 3
    node_config {
      zone         = "us-central1-a"
      machine_type = "n1-standard-1"
    }
  }
}

#Run the getDAGDertals  to get the Composer connection info and set the file : main.py

data "external" "getdaglink" {
  program = ["python", "get_DAG_Bucket_details.py"]

 depends_on = [google_composer_environment.test,]
}

/*
#Place the code in the bucket
resource "google_storage_bucket_object" "place_dag" {
 name   = "composer_sample_trigger_response_dag.py"
 #bucket = data.external.getdaglink.result["dag_bucket"]
 bucket = "us-central1-sanch-composer-3c7c8a8d-bucket/dags"
 source = "${path.root}/composer_sample_trigger_response_dag.py"
 depends_on = [data.external.getdaglink,]
}
*/


############################################ Dataflow Bucket ########################
# Regional storage bucket to be used by daatflow
resource "google_storage_bucket" "test_bucket" {
  name  = "sanch-test-bucket12"
  location = "us-central1"
  
  force_destroy = true
}


resource "google_storage_bucket_object" "content_folder" {
  name          = "tmp/"
  content       = "Not really a directory, but it's empty."
  bucket        = google_storage_bucket.test_bucket.name
}


resource "google_storage_bucket_object" "staging_folder" {
  name          = "stg/"
  content       = "Not really a directory, but it's empty."
  bucket        = google_storage_bucket.test_bucket.name
}

############################################ Input Bucket ########################
# Input storage bucket to be used for csv load
resource "google_storage_bucket" "input_bucket" {
  name  = "sanch-test-bucket-input"
  location = "us-central1"
  force_destroy = true
}

#Run the getclienid to get the Composer connection info and set the file : main.py
resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "getclientid.py"
    interpreter = ["python",]
  }

   depends_on = [google_composer_environment.test, ]

}


#Create the zip file from the main 
resource "null_resource" "test2" {
  provisioner "local-exec" {
    command = "zip main.py.zip  main.py"
  }
   depends_on = [null_resource.test, ]
}

#Place the code in the bucket 
resource "google_storage_bucket_object" "hello_world" {
 name   = "main.py.zip"
 bucket = google_storage_bucket.input_bucket.name
 source = "${path.root}/main.py.zip"
  depends_on = [google_storage_bucket.input_bucket,null_resource.test2,] 
}


############################################ Big Query ########################
resource "google_bigquery_dataset" "lake" {
  dataset_id                  = "lake"
  friendly_name               = "sales lake"
  description                 = "sales "
  location                    = "US"
  default_table_expiration_ms = 3600000

}

resource "google_bigquery_table" "sales" {
  dataset_id = google_bigquery_dataset.lake.dataset_id
  table_id   = "SALES_DATA"

  time_partitioning {
    type = "DAY"
  }
   depends_on = [google_bigquery_dataset.lake, ]
}


############################################ Cloud Function ########################
#Cloud function 
resource "google_cloudfunctions_function" "hello_world_function" {
 name                  = "trigger_dag"
 description           = "Seduled  Function"
 available_memory_mb   = 256
 source_archive_bucket = google_storage_bucket.input_bucket.name
 source_archive_object = google_storage_bucket_object.hello_world.name
 timeout               = 60
 #Name of the function to run at teh start
 #entry_point           = "hello_world"
 runtime               = "python37"
 event_trigger {
    event_type =  "google.storage.object.finalize"
    resource   =  google_storage_bucket.input_bucket.name 
    failure_policy {
      retry = true
    }
  }
 
depends_on = [google_storage_bucket_object.hello_world,]


}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.gcp_project
  region         = var.gcp_region
  cloud_function =  google_cloudfunctions_function.hello_world_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
  depends_on = [google_cloudfunctions_function.hello_world_function]
}

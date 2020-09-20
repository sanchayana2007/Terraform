/*
#enable the service before using it 
#This property is having a abug in terraform 
#and Not being resolved yet depends on cloudresoursemanager apis (Creates, reads, and updates metadata for Google Cloud Platform resource contain#ers.) 
resource "google_project_service" "cloudbuild" {
  service   = "cloudbuild.googleapis.com"
  depends_on = [var.gcp_project]
  disable_on_destroy  = false
}
*/
#Create a Composer Basic enviroment its a distributed Airflow running on 3 nodes by default
resource "google_composer_environment" "test" {
  name   = "sanch-composer"
  region = "us-central1"
  config {
    node_count = 3
    node_config {
      zone         = "us-central1-a"
      machine_type = "n1-standard-1"
    }
  }
}

# Regional storage bucket
resource "google_storage_bucket" "test_bucket" {
  name  = "sanch-test-bucket"
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
 bucket = google_storage_bucket.test_bucket.name
 source = "${path.root}/main.py.zip"
  depends_on = [google_storage_bucket.test_bucket,null_resource.test2,]
}

#
resource "google_cloudfunctions_function" "hello_world_function" {
 name                  = "trigger_dag"
 description           = "Seduled  Function"
 available_memory_mb   = 256
 source_archive_bucket = google_storage_bucket.test_bucket.name
 source_archive_object = google_storage_bucket_object.hello_world.name
 timeout               = 60
 #Name of the function to run at teh start
 #entry_point           = "hello_world"
 runtime               = "python37"
 event_trigger {
    event_type =  "google.storage.object.finalize"
    resource   =  google_storage_bucket.test_bucket.name 
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








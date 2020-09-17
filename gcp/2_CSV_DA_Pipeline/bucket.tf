/*
# zip up our source code
data "archive_file" "hello_world_zip" {
 type        = "zip"
 source_dir  = "${path.root}/test.csv"
 output_path = "${path.root}/test.zip"
}
*/


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
# Regional storage bucket
resource "google_storage_bucket" "test_bucket" {
  name  = "sanch-test-bucket"
  location = "us-central1"
}

#PLace code  file in the Bucket
resource "google_storage_bucket_object" "hello_world" {
 name   = "main.py.zip"
 bucket = google_storage_bucket.test_bucket.name
 source = "${path.root}/main.py.zip"
}


#
resource "google_cloudfunctions_function" "hello_world_function" {
 name                  = "Sanch_function"
 description           = "Seduled  Function"
 available_memory_mb   = 256
 source_archive_bucket = google_storage_bucket.test_bucket.name
 source_archive_object = google_storage_bucket_object.hello_world.name
 timeout               = 60
 /*Name of the function to run at teh start
 entry_point           = "hello_world"*/
 runtime               = "python37"
 event_trigger {
    event_type =  "google.storage.object.finalize"
    resource   =  google_storage_bucket.test_bucket.name 
    failure_policy {
      retry = true
    }
  }

}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.gcp_project
  region         = var.gcp_region
  cloud_function =  google_cloudfunctions_function.hello_world_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

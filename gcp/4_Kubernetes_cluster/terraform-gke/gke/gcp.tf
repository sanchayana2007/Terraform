#####################################################################
# Google Cloud Platform
#####################################################################
provider "google" {
  project = var.project
  region  = var.region
  zone= var.zone
}
# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  default     = "../compose-test-291802-1f8ba3535e89.json"
  description = "GCP authentication file"
}
# define GCP region
variable "gcp_region" {
  type        = string
  default = "us-central1" 
  description = "GCP region"
}
# define GCP project name
variable "gcp_project" {
  type        = string
  default = "compose-test-291802"
   description = "GCP project name"
}

# define GCP zone
variable "gcp_zone" {
  type        = string
  default = "us-central1-a" 
  description = "GCP zone"
}

# define GCP zone
variable "service" {
  type        = string
  default = "compute.googleapis.com" 
  description = "GCP zone"
}



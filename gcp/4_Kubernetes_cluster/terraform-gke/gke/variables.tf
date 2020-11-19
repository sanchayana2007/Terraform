#####################################################################
# Variables
#####################################################################
variable "project" {
  type    = string
  default = "compose-test-291802"
  description = "GCP project name"
}


variable "region" {
 type    = string
 default = "us-central1" 
 description = "GCP region"
}


variable "username" {
 type    = string
 default = "admin" 
}



variable "password" {
 type    = string
 default = "admin12345678910!" 
}


# define GCP zone
variable "zone" {
  type    = string
  default = "us-central1-a"
  description = "GCP zone"
}



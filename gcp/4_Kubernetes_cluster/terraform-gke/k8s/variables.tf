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


#This variables are to be taken from gke module by the main.tf file
variable "username" {
 type    = string
 default = "admin" 
}



variable "password" {
 type    = string
 default = "admin12345678910!" 
}



variable "client_certificate" {
}

variable "client_key" {
}
variable "cluster_ca_certificate" {
}

variable "host" {
}

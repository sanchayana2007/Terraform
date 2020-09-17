variable "PROJ" {
}

variable "ZONE"{
}

data "google_compute_zones" "available" {
  project = "{var.PROJ}"
}

resource "google_project_service" "service" {
  for_each = toset(["compute.googleapis.com"])

  service = each.key

  project            =data.google_compute_zones.available.project
  disable_on_destroy = false
}



resource "google_compute_instance" "default" {
  project      = data.google_compute_zones.available.project 
  zone = "asia-south1-a"	
  name         = "tf-compute-1"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  depends_on = [google_project_service.service]
}

output "instance_id" {
  value = google_compute_instance.default.self_link
}


resource "google_compute_instance" "default" {
  project      = var.gcp_project
  zone         = var.gcp_zone
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

  depends_on = [var.service]
}

output "instance_id" {
  value = google_compute_instance.default.self_link
}

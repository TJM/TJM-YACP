resource "google_compute_instance" "test_vm" {
  project                   = var.gcp_project_id
  zone                      = var.gcp_zone
  name                      = "${var.name_prefix}-${var.env}-01"
  machine_type              = var.gcp_compute_type
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = var.gcp_compute_image
    }
  }
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.main.id
  }
}

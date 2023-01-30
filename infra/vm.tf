# Single Interface Test VM
# resource "google_compute_instance" "test_vm" {
#   project                   = var.gcp_project_id
#   zone                      = var.gcp_zone
#   name                      = "${var.name_prefix}-${var.env}-01"
#   machine_type              = var.gcp_compute_type
#   allow_stopping_for_update = true
#   boot_disk {
#     initialize_params {
#       image = var.gcp_compute_image
#     }
#   }
#   network_interface {
#     network    = google_compute_network.vpc.self_link
#     subnetwork = google_compute_subnetwork.main.id
#   }
# }

# Multi-Interface Test VM
# resource "google_compute_instance" "multi_vm" {
#   project                   = var.gcp_project_id
#   zone                      = var.gcp_zone
#   name                      = "${var.name_prefix}-${var.env}-02"
#   machine_type              = var.gcp_compute_type
#   allow_stopping_for_update = true
#   boot_disk {
#     initialize_params {
#       image = var.gcp_compute_image
#     }
#   }

#   # First interface - DMZ (default route -> Internet)
#   network_interface {
#     network    = google_compute_network.dmz.self_link
#     subnetwork = google_compute_subnetwork.dmz.id
#   }

#   # Secondary Interface - MAIN (inside)
#   network_interface {
#     network    = google_compute_network.vpc.self_link
#     subnetwork = google_compute_subnetwork.main.id
#   }
# }

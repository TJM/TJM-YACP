#

# locals {
#   # labels = merge(
#   #   var.mandatory_labels,
#   #   {
#   #     env      = lower(var.env)
#   #     env_type = terraform.workspace == "default" ? lower(var.env) : "review"
#   #   }
#   # )
# }

resource "random_id" "suffix" {
  byte_length = 3
}

## Project
### NOTE: Project will be pre-created and will be passed in as var.gcp_project_id
# resource "google_project" "main" {
#   name                = "Some Project ${upper(var.env)}"
#   project_id          = "some-project-${var.env}-${random_id.suffix.hex}"
#   folder_id           = var.folder_id
#   billing_account     = var.billing_account
#   auto_create_network = false
#   labels              = local.labels
# }

## Enable OS Login for the project
## https://cloud.google.com/compute/docs/instances/managing-instance-access
resource "google_compute_project_metadata_item" "os_login" {
  project = var.gcp_project_id
  key     = "enable-oslogin"
  value   = "TRUE"
}

resource "google_compute_project_metadata_item" "serial_port" {
  project = var.gcp_project_id
  key     = "serial-port-enable"
  value   = "TRUE"
}

## Enable Google APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com",
  ])
  # project                    = google_project.main.project_id
  project                    = var.gcp_project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false

  # Ensure OS Login is enabled before using any compute APIs
  depends_on = [google_compute_project_metadata_item.os_login]
}

# resource "google_storage_bucket" "images" {
#   name          = "${var.name_prefix}-${var.env}-images-${random_id.suffix.hex}"
#   project       = var.gcp_project_id
#   location      = "US"
#   force_destroy = true

#   uniform_bucket_level_access = true
# }

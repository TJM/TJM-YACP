# volterra == F5XC
provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
}

# F5XC module requires the project and zone to be set in the provider.
provider "google" {
  alias   = "project_bound"
  project = var.gcp_project_id
  zone    = var.gcp_zone
}

locals {
  cluster_labels = var.f5xc_fleet_label != "" ? { "ves.io/fleet" = var.f5xc_fleet_label } : {}
  f5_routes      = concat(var.f5_ip_ranges, var.f5_additional_ips)
}

resource "google_service_account" "f5xc" {
  account_id   = "${google_compute_network.dmz.name}-f5xc"
  project      = var.gcp_project_id
  display_name = "F5XC CE Node SA"
}

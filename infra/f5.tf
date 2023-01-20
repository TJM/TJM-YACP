provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
}

provider "google" {
  alias   = "project_bound"
  project = var.gcp_project_id
  zone    = var.gcp_zone
}

locals {
  cluster_labels = var.f5xc_fleet_label != "" ? { "ves.io/fleet" = var.f5xc_fleet_label } : {}
}


# creates a route per network passed into var.f5_ip_ranges
# Needed to use count instead of for_each to get a nice name iterator
resource "google_compute_route" "f5" {
  # for_each         = toset(var.f5_ip_ranges)
  count            = length(var.f5_ip_ranges)
  name             = "${google_compute_network.vpc.name}-f5-${count.index}"
  project          = var.gcp_project_id
  description      = "F5 Network Route ${count.index}"
  dest_range       = var.f5_ip_ranges[count.index]
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 900
}

module "f5_ce" {
  # source                         = "github.com/cklewar/f5-xc-modules//f5xc/ce/gcp?ref=b73dbac"
  source                         = "github.com/tjm/f5-xc-modules//f5xc/ce/gcp?ref=a110409"
  f5xc_ce_gateway_multi_node     = false # this is broken when true
  gcp_region                     = var.gcp_region
  fabric_subnet_outside          = "" # empty string - do not create
  fabric_subnet_inside           = "" # empty string - do not create
  existing_fabric_subnet_outside = google_compute_subnetwork.subnet.self_link
  network_name                   = "" # unused
  instance_name                  = "${var.name_prefix}-${var.env}-f5xc-${random_id.suffix.hex}"
  ssh_username                   = "centos"
  machine_type                   = var.machine_type
  machine_image                  = var.machine_image
  machine_disk_size              = var.machine_disk_size
  ssh_public_key                 = file(var.ssh_public_key_file)
  host_localhost_public_name     = "vip"
  f5xc_tenant                    = var.f5xc_tenant
  f5xc_api_url                   = var.f5xc_api_url
  f5xc_namespace                 = var.f5xc_namespace
  f5xc_api_token                 = var.f5xc_api_token
  f5xc_token_name                = "${var.name_prefix}-${var.env}-${random_id.suffix.hex}"
  f5xc_fleet_label               = var.f5xc_fleet_label
  f5xc_cluster_latitude          = var.cluster_latitude
  f5xc_cluster_longitude         = var.cluster_longitude
  f5xc_ce_gateway_type           = "ingress_gateway"

  providers = {
    google   = google.project_bound
    volterra = volterra
  }
}

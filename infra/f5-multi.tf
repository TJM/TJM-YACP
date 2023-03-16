# # volterra == F5XC


## DMZ VPC (Network)
resource "google_compute_network" "dmz" {
  project                         = var.gcp_project_id
  name                            = "${var.name_prefix}-${var.env}-dmz"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false # Keep default route to Internet
  # depends_on              = [google_project.main]
}

## DMZ Subnet(s)
resource "google_compute_subnetwork" "dmz" {
  name                     = "${google_compute_network.dmz.name}-${var.gcp_region}"
  ip_cidr_range            = var.dmz_subnet
  region                   = var.gcp_region
  description              = "${var.name_prefix} ${upper(var.env)} ${var.gcp_region} DMZ"
  network                  = google_compute_network.dmz.self_link
  project                  = var.gcp_project_id
  private_ip_google_access = true
}

## Create a "count" of external NAT IPs that can be whitelisted
resource "google_compute_address" "dmz_nat" {
  count   = 1
  name    = "${google_compute_network.dmz.name}-${var.gcp_region}-nat-${count.index}"
  project = var.gcp_project_id
  region  = var.gcp_region
}

## Put Output here so disabling the entire file works
output "dmz_nat_ips" {
  description = "List of public IP addresses use for outbound NAT in DMZ"
  value       = google_compute_address.dmz_nat.*.address
}

## Create a Cloud Router to use with a Cloud NAT gateway
## https://cloud.google.com/nat/docs/gce-example#create-nat
resource "google_compute_router" "dmz" {
  name    = "${google_compute_network.dmz.name}-${var.gcp_region}"
  project = var.gcp_project_id
  region  = var.gcp_region
  network = google_compute_network.dmz.self_link
}

## Create a Cloud NAT gateway
## https://cloud.google.com/nat/docs/gce-example#create-nat
resource "google_compute_router_nat" "dmz" {
  name    = "${google_compute_network.dmz.name}-${var.gcp_region}"
  project = var.gcp_project_id
  router  = google_compute_router.dmz.name
  region  = var.gcp_region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.dmz_nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Allow IAP TCP forwarding - to allow SSH access
# https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "iap_dmz" {
  project       = var.gcp_project_id
  name          = "${google_compute_network.dmz.name}-allow-iap-gce-${random_id.suffix.hex}"
  network       = google_compute_network.dmz.self_link
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  # target_tags   = ["iap"]
  allow {
    protocol = "tcp"
    ports    = [22, 3389]
  }
}


## INGRESS Firewall allow for f5_ip_ranges
## FUTURE USE: For when we have a public IP associated
# resource "google_compute_firewall" "f5_ip_ranges_ingress_dmz" {
#   name          = "${google_compute_network.dmz.name}-f5-ingress"
#   project       = var.gcp_project_id
#   network       = google_compute_network.dmz.name
#   direction     = "INGRESS"
#   priority      = 1000
#   source_ranges = var.f5_ip_ranges
#   target_tags   = ["f5xc"]
#   allow {
#     protocol = "tcp"
#     ports    = ["443"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["4500"]
#   }
# }


resource "google_compute_image" "f5xc_multi" {
  name    = var.f5_machine_image_multi
  project = var.gcp_project_id
  family  = "f5xc-ce"
  guest_os_features {
    type = "MULTI_IP_SUBNET"
  }
  raw_disk {
    source = "https://storage.googleapis.com/ves-images/${var.f5_machine_image_multi}.tar.gz"
  }
}

module "f5_ce_multi" {
  # source = "github.com/cklewar/f5-xc-modules//f5xc/ce/gcp?ref=0aaa5ca" # main (previous commit)
  source = "github.com/cklewar/f5-xc-modules//f5xc/ce/gcp?ref=853b86c" # main
  # source = "github.com/tjm/f5-xc-modules//f5xc/ce/gcp?ref=7d2bb4d" # fix/no-public-ips
  # source                         = "../../F5/f5-xc-modules/f5xc/ce/gcp"
  has_public_ip = false # 0.11.18
  # use_public_ip                  = false
  f5xc_ce_gateway_multi_node     = false # this is broken when true
  gcp_region                     = var.gcp_region
  gcp_service_account_email      = google_service_account.f5xc.email
  fabric_subnet_outside          = "" # empty string - do not create
  fabric_subnet_inside           = "" # empty string - do not create
  existing_fabric_subnet_outside = google_compute_subnetwork.dmz.self_link
  existing_fabric_subnet_inside  = google_compute_subnetwork.main.self_link
  network_name                   = "" # unused
  instance_name                  = "${var.name_prefix}-${var.env}-f5xc-multi-${random_id.suffix.hex}"
  ssh_username                   = "centos"
  machine_type                   = var.machine_type
  machine_image                  = google_compute_image.f5xc_multi.name
  machine_disk_size              = var.machine_disk_size
  ssh_public_key                 = file(var.ssh_public_key_file)
  host_localhost_public_name     = "vip"
  f5xc_tenant                    = var.f5xc_tenant
  f5xc_api_url                   = var.f5xc_api_url
  f5xc_namespace                 = var.f5xc_namespace
  f5xc_api_token                 = var.f5xc_api_token
  f5xc_token_name                = "${var.name_prefix}-${var.env}-multi-${random_id.suffix.hex}"
  f5xc_fleet_label               = var.f5xc_fleet_label
  f5xc_cluster_latitude          = var.cluster_latitude
  f5xc_cluster_longitude         = var.cluster_longitude
  f5xc_ce_gateway_type           = "ingress_egress_gateway"
  instance_tags                  = ["f5xc"]

  depends_on = [
    google_compute_router_nat.dmz
  ]

  providers = {
    google   = google.project_bound
    volterra = volterra
  }
}

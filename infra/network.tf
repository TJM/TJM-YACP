## VPC (Network)
resource "google_compute_network" "vpc" {
  project                         = var.gcp_project_id
  name                            = "${var.name_prefix}-${var.env}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true # No default route to Internet
  # depends_on              = [google_project.main]
}

## Subnet(s)
resource "google_compute_subnetwork" "subnet" {
  name                     = "${google_compute_network.vpc.name}-${var.gcp_region}"
  ip_cidr_range            = var.subnet
  region                   = var.gcp_region
  description              = "${var.name_prefix} ${upper(var.env)} ${var.gcp_region}"
  network                  = google_compute_network.vpc.self_link
  project                  = var.gcp_project_id
  private_ip_google_access = true
}

# Create a "count" of external NAT IPs that can be whitelisted
resource "google_compute_address" "nat" {
  count   = 1
  name    = "${google_compute_network.vpc.name}-${var.gcp_region}-nat-${count.index}"
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Create a Cloud Router to use with a Cloud NAT gateway
# https://cloud.google.com/nat/docs/gce-example#create-nat
resource "google_compute_router" "main" {
  name    = "${google_compute_network.vpc.name}-${var.gcp_region}"
  project = var.gcp_project_id
  region  = var.gcp_region
  network = google_compute_network.vpc.self_link
}

# Create a Cloud NAT gateway
# https://cloud.google.com/nat/docs/gce-example#create-nat
resource "google_compute_router_nat" "main" {
  name    = "${google_compute_network.vpc.name}-${var.gcp_region}"
  project = var.gcp_project_id
  router  = google_compute_router.main.name
  region  = var.gcp_region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# We do not want a default route to the Internet (this is a restricted network)
# resource "google_compute_route" "internet" {
#   project          = var.gcp_project_id
#   name             = "${google_compute_network.vpc.name}-public-internet"
#   description      = "Route to the internet"
#   dest_range       = "0.0.0.0/0"
#   network          = google_compute_network.vpc.name
#   next_hop_gateway = "default-internet-gateway"
#   priority         = 1000
# }

# creates a router per endpoint passed into var.public_services
# this restricts traffic to only these destinations
resource "google_compute_route" "public_services" {
  for_each         = var.public_services
  name             = "${google_compute_network.vpc.name}-${each.key}"
  project          = var.gcp_project_id
  description      = "Route for ${each.key}"
  dest_range       = "${each.value}/32"
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 900
}

# Google Private DNS
# - https://cloud.google.com/vpc/docs/configure-private-google-access

## Route
resource "google_compute_route" "google_private_access" {
  name             = "${google_compute_network.vpc.name}-google-private-access"
  project          = var.gcp_project_id
  description      = "Route for Google Private Access"
  dest_range       = "199.36.153.8/30"
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

## EGRESS Firewall
resource "google_compute_firewall" "private_google_access" {
  name               = "${google_compute_network.vpc.name}-private-google-access"
  project            = var.gcp_project_id
  network            = google_compute_network.vpc.name
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["199.36.153.8/30"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

## DNS
# Create private zone for private.googleapis.com domains
resource "google_dns_managed_zone" "google_private_access" {
  for_each    = toset(var.google_private_access_domains)
  project     = var.gcp_project_id
  name        = "${google_compute_network.vpc.name}-${replace(each.value, ".", "-")}-private"
  dns_name    = "${each.value}."
  description = "Google Private Access ${each.value}"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.self_link
    }
  }

  # depends_on = [google_project_service.apis]
}

# Create private googleapis.com A record
resource "google_dns_record_set" "google_private_access_a" {
  for_each     = google_dns_managed_zone.google_private_access
  project      = var.gcp_project_id
  name         = each.value.dns_name
  managed_zone = each.value.name
  type         = "A"
  ttl          = 86400

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]
}

# Create private googleapis.com CNAME record
resource "google_dns_record_set" "google_private_access_cname" {
  for_each     = google_dns_managed_zone.google_private_access
  project      = var.gcp_project_id
  name         = "*.${each.value.dns_name}"
  managed_zone = each.value.name
  type         = "CNAME"
  ttl          = 86400
  rrdatas      = ["${each.value.dns_name}"]
}

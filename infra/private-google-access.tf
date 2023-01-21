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

## DNS
# Create private zone for private.googleapis.com
resource "google_dns_managed_zone" "googleapis_zone" {
  project     = var.gcp_project_id
  name        = "${google_compute_network.vpc.name}-googleapis-com-private"
  dns_name    = "googleapis.com."
  description = "Google APIs Private Access Zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.self_link
    }
  }

  # depends_on = [google_project_service.apis]
}

resource "google_dns_managed_zone" "gcr_zone" {
  project     = var.gcp_project_id
  name        = "${google_compute_network.vpc.name}-gcr-io-private"
  dns_name    = "gcr.io."
  description = "Google Container Registry Private Access Zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.self_link
    }
  }

  # depends_on = [google_project_service.apis]
}

# Create private googleapis.com A record
resource "google_dns_record_set" "a" {
  project      = var.gcp_project_id
  name         = "private.${google_dns_managed_zone.googleapis_zone.dns_name}"
  managed_zone = google_dns_managed_zone.googleapis_zone.name
  type         = "A"
  ttl          = 86400

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]
}

resource "google_dns_record_set" "gcr_a_record" {
  project      = var.gcp_project_id
  name         = google_dns_managed_zone.gcr_zone.dns_name
  managed_zone = google_dns_managed_zone.gcr_zone.name
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
resource "google_dns_record_set" "cname" {
  project      = var.gcp_project_id
  name         = "*.${google_dns_managed_zone.googleapis_zone.dns_name}"
  managed_zone = google_dns_managed_zone.googleapis_zone.name
  type         = "CNAME"
  ttl          = 86400
  rrdatas      = ["${google_dns_record_set.a.name}"]
}

resource "google_dns_record_set" "gcr_cname" {
  project      = var.gcp_project_id
  name         = "*.${google_dns_managed_zone.gcr_zone.dns_name}"
  managed_zone = google_dns_managed_zone.gcr_zone.name
  type         = "CNAME"
  ttl          = 86400
  rrdatas      = ["${google_dns_record_set.gcr_a_record.name}"]
}

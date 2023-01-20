# Allow IAP TCP forwarding
# https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "iap" {
  project       = var.gcp_project_id
  name          = "${var.name_prefix}-${var.env}-allow-iap-gce-${random_id.suffix.hex}"
  network       = google_compute_network.vpc.self_link
  priority      = 65534
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  # target_tags   = ["iap"]
  allow {
    protocol = "tcp"
    ports    = [22, 3389]
  }
}

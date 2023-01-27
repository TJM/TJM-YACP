# GKE Cluster - Private Mode

## Service Account
resource "google_service_account" "gke" {
  account_id   = "${google_compute_network.vpc.name}-gke"
  project      = var.gcp_project_id
  display_name = "GKE Cluster Node SA"
}


## Subnetwork
resource "google_compute_subnetwork" "gke" {
  name                     = "${google_compute_network.vpc.name}-${var.gcp_region}-gke-${random_id.suffix.hex}"
  ip_cidr_range            = var.gke_node_cidr
  region                   = var.gcp_region
  description              = "${var.name_prefix} ${upper(var.env)} ${var.gcp_region}"
  network                  = google_compute_network.vpc.self_link
  project                  = var.gcp_project_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${google_compute_network.vpc.name}-gke-pod-${random_id.suffix.hex}"
    ip_cidr_range = var.gke_pod_cidr
  }
  secondary_ip_range {
    range_name    = "${google_compute_network.vpc.name}-gke-svc-${random_id.suffix.hex}"
    ip_cidr_range = var.gke_service_cidr
  }
}

## EGRESS FW
resource "google_compute_firewall" "gke_egress_cp" {
  name               = "${google_compute_network.vpc.name}-gke-egress-cp"
  project            = var.gcp_project_id
  network            = google_compute_network.vpc.name
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [var.gke_master_cidr]
  target_tags        = ["gke"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

## Cluster
# resource "google_container_cluster" "primary" {
#   count      = 0
#   name       = "${google_compute_network.vpc.name}-01"
#   project    = var.gcp_project_id
#   location   = var.gcp_region
#   network    = google_compute_network.vpc.self_link
#   subnetwork = google_compute_subnetwork.gke.self_link


#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count       = 1

#   ip_allocation_policy {
#     cluster_secondary_range_name  = google_compute_subnetwork.gke.secondary_ip_range[0].range_name
#     services_secondary_range_name = google_compute_subnetwork.gke.secondary_ip_range[1].range_name
#   }

#   private_cluster_config {
#     enable_private_nodes    = true
#     enable_private_endpoint = false
#     master_ipv4_cidr_block  = var.gke_master_cidr
#   }

#   node_config {
#     tags = ["gke"]
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.gke.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }

#   depends_on = [
#     google_compute_firewall.gke_egress_cp
#   ]
# }

# resource "google_container_node_pool" "pool1" {
#   name               = "${google_compute_network.vpc.name}-pool-1"
#   project            = var.gcp_project_id
#   location           = var.gcp_region
#   cluster            = google_container_cluster.primary.name
#   initial_node_count = 1

#   autoscaling {
#     min_node_count = 1
#     max_node_count = 3
#   }

#   node_config {
#     machine_type = "e2-standard-4"
#     tags         = ["gke"]

#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.gke.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }

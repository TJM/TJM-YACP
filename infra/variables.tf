# variable "folder_id" {
#   type        = string
#   description = "Folder id"
# }

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
  default     = "us-west4"
}

variable "gcp_zone" {
  type    = string
  default = "us-west4-c"
}

variable "subnet" {
  type        = string
  description = "CIDR range of subnet"
  default     = "10.4.0.0/16"
}

variable "name_prefix" {
  type        = string
  description = "Resource naming Prefix"
  default     = "tjm"
}

variable "env" {
  type        = string
  description = "Environment - also part of resource naming"
  default     = "f5lab"
}

variable "google_private_access_domains" {
  type        = list(string)
  description = "List of Google Private Access domans to setup DNS for"
  default = [
    "googleapis.com",
    "gcr.io",
    "pkg.dev"
  ]
}

## Test VM
variable "gcp_compute_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "gcp_compute_type" {
  type    = string
  default = "e2-small"
}
## End TestVM

# Map of public services (VIPs) to route, Example:
# public_services = {
#   "vault"       = "1.2.3.4"
#   "artifactory" = "1.2.3.5"
# }
variable "public_services" {
  type    = map(string)
  default = {}
}

variable "f5_ip_ranges" {
  type = list(string)
  default = [ # Americas range from https://docs.cloud.f5.com/docs/reference/network-cloud-ref
    "5.182.215.0/25",
    "84.54.61.0/25",
    "23.158.32.0/25",
    "84.54.62.0/25",
    "185.94.142.0/25",
    "185.94.143.0/25",
    "159.60.190.0/24",
    "72.19.3.0/24",     # volterra-03
    "20.150.36.4/32",   # vesio.blob.core.windows.net
    "20.60.62.4/32",    # waferdatasetsprod.blob.core.windows.net
    "18.117.40.234/32", # register.ves.volterra.io
    "13.107.237.0/24",  # downloads.volterra.io
    "13.107.238.0/24",  # downloads.volterra.io
  ]
}


# ------------------------------
# begin eff migration here
# ------------------------------

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_api_token" {
  type    = string
  default = "/YdvLxcS6zt+AjzcBXRzEVpdLAk="
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "ssh_public_key_file" {
  type = string
}

variable "cluster_latitude" {
  type    = string
  default = "36.114647" # Las Vegas, NV (us-west4)
}

variable "cluster_longitude" {
  type    = string
  default = "-115.172813" # Las Vegas, NV (us-west4)
}


# https://docs.cloud.f5.com/docs/images/node-cloud-images
variable "machine_image" {
  type = string
  # default = "vesio-dev-cz/centos7-atomic-202007210749-multi" # Does not work - never registers, no sshd
  # default = "vesio-dev-cz/centos7-atomic-20220721105-single-voltmesh-us" # Doesn't work - Unable to verify image (permissions)
  # default = "vesio-dev-cz/centos7-atomic-20220721105-single-voltmesh" # Doesn't work - Unable to verify image (permissions)
  default = "centos7-atomic-20220721105-single-voltmesh" # LOCAL IMAGE
}

variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "machine_disk_size" {
  type    = string
  default = "40"
}

variable "f5xc_ce_gateway_type" {
  type    = string
  default = "ingress_egress_gateway"
}

variable "f5xc_fleet_label" {
  type    = string
  default = "gcp-ce-test"
}

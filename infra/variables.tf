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
  description = "CIDR range of main subnet"
  default     = "10.4.0.0/16"
}

variable "dmz_subnet" {
  type        = string
  description = "CIDR range of DMZ subnet"
  default     = "192.168.0.0/20"
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

# Map of public services (VIPs) to route, Example:
# public_services = {
#   "vault"       = "1.2.3.4"
#   "artifactory" = "1.2.3.5"
# }
variable "public_services" {
  type    = map(string)
  default = {}
}

## Test VM
variable "gcp_compute_image" {
  type    = string
  default = "centos-cloud/centos-7-v20221206"
}

variable "gcp_compute_type" {
  type    = string
  default = "e2-small"
}
## End TestVM

## GKE

variable "gke_master_cidr" {
  type        = string
  description = "GKE Master Nodes CIDR (must be /28)"
  default     = "172.16.0.0/28"
}

variable "gke_node_cidr" {
  type        = string
  description = "GKE Worker Nodes SubNetwork CIDR (/24)"
  default     = "10.0.4.0/24"
}

variable "gke_pod_cidr" {
  type        = string
  description = "GKE Pods SubNetwork CIDR (must be /24 for each node IP)"
  default     = "100.64.0.0/16"
}

variable "gke_service_cidr" {
  type        = string
  description = "GKE Service SubNetwork CIDR (/24?)"
  default     = "192.168.4.0/24"
}

### Master Authorized Networks List (cidr_blocks)
### - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_master_authorized_networks_config
variable "gke_master_authorized_networks_config" {
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
  default = [
    {
      display_name = "DEN3 New NAT egress IP"
      cidr_block   = "66.170.91.254/32"
    },
    {
      display_name = "DEN3 Legacy NAT egress IP"
      cidr_block   = "216.46.186.66/32"
    },
    {
      display_name = "SEA1 NAT egress IP"
      cidr_block   = "66.170.83.151/32"
    },
    {
      display_name = "SEA1 NAT egress IP"
      cidr_block   = "66.170.83.152/32"
    },
    { display_name = "Tommy McNeely - Ranch"
      cidr_block   = "216.147.126.199/32"
    },
  ]
}



## End GKE



variable "f5_ip_ranges" {
  type        = list(string)
  description = "List of IP ranges to allow in/out for F5 CE IPSEC and SSL VPN"
  default = [ # Americas range from https://docs.cloud.f5.com/docs/reference/network-cloud-ref
    "5.182.215.0/25",
    "84.54.61.0/25",
    "23.158.32.0/25",
    "84.54.62.0/25",
    "185.94.142.0/25",
    "185.94.143.0/25",
    "159.60.190.0/24",
  ]
}

variable "f5_additional_ips" {
  type        = list(string)
  description = "List of additional outbound IP ranges for F5 CE"
  default = [
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
  type      = string
  sensitive = true
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_api_token" {
  type      = string
  sensitive = true
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
  type        = string
  description = "F5XC CE Single-NIC Machine Image"
  default     = "centos7-atomic-20220721105-single-voltmesh"
}

variable "f5_machine_image_multi" {
  type        = string
  description = "F5XC CE Multi-NIC Machine Image"
  default     = "centos7-atomic-20220721105-multi-voltmesh"
  # default = "centos7-atomic-20220721105-multi-voltmesh-us" # ERROR: no read access to this image
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

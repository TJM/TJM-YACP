# TJM-YACP

YACP -> YetAnotherCaseyProject

## What is this?

This is terraform code to setup a F5 XC (Volterra) CE instance in an existing GCP Project (YetAnotherCaseyProject).

This is a test of a "secure" network (extremely limited Internet access).

## Prerequisites

* Existing Google Project, with all the necessary APIs enabled
* Terraform 1.x :-/
* The current revision (see `variables.tf`) is using a local `machine_image`, so you will have to add it:
  * `gcloud compute images create centos7-atomic-20220721105-single-voltmesh --source-uri gs://ves-images/centos7-atomic-20220721105-single-voltmesh.tar.gz`

## How to make it work

* Create a `terraform.tfvars` file in the "infra" directory or set the variables through CI/CD. Example:

```hcl
gcp_project_id = "google-project-id"

name_prefix    = "tjm"
env            = "f5lab"
# public_services = {
#   "vault"       = "1.2.3.4"
#   "artifactory" = "2.3.4.5"
# }

# F5
f5xc_tenant       = "(F5 Tenant ID)"
f5xc_api_token    = "(PASTE API KEY)"
f5xc_api_p12_file = "(path to filename.p12)"
f5xc_api_url      = "https://COMPANY.console.ves.volterra.io/api"

ssh_public_key_file = "/Users/USERNAME/.ssh/google_compute_engine.pub"
```

* `cd infra`
* `terraform init`
* `export VES_P12_PASSWORD='(P12FilePassword)'`
* `terraform apply`
  * Look at the plan, then approve (`yes`)

## Issues

* The VM is created, but times out waiting to approve the registration.
* We are seeing it trying to connect to an IP address (`20.150.36.4`) that is not on the access list. The IP is "owned" by Microsoft, but we are not sure what it is yet.
* We are missing some outbound IPs, but this needs to be a finite/static list.

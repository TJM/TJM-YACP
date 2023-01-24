# TJM-YACP

YACP -> YetAnotherCaseyProject

## What is this?

This is terraform code to setup a F5 XC (Volterra) CE instance in an existing GCP Project (YetAnotherCaseyProject).

This is a test of a "secure" network (extremely limited Internet access).

## Prerequisites

* Existing Google Project, with all the necessary APIs enabled
* Terraform 1.x :-/
* API Token and API Certificate from F5 site (Administration -> Personal Management -> Credentials)

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

* We are statically defining IP ranges that should be handled some other way.
  * F5 May setup something in "their" IP ranges that forwards to the cloud services so that we can avoid this.
* We are missing some outbound IPs. The [F5 Network Documentation](https://docs.cloud.f5.com/docs/reference/network-cloud-ref) is missing some networks.

terraform {
  required_providers {
    google      = "~> 4.48.0"
    google-beta = "~> 4.48.0"
    random      = "3.4.3"
    local       = ">= 2.2.3"
    null        = ">= 3.1.1"
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.16"
    }
  }
}

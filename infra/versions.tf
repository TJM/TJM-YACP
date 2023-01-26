terraform {
  required_providers {
    google = "4.50.0"
    local  = "2.3.0"
    null   = "3.2.1"
    random = "3.4.3"

    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.18"
    }
  }
}

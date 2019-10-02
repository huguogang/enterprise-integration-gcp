# TFSTATE  backend
terraform {
  backend "gcs" {
    bucket = "developertips-tfstate"
    prefix = "eigcp"
  }
}

############################################
# Global GCP Configuration
############################################
locals {
  # TODO: Change to your own project id
  gcp_project_id = "developertips"
}

provider "google" {
  project = "${local.gcp_project_id}"
  region  = "us-central1"
  zone    = "us-central1-c"
}


# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "6.6.0"
#     }
#   }

#   required_version = ">= 0.12"
# }

provider "google" {
  project = "my-project-377213"
  region  = "us-central1" # Adjust as needed
}

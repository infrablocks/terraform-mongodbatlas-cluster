terraform {
  required_version = ">= 0.14"

  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 0.8"
    }
  }
}
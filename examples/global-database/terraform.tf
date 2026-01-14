terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.81.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }
  required_version = ">= 1.8"
}

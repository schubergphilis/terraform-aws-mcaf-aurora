terraform {
  required_providers {
    assert = {
      source  = "hashicorp/assert"
      version = ">= 0.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.81.0"
    }
  }
  required_version = ">= 1.8"
}

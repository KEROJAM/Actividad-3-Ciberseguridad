terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Credenciales ficticias: LocalStack no valida credenciales reales.
  access_key = "test"
  secret_key = "test"

  # Evita que Terraform consulte AWS real (STS, metadatos, account id).
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  # Necesario para hablar con un endpoint local compatible con S3.
  s3_use_path_style = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

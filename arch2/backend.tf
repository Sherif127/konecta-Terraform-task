terraform {
  backend "s3" {
    bucket         = "konecta-backend-bucket"
    key            = "task6/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

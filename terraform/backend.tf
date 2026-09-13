terraform {
  backend "s3" {
    bucket = "ecs-devops-terraform-state-YOUR-UNIQUE-ID"

    key = "ecs-devops/terraform.tfstate"

    region = "ap-south-1"

    use_lockfile = true
  }
}

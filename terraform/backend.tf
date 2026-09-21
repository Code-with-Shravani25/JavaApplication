terraform {
  backend "s3" {
    bucket = "ecs-devops-terraform-state-20161309"

    key = "ecs-devops/terraform.tfstate"

    region = "us-east-1"

    use_lockfile = true
  }
}

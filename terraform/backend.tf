terraform {
  backend "s3" {
    bucket = "shravani-ecs-terraform-state-20261309"

    key = "ecs-devops/terraform.tfstate"

    region = "ap-south-1"

    use_lockfile = true
  }
}

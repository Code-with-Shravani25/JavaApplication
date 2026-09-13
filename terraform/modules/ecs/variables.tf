variable "project_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "execution_role_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "alb_listener_dependency" {
  type = string
}

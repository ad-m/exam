variable "region" {
  type        = string
  description = "region"
  default     = "us-east-2"
}


variable "nginx_version" {
  type        = string
  description = "Nginx version to deploy (Docker Hub tag)"
  default     = "latest"
}

variable "docker_compose_version" {
  # TODO: Consume variable in deployment
  type        = string
  description = "Docker compose version (GitHub release)"
  default     = "latest"
}

variable "ami" {
  type        = string
  description = "AWS AMI in use"
  default     = "ami-002068ed284fb165b"
}

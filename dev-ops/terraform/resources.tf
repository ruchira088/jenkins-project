terraform {
    backend "s3" {
        bucket =  "terraform.ruchij.com"
        key = "backends/BACKEND_KEY"
        region = "ap-southeast-2"
    }
}

provider "aws" {
    region = "ap-southeast-2"
}

variable "docker_repository_name" {}

resource "aws_ecr_repository" "ecrRepository" {
    name = "${var.docker_repository_name}"
}

output "dockerRepositoryUrl" {
    value = "${aws_ecr_repository.ecrRepository.repository_url}"
}
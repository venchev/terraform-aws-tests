# This module is creating cloud repository for our docker images in AWS.
# It is mandatory requirement that we should upload the docker images to the AWS repo, 
# before we start using them in any setups in the cloud.

# Using the flag "MUTABLE" guarantees that the repo will be using the latest version
# of images.

# Additionally, an image scanning option is set for the docker images, i.e.
# it is scanning the uploaded images for software vulnerabilities.
# This is an optional feature.
# If it is enabled, we are adding option for scanning of docker image immediately,
# when it is getting pushed to the repository.


resource "aws_ecr_repository" "repo" {
  name                 = "main_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}


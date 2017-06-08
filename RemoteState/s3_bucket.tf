#
# Project Name:: en_infra_aws
# File:: s3_bucket.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Sets up an S3 Bucket for RemoteState Storage
#

#--
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.statefile_bucket}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

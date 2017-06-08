#
# Project Name:: en_infra_aws
# File:: s3_bucket.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Sets up an S3 Bucket for RemoteState Storage
#

#--
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.statefile_dynamo}"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

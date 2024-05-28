terraform {
  source = "${get_repo_root()}//terraform"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket                  = "tf-state-${get_aws_account_id()}"
    key                     = "AmazonConnect_Callback/terraform/terraform.tfstate"
    region                  = "eu-west-2"
    encrypt                 = true
    skip_bucket_root_access = true
    disable_bucket_update   = true
  }
}

inputs = {
  lambda_name         = "CallbackTest"
  bucket_name         = "amazonconnect-callbacktest"
  #kinesis_stream_name = "bppulse-test-nonsso-ctr-strm"
  env_type            = "dev"
  account_prefix      = "WS-009H"
}

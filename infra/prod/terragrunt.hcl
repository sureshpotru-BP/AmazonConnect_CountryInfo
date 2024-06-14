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
    key                     = "AmazonConnect_CountryInfo/terraform/terraform.tfstate"
    region                  = "eu-west-2"
    encrypt                 = true
    skip_bucket_root_access = true
    disable_bucket_update   = true
  }
}

inputs = {
  lambda_name         = "AmazonConnect_CountryInfo"
  bucket_name         = "amazonconnect-countryinfo-uk"
  #kinesis_stream_name = "bpcm-ctr-strm"
  env_type            = "prod"
  account_prefix      = "WS-009I"
}

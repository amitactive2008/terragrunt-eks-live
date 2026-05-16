remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    profile = "amit"
    
    # Move role_arn inside this block
    assume_role = {
      role_arn = "arn:aws:iam::088317451471:role/terraform"
    }

    bucket         = "dreams-unlimited"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile = true
  }
}
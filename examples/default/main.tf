provider "aws" {
  region = "eu-central-1"
}

module "default" {
  source = "../.."
  nr_account = "1234567"
  nr_license_key = "0000aaaaffffbbbb4444aaaabb225a1fffffNRAL"

  tags = {
    tag1 = "abc123"
    tag2 = "def456"
  }
}
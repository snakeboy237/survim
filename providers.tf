provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
}

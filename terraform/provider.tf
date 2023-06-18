provider "aws" {
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Enviornment = "Dev"
      Owner       = "Rohin Chopra"
      Project     = "Personal Website API"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "n_virginia"

  default_tags {
    tags = {
      Enviornment = "Dev"
      Owner       = "Rohin Chopra"
      Project     = "Personal Website API"
    }
  }
}

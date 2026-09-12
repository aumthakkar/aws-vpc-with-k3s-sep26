terraform {
  backend "s3" {
    region = "eu-north-1"
    key    = "mtciterraform/aws-vpc-sep26"
    bucket = "mtciterraform"
  }
}
locals {
  gcp_region = "us-east1"
  gcp_asn = 65500
  gcp_cidr = "10.128.0.0/20"

}

locals {
    aws_route_tables_ids = ["rtb-xxxx"]
}

variable "ROOT_PATH" {
  type = string
}
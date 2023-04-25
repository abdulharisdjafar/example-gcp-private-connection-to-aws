data "terraform_remote_state" "ha_vpn" {
  backend = "local"

  config = {
    path = "${var.ROOT_PATH}/gcp-create-ha-vpn/terraform.tfstate"
  }
}


locals {
  gcp_region = "us-east1"
  gcp_asn = 65500
  gcp_cidr = "10.128.0.0/20"

}

locals {
    aws_vpc = "vpc-0b330e3bf28df5bdf"
    aws_route_tables_ids = ["rtb-04617d504472023cd"]
    aws_region = "eu-east-1"
}

variable "ROOT_PATH" {
  type = string
}
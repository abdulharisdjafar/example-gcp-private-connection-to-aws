variable "ROOT_PATH" {
  type = string
}

data "terraform_remote_state" "aws_vpn" {
  backend = "local"

  config = {
    path = "${var.ROOT_PATH}/aws-create-vpn/terraform.tfstate"
  }
}


data "terraform_remote_state" "ha_vpn" {
  backend = "local"

  config = {
    path = "${var.ROOT_PATH}/gcp-create-ha-vpn/terraform.tfstate"
  }
}


locals {
  gcp_network = "projects/quipper-school-analytics-dev/global/networks/vpc-data-pipeline"
  gcp_region = "us-east1"
  gcp_asn = 65500
  gcp_cidr = "10.128.0.0/20"

}



locals {
  external_vpn_gateway_interfaces = {
    "0" = {
      tunnel_address        = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel1_address
      vgw_inside_address    = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel1_vgw_inside_address
      asn                   = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel1_bgp_asn
      cgw_inside_address    = "${data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel1_cgw_inside_address}/30"
      shared_secret         = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel1_preshared_key
      vpn_gateway_interface = 0
    },
    "1" = {
      tunnel_address        = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel2_address
      vgw_inside_address    = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel2_vgw_inside_address
      asn                   = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel2_bgp_asn
      cgw_inside_address    = "${data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel2_cgw_inside_address}/30"
      shared_secret         = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn1.tunnel2_preshared_key
      vpn_gateway_interface = 0
    },
    "2" = {
      tunnel_address        = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel1_address
      vgw_inside_address    = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel1_vgw_inside_address
      asn                   = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel1_bgp_asn
      cgw_inside_address    = "${data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel1_cgw_inside_address}/30"
      shared_secret         = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel1_preshared_key
      vpn_gateway_interface = 1
    },
    "3" = {
      tunnel_address        = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel2_address
      vgw_inside_address    = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel2_vgw_inside_address
      asn                   = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel2_bgp_asn
      cgw_inside_address    = "${data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel2_cgw_inside_address}/30"
      shared_secret         = data.terraform_remote_state.aws_vpn.outputs.aws_vpn_connection_vpn2.tunnel2_preshared_key
      vpn_gateway_interface = 1
    },
  }
}
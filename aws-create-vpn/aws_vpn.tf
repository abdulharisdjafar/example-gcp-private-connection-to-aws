resource "aws_security_group" "sg_vpn" {
  name        = "sg_vpn"
  vpc_id      = "vpc-0b330e3bf28df5bdf"


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_customer_gateway" "customer_gateway1" {
  bgp_asn    = local.gcp_asn
  ip_address = data.terraform_remote_state.ha_vpn.outputs.google_compute_ha_vpn_gateway_ha_vpn_gateway_vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags       =  {
      team = "global-data-intelegences"
  }
}

resource "aws_customer_gateway" "customer_gateway2" {
  bgp_asn    = local.gcp_asn
  ip_address = data.terraform_remote_state.ha_vpn.outputs.google_compute_ha_vpn_gateway_ha_vpn_gateway_vpn_interfaces[1].ip_address
  type       = "ipsec.1"

  tags       =  {
      team = "global-data-intelegences"
  }
}

resource "aws_vpn_gateway" "default" {
  vpc_id = "${local.aws_vpc}"

  tags       =  {
      team = "global-data-intelegences"
  }
}

resource "aws_vpn_connection" "vpn1" {
  vpn_gateway_id      = aws_vpn_gateway.default.id
  customer_gateway_id = aws_customer_gateway.customer_gateway1.id
  type                = aws_customer_gateway.customer_gateway1.type

  tags       =  {
      team = "global-data-intelegences"
  }
}

resource "aws_vpn_connection" "vpn2" {
  vpn_gateway_id      = aws_vpn_gateway.default.id
  customer_gateway_id = aws_customer_gateway.customer_gateway2.id
  type                = aws_customer_gateway.customer_gateway2.type

  tags       =  {
      team = "global-data-intelegences"
  }
}

resource "aws_route" "gcp" {
  count                  = length(local.aws_route_tables_ids)
  route_table_id         = local.aws_route_tables_ids[count.index]
  gateway_id             = aws_vpn_gateway.default.id
  destination_cidr_block = local.gcp_cidr

}

# Allow inbound access to VPC resources from GCP CIDR
resource "aws_security_group_rule" "google_ingress_vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [local.gcp_cidr]
  security_group_id = aws_security_group.sg_vpn.id

}

# Allow outbound access from VPC resources to GCP CIDR
resource "aws_security_group_rule" "google_egress_vpn" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [local.gcp_cidr]
  security_group_id = aws_security_group.sg_vpn.id

}

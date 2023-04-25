resource "google_compute_router" "ha_vpn_gateway_router" {
  name        = "ha-vpn-gateway-router"
  network     = local.gcp_network
  description = "Google to AWS via Transit GW connection for AWS"
  bgp {
    asn = local.gcp_asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = local.gcp_cidr
      description = local.gcp_cidr
    }
  }

}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "aws-external-gateway"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "AWS Transit GW"

  dynamic "interface" {
    for_each = local.external_vpn_gateway_interfaces
    content {
      id         = interface.key
      ip_address = interface.value["tunnel_address"]
    }
  }

}

resource "google_compute_vpn_tunnel" "tunnels" {
  for_each                        = local.external_vpn_gateway_interfaces

  name                            = "gcp-tunnel${each.key}"
  description                     = "Tunnel to AWS - HA VPN interface ${each.key} to AWS interface ${each.value.tunnel_address}"
  router                          = google_compute_router.ha_vpn_gateway_router.self_link
  ike_version                     = 2
  shared_secret                   = each.value.shared_secret
  vpn_gateway                     = data.terraform_remote_state.ha_vpn.outputs.self_link
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.self_link
  peer_external_gateway_interface = each.key

}

resource "google_compute_router_interface" "interfaces" {
  for_each   = local.external_vpn_gateway_interfaces

  name       = "interface${each.key}"
  router     = google_compute_router.ha_vpn_gateway_router.name
  ip_range   = each.value.cgw_inside_address
  vpn_tunnel = google_compute_vpn_tunnel.tunnels[each.key].name
}

resource "google_compute_router_peer" "router_peers" {
  for_each        = local.external_vpn_gateway_interfaces

  name            = "peer${each.key}"
  router          = google_compute_router.ha_vpn_gateway_router.name
  peer_ip_address = each.value.vgw_inside_address
  peer_asn        = each.value.asn
  interface       = google_compute_router_interface.interfaces[each.key].name
}


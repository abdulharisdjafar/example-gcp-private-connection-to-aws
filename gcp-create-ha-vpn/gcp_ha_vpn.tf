resource "google_compute_network" "vpc" {
  project = "quipper-school-analytics-dev"
  auto_create_subnetworks = false
  name                    = "vpc-data-pipeline"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc_subnetworks" {
  ip_cidr_range = local.gcp_cidr
  project       = "quipper-school-analytics-dev"
  name          = "sbnt-data-pipeline"
  network       = google_compute_network.vpc.id
  region        = "us-east1"
  private_ip_google_access = true
}

resource "google_compute_ha_vpn_gateway" "ha_vpn_gateway" {
  name    = "ha-vpn-gateway"
  network = google_compute_network.vpc.id
  region  = local.gcp_region
}



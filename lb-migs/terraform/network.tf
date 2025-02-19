# Without a CLOUD NAT or GOOGLE PRIVATE ACCESS, the instances cannot pull the container images

# Cloud Router (Required for Cloud NAT)
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = "default" # Use your existing VPC name
  region  = var.region
}

# Cloud NAT (For Outbound Internet Without Public IPs)
resource "google_compute_router_nat" "cloud_nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

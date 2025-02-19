# Without a CLOUD NAT or GOOGLE PRIVATE ACCESS, the instances cannot pull the container images

# Cloud Router (Required for Cloud NAT)
resource "google_compute_router" "nat_router" {
  for_each    = toset(var.regions)
  name    = "nat-router"
  network = "default" # Use your existing VPC name
  region  = each.value
}

# Cloud NAT (For Outbound Internet Without Public IPs)
resource "google_compute_router_nat" "cloud_nat" {
  for_each    = toset(var.regions)
  name                               = "cloud-nat"
  router                             = google_compute_router.nat_router[each.value].name
  region                             = each.value
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "default" {
 name    = "web-firewall"
 network = "default"

 allow {
   protocol = "icmp"
 }

 allow {
   protocol = "tcp"
   ports    = ["80"]
 }

 source_ranges = ["0.0.0.0/0"]
 target_tags = ["web"]
}
# DNS Zone
resource "google_dns_managed_zone" "dns_zone" {
  name     = "my-dns-zone"
  dns_name = "${var.domain_name}."
}

# Create an A record for the Load Balancer
resource "google_dns_record_set" "lb_dns" {
  name         = "${var.subdomain}.${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.dns_zone.name

  rrdatas = [google_compute_global_address.lb_ip.address]
}

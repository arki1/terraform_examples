provider "google" {
  alias   = "dns"
  project = "arki1-cloud" # Project where the DNS is hosted
}

resource "google_dns_record_set" "subdomain" {
  provider     = google.dns
  name         = "${var.subdomain}.${var.parent_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = "arki1-cloud" # Change this to your existing Cloud DNS zone

  rrdatas = [google_compute_global_forwarding_rule.https_forwarding_rule.ip_address]
}


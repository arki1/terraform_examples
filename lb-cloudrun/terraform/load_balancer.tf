# Create Serverless Network Endpoint Groups (NEGs) for each Cloud Run service
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each              = google_cloud_run_service.cloudrun_service
  name                  = "cloudrun-neg-${each.key}"
  region                = each.key
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = each.value.name
  }
}


# Create a Global Backend Service that includes all regional NEGs
resource "google_compute_backend_service" "backend" {
  name                  = "cloudrun-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"
  enable_cdn            = false
  
  outlier_detection {
    consecutive_errors = 10
    max_ejection_percent = 90
  }

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.serverless_neg
    
    content {
      group = backend.value.id
    }
  }
}

# Create URL Map
resource "google_compute_url_map" "url_map" {
  name            = "cloudrun-url-map"
  default_service = google_compute_backend_service.backend.id
}

# Create Target HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name            = "cloudrun-https-proxy"
  url_map         = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

# Create a Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = "cloudrun-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Create SSL Certificate
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "cloudrun-ssl-cert-${var.subdomain}"

  managed {
    domains = ["${var.subdomain}.${var.parent_domain}"]
  }

  lifecycle {
    prevent_destroy = true
  }
}

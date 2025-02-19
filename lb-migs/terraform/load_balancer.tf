# Backend Service using the MIG (No need for NEG)
resource "google_compute_backend_service" "backend" {
  name                  = "backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]

  depends_on = [google_compute_health_check.default]

  dynamic "backend" {
    for_each = google_compute_region_instance_group_manager.mig
    
    content {
      group = backend.value.instance_group
    }
  }
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend.id
}

# HTTP Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name    = "https-proxy"
  url_map = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = "https-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
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

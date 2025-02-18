# Create a Network Endpoint Group (NEG) that points to the Managed Instance Group
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "neg-${var.region}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
}

# Backend Service using the NEG
resource "google_compute_backend_service" "backend" {
  name                  = "backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# Global Forwarding Rule (Public IP Address)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}

# Reserve Static IP for Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip"
}

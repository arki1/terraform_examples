
output "load_balancer_url" {
  value = "https://${var.subdomain}.${var.parent_domain}"
}

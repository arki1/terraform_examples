output "cloud_run_urls" {
  value = { for region, service in google_cloud_run_service.cloudrun_service : region => service.status[0].url }
}

output "load_balancer_url" {
  value = "https://${var.subdomain}.${var.parent_domain}"
}

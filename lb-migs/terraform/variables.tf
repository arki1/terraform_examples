
# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "regions" {
  description = "List of regions to deploy Cloud Run services"
  type        = list(string)
  default     = [
    "us-central1",
    "us-east1",
    "southamerica-east1",
    "southamerica-west1",
    "europe-west2",
    "northamerica-northeast1"
  ]
}

variable "parent_domain" {
  description = "The domain name for the DNS configuration"
  type        = string
  default     = "arki1.cloud"
}

variable "subdomain" {
  description = "The subdomain for the Load Balancer (e.g., 'app')"
  type        = string
}
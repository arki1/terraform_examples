variable "project_id" {
  description = "Google Cloud project ID"
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
    "europe-west1",
    "northamerica-northeast1"
  ]
}

variable "parent_domain" {
  description = "The main domain configured in the DNS project"
  type        = string
  default     = "arki1.cloud" # This should be the root domain
}

variable "subdomain" {
  description = "Subdomain for the load balancer (e.g., example)"
  type        = string
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}


variable "parent_domain" {
  description = "The domain name for the DNS configuration"
  type        = string
  default     = "arki1.cloud"
}

variable "subdomain" {
  description = "The subdomain for the Load Balancer (e.g., 'app')"
  type        = string
  default     = "feu"
}
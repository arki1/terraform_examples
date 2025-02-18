provider "google" {
  project = var.project_id
}

# Enable required APIs
resource "google_project_service" "enable_services" {
  for_each = toset([
    "run.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com"
  ])
  service = each.key
}

# Deploy Cloud Run services across multiple regions
resource "google_cloud_run_service" "cloudrun_service" {
  for_each = toset(var.regions)

  name     = "cloudrun-hello-${each.value}"
  location = each.value

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }
    
    spec {
      containers {
        image = "gcr.io/${var.project_id}/cloudrun-hello"
        env {
          name  = "GOOGLE_CLOUD_REGION"
          value = each.value
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
  depends_on                 = [google_project_service.enable_services]
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  for_each = google_cloud_run_service.cloudrun_service

  location = each.key
  project  = var.project_id
  service  = each.value.name

  policy_data = <<EOT
{
  "bindings": [
    {
      "role": "roles/run.invoker",
      "members": ["allUsers"]
    }
  ]
}
EOT
}

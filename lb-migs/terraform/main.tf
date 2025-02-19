provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "vm_service_account" {
  account_id   = "vm-container-access"
  display_name = "VM Container Access Service Account"
}

# Grant required roles to the service account
resource "google_project_iam_member" "artifact_registry_access" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "storage_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# VM Template with Built-in Container Support
resource "google_compute_instance_template" "vm_template" {
  name_prefix  = "vm-template-"
  machine_type = "e2-medium"

  # Container-Optimized OS (cos-stable)
  disk {
    source_image      = {
      family  = "cos-stable"
      project = "cos-cloud"
    }
    auto_delete       = true
    boot              = true
    disk_type         = "pd-balanced"
    disk_size_gb      = 10
  }

  # container has automatic access to host ports
  # see: https://cloud.google.com/compute/docs/containers/configuring-options-to-run-containers#publishing_container_ports
  metadata = {
    "gce-container-declaration" = <<-EOT
      spec:
        containers:
        - name: container-hello
          image: gcr.io/${var.project_id}/container-hello
          env:
          - name: GOOGLE_CLOUD_REGION
            value: ${var.region}
          ports:
          - containerPort: 80
        restartPolicy: Always
    EOT
  }

  network_interface {
    network    = "default" # Use your existing VPC name
    subnetwork = "default" # Or the actual subnet where your VMs run
  }

  tags = ["container-vm", "web"]

  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  # Container deployment within the VM (No startup script needed)
  confidential_instance_config {
    enable_confidential_compute = false
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Regional Managed Instance Group with Region in Name
resource "google_compute_region_instance_group_manager" "mig" {
  name               = "mig-${var.region}"
  base_instance_name = "container-vm"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.vm_template.id
  }

  target_size = 2  # Number of instances in the group

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 80
  }

  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b",
  ]
}

# Health Check (Updated for Port 80)
resource "google_compute_health_check" "default" {
  name                = "health-check-${var.region}"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

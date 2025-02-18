provider "google" {
  project = var.project_id
  region  = var.region
}

# VM Template with Container-Optimized OS
resource "google_compute_instance_template" "vm_template" {
  name_prefix  = "vm-template-"
  machine_type = "e2-medium"

  # Container-Optimized OS
  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/cos-cloud/global/images/family/cos-stable"
  }

  network_interface {
    network = "default"
  }

  metadata = {
    google-logging-enabled = "true"
  }

  tags = ["container-vm"]

  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  # Run the container properly and expose port 80
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo 'Starting container...'
    /usr/bin/docker-credential-gcr configure-docker
    docker run -d -p 80:8080 --name my-container -e GOOGLE_CLOUD_REGION=${var.region} gcr.io/${var.project_id}/cloudrun-hello
  EOT
}

# Regional Managed Instance Group with Region in Name
resource "google_compute_region_instance_group_manager" "mig" {
  name               = "my-regional-mig-${var.region}"
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

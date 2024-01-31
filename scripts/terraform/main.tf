terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# resource "google_service_account" "service_account" {
#   account_id   = "sui-full-node-tf-svc-acct"
#   display_name = "Sui Full Node Terraform Service Account"
#   description  = "Service account for managing Sui Full Node operations, including access to necessary GCP resources and services."
# }

# resource "google_project_iam_member" "service_account_perms" {
#   project = var.project
#   role    = "roles/editor"
#   member  = google_service_account.service_account.member
# }

resource "google_compute_disk" "vm_disk" {
  name  = "${var.name}-disk"
  zone  = var.zone
  image = "ubuntu-os-cloud/ubuntu-2204-lts"
  size = var.disk_size
  type = "pd-ssd"
}

resource "google_compute_instance" "vm_instance" {
  name         = var.name
  machine_type = var.machine_type

  boot_disk {
    source = google_compute_disk.vm_disk.self_link
    auto_delete = false
  }

  service_account {
    # email = google_service_account.service_account.email
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Installing Google Cloud Ops Agent..."
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    echo "Ops Agent installation complete."
  EOT

  metadata = {
    user-data = file(var.cloud_init_script_path)
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

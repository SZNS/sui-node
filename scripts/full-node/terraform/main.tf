terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_resource_policy" "vm_disk_snapshot_schedule" {
  provider = google-beta
  name   = "${var.name}-snapshot-policy"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00" # Snap on these days: Everyday except never during time window: 23:00 to 03:00 EST
      }
    }

    retention_policy {
      max_retention_days    = 2
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = ["us"]
      labels = {
        auto_snapshot = "true"
      }
    }
  }
}

resource "google_compute_disk" "vm_disk" {
  provider = google-beta
  name  = "${var.name}-disk"
  zone  = var.zone
  image = "ubuntu-os-cloud/ubuntu-2204-lts"
  size  = var.disk_size
  type  = "pd-ssd"
  resource_policies = [google_compute_resource_policy.vm_disk_snapshot_schedule.id]
}

resource "google_compute_instance" "vm_instance" {
  name         = var.name
  machine_type = var.machine_type
  boot_disk {
    source      = google_compute_disk.vm_disk.self_link
    auto_delete = false
  }

  service_account {
    email = var.service_account_email != "" ? var.service_account_email : null
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

  metadata = {
    user-data = file(var.cloud_init_script_path)
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

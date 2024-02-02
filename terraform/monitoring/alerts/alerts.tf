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

resource "google_monitoring_notification_channel" "email_alerts" {
  display_name = "Sui Node (${var.machine_name}) Alert Notifications"
  type         = "email"
  labels = {
    email_address = "${var.notification_channel_email}"
  }

  enabled = true

  force_delete = false
}

resource "google_monitoring_alert_policy" "cpu_alert_policy" {
  provider = google-beta
  display_name = "Sui Node (${var.machine_name}) - CPU High Usage"

  alert_strategy {
    auto_close = "604800s"
  }

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "resource.type = \"gce_instance\" AND (resource.labels.zone = \"${var.zone}\" AND resource.labels.project_id = \"${var.project}\") AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\" AND metadata.system_labels.name = \"${var.machine_name}\""
      threshold_value = var.cpu_threshold

      trigger {
        count = 10
      }
    }

    display_name = "Sui Node (${var.machine_name}) - CPU Utilization"
  }


  documentation {
    content   = "The Sui Node CPU utilization is above ${var.mem_threshold}%. Please check the node to prevent any issues."
    mime_type = "text/markdown"
  }

  enabled               = true
  notification_channels = [google_monitoring_notification_channel.email_alerts.id]
}

resource "google_monitoring_alert_policy" "mem_alert_policy" {
  alert_strategy {
    auto_close = "604800s"
  }

  display_name = "Sui Node (${var.machine_name}) - Memory High Usage"

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "resource.type = \"gce_instance\" AND (resource.labels.zone = \"${var.zone}\" AND resource.labels.project_id = \"${var.project}\") AND metric.type = \"agent.googleapis.com/memory/percent_used\" AND metric.labels.state = \"used\" AND metadata.system_labels.name = \"${var.machine_name}\""
      threshold_value = var.mem_threshold

      trigger {
        count = 10
      }
    }

    display_name = "Sui Node - Memory Utilization"
  }

  documentation {
    content   = "The Sui Node memory utilization is above ${var.mem_threshold}%. Please check the node"
    mime_type = "text/markdown"
  }

  enabled               = true
  notification_channels = [google_monitoring_notification_channel.email_alerts.id]
}

resource "google_monitoring_alert_policy" "disk_alert_policy" {
  alert_strategy {
    auto_close = "604800s"
  }

display_name = "Sui Node (${var.machine_name}) - Available Disk Space low"


  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }

      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "resource.type = \"gce_instance\" AND resource.labels.project_id = \"${var.project}\" AND metric.type = \"agent.googleapis.com/disk/bytes_used\" AND metric.labels.state = \"used\" AND metadata.system_labels.name = \"${var.machine_name}\""
      threshold_value = var.disk_threshold

      trigger {
        count = 1
      }
    }

    display_name = "Sui Node - Disk space"
  }

  documentation {
    content   = "Please check on the Sui Node as disk space is running low."
    mime_type = "text/markdown"
  }

  enabled               = true
  notification_channels = [google_monitoring_notification_channel.email_alerts.id]
}

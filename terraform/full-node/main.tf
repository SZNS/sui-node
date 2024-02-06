terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

locals {
  ops_agent_config_content    = file("${path.module}/configs/ops_agent_config.yaml")
  full_node_config_content    = file("${path.module}/configs/sui_full_node_config.yaml")
  node_service_config_content = file("${path.module}/configs/sui_node_service.service")
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
  name     = "${var.name}-snapshot-policy"
  region   = var.region

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
  provider          = google-beta
  name              = "${var.name}-disk"
  zone              = var.zone
  image             = "ubuntu-os-cloud/ubuntu-2204-lts"
  size              = var.disk_size
  type              = "pd-ssd"
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
    user-data = data.cloudinit_config.cloud_init.rendered
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/configs/cloud-config.yaml")
  }

  # Setup Sui Full Node
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
                    #!/bin/sh
                    mkdir -p /opt/sui/bin
                    mkdir -p /opt/sui/config
                    mkdir -p /opt/sui/db
                    mkdir -p /opt/sui/key-pairs
                    chown -R sui:sui /opt/sui
                    curl -fsSL https://get.docker.com | sh
                    usermod -aG docker sui
                    curl https://sh.rustup.rs -sSf | sh -s --y
                    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /home/sui/.bashrc
                    wget -P /opt/sui/config https://github.com/MystenLabs/sui-genesis/raw/main/mainnet/genesis.blob
                    wget -O /opt/sui/config/fullnode.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
                    wget -P /opt/sui/bin/ https://releases.sui.io/${var.sui_release_commit_sha}/sui-node
                    chown -R sui:sui /opt/sui
                    chmod 544 /opt/sui/bin/sui-node
                    echo 'Configuring Sui Full Node...'
                    echo '${local.full_node_config_content}' | sudo tee /opt/sui/config/fullnode.yaml
                    echo '${local.node_service_config_content}' | sudo tee /etc/systemd/system/sui-node.service
                    echo 'Configuring Sui Full Node complete...'
                    EOF
  }

  # Install and Configure Ops Agent for Sui Metrics
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
                    #!/bin/sh
                    echo 'Installing Google Cloud Ops Agent...'
                    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
                    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
                    echo '${local.ops_agent_config_content}' | sudo tee /etc/google-cloud-ops-agent/config.yaml
                    sudo service google-cloud-ops-agent restart
                    echo "Ops Agent installation complete..."
                    EOF
  }

  # Run Sui Full Node Service
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
                    #!/bin/sh
                    echo 'Running Sui Full Node Service'
                    sudo systemctl daemon-reload
                    sudo systemctl enable sui-node
                    sudo systemctl start sui-node
                    EOF
  }
}

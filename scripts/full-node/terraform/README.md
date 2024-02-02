# Sui Full Node Terraform & Cloud-init Configuration

This repository contains a Terraform script and a Cloud-init configuration for setting up a Google Compute Engine instance as a [Sui Full Node](https://docs.sui.io/guides/operator/sui-full-node). It's designed to automate the infrastructure setup and teardown process.

## Configuration Overview

The Terraform script configures the following:

- **Instance Name**: `sui-full-node`
- **Region and Zone**: `us-east4`, `us-east4-c`
- **Machine Type**: `c3-highmem-22` (22 vCPU + 176 GB RAM)
- **Boot Disk**:
  - **OS**: Ubuntu 22.04 LTS (x86/64)
  - **Type**: SSD persistent disk, 6TB NVMe
  - **Encryption**: Default Google-managed encryption key
  - **Deletion Rule**: Keep boot disk
- **Snapshot Backup Policy**:
  - **Frequency:** Daily at 4:00 AM
  - **Max Retention Days:** 2 Days
- **Access Scopes**:
  - Compute Engine: Read Only
  - Service Control: Enabled
  - Service Management: Read Only
  - Stackdriver APIs: Various access levels
  - Storage: Read Write
- **Ops Agent**: Ops Agent, Monitoring, and Logging installed

The Cloud-init script provisions the `sui` user, installs necessary software packages, and prepares the environment for running a Sui Full Node.

## Detailed Configuration

The repository includes detailed configurations for:

- User and group setup
- Software package installation
- Rust and Docker installation
- Sui Full Node specific configurations, including genesis file and node template

Refer to the Cloud-init script for detailed commands and configurations.

## GCP Prerequisites

NOTE: If you already have a GCP account setup, skip to Getting Started. If you do not have a GCP account, then follow the below section to create and configure your GCP account.

1. Create a GCP account: https://cloud.google.com/
2. Install Google Cloud CLI: https://cloud.google.com/sdk/docs/install-sdk
3. After you have installed the gcloud CLI, log into GCP using gcloud:

```
gcloud auth login --update-adc
```

4. Create a GCP project - [Follow these instructions to setup a new project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project).
5. Enable billing and upgrade your account to have full access to all features of GCP. [Follow these steps](https://cloud.google.com/free/docs/gcp-free-tier#how-to-upgrade).
6. Enable the following APIs in your project:
```
Compute Engine API: Allows you to create and manage Compute Engine resources.
Cloud Logging API: Needed for log data collection and management.
Cloud Monitoring API: Required for gathering and viewing metrics.
```

## Getting Started

To use this repository:

1. **Install Terraform**: Follow the instructions [here](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli#install-terraform).
2. **Initialize Terraform**: Run `terraform init` in the repository directory.
3. **Configure Variables**: Create a `terraform.tfvars` file for local variables, setting your `project` and `service_account_email` (optional).

If `service_account_email` is not provided, the default service account will be used.

   Example `terraform.tfvars`:

   ```
   project = "your-gcp-project-id"
   service_account_email = "your-service-account-email@example.com"
   ```

4. **Deploy**: Execute `terraform apply` to create the resources in GCP.
5. **Teardown**: Use `terraform destroy` to remove the infrastructure when needed.

# Terraform

Users can also use Terraform to provision the Sui Full Node in their GCP environment. Below document provides highlevel overview of the Terraform configuration. More instructions on how to run, refer to these [Docs](../terraform/README.md)


**Order of Resource Creation:**

When `terraform apply` is executed, resources are created in the following order:

1. Snapshot Schedule Policy
    1. Initializes a snapshot schedule policy to backup the persistent disk
        1. Backups created daily at 4 AM
        2. Retained for 2 days
        
        ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a43eda3-718b-4a0c-bb46-015b10c65c2d/53ac6743-379a-4fa2-bbf0-ba28ccf56c5f/Untitled.png)
        
2. Compute Disk
    1. Creates persistent SDD disk
        1. US East Region & Zone (us-east4-c)
        2. Ubuntu 22.04 OS Image
        3. 6 TB NVMe
    2. Attaches previously created snapshot policy to disk
3. Compute Instance
    1. Creates compute engine instance
        1. c3-highmem-22 Machine Type *(22 vCPU + 176 GB RAM)*
        2. Configures service account (if provided, otherwise uses default) with access scopes for GCP services
        3. Applies metadata (user-data script) and network interface settings
            1. Executes a cloud-init script to install GCP Logging & Monitoring via Ops Agent and configure Sui full node
                
                ![Screenshot 2024-02-02 at 1.14.34 PM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a43eda3-718b-4a0c-bb46-015b10c65c2d/063e60c4-4d7b-41e7-9e68-9cc8ff6352eb/Screenshot_2024-02-02_at_1.14.34_PM.png)
                

The resources will be **destroyed** in the reverse order when `terraform destroy` is executed (i.e. compute instance → compute disk → snapshot policy).

**User Guidance:** 

1. Ensure Terraform is installed (https://developer.hashicorp.com/terraform/install)
2. Authenticate with Google Cloud (through `gcloud` CLI or a service account key)
3. Supply proper environment variables for `project`, `region`, `zone`, `name`, `disk_size`, `machine_type`, `cloud_init_script_path`
    1. Most of these already have default values set in `variables.tf`, but can be overwritten either in a `terraform.tfvars` file or passed at runtime (e.g. variables without a default will be prompted for at runtime). 
4. Run commands
    
    ```yaml
    terraform init # To initialize Terraform environment where script is
    terraform plan # To plan and review changes
    terraform apply # To create all infrastructure
    terraform destroy # To destroy all infrastructure
    ```
    

**Considerations:**

- Snapshot Policy Configuration
    - Scheduled daily at 4 AM to avoid backups within the timeframe of 23:00 to 3:00
- Uses `google-beta` Provider
    - Essential for features not available in the standard Terraform Google provider, namely setting the snapshot policy on the persistent disk (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk#resource_policies)
- Uses `cloud-init` for boot initialization of VM instance
    - Supports the complex initialization process required with setting up Sui full node and Ops Agent monitoring/logging
        - Package installation
        - User setup
        - Writing files to directory
    - Provides detailed logging and debugging capabilities during initialization
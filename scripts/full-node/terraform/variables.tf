variable "project" { }

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-c"
}

variable "name" {
  default = "sui-full-node"
}

variable "disk_size" {
    default = 6144 # 6TB NVMe
}

variable "machine_type" {
    default = "c3-highmem-22" # (22 vCPU + 176 GB RAM)
}

variable "service_account_email" {
  default = ""
}

variable "cloud_init_script_path" {
    default = "cloud-init.yaml"
}

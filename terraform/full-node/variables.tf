variable "project" {}

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

variable "sui_release_commit_sha" {
  description = "Latest Commit SHA for the Sui Node"
  default     = "09db80adf1af7f60464ffc04b09b8fafc02917c5"
}

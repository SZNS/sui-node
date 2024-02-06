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
  default     = "115117180263c8bc25190ce76b6cbe2114551f7c"
}

variable "project" {}

variable "region" {}

variable "zone" {}

variable "notification_channel_email" {}

variable "machine_name" {}

# As a percentage (eg: 0.85 = 85%)
variable "cpu_threshold" {
  default = 0.85
}

# As a percentage (eg: 85 = 85%)
variable "mem_threshold" {
  default = 85
}

# In bytes
variable "disk_threshold" {
  default = 6000000000000
}

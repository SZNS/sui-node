variable "project" { }

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-c"
}

variable "notification_channel_email" {}

variable "machine_name" { }

# As a percentage (eg: 85 = 85%)
variable "cpu_threshold" {
  default = 85
}

# As a percentage (eg: 85 = 85%)
variable "mem_threshold" {
  default = 85
}

# In bytes
variable "disk_threshold" {
  default = 6000000000000
}

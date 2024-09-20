variable "iso_path" {
  description = "Path to the Kairos ISO"
  type        = string
  nullable = false
}

variable "firmware" {
  description = "Firmware file for EFI boot"
  type        = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
  nullable = false
}

variable "nvram_template" {
  description = "NVRAM file for EFI boot"
  type        = string
  default = "/usr/share/OVMF/OVMF_VARS.fd"
  nullable = false
}

variable "instance_count" {
  description = "Number of worker instances to deploy"
  type        = number
  default     = 2
}
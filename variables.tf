variable "flatcar_base_image" {
  description = "Path to the base VM image for Flatcar Container Linux"
  type        = string
}

variable "rocky_base_image" {
  description = "Path to the base VM image for Rocky Linux VMs"
  type        = string
}

variable "base_image" {
  description = "Generic base VM image path, if needed"
  type        = string
  default     = ""
}

variable "vm_definitions" {
  description = "Definitions of virtual machines including CPU, memory configuration, and OS type"
  type = map(object({
    cpus   = number
    memory = number
    ip     = string
    type   = string # Type can be 'flatcar' or 'rocky'
  }))
}

variable "ssh_keys" {
  description = "List of SSH keys to inject into VMs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "cluster_domain" {
  description = "Domain name of the cluster"
  type        = string
}

variable "rocky_iso_path" {
  description = "Path to the Rocky Linux ISO image"
  type        = string
}

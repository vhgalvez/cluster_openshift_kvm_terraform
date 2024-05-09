variable "flatcar_base_image" {
  description = "Path to the base VM image for Flatcar Container Linux"
  type        = string
}

variable "rocky_base_image" {
  description = "Path to the base VM image for Rocky Linux VMs"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "cluster_domain" {
  description = "Domain name of the cluster"
  type        = string
}

variable "vm_definitions" {
  description = "Definitions of virtual machines including CPU, memory configuration, and IP for Flatcar"
  type = map(object({
    cpus   = number
    memory = number
    ip     = string
    type   = string
  }))
}

variable "vm_rockylinux_definitions" {
  description = "Definitions of virtual machines including CPU, memory configuration, and IP for Rocky Linux"
  type = map(object({
    cpus   = number
    memory = number
    ip     = string
  }))
}

variable "ssh_keys" {
  description = "List of SSH keys to inject into VMs"
  type        = list(string)
}

# variables.tf
variable "base_image" {
  description = "Path to the base VM image"
  type        = string
}

variable "vm_definitions" {
  description = "Definitions of virtual machines including CPU and memory configuration"
  type = map(object({
    type   = string
    cpus   = number
    memory = number
    ip     = string

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
# Definiciones adicionales de máquinas virtuales para Rocky Linux
variable "rocky_vm_definitions" {
  description = "Definitions of virtual machines for Rocky Linux including CPU and memory configuration"
  type = map(object({
    cpus   = number
    memory = number
    ip     = string
  }))
}

variable "flatcar_base_image" {
  description = "Path to the base VM image for Flatcar Container Linux"
  type        = string
}

variable "rocky_base_image" {
  description = "Path to the base VM image for Rocky Linux VMs"
  type        = string
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.10.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "kube_network" {
  name      = "kube_network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}

resource "libvirt_pool" "volumetmp" {
  name = var.cluster_name
  type = "dir"
  path = "/var/lib/libvirt/images/${var.cluster_name}"
}

resource "libvirt_volume" "base_flatcar" {
  name   = "${var.cluster_name}-flatcar-base"
  source = var.flatcar_base_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "base_rocky" {
  name   = "${var.cluster_name}-rocky-base"
  source = var.rocky_base_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

# Template para Flatcar
data "template_file" "flatcar_vm-configs" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "flatcar" }

  template = file("${path.module}/configs/flatcar-${each.key}-config.yaml.tmpl")
  vars = {
    ssh_keys     = jsonencode(var.ssh_keys),
    name         = each.key,
    host_name    = "${each.key}.${var.cluster_name}.${var.cluster_domain}",
    strict       = true,
    pretty_print = true
  }
}

# Template para Rocky Linux
data "template_file" "rocky_vm-configs" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "rocky" }

  template = file("${path.module}/configs/rocky-${each.key}-config.yaml.tmpl")
  vars = {
    ssh_keys     = jsonencode(var.ssh_keys),
    name         = each.key,
    host_name    = "${each.key}.${var.cluster_name}.${var.cluster_domain}",
    strict       = true,
    pretty_print = true
  }
}

# Ignition para Flatcar
data "ct_config" "flatcar_vm-ignitions" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "flatcar" }

  content = data.template_file.flatcar_vm-configs[each.key].rendered
}

resource "libvirt_ignition" "flatcar_ignition" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "flatcar" }

  name    = "${each.key}-ignition"
  pool    = libvirt_pool.volumetmp.name
  content = data.ct_config.flatcar_vm-ignitions[each.key].rendered
}

# Cloud-init ISO para Rocky
resource "libvirt_cloudinit_disk" "rocky_cloudinit" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "rocky" }

  name    = "${each.key}-cloudinit.iso"
  pool    = libvirt_pool.volumetmp.name
  user_data = data.template_file.rocky_vm-configs[each.key].rendered
}

# VMs Flatcar
resource "libvirt_domain" "flatcar_vm" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "flatcar" }

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.base_flatcar.id
  }

  coreos_ignition = libvirt_ignition.flatcar_ignition[each.key].id

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

# VMs Rocky
resource "libvirt_domain" "rocky_vm" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "rocky" }

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.base_rocky.id
  }

  disk {
    volume_id = libvirt_cloudinit_disk.rocky_cloudinit[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

output "ip_addresses_flatcar" {
  value = { for key, vm in libvirt_domain.flatcar_vm : key => vm.network_interface[0].addresses[0] }
}

output "ip_addresses_rocky" {
  value = { for key, vm in libvirt_domain.rocky_vm : key => vm.network_interface[0].addresses[0] }
}



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


# terraform.tfvars
base_image = "/var/lib/libvirt/images/flatcar_image/flatcar_image/flatcar_production_qemu_image.img"
rocky_iso_path   = "/var/lib/libvirt/images/roky_linux_mininal_isos/Rocky-9.3-x86_64-minimal.iso"

vm_definitions = {

  "master1"    =  { cpus = 2, memory = 2048, ip = "10.17.3.11" type = "flatcar"},
  "master2"    =  { cpus = 2, memory = 2048, ip = "10.17.3.12" type = "flatcar" },
  "master3"    =  { cpus = 2, memory = 2048, ip = "10.17.3.13" type = "flatcar" },
  "worker1"    =  { cpus = 2, memory = 2048, ip = "10.17.3.14" type = "flatcar" },
  "worker2"    =  { cpus = 2, memory = 2048, ip = "10.17.3.15" type = "flatcar" },
  "worker3"    =  { cpus = 2, memory = 2048, ip = "10.17.3.16" type = "flatcar" },
  "bootstrap1" =  { cpus = 2, memory = 2048, ip = "10.17.3.17" type = "flatcar" },
  "bastion"      = { cpus = 2, memory = 2048, ip = "10.17.3.21" type = "rocky" },
  "freeipa"      = { cpus = 2, memory = 2048, ip = "10.17.3.17" type = "flatcar" },
  "loadbalancer" = { cpus = 2, memory = 2048, ip = "10.17.3.18" type = "flatcar" },
  "postgres"     = { cpus = 2, memory = 2048, ip = "10.17.3.20" type = "flatcar" },

ssh_keys       = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"]
cluster_name   = "cluster_cefaslocalserver"
cluster_domain = "cefaslocalserver.com"

configuracion esta bien funcina bien.
## usa flatcar container linux
configs\machine-bastion-1-config.yaml.tmpl
---
passwd:
  users:
    - name: core
      ssh_authorized_keys: ${ssh_keys}

storage:
  files:
    - path: /etc/hostname
      filesystem: "root"
      mode: 0644
      contents:
        inline: ${host_name}
    - path: /home/core/works
      filesystem: root
      mode: 0755
      contents:
        inline: |
          #!/bin/bash
          set -euo pipefail
          echo My name is ${name} and the hostname is ${host_name}



## usa rocky linux minimal

configs\machine-load_balancer-1-config.yaml.tmpl

---
passwd:
  users:
    - name: core
      ssh_authorized_keys: ${ssh_keys}

storage:
  files:
    - path: /etc/hostname
      filesystem: "root"
      mode: 0644
      contents:
        inline: ${host_name}
    - path: /home/core/works
      filesystem: root
      mode: 0755
      contents:
        inline: |
          #!/bin/bash
          set -euo pipefail
          echo My name is ${name} and the hostname is ${host_name}



main.tf que funcina bien con flatcar pero tiene rocky linux minimal, usalo de referencia
terraform {
  required_version = ">= 0.13"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.10.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "kube_network" {
  name      = "kube_network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}

resource "libvirt_pool" "volumetmp" {
  name = var.cluster_name
  type = "dir"
  path = "/var/lib/libvirt/images/${var.cluster_name}"
}

resource "libvirt_volume" "base" {
  name   = "${var.cluster_name}-base"
  source = var.base_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

data "template_file" "vm-configs" {
  for_each = var.vm_definitions

  template = file("${path.module}/configs/machine-${each.key}-config.yaml.tmpl")

  vars = {
    ssh_keys     = jsonencode(var.ssh_keys),
    name         = each.key,
    host_name    = "${each.key}.${var.cluster_name}.${var.cluster_domain}",
    strict       = true,
    pretty_print = true
  }
}

data "ct_config" "vm-ignitions" {
  for_each = var.vm_definitions

  content = data.template_file.vm-configs[each.key].rendered
}

resource "libvirt_ignition" "ignition" {
  for_each = var.vm_definitions

  name    = "${each.key}-ignition"
  pool    = libvirt_pool.volumetmp.name
  content = data.ct_config.vm-ignitions[each.key].rendered
}

resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_definitions

  name           = "${each.key}-${var.cluster_name}.qcow2"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_domain" "machine" {
  for_each = var.vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip] # Correctly refer to the IP
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  coreos_ignition = libvirt_ignition.ignition[each.key].id

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

output "ip_addresses" {
  value = { for key, machine in libvirt_domain.machine : key => machine.network_interface[0].addresses[0] if length(machine.network_interface[0].addresses) > 0 }
}



[root@server .ssh]# tree
.
├── clusterkey
│   ├── id_rsa_clusterkey
│   └── id_rsa_clusterkey.pub
├── id_rsa
├── id_rsa_mv_instancia_flatcar
├── id_rsa.pub
├── known_hosts
└── known_hosts.old

1 directory, 7 files
[root@server .ssh]# pwd
/home/victory/.ssh
[root@server .ssh]#

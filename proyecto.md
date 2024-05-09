flatcar-container-linux  funcina bien , pero rocky linux minimal no funcina bien

# main.tf 
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
  for_each = { for vm, definition in merge(var.vm_definitions, var.rocky_vm_definitions) : vm => definition }

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
    addresses      = [each.value.ip]
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

resource "libvirt_domain" "rocky_vm" {
  for_each = var.rocky_vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}


output "ip_addresses" {
  value = { for key, machine in libvirt_domain.machine : key => machine.network_interface[0].addresses[0] if length(machine.network_interface[0].addresses) > 0 }
}

output "rocky_ip_addresses" {
  value = { for key, machine in libvirt_domain.rocky_vm : key => machine.network_interface[0].addresses[0] if length(machine.network_interface[0].addresses) > 0 }
}

# variables.tf
variable "base_image" {
  description = "Path to the base VM image"
  type        = string
}

variable "vm_definitions" {
  description = "Definitions of virtual machines including CPU and memory configuration"
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

# Ruta a la imagen ISO de Rocky Linux
variable "rocky_iso_path" {
  description = "Path to the Rocky Linux ISO image"
  type        = string
}

# Ruta al archivo base para las VMs con Rocky Linux
variable "rocky_base_image" {
  description = "Path to the base VM image for Rocky Linux VMs"
  type        = string
}



# terraform.tfvars
base_image       = "/var/lib/libvirt/images/flatcar_image/flatcar_image/flatcar_production_qemu_image.img"
rocky_base_image = "/var/lib/libvirt/images/rocky_linux_base.qcow2"
rocky_iso_path   = "/var/lib/libvirt/images/roky_linux_mininal_isos/Rocky-9.3-x86_64-minimal.iso"
vm_definitions = {
  "master1"   = { cpus = 2, memory = 2048, ip = "10.17.3.11" },
  "master2"   = { cpus = 2, memory = 2048, ip = "10.17.3.12" },
  "master3"   = { cpus = 2, memory = 2048, ip = "10.17.3.13" },
  "worker1"   = { cpus = 2, memory = 2048, ip = "10.17.3.14" },
  "worker2"   = { cpus = 2, memory = 2048, ip = "10.17.3.15" },
  "worker3"   = { cpus = 2, memory = 2048, ip = "10.17.3.16" },
  "bootstrap1" = { cpus = 2, memory = 2048, ip = "10.17.3.17" },
}
rocky_vm_definitions = {
  "bastion"      = { cpus = 2, memory = 2048, ip = "10.17.3.21" },
  "freeipa"      = { cpus = 2, memory = 2048, ip = "10.17.3.17" },
  "loadbalancer" = { cpus = 2, memory = 2048, ip = "10.17.3.18" },
  "postgres"     = { cpus = 2, memory = 2048, ip = "10.17.3.20" },
}
ssh_keys       = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"]
cluster_name   = "cluster_cefaslocalserver"
cluster_domain = "cefaslocalserver.com"



configucion esta bien funcina bien.
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

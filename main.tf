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

data "libvirt_volume" "base_flatcar" {
  name   = "flatcar_production_qemu_image.img"
  pool   = "default"
}

data "libvirt_volume" "base_rocky" {
  name   = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  pool   = "default"
}

resource "libvirt_volume" "vm_flatcar" {
  for_each       = { for k, v in var.vm_definitions if v.type == "flatcar" : k => v }
  name           = "${var.cluster_name}-flatcar-${each.key}"
  base_volume_id = data.libvirt_volume.base_flatcar.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_volume" "vm_rocky" {
  for_each       = { for k, v in var.vm_definitions if v.type == "rocky" : k => v }
  name           = "${var.cluster_name}-rocky-${each.key}"
  base_volume_id = data.libvirt_volume.base_rocky.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_domain" "vm" {
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
    volume_id = each.value.type == "flatcar" ? libvirt_volume.vm_flatcar[each.key].id : libvirt_volume.vm_rocky[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

output "ip_addresses_flatcar" {
  value = { for key, vm in libvirt_domain.vm : key => vm.network_interface[0].addresses[0] if var.vm_definitions[key].type == "flatcar" }
}

output "ip_addresses_rocky" {
  value = { for key, vm in libvirt_domain.vm : key => vm.network_interface[0].addresses[0] if var.vm_definitions[key].type == "rocky" }
}
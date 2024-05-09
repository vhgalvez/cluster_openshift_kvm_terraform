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

resource "libvirt_cloudinit_disk" "rocky_cloudinit" {
  for_each = { for vm, def in var.vm_definitions : vm => def if def.type == "rocky" }

  name    = "${each.key}-cloudinit.iso"
  pool    = libvirt_pool.volumetmp.name
  user_data = data.template_file.rocky_vm-configs[each.key].rendered
}

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

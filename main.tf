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

data "template_file" "vm-configs" {
  for_each = var.vm_definitions

  template = file("${path.module}/configs/machine-${each.key}-config.yaml.tmpl")

  vars = {
    ssh_keys  = jsonencode(var.ssh_keys),
    name      = each.key,
    host_name = "${each.key}.${var.cluster_name}.${var.cluster_domain}",
  }
}

data "ct_config" "vm-ignitions" {
  for_each = var.vm_definitions

  content = data.template_file.vm-configs[each.key].rendered
}

resource "libvirt_ignition" "vm_ignition" {
  for_each = var.vm_definitions

  name    = "${each.key}-ignition"
  pool    = libvirt_pool.volumetmp.name
  content = data.ct_config.vm-ignitions[each.key].rendered
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
    volume_id = each.value.type == "flatcar" ? libvirt_volume.base_flatcar.id : libvirt_volume.base_rocky.id
  }

  coreos_ignition = libvirt_ignition.vm_ignition[each.key].id

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

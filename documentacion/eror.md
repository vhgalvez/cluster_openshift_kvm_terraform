Error: couldn't retrieve IP address of domain id: 704b2aba-3488-47fa-aef2-e3e1d2992fa5. Please check following:
│ 1) is the domain running proplerly?
│ 2) has the network interface an IP address?
│ 3) Networking issues on your libvirt setup?
│  4) is DHCP enabled on this Domain's network?
│ 5) if you use bridge network, the domain should have the pkg qemu-agent installed
│ IMPORTANT: This error is not a terraform libvirt-provider error, but an error caused by your KVM/libvirt infrastructure configuration/setup
│  timeout while waiting for state to become 'all-addresses-obtained' (last state: 'waiting-addresses', timeout: 5m0s)
│
│   with libvirt_domain.vm_rocky["load_balancer1"],
│   on main.tf line 89, in resource "libvirt_domain" "vm_rocky":
│   89: resource "libvirt_domain" "vm_rocky" {
│
╵
╷
│ Error: couldn't retrieve IP address of domain id: 0fa120be-b626-4f98-93d4-575309ba4a25. Please check following:
│ 1) is the domain running proplerly?
│ 2) has the network interface an IP address?
│ 3) Networking issues on your libvirt setup?
│  4) is DHCP enabled on this Domain's network?
│ 5) if you use bridge network, the domain should have the pkg qemu-agent installed
│ IMPORTANT: This error is not a terraform libvirt-provider error, but an error caused by your KVM/libvirt infrastructure configuration/setup
│  timeout while waiting for state to become 'all-addresses-obtained' (last state: 'waiting-addresses', timeout: 5m0s)
│
│   with libvirt_domain.vm_rocky["bastion1"],
│   on main.tf line 89, in resource "libvirt_domain" "vm_rocky":
│   89: resource "libvirt_domain" "vm_rocky" {
│
╵
╷
│ Error: couldn't retrieve IP address of domain id: 8cc93817-6429-4c15-acdb-9223f573e769. Please check following:
│ 1) is the domain running proplerly?
│ 2) has the network interface an IP address?
│ 3) Networking issues on your libvirt setup?
│  4) is DHCP enabled on this Domain's network?
│ 5) if you use bridge network, the domain should have the pkg qemu-agent installed
│ IMPORTANT: This error is not a terraform libvirt-provider error, but an error caused by your KVM/libvirt infrastructure configuration/setup
│  timeout while waiting for state to become 'all-addresses-obtained' (last state: 'waiting-addresses', timeout: 5m0s)
│
│   with libvirt_domain.vm_rocky["postgresql1"],
│   on main.tf line 89, in resource "libvirt_domain" "vm_rocky":
│   89: resource "libvirt_domain" "vm_rocky" {
│
╵
╷
│ Error: couldn't retrieve IP address of domain id: 243d3ac9-79f3-43ea-ad7b-80dbdaf69c10. Please check following:
│ 1) is the domain running proplerly?
│ 2) has the network interface an IP address?
│ 3) Networking issues on your libvirt setup?
│  4) is DHCP enabled on this Domain's network?
│ 5) if you use bridge network, the domain should have the pkg qemu-agent installed
│ IMPORTANT: This error is not a terraform libvirt-provider error, but an error caused by your KVM/libvirt infrastructure configuration/setup
│  timeout while waiting for state to become 'all-addresses-obtained' (last state: 'waiting-addresses', timeout: 5m0s)
│
│   with libvirt_domain.vm_rocky["freeipa1"],
│   on main.tf line 89, in resource "libvirt_domain" "vm_rocky":
│   89: resource "libvirt_domain" "vm_rocky" {
│
╵
[victory@server cluster_openshift_kvm_terraform]$ cat variables.tf && cat terraform.tfvars &&  cat main.tf && tree -h && sudo ls -l /home/victory/infra_code/kvm_cluster_terraform/configs && pwd && sudo virsh list --all
# variables.tf
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
  }))
}

variable "vm_rockylinux_definitions" {
  description = "Definitions of Rocky Linux virtual machines including CPU, memory configuration, and IP"
  type = map(object({
    cpus   = number
    memory = number
    ip     = string
  }))
}

variable "ssh_keys" {
  description = "List of SSH keys to inject into VMs"
  type        = list(string)
}# terraform.tfvars
flatcar_base_image = "/var/lib/libvirt/images/flatcar_image/flatcar_image/flatcar_production_qemu_image.img"
rocky_base_image   = "/var/lib/libvirt/images/rocky_image/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
cluster_name       = "cluster_cefaslocalserver"
cluster_domain     = "cefaslocalserver.com"

vm_definitions = {
  "master1"        = { cpus = 2, memory = 2048, ip = "10.17.3.11"},
  "master2"        = { cpus = 2, memory = 2048, ip = "10.17.3.12"},
  "master3"        = { cpus = 2, memory = 2048, ip = "10.17.3.13"},
  "worker1"        = { cpus = 2, memory = 2048, ip = "10.17.3.14"},
  "worker2"        = { cpus = 2, memory = 2048, ip = "10.17.3.15"},
  "worker3"        = { cpus = 2, memory = 2048, ip = "10.17.3.16"},
  "bootstrap1"     = { cpus = 2, memory = 2048, ip = "10.17.3.17"},
}

vm_rockylinux_definitions = {
  "bastion1"       = { cpus = 2, memory = 2048, ip = "10.17.3.21"},
  "freeipa1"       = { cpus = 2, memory = 2048, ip = "10.17.3.22"},
  "load_balancer1" = { cpus = 2, memory = 2048, ip = "10.17.3.18"},
  "postgresql1"    = { cpus = 2, memory = 2048, ip = "10.17.3.20"},
}


ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]terraform {
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
  name   = "flatcar_production_qemu_image.img"
  pool   = "default"
  source = var.flatcar_base_image
  format = "qcow2"
}

resource "libvirt_volume" "base_rocky" {
  name   = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  pool   = "default"
  source = var.rocky_base_image
  format = "qcow2"
}

resource "libvirt_volume" "vm_flatcar_clone" {
  for_each       = var.vm_definitions
  name           = "${each.key}_flatcar.qcow2"
  base_volume_id = libvirt_volume.base_flatcar.id
  pool           = "default"
  format         = "qcow2"
}

resource "libvirt_volume" "vm_rocky_clone" {
  for_each       = var.vm_rockylinux_definitions
  name           = "${each.key}_rocky.qcow2"
  base_volume_id = libvirt_volume.base_rocky.id
  pool           = "default"
  format         = "qcow2"
}

resource "libvirt_domain" "vm_flatcar" {
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
    volume_id = libvirt_volume.vm_flatcar_clone[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "vm_rocky" {
  for_each = var.vm_rockylinux_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.vm_rocky_clone[each.key].id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

output "ip_addresses_flatcar" {
  value = { for key, vm in libvirt_domain.vm_flatcar : key => vm.network_interface[0].addresses[0] }
}

output "ip_addresses_rocky" {
  value = { for key, vm in libvirt_domain.vm_rocky : key => vm.network_interface[0].addresses[0] }
}
.
├── [ 4.0K]  configs
│   ├── [  428]  machine-bastion-1-config.yaml.tmpl
│   ├── [  428]  machine-bastion1-config.yaml.tmpl
│   ├── [  428]  machine-bootstrap-1-config.yaml.tmpl
│   ├── [  428]  machine-bootstrap1-config.yaml.tmpl
│   ├── [  428]  machine-elasticsearch-1-config.yaml.tmpl
│   ├── [  428]  machine-elasticsearch1-config.yaml.tmpl
│   ├── [  428]  machine-freeipa-1-config.yaml.tmpl
│   ├── [  428]  machine-freeipa1-config.yaml.tmpl
│   ├── [  428]  machine-kibana-1-config.yaml.tmpl
│   ├── [  428]  machine-kibana1-config.yaml.tmpl
│   ├── [  428]  machine-load_balancer-1-config.yaml.tmpl
│   ├── [  428]  machine-load_balancer1-config.yaml.tmpl
│   ├── [  428]  machine-master-1-config.yaml.tmpl
│   ├── [  428]  machine-master1-config.yaml.tmpl
│   ├── [  428]  machine-master-2-config.yaml.tmpl
│   ├── [  428]  machine-master2-config.yaml.tmpl
│   ├── [  428]  machine-master-3-config.yaml.tmpl
│   ├── [  428]  machine-master3-config.yaml.tmpl
│   ├── [  428]  machine-nfs-1-config.yaml.tmpl
│   ├── [  428]  machine-nfs1-config.yaml.tmpl
│   ├── [  428]  machine-postgresql-1-config.yaml.tmpl
│   ├── [  428]  machine-postgresql1-config.yaml.tmpl
│   ├── [  428]  machine-worker-1-config.yaml.tmpl
│   ├── [  428]  machine-worker1-config.yaml.tmpl
│   ├── [  428]  machine-worker-2-config.yaml.tmpl
│   ├── [  428]  machine-worker2-config.yaml.tmpl
│   ├── [  428]  machine-worker-3-config.yaml.tmpl
│   ├── [  428]  machine-worker3-config.yaml.tmpl
│   ├── [  428]  rocky-bastion1-config.yaml.tmpl
│   ├── [  428]  rocky-freeipa1-config.yaml.tmpl
│   ├── [  428]  rocky-load_balancer1-config.yaml.tmpl
│   └── [  428]  rocky-postgresql1-config.yaml.tmpl
├── [   26]  documentacion
│   └── [  815]  D_tecnica.md
├── [  362]  eliminar_vms.sh
├── [ 1.0K]  LICENSE
├── [ 2.6K]  main.tf
├── [  11K]  proyecto.md
├── [ 7.6K]  README.md
├── [  39K]  terraform.tfstate
├── [  182]  terraform.tfstate.backup
├── [ 1.5K]  terraform.tfvars
└── [ 1021]  variables.tf

2 directories, 42 files
[sudo] password for victory:
total 112
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-bastion-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-bastion1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-bootstrap-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-bootstrap1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-elasticsearch-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-elasticsearch1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-freeipa-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-freeipa1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-kibana-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-kibana1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-load_balancer-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-load_balancer1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-master-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-master1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-master-2-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-master2-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-master-3-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-master3-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-nfs-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 may  1 19:16 machine-nfs1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-postgresql-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:52 machine-postgresql1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-worker-1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-worker1-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-worker-2-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-worker2-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 23:36 machine-worker-3-config.yaml.tmpl
-rw-r--r--. 1 root root 428 abr 30 18:51 machine-worker3-config.yaml.tmpl
/home/victory/infra_code/cluster_openshift_kvm_terraform
 Id   Nombre           Estado
-----------------------------------
 1    master1          ejecutando
 2    load_balancer1   ejecutando
 3    master2          ejecutando
 4    postgresql1      ejecutando
 5    freeipa1         ejecutando
 6    bastion1         ejecutando
 7    worker2          ejecutando
 8    worker1          ejecutando
 9    master3          ejecutando
 10   bootstrap1       ejecutando
 11   worker3          ejecutando
corrige el error
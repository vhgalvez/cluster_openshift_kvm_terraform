# terraform.tfvars
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
]
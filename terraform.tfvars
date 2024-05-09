# terraform.tfvars
base_image       = "/var/lib/libvirt/images/flatcar_image/flatcar_production_qemu_image.img"
rocky_base_image = "/var/lib/libvirt/images/rocky_linux_base.qcow2"
rocky_iso_path   = "/var/lib/libvirt/images/Rocky_Linux-8.4-x86_64-minimal.iso"
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

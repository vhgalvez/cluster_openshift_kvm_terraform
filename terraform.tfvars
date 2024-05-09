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
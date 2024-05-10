


https://github.com/ragrahari/elkf-helm-openshift.git
https://vocore.io/

https://github.com/OpenDevin/OpenDevin

sudo chmod -R 755 /var/lib/libvirt/images/roky_linux_mininal_isos/Rocky-9.3-x86_64-minimal.iso


sudo setenforce 0
sudo setenforce 0  # Pone SELinux en modo permisivo


[victory@server cluster_openshift_kvm_terraform]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
[victory@server cluster_openshift_kvm_terraform]$

sudo dnf install arp-scan

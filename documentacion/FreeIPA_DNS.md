# Instalación de FreeIPA

## FreeIPA para Configuración de DNS

Una vez configurado el nombre de host y la resolución DNS, procede con la instalación de FreeIPA:

```bash
sudo yum install -y ipa-server ipa-server-dns
sudo ipa-server-install
```

Sigue las instrucciones en pantalla para completar la configuración de FreeIPA, incluyendo dominio y realm.

## Configuración del Servidor DNS en FreeIPA

1. Establece el nombre de host de FreeIPA:

```bash
    hostnamectl set-hostname ipa.example.com
```

2. Edita el archivo /etc/hosts para agregar la dirección IP y el hostname de tu servidor FreeIPA:

```bash
echo "192.168.120.10 ipa.example.com ipa" | sudo tee -a /etc/hosts
```

3. Configura y verifica el DNS en FreeIPA
Instala y configura el DNS durante la instalación de FreeIPA y verifica utilizando comandos como `dig` o `nslookup`.

Esta documentación técnica detalla los pasos para establecer un servidor de DNS usando Rocky Linux y FreeIPA, proporcionando una base sólida para servicios de red internos.


# Configuración de DNS en CEFAS Local Server

```bash
sudo hostnamectl set-hostname dns.cefaslocalserver.com
```
    
Agrega la dirección IP y el nombre de dominio al archivo `/etc/hosts`:
```bash
echo "10.17.3.17  dns.cefaslocalserver.com ipa" | sudo tee -a /etc/hosts
```

## Detalles Técnicos del Clúster

| Componente       | CPUs | Memoria (MB) | Descripción                |
|------------------|------|--------------|----------------------------|
| Bootstrap Node   | 1    | 1024         | Inicializa el clúster      |
| Master Nodes     | 2    | 2048         | Gestión del clúster        |
| Worker Nodes     | 2    | 2048         | Ejecución de aplicaciones  |
| FreeIPA          | 1    | 1024         | Gestión de identidades     |
| Load Balancer    | 1    | 1024         | Distribución de carga      |
| NFS              | 1    | 1024         | Almacenamiento de archivos |
| PostgreSQL       | 1    | 1024         | Gestión de bases de datos  |
| Bastion Node     | 1    | 1024         | Acceso seguro al clúster   |
| Elasticsearch    | 2    | 2048         | Análisis de logs           |
| Kibana           | 1    | 1024         | Visualización de datos     |

### Especificaciones del Servidor Físico

| Característica   | Especificación                       |
|------------------|--------------------------------------|
| OS               | Rocky Linux 9.3 (Blue Onyx) x86_64   |
| Host             | ProLiant DL380 G7                    |
| Kernel           | 5.14.0-362.24.1.el9_3.0.1.x86_64     |
| Virtualization   | KVM                                  |
| Packages         | 1235 (rpm)                             |
| Shell            | bash 5.1.8                             |
| Resolution       | 1024x768                               |
| Terminal         | /dev/pts/0                             |
| CPU              | Intel Xeon X5650 (24) @ 2.666GHz       |
| GPU              | AMD ATI 01:03.0 ES1000                 |
| Memory           | 1093MiB / 35904MiB                     |
| Disk             | 1.5TB / 3.0TB                          |

### Server Configuration Summary

## Server Specifications

- **OS:** Rocky Linux 9.3 (Blue Onyx)
- **Host:** ProLiant DL380 G7
- **Kernel:** 5.14.0-362.24.1.el9_3.0.1.x86_64
- **CPU:** Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU:** AMD ATI 01:03.0 ES1000
- **Memory:** 1093MiB / 35904MiB
- **Resolution:** 1024x768
- **Shell:** bash 5.1.8
- **Packages:** 1235 (rpm)
- **Terminal:** /dev/pts/0

## Network Interfaces fisicas

| Interface | IP Address     | Netmask         | Broadcast       |
|-----------|----------------|-----------------|-----------------|
| enp3s0f0  | 192.168.0.24   | 255.255.255.0   | 192.168.0.255   |
| enp3s0f1  | 192.168.0.25   | 255.255.255.0   | 192.168.0.255   |
| enp4s0f0  | 192.168.0.20   | 255.255.255.0   | 192.168.0.255   |
| enp4s0f1  | 192.168.0.26   | 255.255.255.0   | 192.168.0.255   |
| lo        | 127.0.0.1      | 255.0.0.0       | N/A             |

## Disk Configuration

- **/dev/sda:** 3.27 TiB
- **/dev/sdb:** 465.71 GiB
- **Logical Volume Management:**
  - **Root:** 100 GiB
  - **Swap:** 17.72 GiB
  - **Home:** 3 TiB

## Disk Partitions

| Device   | Start      | End        | Size       | Type           |
|----------|------------|------------|------------|----------------|
| /dev/sda1| 2048       | 4095       | 2048       | System         |
| /dev/sda2| 4096       | 2101247    | 2 GB       | Linux Filesystem|
| /dev/sda3| 2101248    | 6204170239 | ~2.89 TiB  | Linux Filesystem|

## Memory and Storage

- **Total Memory:** 35GiB
- **Free Memory:** 33GiB
- **Swap:** 17GiB

## Filesystem Usage

| Filesystem        | Size   | Used   | Available | Use% | Mounted on |
|-------------------|--------|--------|-----------|------|------------|
| /dev/mapper/rl-root| 100G   | 7.5G   | 93G       | 8%   | /          |
| /dev/sda2         | 1014M  | 718M   | 297M      | 71%  | /boot      |
| /dev/mapper/rl-home| 3.0T   | 25G    | ~3.0T     | 1%   | /home      |

This configuration provides a detailed view of the system setup, ensuring all elements are concisely documented for effective cluster management.

# Configuración de Máquinas Virtuales en CEFAS Local Server

## Red NAT con IPs Fijas y Nombres de Dominio Asignados

| Máquina          | CPU (cores) | Memoria (MB) | IP          | Dominio                               |
|------------------|-------------|--------------|-------------|---------------------------------------|
| **Bootstrap1**   | 1           | 1024         | 10.17.3.10  | bootstrap.cefaslocalserver.com       |
| **Master1**      | 2           | 2048         | 10.17.3.11  | master1.cefaslocalserver.com         |
| **Master2**      | 2           | 2048         | 10.17.3.12  | master2.cefaslocalserver.com         |
| **Master3**      | 2           | 2048         | 10.17.3.13  | master3.cefaslocalserver.com         |
| **Worker1**      | 2           | 2048         | 10.17.3.14  | worker1.cefaslocalserver.com         |
| **Worker2**      | 2           | 2048         | 10.17.3.15  | worker2.cefaslocalserver.com         |
| **Worker3**      | 2           | 2048         | 10.17.3.16  | worker3.cefaslocalserver.com         |
| **FreeIPA1**     | 1           | 1024         | 10.17.3.17  | dns.cefaslocalserver.com             |
| **Load Balancer1** | 1        | 1024         | 10.17.3.18  | loadbalancer.cefaslocalserver.com    |
| **NFS1**         | 1           | 1024         | 10.17.3.19  | nfs.cefaslocalserver.com             |
| **PostgreSQL1**  | 1           | 1024         | 10.17.3.20  | postgresql.cefaslocalserver.com      |
| **Bastion1**     | 1           | 1024         | 10.17.3.21  | bastion.cefaslocalserver.com         |
| **Elasticsearch1** | 2        | 2048         | 10.17.3.22  | elasticsearch.cefaslocalserver.com   |
| **Kibana1**      | 1           | 1024         | 10.17.3.23  | kibana.cefaslocalserver.com          |

Este documento presenta la configuración técnica de cada máquina virtual establecida bajo el dominio `cefaslocalserver.com`, proporcionando detalles sobre los recursos de hardware asignados y las direcciones IP fijas dentro de una red NAT.

### Configuración de Red Virtualizada con Terraform

```terraform
resource "libvirt_network" "kube_network" {
  name      = "kube_network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}
```

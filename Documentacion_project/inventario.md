# Hardware del Servidor

- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria**: 1093MiB / 35904MiB
- **Almacenamiento**:
  - Disco Duro Principal: 1.5TB
  - Disco Duro Secundario: 3.0TB

## Sistemas Operativos y Virtualización

- **Rocky Linux 9.3 (Blue Onyx)**
- **rocky linux minimal**
- **KVM con Libvirt**: kvm/qemu y libvirt y Virt-Manager
- **Flatcar Container Linux**

### Configuración de Red

- **Open vSwitch**: Gestión de redes virtuales y VLANs
- **VPN con WireGuard**
- **IP Pública**
- **DHCP en KVM**
- **Firewall**
- **Modo NAT y Bridge**
- **VLANs**: 101, 102, 103, 104, 105, 106, 107
- **Switch y Router:** Facilitan la comunicación y conectividad del clúster.

### Máquinas Virtuales y sistemas operativos

- **Bastion Node**: rocky linux minimal
- **Bootstrap Node**: rocky linux minimal
- **Master Nodes**: Flatcar Container Linux
- **Worker Nodes**: Flatcar Container Linux
- **FreeIPA Node**: rocky linux minimal
- **Load Balancer Node**: rocky linux minimal
- **PostgreSQL Node**: rocky linux minimal


### Máquinas Virtuales y Roles

- **Bastion Node**: Punto de acceso seguro, modo de red Bridge, interfaz enp3s0f1
- **Bootstrap Node**: Inicializa el clúster
- **Master Nodes**: Gestión del clúster
- **Worker Nodes**: Ejecución de aplicaciones
- **FreeIPA Node**: DNS y Gestión de identidades
- **Load Balancer Node**: Traefik para balanceo de carga
- **PostgreSQL Node**: Gestión de bases de datos

### Interfaces de Red Identificadas

- **enp3s0f0**: 192.168.0.24
- **enp3s0f1**: 192.168.0.25 (utilizada para Bridge en Bastion Node)
- **enp4s0f0**: 192.168.0.20
- **enp4s0f1**: 192.168.0.26
- **lo (Loopback)**: 127.0.0.1

### Automatización y Orquestación

- **Terraform**: Automatización de infraestructura
- **Ansible**: Configuración y manejo de operaciones

### Microservicios en pods

#### Análisis y Visualización de Datos

- **ELK Stack Elasticsearch**:visualización de métricas del clúster
- **ELK Stack Kibana** Visualización de datos
- **ELK Stack Logstash**: Procesamiento de logs
- **Prometheus**: Herramientas para el monitoreo
- **Grafana**: visualización de métricas del clúster
- **cAdvisor**: Monitorear el rendimiento y uso de recursos por parte de los contenedores.
- **Nagios**: para salud y rendimiento del sistema

#### Microservicios de servicios de Aplicaciones

**Nginx:** Servidor web y proxy inverso para aplicaciones web.
**Apache Kafka:** Plataforma de mensajería utilizada para la comunicación entre microservicios.
**Redis:** Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.



### Seguridad y Protección

**Firewall y Fail2Ban:** Protección contra accesos no autorizados y ataques.
**DNS y FreeIPA:** Gestión centralizada de autenticación y políticas de seguridad.



### Almacenamiento persistente

**Rook y Ceph** Orquestar Ceph en Kubernetes para almacenamiento persistente.

### Especificaciones de Almacenamiento y Memoria

- **Configuración de Disco y Particiones**:
  - **/dev/sda**: 3.27 TiB
  - **/dev/sdb**: 465.71 GiB
- **Particiones**:
  - **/dev/sda1**: Sistema
  - **/dev/sda2**: 2 GB Linux Filesystem
  - **/dev/sda3**: ~2.89 TiB Linux Filesystem
- **Uso de Memoria**:
  - **Total Memory**: 35GiB
  - **Free Memory**: 33GiB
  - **Swap**: 17GiB
- **Uso del Filesystem**:
  - **/dev/mapper/rl-root**: 100G (7.5G usado)
  - **/dev/sda2**: 1014M (718M usado)
  - **/dev/mapper/rl-home**: 3.0T (25G usado)
  
### Configuración de VLANs y Redes Virtuales

- **VLAN 101**: Bootstrap Node 1
- **VLAN 102**: Master Nodes 3
- **VLAN 103**: Worker Nodes 3
- **VLAN 104**: Bastion Node 1
- **VLAN 105**: PostgreSQL Node 1
- **VLAN 106**: Load Balancer Traefik Node 1  
- **VLAN 107**: FreeIPA Node 1


## Red y Conectividad

- **Switch**: TP-Link LS1008G - 8 puertos Gigabit no administrados
- **Router WiFi**: Conexión fibra óptica, 600 Mbps de subida/bajada, IP pública
- **Red**: Configurada con Open vSwitch para manejo avanzado y políticas de red
- **VPN**: WireGuard para acceso seguro ssh administrado por Bastion Node

## Máquinas Virtuales y Roles

- **Total VMs**: 9
- **Roles**:
  - **Bootstrap Node**: 1 CPU, 1024 MB, inicializa clúster
  - **Master Nodes**: 3 x (2 CPUs, 2048 MB), gestionan el clúster
  - **Worker Nodes**: 3 x (2 CPUs, 2048 MB), ejecutan aplicaciones
  - **Bastion Node**: 1 CPU, 1024 MB, seguridad y acceso
  - **Load Balancer**: 1 CPU, 1024 MB, con Traefik

### VLAN 101: Bootstrapping

| Máquina    | CPU (cores) | Memoria (MB) | IP         | Dominio                        | Sistema Operativo       |
| ---------- | ----------- | ------------ | ---------- | ------------------------------ | ----------------------- |
| Bootstrap1 | 1           | 1024         | 10.17.3.10 | bootstrap.cefaslocalserver.com | Flatcar Container Linux |

### VLAN 102: Masters

| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                      | Sistema Operativo       |
| ------- | ----------- | ------------ | ---------- | ---------------------------- | ----------------------- |
| Master1 | 2           | 2048         | 10.17.3.11 | master1.cefaslocalserver.com | Flatcar Container Linux |
| Master2 | 2           | 2048         | 10.17.3.12 | master2.cefaslocalserver.com | Flatcar Container Linux |
| Master3 | 2           | 2048         | 10.17.3.13 | master3.cefaslocalserver.com | Flatcar Container Linux |

### VLAN 103: Workers

| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                      | Sistema Operativo       |
| ------- | ----------- | ------------ | ---------- | ---------------------------- | ----------------------- |
| Worker1 | 2           | 2048         | 10.17.3.14 | worker1.cefaslocalserver.com | Flatcar Container Linux |
| Worker2 | 2           | 2048         | 10.17.3.15 | worker2.cefaslocalserver.com | Flatcar Container Linux |
| Worker3 | 2           | 2048         | 10.17.3.16 | worker3.cefaslocalserver.com | Flatcar Container Linux |

### VLAN 104: Management and Utility

| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                      | Modo de Red | Sistema Operativo       |
| -------- | ----------- | ------------ | ---------- | ---------------------------- | ----------- | ----------------------- |
| Bastion1 | 1           | 1024         | 10.17.3.21 | bastion.cefaslocalserver.com | Bridge      | Rocky Linux 9.3 Minimal |

### VLAN 105: Storage and Databases

| Máquina     | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Sistema Operativo       |
| ----------- | ----------- | ------------ | ---------- | ------------------------------- | ----------------------- |
| PostgreSQL1 | 1           | 1024         | 10.17.3.20 | postgresql.cefaslocalserver.com | Rocky Linux 9.3 Minimal |

### VLAN 106: Load Balancing

| Máquina        | CPU (cores) | Memoria (MB) | IP         | Dominio                           | Sistema Operativo       |
| -------------- | ----------- | ------------ | ---------- | --------------------------------- | ----------------------- |
| Load Balancer1 | 1           | 1024         | 10.17.3.18 | loadbalancer.cefaslocalserver.com | Rocky Linux 9.3 Minimal |

### VLAN 107: Identity Management

| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                  | Sistema Operativo       |
| -------- | ----------- | ------------ | ---------- | ------------------------ | ----------------------- |
| FreeIPA1 | 1           | 1024         | 10.17.3.17 | dns.cefaslocalserver.com | Rocky Linux 9.3 Minimal |
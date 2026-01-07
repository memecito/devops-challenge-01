# 🐾 Spring Petclinic - Kubernetes & Automation Challenge

Este repositorio contiene la arquitectura completa para desplegar el ecosistema de microservicios de Spring Petclinic de forma 100% automatizada. El proyecto utiliza un enfoque de Infraestructura como Código (IaC), permitiendo pasar de una máquina vacía a un clúster de Kubernetes funcional mediante un solo comando.

## 🎯 Objetivo del Proyecto

El propósito de este reto es demostrar la capacidad de orquestar una arquitectura compleja de microservicios resolviendo desafíos reales de DevOps:

Aprovisionamiento Automático: Uso de Vagrant para crear entornos reproducibles.

Configuración Determinista: Aplicación de Playbooks de Ansible para la puesta a punto del nodo.

Ciclo de Vida de Contenedores: Construcción de imágenes JAR, gestión de un Docker Registry privado y pushing automatizado.

Orquestación Cloud-Native: Despliegue en K3s utilizando nombres de servicio nativos para el descubrimiento por DNS.

Observabilidad: Integración de un stack de monitoreo con Prometheus y Grafana.

## 🏗️ Arquitectura del Sistema

La solución despliega un total de 10 pods coordinados:

Infraestructura: Docker Registry local, K3s Control Plane.

Core Spring: Config Server, Discovery Server (Eureka).

Microservicios de Negocio: Customers, Vets, Visits, GenAI.

Gateway: API Gateway (Punto de entrada único en puerto 80).

Monitoreo: Grafana (Visualización), Prometheus (Métricas).

## 🛠️ Tecnologías Utilizadas

Vagrant: Gestión de la máquina virtual (Ubuntu 22.04).

Ansible: Automatización de la instalación de Java 17, Maven, K3s y Docker.

K3s: Distribución ligera de Kubernetes certificada.

Docker: Construcción y alojamiento de imágenes.

Spring Cloud: Gestión de configuración y descubrimiento.

Prometheus & Grafana: Stack de métricas y monitorización.

Bash Scripting: Orquestación del flujo Build -> Push -> Deploy.

## 🚀 Requisitos Previos

Para ejecutar este proyecto, tu máquina local debe tener:

Vagrant (v2.3+)

VirtualBox

Hardware: Mínimo 12GB de RAM total (la VM utiliza 8GB) y 4 núcleos de CPU.

Plugins: vagrant plugin install vagrant-disksize.

## 🏁 Cómo Ejecutar el Proyecto

El despliegue está totalmente automatizado a través del ciclo de vida de Vagrant:

Clonar el repositorio:

git clone [https://github.com/tu-usuario/petclinic-k8s-automation.git](https://github.com/tu-usuario/petclinic-k8s-automation.git)
cd petclinic-k8s-automation


Lanzar la infraestructura:

vagrant up


Este comando realizará todo el trabajo: aprovisionar la VM, instalar dependencias, compilar el código Java, crear las imágenes Docker, subirlas al registro local y desplegar los servicios en Kubernetes.

Verificar el estado (opcional):
Puedes entrar en la máquina para monitorizar el arranque de los pods:

vagrant ssh
watch kubectl get pods


## 📊 Acceso a los Servicios

Una vez que los servicios estén en estado 1/1 Running, abre tu navegador en las siguientes URLs:

Servicio

URL

Credenciales

🐾 Aplicación Web

http://192.168.56.20

-

📈 Grafana

http://192.168.56.20:3000

admin / admin

🔬 Prometheus

http://192.168.56.20:9090

-

📡 Eureka Dashboard

http://192.168.56.20:8761

-

Nota: Debido a la naturaleza de Java/Spring, la aplicación puede tardar hasta 3-5 minutos en estar totalmente disponible tras el arranque inicial.

## 🛡️ Troubleshooting

Si encuentras algún problema (errores de puerto, falta de RAM, o fallos en VirtualBox), consulta nuestra Guía de Solución de Problemas detallada.

Desarrollado por memecito - 2026
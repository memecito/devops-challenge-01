# 🛠️ Guía Maestra de Solución de Problemas: Proyecto Petclinic Automation

Esta guía exhaustiva recopila los errores críticos identificados durante el ciclo de vida del proyecto Petclinic en Kubernetes. Proporciona no solo la solución inmediata, sino también una inmersión técnica en las causas raíz y estrategias preventivas para mantener la estabilidad del clúster.

## 1. Infraestructura y Virtualización (Host)

❌ Error: "No usable default provider" o "Kernel module not loaded"

Síntoma: Al ejecutar vagrant up, el sistema devuelve un error indicando que no se encuentra un proveedor válido o que VirtualBox no es usable.

Causa Raíz: Este problema se debe a la ruptura del puente entre el software de virtualización y el Kernel del sistema host. Ocurre principalmente por:

Secure Boot (UEFI): Una medida de seguridad que impide cargar controladores no firmados digitalmente (como los de VirtualBox).

Actualizaciones del Kernel: Al actualizar Ubuntu, los módulos antiguos de VirtualBox dejan de ser compatibles.

Solución Paso a Paso:

Intentar recompilar los módulos: sudo /sbin/vboxconfig.

Si falla por Secure Boot, seguir el proceso de Enrolamiento MOK: Introducir una contraseña temporal, reiniciar, y en la pantalla azul seleccionar "Enroll MOK" -> "Continue" -> "Yes".

Asegurar cabeceras instaladas: sudo apt install dkms linux-headers-$(uname -r).

Implicación Técnica: Vagrant es una capa de abstracción; si el proveedor subyacente (VirtualBox) no tiene sus módulos cargados en el "Ring 0" del procesador, la virtualización por hardware es imposible.

## 2. Registro de Imágenes y Ciclo de Vida Docker

❌ Error: "server gave HTTP response to HTTPS client"

Síntoma: El comando docker push se interrumpe con un fallo de protocolo al intentar subir imágenes al registro local.

Causa: Por diseño, Docker aplica el principio de "Seguridad por Defecto", asumiendo que cualquier registro remoto debe estar cifrado con TLS (HTTPS). Al usar un registro local 10.0.2.15:5000 sin certificados, el cliente Docker rechaza la conexión.

Solución:

Editar o crear /etc/docker/daemon.json e incluir: { "insecure-registries" : ["10.0.2.15:5000"] }.

Reiniciar el demonio: sudo systemctl restart docker.

Consecuencias: Sin esta configuración, el flujo CI/CD local se rompe, impidiendo que las imágenes actualizadas lleguen al clúster de Kubernetes.

❌ Error: "ErrImageNeverPull" o "ImagePullBackOff"

Síntoma: El Pod aparece en Waiting perpetuo. El comando kubectl describe pod muestra fallos de descarga.

Causa: 1.  Inconsistencia de Red: El archivo registries.yaml de K3s no apunta a la IP correcta de la VM.
2.  Imágenes Inexistentes: El script build.sh falló silenciosamente (frecuente si el JAR estaba corrupto o incompleto).

Estrategia de Diagnóstico: Ejecutar curl -s http://10.0.2.15:5000/v2/_catalog. Si la lista no muestra los 10 microservicios, el problema está en la fase de construcción, no en Kubernetes.

## 3. Red, DNS y Descubrimiento de Servicios

❌ Error: "java.net.UnknownHostException: config-server"

Síntoma: El Pod inicia pero colapsa a los pocos segundos. Los logs (kubectl logs) muestran que la aplicación Spring Boot no puede localizar la URL del Config Server.

Causa: Spring Cloud utiliza nombres de host lógicos (como http://config-server:8888). Si el servicio de Kubernetes se llama spring-petclinic-config-server, el CoreDNS interno del clúster no encontrará la entrada config-server.

Solución de Arquitectura: - Nombres Nativos: Refactorizar el despliegue para usar nombres cortos y directos en los metadatos de Kubernetes (ej. name: config-server).

Esto permite que el Service Discovery de Kubernetes funcione de forma transparente con el de Spring.

Detalle Técnico: Kubernetes inyecta sufijos de búsqueda DNS (ej. .default.svc.cluster.local). Al usar nombres cortos, garantizamos que la resolución sea inmediata y eficiente.

## 4. Gestión Crítica de Recursos y Memoria

❌ Error: "CrashLoopBackOff" con Exit Code 137 (OOMKilled)

Síntoma: Pods que se reinician aleatoriamente. El estado cambia de Running a Error sin lógica aparente.

Causa: Out Of Memory (OOM). Las aplicaciones Java (JVM) son consumidoras intensivas de RAM. Con 8 microservicios Java más Grafana y Prometheus, los 8GB de la VM están al límite. Si el consumo total supera la RAM física disponible, el kernel de Linux activa el OOM Killer y mata el proceso con mayor consumo (usualmente un servicio de Spring).

Estrategias de Mitigación:

Límites en YAML: Definir resources.limits.memory y resources.requests.memory en el template de Kubernetes para evitar que un solo Pod consuma toda la memoria del nodo.

Ajuste de JVM: Pasar variables de entorno como JAVA_OPTS="-Xmx512m -Xms256m" para limitar el heap de Java desde dentro del contenedor.

Despliegue Secuencial: No lanzar todos los YAML a la vez; esperar a que el Config y Discovery Server estén estables antes de lanzar el resto.

## 5. Automatización y Contexto de Ejecución

❌ Error: "k8s-template.yaml: No such file or directory"

Síntoma: Los archivos YAML en k8s-generated/ están vacíos o el script deploy-all.sh termina con errores de lectura.

Causa: Vagrant y Ansible ejecutan comandos desde el directorio raíz del usuario (/home/vagrant). Si el script utiliza rutas relativas, no encontrará los archivos de apoyo si no se encuentra en el subdirectorio correcto.

Solución Profesional: Usar la captura del directorio del script:

cd "$(dirname "$0")" # Cambia el directorio actual a la ubicación física del script


Lección Aprendida: En la automatización de infraestructura, nunca asumas el directorio actual (CWD). Siempre utiliza rutas absolutas o calcula la ruta relativa respecto al script para garantizar la portabilidad entre diferentes entornos de ejecución.

Manual de Troubleshooting Expandido - Proyecto Petclinic 2026. Documentación de Nivel Senior.

## 6. Conflictos de Ingress y Puertos (K3s)
❌ Error: "404 Page Not Found" al acceder por puerto 80

    Síntoma: Connectivity OK (Grafana funciona), pero el acceso a la web principal devuelve 404.

    Causa Raíz: K3s incluye Traefik por defecto como Ingress Controller. Traefik se vincula al puerto 80 de la interfaz de red. Al intentar exponer nuestro api-gateway en el mismo puerto, se produce una colisión. El 404 es la respuesta por defecto de Traefik al no encontrar rutas (Ingress) definidas.

    Solución Técnica: 1. Deshabilitar Traefik mediante el flag --disable traefik en la instalación de K3s. 2. Asegurar que el servicio api-gateway sea de tipo LoadBalancer.

    Explicación: Al desactivar el Ingress por defecto, permitimos que el componente ServiceLB de K3s asigne la IP del nodo directamente a nuestro servicio, convirtiendo al api-gateway en el único receptor de tráfico del puerto 80.

## 7. Verificación de Rutas de Microservicios
❌ Error: La web carga pero no hay datos de mascotas/veterinarios

    Causa: El API Gateway ha levantado pero los servicios internos (Vets, Customers) aún no han terminado de registrarse en Eureka.

    Solución: Los microservicios de Spring Boot tienen un tiempo de "warm-up" de unos 60-90 segundos tras mostrar el estado Running en Kubernetes. Simplemente refresca la página tras un par de minutos.
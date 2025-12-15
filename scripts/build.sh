#!/bin/bash

# Version
DOCKER_VERSION="0.0.1"
MAVEN_VERSION="3.4.1"


# 2 Lista de microservicios  
MICROSERVICIOS=(
  "spring-petclinic-admin-server"
  "spring-petclinic-api-gateway"
  "spring-petclinic-config-server"
  "spring-petclinic-customers-service"
  "spring-petclinic-discovery-server"
  "spring-petclinic-genai-service"
  "spring-petclinic-vets-service"
  "spring-petclinic-visits-service"
)

# Bucle para construir cada imagen

for SERVICE in "${MICROSERVICIOS[@]}"
do
	echo "Construyendo imagen para: $SERVICE"
# Asignación de Puertos
    case $SERVICE in
        "spring-petclinic-config-server") export CONTAINER_PORT=8888 ;;
        "spring-petclinic-discovery-server") export CONTAINER_PORT=8761 ;;
        "spring-petclinic-admin-server") export CONTAINER_PORT=9090 ;;
        *) export CONTAINER_PORT=8080 ;;
    esac
# Entramos en la carpeta
	cd $SERVICE
	JAR_NAME="target/$SERVICE-$MAVEN_VERSION"
# Usamos el dockerfile generico y le vamos pasando el jar con la version del pom
	docker build -f ../docker/Dockerfile --build-arg ARTIFACT_NAME=$JAR_NAME --build-arg EXPOSED_PORT=$CONTAINER_PORT -t $SERVICE:$DOCKER_VERSION .
# Volvemos al directorio superior
	cd ..
  echo "📦 [Docker -> K3s] Importando imagen $IMAGE_NAME..."
  IMAGE_SIZE=$(docker image inspect "$SERVICE:$DOCKER_VERSION" --format='{{.Size}}')
  if command -v pv &> /dev/null; then
    docker save "$SERVICE:$DOCKER_VERSION" | pv -s $IMAGE_SIZE | sudo k3s ctr images import -
  else
    docker save "$SERVICE:$DOCKER_VERSION" | sudo k3s ctr images import -
  fi
   
	echo "Imagen $SERVICE:$DOCKER_VERSION creada."
done

# Creacion de las imagenes de grafana y prometheus
echo "📊 Construyendo imagen para: grafana y prometheus"
echo "Construyendo Grafana.."
docker build -f ./docker/grafana/Dockerfile  --build-arg EXPOSED_PORT=3030 -t grafana-server:$DOCKER_VERSION .

echo " Importando grafana-server:$DOCKER_VERSION a K3s..."
IMAGE_SIZE=$(docker image inspect "grafana-server:$DOCKER_VERSION" --format='{{.Size}}')
if command -v pv &> /dev/null; then
  docker save "grafana-server:$DOCKER_VERSION" | pv -s $IMAGE_SIZE | sudo k3s ctr images import -
else
  docker save "grafana-server:$DOCKER_VERSION" | sudo k3s ctr images import -
fi

echo "Construyendo Prometheus.."
docker build -f ./docker/prometheus/Dockerfile --build-arg EXPOSED_PORT=9090 -t prometheus-server:$DOCKER_VERSION .
IMAGE_SIZE=$(docker image inspect "prometheus-server:$DOCKER_VERSION" --format='{{.Size}}')
echo " Importando prometheus-server:$DOCKER_VERSION a K3s..."
if command -v pv &> /dev/null; then
  docker save "prometheus-server:$DOCKER_VERSION" | pv -s $IMAGE_SIZE | sudo k3s ctr images import -
else
  docker save "prometheus-server:$DOCKER_VERSION" | sudo k3s ctr images import -
fi

echo "🏁 Proceso de construcción de imágenes completado."


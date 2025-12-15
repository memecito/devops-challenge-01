#!/bin/bash

VERSION="0.0.2"

MICROSERVICIOS=(
	"spring-petclinic-admin-server"
	"spring-petclinic-api-gateway"
	"spring-petclinic-config-server"
	"spring-petclinic-customers-service"
	"spring-petclinic-discovery-server"
	"spring-petclinic-genai-service"
	"spring-petclinic-vets-service"
	"spring-petclinic-visits-service"
    "grafana"
    "prometheus"
)
VERSION=3.4.1
mkdir -p k8s-generated

for SERVICE in "${MICROSERVICIOS[@]}"
do
    export SERVICE_NAME=$SERVICE
    export IMAGE_NAME="$SERVICE:$VERSION"
    
    # 1. Asignación de Puertos
    case $SERVICE in
        "spring-petclinic-api-gateway") 
            export CONTAINER_PORT=8080 
            export SERVICE_TYPE="LoadBalancer" 
            export EXTERNAL_PORT=80
            ;;
        "spring-petclinic-config-server") 
            export CONTAINER_PORT=8888 
            export SERVICE_TYPE="ClusterIP"
            export EXTERNAL_PORT=8888
            ;;
        "spring-petclinic-discovery-server") 
            export CONTAINER_PORT=8761 
            export SERVICE_TYPE="ClusterIP"
            export EXTERNAL_PORT=8761
            ;;
        "spring-petclinic-admin-server") 
            export CONTAINER_PORT=9090 
            export SERVICE_TYPE="ClusterIP"
            export EXTERNAL_PORT=9090
            ;;
        "grafana") 
            export CONTAINER_PORT=3000 
            export SERVICE_TYPE="LoadBalancer"
            export EXTERNAL_PORT=3000
            ;;
        "prometheus") 
            export CONTAINER_PORT=9090 
            export SERVICE_TYPE="ClusterIP"
            export EXTERNAL_PORT=""
        ;;
        *) 
            export CONTAINER_PORT=8080 
            export SERVICE_TYPE="ClusterIP"
            export EXTERNAL_PORT=8080
            ;;
    esac

    # 2. EL PUENTE: Pasar imagen de Docker a K3s
    # echo "📦 [Docker -> K3s] Importando imagen $IMAGE_NAME..."
    # Guardamos la imagen de Docker y la importamos en K3s
    # docker save "$IMAGE_NAME" | sudo k3s ctr images import -
    
    echo "⚙️  Generando deployment para: $SERVICE_NAME (Puerto: $CONTAINER_PORT)"
    envsubst < k8s-template.yaml > k8s-generated/$SERVICE.yaml

    echo "🚀 Desplegando en K3s..."
    kubectl apply -f k8s-generated/$SERVICE.yaml

done



echo "✅ Todo desplegado."

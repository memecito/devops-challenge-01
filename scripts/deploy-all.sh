#!/bin/bash

# --- 1. Configuración de Rutas y Prefijos ---
SCRIPT_DIR="/home/vagrant/provisioning_files/scripts"
cd "$SCRIPT_DIR" || exit

PRE="spring-petclinic-" # Prefijo que usamos para buscar imágenes y carpetas
VERSION="0.0.1" 
IP_VM=$(hostname -I | awk '{print $1}')
mkdir -p k8s-generated

# Ahora los nombres son los "reales" que espera Spring Cloud
MICROSERVICIOS=(
    "admin-server"
    "api-gateway"
    "config-server"
    "customers-service"
    "discovery-server"
    "genai-service"
    "vets-service"
    "visits-service"
)

echo "🚀 Desplegando Microservicios con nombres cortos (DNS nativo)..."

# --- 2. Bucle de Despliegue ---
for SERVICE in "${MICROSERVICIOS[@]}"
do
    # El nombre del servicio en K8s será corto (ej: config-server)
    export SERVICE_NAME=$SERVICE 
    
    # La imagen sigue teniendo el nombre largo que creó el build.sh
    export IMAGE_NAME="$IP_VM:5000/${PRE}${SERVICE}:${VERSION}"    
    
    # Configuración de puertos según el nombre corto
    case $SERVICE in
        "api-gateway") 
            export CONTAINER_PORT=8080 && export SERVICE_TYPE="LoadBalancer" && export EXTERNAL_PORT=80 ;;
        "config-server") 
            export CONTAINER_PORT=8888 && export SERVICE_TYPE="ClusterIP" && export EXTERNAL_PORT=8888 ;;
        "discovery-server") 
            export CONTAINER_PORT=8761 && export SERVICE_TYPE="ClusterIP" && export EXTERNAL_PORT=8761 ;;
        "admin-server") 
            export CONTAINER_PORT=9090 && export SERVICE_TYPE="ClusterIP" && export EXTERNAL_PORT=9090 ;;
        *) 
            export CONTAINER_PORT=8080 && export SERVICE_TYPE="ClusterIP" && export EXTERNAL_PORT=8080 ;;
    esac

    echo "⚙️  Generando YAML para: $SERVICE_NAME"
    envsubst < k8s-template.yaml > k8s-generated/$SERVICE.yaml
    
    echo "📦 Aplicando $SERVICE_NAME..."
    kubectl apply -f k8s-generated/$SERVICE.yaml
done

# --- 3. Herramientas Extra (Sin prefijo) ---
for EXTRA in "grafana" "prometheus"
do
    export SERVICE_NAME=$EXTRA
    export IMAGE_NAME="$IP_VM:5000/$EXTRA:$VERSION"
    export CONTAINER_PORT=$([[ $EXTRA == "grafana" ]] && echo "3000" || echo "9090")
    export EXTERNAL_PORT=$CONTAINER_PORT
    export SERVICE_TYPE=$([[ $EXTRA == "grafana" ]] && echo "LoadBalancer" || echo "ClusterIP")

    envsubst < k8s-template.yaml > k8s-generated/$EXTRA.yaml
    kubectl apply -f k8s-generated/$EXTRA.yaml
done

echo "---"
echo "✅ Proceso completado. Los microservicios ahora se ven por sus nombres reales."
pipeline {
    agent any

    environment {
        REGISTRY = "localhost:5000"
        VERSION = "0.0.1"
        NAMESPACE = "devops-tools"
        // Prefijo habitual de las carpetas en el repo de Petclinic
        PRE = "spring-petclinic-"
        APP_PATH = "app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/memecito/petclinic-v3.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Podman Build & Push') {
            steps {
                script {
                    def services = [
                        'config-server',
                        'discovery-server',
                        'customers-service',
                        'vets-service',
                        'visits-service',
                        'api-gateway',
                        'admin-server'
                    ]

                    services.each { service ->
                        def imageName = "${REGISTRY}/${service}:${VERSION}"
                        // Construimos la ruta de la carpeta del microservicio
                        def serviceFolder = "${PRE}${service}"
                        
                        echo "🏗️ Construyendo imagen con Podman: ${imageName} desde ./${serviceFolder}"
                        
                        // Usamos Podman con flag para registro inseguro si es necesario
                        sh "podman build -t ${imageName} -f ./docker/Dockerfile ./${serviceFolder}"
                        
                        echo "🚀 Subiendo a Registro: ${imageName}"
                        sh "podman push ${imageName} --tls-verify=false"
                        
                        sh "podman rmi ${imageName}"
                    }
                }
            }
        }

        stage('Helm Deploy') {
            steps {
                script {
                    def services = [
                        'config-server',
                        'discovery-server',
                        'customers-service',
                        'vets-service',
                        'visits-service',
                        'api-gateway',
                        'admin-server'
                    ]

                    // Definimos el Mapa de puertos (Equivalente al switch case pero más limpio)
                    def servicePorts = [
                        'config-server': 8888,
                        'discovery-server': 8761,
                        'admin-server': 9090
                    ]

                    services.each { service ->
                        // Si el servicio está en el mapa, usa su puerto. Si no, usa 8080.
                        def containerPort = servicePorts[service] ?: 8080
                        
                        echo "🚢 Desplegando con Helm: ${service} en puerto ${containerPort}"
                        
                        sh """
                        helm upgrade --install ${service} ./helm/petclinic-service \\
                            --namespace ${NAMESPACE} \\
                            --set image.repository=${REGISTRY}/${service} \\
                            --set image.tag=${VERSION} \\
                            --set service.port=${containerPort} \\
                            --set service.targetPort=${containerPort} \\
                            --set env.javaOpts="-Xmx384m -Xms256m"
                        """
                    }   
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado."
        }
    }
}
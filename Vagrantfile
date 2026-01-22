Vagrant.configure("2") do |config|

   config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
   config.vm.box = "rockylinux/9"
   config.vm.box_version="5.0.0"

  # Asegurar espacio en disco para las imágenes Docker y JARs
  if Vagrant.has_plugin?("vagrant-disksize")
    config.vm.disk_size = '40GB'
  end

  # IP estática para acceso desde el navegador del host
  config.vm.network "private_network", ip: "192.168.56.20", adapter: 2

  # # Sincronización de carpetas de trabajo
  # config.vm.synced_folder ".", "/home/vagrant/provisioning_files", 
  #   owner: "vagrant", 
  #   group: "vagrant",
  #  # type: "virtualbox",
  #   mount_options: ["dmode=775", "fmode=664"]

  config.vm.provider "virtualbox" do |vb|
    vb.name = "petclinic-k3s-final"
    vb.memory = "6144"
    vb.cpus = 4
    # Optimización para evitar cuellos de botella en la construcción
    vb.customize ["modifyvm", :id, "--vram", "64"]
    vb.customize ["modifyvm", :id, "--audio", "none"]

  end

  # PASO 1: Configuración del Sistema con Ansible
  # Primer provisioner: Instala Ansible y las colecciones necesarias
  config.vm.provision "shell", inline: <<-SHELL
    sudo dnf install -y epel-release
    sudo dnf install -y ansible-core
    # Instalamos las colecciones para que estén listas cuando entre el siguiente provisioner
    ansible-galaxy collection install kubernetes.core containers.podman ansible.posix -p /usr/share/ansible/collections
  SHELL

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "provisioning/playbook.yaml"
    ansible.verbose = "v" # Modo verbose para más detalles en la salida
  end

  # # PASO 2: Construcción de Artefactos e Imágenes
  # config.vm.provision "shell", name: "Build Images", inline: <<-SHELL
  #   echo "🏗️ Construyendo JARs e Imágenes Docker..."
  #   cd /home/vagrant/provisioning_files/scripts
  #   chmod +x build.sh
  #   ./build.sh
  # SHELL

  # # PASO 3: Despliegue en Kubernetes con Lógica de Prefijos
  # config.vm.provision "shell", name: "Kubernetes Deploy", inline: <<-SHELL
  #   echo "🚀 Desplegando en el Clúster K3s..."
  #   cd /home/vagrant/provisioning_files/scripts
  #   chmod +x deploy-all.sh
  #   ./deploy-all.sh
  # SHELL

  # # Mensaje Final de éxito
  # config.vm.provision "shell", inline: <<-SHELL
  #   echo "--------------------------------------------------"
  #   echo "✅ ¡ENTORNO LISTO!"
  #   echo "🐾 App: http://192.168.56.20"
  #   echo "📊 Grafana: http://192.168.56.20:3000 (admin/admin)"
  #   echo "--------------------------------------------------"
  # SHELL
end
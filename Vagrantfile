Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Asegurar espacio en disco para las imágenes Docker y JARs
  if Vagrant.has_plugin?("vagrant-disksize")
    config.disksize.size = '40GB'
  end

  # IP estática para acceso desde el navegador del host
  config.vm.network "private_network", ip: "192.168.56.20"

  # Sincronización de carpetas de trabajo
  config.vm.synced_folder ".", "/home/vagrant/provisioning_files", owner: "vagrant", group: "vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "petclinic-k3s-final"
    vb.memory = "8192"
    vb.cpus = 4
    # Optimización para evitar cuellos de botella en la construcción
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end

  # PASO 1: Configuración del Sistema con Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
  end

  # PASO 2: Construcción de Artefactos e Imágenes
  config.vm.provision "shell", name: "Build Images", inline: <<-SHELL
    echo "🏗️ Construyendo JARs e Imágenes Docker..."
    cd /home/vagrant/provisioning_files/scripts
    chmod +x build.sh
    ./build.sh
  SHELL

  # PASO 3: Despliegue en Kubernetes con Lógica de Prefijos
  config.vm.provision "shell", name: "Kubernetes Deploy", inline: <<-SHELL
    echo "🚀 Desplegando en el Clúster K3s..."
    cd /home/vagrant/provisioning_files/scripts
    chmod +x deploy-all.sh
    ./deploy-all.sh
  SHELL

  # Mensaje Final de éxito
  config.vm.provision "shell", inline: <<-SHELL
    echo "--------------------------------------------------"
    echo "✅ ¡ENTORNO LISTO!"
    echo "🐾 App: http://192.168.56.20"
    echo "📊 Grafana: http://192.168.56.20:3000 (admin/admin)"
    echo "--------------------------------------------------"
  SHELL
end
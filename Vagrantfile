Vagrant.configure("2") do |config|
  # Usamos una imagen de Ubuntu estándar
  config.vm.box = "ubuntu/jammy64" # Ubuntu 22.04 LTS

  # Red Privada: Esta será la IP donde accederás al Front desde tu navegador real
  config.vm.network "private_network", ip: "192.168.56.20"

  # Sincronizamos la carpeta actual (.) con /home/vagrant/app en la VM
  config.vm.synced_folder ".", "/home/vagrant/app", owner: "vagrant", group: "vagrant"

  # Configuración de Hardware (VirtualBox)
  config.vm.provider "virtualbox" do |vb|
    vb.name = "petclinic-k3s"
    vb.memory = "8192"  # 8GB de RAM recomendado (4GB mínimo absoluto)
    vb.cpus = 4         # 2 o 4 CPUs para que compile rápido
  end

  # Provisionamiento con Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.verbose = "v" # Para ver logs si algo falla
  end
end

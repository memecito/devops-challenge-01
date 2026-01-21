# --- CONFIGURACIÓN (Edita estas rutas) ---

$VM_NAME = "Rocky-Jenkins-Server"
$ISO_PATH = "C:\Users\EM2025008061\Downloads\Rocky-9.7-x86_64-minimal.iso" 
$VM_DIR = "$env:USERPROFILE\VirtualBox VMs\$VM_NAME"
$RAM = 4096   
$CPUS = 2     
$DISK_SIZE = 30000 
# -----------------------------------------

# 1. Crear y registrar la VM
VBoxManage.exe createvm --name $VM_NAME --ostype "RedHat_64" --register

# 2. Configurar hardware y red (Port Forwarding)
VBoxManage.exe modifyvm $VM_NAME `
    --cpus $CPUS --memory $RAM --vram 128 `
    --nic1 nat `
    --natpf1 "ssh,tcp,,2222,,22" `
    --natpf1 "jenkins_web,tcp,,8080,,8080" `
    --natpf1 "jenkins_nodeport,tcp,,32195,,32195"

# 3. Crear disco duro virtual
VBoxManage.exe storagectl $VM_NAME --name "SATA" --add sata
VBoxManage.exe createmedium disk --filename "$VM_DIR\$VM_NAME.vdi" --size $DISK_SIZE
VBoxManage.exe storageattach $VM_NAME --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VM_DIR\$VM_NAME.vdi"

# 4. Añadir lectora de CD con la ISO
VBoxManage.exe storagectl $VM_NAME --name "IDE" --add ide
VBoxManage.exe storageattach $VM_NAME --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium $ISO_PATH

Write-Host "¡Listo! La máquina '$VM_NAME' ha sido creada." -ForegroundColor Green
Write-Host "Ya puedes abrir VirtualBox e iniciar la instalación."
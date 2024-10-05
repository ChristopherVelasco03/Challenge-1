
if [ "$#" -lt 8 ]; then
    echo "Uso: $0 <nombre_vm> <tipo_os> <numero_cpus> <memoria_ram_gb> <vram_mb> <tamano_disco_gb> <nombre_controlador_sata> <nombre_controlador_ide>"
    exit 1
fi

NOMBRE_VM=$1
TIPO_OS=$2
NUM_CPUS=$3
MEMORIA_RAM=$(($4 * 1024)) # Convertir GB a MB
VRAM_MB=$5
TAMANO_DISCO_GB=$6
CONTROLADOR_SATA=$7
CONTROLADOR_IDE=$8

VBoxManage createvm --name "$NOMBRE_VM" --ostype "$TIPO_OS" --register
echo "Máquina virtual '$NOMBRE_VM' creada."

VBoxManage modifyvm "$NOMBRE_VM" --cpus "$NUM_CPUS" --memory "$MEMORIA_RAM" --vram "$VRAM_MB"
echo "Configuración de CPUs: $NUM_CPUS, Memoria RAM: $MEMORIA_RAM MB, VRAM: $VRAM_MB MB aplicada."

DISCO_VDI="${NOMBRE_VM}_disk.vdi"
VBoxManage createmedium disk --filename "$DISCO_VDI" --size $(($TAMANO_DISCO_GB * 1024)) # Tamaño en MB
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_SATA" --add sata --controller IntelAHCI
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_SATA" --port 0 --device 0 --type hdd --medium "$DISCO_VDI"
echo "Disco duro virtual de $TAMANO_DISCO_GB GB creado y adjuntado con el controlador SATA '$CONTROLADOR_SATA'."

VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_IDE" --add ide
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_IDE" --port 1 --device 0 --type dvddrive --medium emptydrive
echo "Controlador IDE '$CONTROLADOR_IDE' creado y adjuntado con unidad de CD/DVD vacía."

echo "Configuración final de la máquina virtual '$NOMBRE_VM':"
VBoxManage showvminfo "$NOMBRE_VM"

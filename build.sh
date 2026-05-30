#!/bin/bash
# Dieses Skript führt die gesamte Pipeline aus: Build -> Konvertierung -> QEMU-Start.

# --- Konfiguration ---
IMAGE_NAME="localhost/os-base:latest"
QCOW_PATH="qcow2/disk.qcow2"
BUILDER_IMAGE="quay.io/centos-bootc/bootc-image-builder:latest"

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. PREREQUISITES PRÜFEN
if ! command -v podman &> /dev/null || ! command -v qemu-system-x86_64 &> /dev/null; then
    echo -e "${RED}FEHLER: Podman oder qemu-system-x86_64 fehlt.${NC}"
    exit 1
fi

echo -e "${GREEN}--- Starte Build-Pipeline für $IMAGE_NAME ---${NC}"

# 2. VORBEREITUNG & BEREINIGUNG
echo "-> Bereinige alte Artefakte und generiere Containerfile..."
rm -rf qcow2 *.tar # Entfernt alte QCOW2-Ordner
bluebuild template recipe.yml -o Containerfile

# 3. BUILD PHASE (Das Image als ROOT bauen)
echo "-> Image als Root bauen (Speicherort: /var/lib/containers/storage)..."
# Wir nutzen sudo, um das Image direkt im Root-Speicher abzulegen (effizient).
sudo podman build -t "$IMAGE_NAME" .

if [ $? -ne 0 ]; then
    echo -e "${RED}FEHLER: Podman Build fehlgeschlagen. Prüfen Sie den Root-Login (Schritt 3).${NC}"
    exit 1
fi

# 4. CONVERSION PHASE (QCOW2 erstellen)
echo "-> Konvertiere Image zu $QCOW_PATH (Passwort für sudo erforderlich)..."

# Startet den Builder-Container als Root. Das Image ist bereits im Root-Speicher verfügbar.
sudo podman run \
  --rm \
  --privileged \
  -v .:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  "$BUILDER_IMAGE" \
  --type qcow2 \
  --rootfs btrfs \
  "$IMAGE_NAME"

# Prüfen, ob die Konvertierung erfolgreich war und die QCOW2-Datei existiert
if [ $? -ne 0 ] || [ ! -f "$QCOW_PATH" ]; then
    echo -e "${RED}FEHLER: Konvertierung fehlgeschlagen. QCOW2-Datei wurde nicht erstellt.${NC}"
    exit 1
fi

echo -e "${GREEN}--- Konvertierung erfolgreich. Starte VM... ---${NC}"

# 5. STARTUP PHASE (QEMU starten)
echo "=========================================================="
echo "VM wird gestartet. Login: User: fedora, Passwort: fedora"
echo "=========================================================="

sudo qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 4096 \
  -smp 4 \
  -drive file="$QCOW_PATH",format=qcow2,if=virtio \
  -device virtio-vga \
  -display sdl \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -bios /usr/share/ovmf/OVMF.fd
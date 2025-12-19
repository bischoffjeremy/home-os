
![Logo](files/logo.jpeg)

# 🔥 When committing, the image is automatically built and pushed to the github repo🔥
The existing "free" github runners are used!


# 🚀 Custom Aurora NVIDIA-Image

Custom Fedora Aurora NVIDIA-Open Image mit BlueBuild, sysusers, tmpfiles, Root-Passwort & Schweizer Tastatur.

Basiert auf **Aurora NVIDIA-Open** (Universal Blue) mit KDE Plasma, NVIDIA-Treibern und immutable bootc/OStree-Technologie.

---

## ✅ Voraussetzungen

- Linux mit `podman`
- GitHub Account
- sudo-Rechte

---

## 🔧 Quick Start

### 1. Podman bei GitHub anmelden

```bash
echo "DEIN_GITHUB_TOKEN" | sudo podman login ghcr.io -u DEIN_GITHUB_USERNAME --password-stdin
```

### 2. BlueBuild CLI installieren

```bash
podman run --pull always --rm ghcr.io/blue-build/cli:latest-installer | bash
```

### 3. Image bauen

```bash
touch cosign.pub cosign.key
bluebuild template recipe.yml -o Containerfile
sudo podman build -t os-base:latest .
```

### 4. QCOW2 erzeugen

```bash
sudo podman run --rm --privileged \
  -v .:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  --rootfs btrfs \
  localhost/os-base:latest
```

### 5. In QEMU starten

```bash
sudo qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 4096 \
  -smp 4 \
  -drive file=qcow2/disk.qcow2,if=virtio,format=qcow2 \
  -device virtio-vga \
  -display sdl \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -bios /usr/share/ovmf/OVMF.fd
```

**Login:**
- `root` / `root`
- `fedora` / *(nach erstem Login setzen)*

---

## 🔑 Fedora-Passwort setzen (nach erstem Boot)

Der User `fedora` wird erst beim Boot erstellt. Passwort setzen:

```bash
passwd -d fedora     # entfernt Pflicht für "current password"
passwd fedora        # setzt neues Passwort
```

---

## 🎉 Features

✔ CH-Tastatur (Konsole + X11/Wayland)  
✔ systemd-sysusers User (`fedora`)  
✔ Persistentes `/var/home`  
✔ Systemweite Flatpaks (Brave, VS Code, Obsidian, etc.)  
✔ Root-Login aktiviert  
✔ bootc/Silverblue-konform  

---

## 🛠️ Troubleshooting: Flatpaks installieren nicht automatisch

```bash
# Status prüfen
systemctl status system-flatpak-setup.timer

# Manuell starten
sudo systemctl restart system-flatpak-setup.timer

# Oder via ujust
ujust install-flatpaks

# Installierte Flatpaks anzeigen
flatpak list --system
```

Danach: Abmelden/Neustart.

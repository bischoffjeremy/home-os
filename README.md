# Ailurus OS
---

![Logo](logo/logo.svg)

---

## Installed Tools
| App | Description |
|:---:|:------------|
| <img src="https://icons.duckduckgo.com/ip3/brave.com.ico" width="48"> | **Brave Browser** - Privacy focused browser |
| <img src="https://icons.duckduckgo.com/ip3/code.visualstudio.com.ico" width="48"> | **VS Code** - Code editor |
| <img src="https://icons.duckduckgo.com/ip3/obsidian.md.ico" width="48"> | **Obsidian** - Markdown notes |
| <img src="https://apps.ankiweb.net/logo.svg" width="48"> | **Anki** - Flashcard learning system |
| <img src="https://icons.duckduckgo.com/ip3/xournalpp.github.io.ico" width="48"> | **Xournal++** - PDF annotation |
| <img src="https://icons.duckduckgo.com/ip3/bitwarden.com.ico" width="48"> | **Bitwarden** - Password manager |
| <img src="https://avatars.githubusercontent.com/u/60014385?s=48&v=4" width="48"> | **Ksnip** - Screenshot tool |
| <img src="https://images.videolan.org/images/VLC-IconSmall.png" width="48"> | **VLC** - Media player |
| <img src="https://icons.duckduckgo.com/ip3/ytmdesktop.app.ico" width="48"> | **YouTube Music Desktop** - Music streaming |
| <img src="https://icons.duckduckgo.com/ip3/portswigger.net.ico" width="48"> | **Burp Suite** - Security testing |
| <img src="https://icons.duckduckgo.com/ip3/protonvpn.com.ico" width="48"> | **ProtonVPN** - VPN client |
| <img src="https://dl.flathub.org/media/com/github/jeromerobert.pdfarranger/be4cba4552137f343cab16b4ee68a747/icons/128x128/com.github.jeromerobert.pdfarranger.png" width="48"> | **PDF Arranger** - PDF editor |

---

## 🔥 When code is pushed, the image will be automatically built and pushed to the GitHub repo 🔥
The existing "free" GitHub runners are used!


## 🚀 Custom Aurora NVIDIA-Image

Custom Fedora Aurora NVIDIA-Open image with BlueBuild, sysusers, tmpfiles, root password & Swiss keyboard layout.

Based on **Aurora NVIDIA-Open** (Universal Blue) with KDE Plasma, NVIDIA drivers and immutable bootc/OStree technology.

---

## ✅ Prerequisites

- Linux with `podman`
- GitHub account
- sudo privileges

---

## 🔧 Quick Start

### 1. Login to GitHub with Podman

```bash
echo "YOUR_GITHUB_TOKEN" | sudo podman login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### 2. Install BlueBuild CLI

```bash
podman run --pull always --rm ghcr.io/blue-build/cli:latest-installer | bash
```

### 3. Build image

```bash
touch cosign.pub cosign.key
bluebuild template recipe.yml -o Containerfile
sudo podman build -t os-base:latest .
```

### 4. Create QCOW2

```bash
sudo podman run --rm --privileged \
  -v .:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  --rootfs btrfs \
  localhost/os-base:latest
```

### 5. Start in QEMU

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
- `fedora` / *(set after first login)*

---

## 🔑 Set Fedora password (after first boot)

The user `fedora` is created at boot time. Set password:

```bash
passwd -d fedora     # removes requirement for "current password"
passwd fedora        # sets new password
```

---


---
## BUILD ISO for deployment

```bash
sudo podman run --rm --privileged \
  -v .:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --rootfs btrfs \
  localhost/os-base:latest
```

## 🎉 Features

✔ Swiss keyboard layout (console + X11/Wayland)  
✔ systemd-sysusers user (`fedora`)  
✔ Persistent `/var/home`  
✔ System-wide Flatpaks (Brave, VS Code, Obsidian, etc.)  
✔ Root login enabled  
✔ bootc/Silverblue compliant  

---

## 🛠️ Troubleshooting: Flatpaks not installing automatically

```bash
# Check status
systemctl status system-flatpak-setup.timer

# Start manually
sudo systemctl restart system-flatpak-setup.timer

# Or via ujust
ujust install-flatpaks

# Show installed Flatpaks
flatpak list --system
```

Afterwards: Logout/Restart.

---

## 🧰 Dev-Container: dev-general

Distrobox-Container with Python, Node.js (NVM), Podman/Docker CLI and VS Code.

```bash
distrobox create --name dev-general --image ghcr.io/bischoffjeremy/dev-general:latest
distrobox enter dev-general
distrobox enter dev-general -- distrobox-export --app code
```
## 🧊 Immutable System Management

Since Ailurus OS is based on OSTree technology, the system image (/usr) remains immutable. Local changes on the machine are stored as a "delta". The following commands help you inspect and manage the system state:

### 🔍 Show local configuration changes (Diff)

Displays all files in /etc that were locally modified (M) or added (A), and therefore differ from the GitHub image:

```bash
sudo ostree admin config-diff
```

### 📟 Show local Kernel Arguments (kargs)

Displays active boot parameters (useful for hardware fixes such as the 120Hz Lenovo workaround):

```bash
rpm-ostree kargs
```

### 🚀 Force clean state (Unlock Updates)

If an update is stuck in a staged state and local changes are blocking it, this command cleans up pending data:

```bash
rpm-ostree cleanup -m
```

### 🔄 Check current deployment & rollback targets

Shows current and previous deployments (including rollback options):

```bash
rpm-ostree status
```

### ⏪ Rollback to previous deployment

Boot into the previous system image (e.g. after a broken update):

```bash
sudo rpm-ostree rollback
reboot
```

### 📦 Show layered packages

Displays manually installed packages (layered packages) that are not part of the base image:

```bash
rpm-ostree status | grep LayeredPackages -A 5
```

### ➕ Temporarily layer a package (not recommended long-term)

Installs an RPM on top of the immutable image:

```bash
sudo rpm-ostree install htop
reboot
```

### ❌ Remove layered package

```bash
sudo rpm-ostree uninstall htop
reboot
```

### 🧹 Cleanup old deployments

Removes old images and frees disk space:

```bash
rpm-ostree cleanup -p
```

### 🌐 Rebase to a new image

Switch to a different container image (e.g. a new version from GitHub Container Registry):

```bash
sudo rpm-ostree rebase ghcr.io/USER/IMAGE:latest
reboot
```

# Ailurus OS

![Logo](logo/Wallpaper-small.png)

---

<p align="center">
	<strong>➡️ <a href="https://github.com/bischoffjeremy/home-os/wiki/Getting-Started" style="font-size:1.3em;">Getting Started: Step-by-step install guide in the Wiki</a> ⬅️</strong>
</p>

---

Custom Fedora Aurora NVIDIA-Open image based on Universal Blue with KDE Plasma and immutable bootc/OSTree. Built with BlueBuild, deployed via GitHub Actions.

All images are signed with [Cosign](https://docs.sigstore.dev/cosign/overview/) and scanned for vulnerabilities with [Grype](https://github.com/anchore/grype).

---

## Build & Security Status

| Image | Build | Vuln Scan | Signed | Last Update |
|:------|:-----:|:---------:|:------:|:------------|
| **os-base** | [![Build OS](https://github.com/bischoffjeremy/home-os/actions/workflows/build.yml/badge.svg)](https://github.com/bischoffjeremy/home-os/actions/workflows/build.yml) | [![Vuln Scan](https://img.shields.io/badge/grype-extras-brightgreen?logo=anchore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build.yml) | [![Signed](https://img.shields.io/badge/cosign-signed-brightgreen?logo=sigstore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build.yml) | ![Updated](https://img.shields.io/github/last-commit/bischoffjeremy/home-os/master?label=updated) |
| **dev-general** | [![Build](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer.yml/badge.svg)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer.yml) | [![Vuln Scan](https://img.shields.io/badge/grype-extras-brightgreen?logo=anchore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer.yml) | [![Signed](https://img.shields.io/badge/cosign-signed-brightgreen?logo=sigstore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer.yml) | ![Updated](https://img.shields.io/github/last-commit/bischoffjeremy/home-os/master?label=updated&path=devcontainer/dev-general) |
| **dev-docs** | [![Build](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-docs.yml/badge.svg)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-docs.yml) | [![Vuln Scan](https://img.shields.io/badge/grype-extras-brightgreen?logo=anchore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-docs.yml) | [![Signed](https://img.shields.io/badge/cosign-signed-brightgreen?logo=sigstore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-docs.yml) | ![Updated](https://img.shields.io/github/last-commit/bischoffjeremy/home-os/master?label=updated&path=devcontainer/dev-docs) |
| **dev-media** | [![Build](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-media.yml/badge.svg)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-media.yml) | [![Vuln Scan](https://img.shields.io/badge/grype-extras-brightgreen?logo=anchore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-media.yml) | [![Signed](https://img.shields.io/badge/cosign-signed-brightgreen?logo=sigstore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-media.yml) | ![Updated](https://img.shields.io/github/last-commit/bischoffjeremy/home-os/master?label=updated&path=devcontainer/dev-media) |
| **dev-pentest** | [![Build](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-pentest.yml/badge.svg)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-pentest.yml) | [![Vuln Scan](https://img.shields.io/badge/grype-extras-brightgreen?logo=anchore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-pentest.yml) | [![Signed](https://img.shields.io/badge/cosign-signed-brightgreen?logo=sigstore)](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-pentest.yml) | ![Updated](https://img.shields.io/github/last-commit/bischoffjeremy/home-os/master?label=updated&path=devcontainer/dev-pentest) |

---

## Installed Default Apps
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

## Dev Containers

This project includes open-source Distrobox dev containers that anyone can use freely. They are built automatically via GitHub Actions and published to `ghcr.io`.

| Container | Purpose | Image |
|-----------|---------|-------|
| **dev-general** | Python, Node.js, Podman/Docker CLI, VS Code | `ghcr.io/bischoffjeremy/dev-general:latest` |
| **dev-docs** | TeX Live, LibreOffice, Pandoc | `ghcr.io/bischoffjeremy/dev-docs:latest` |
| **dev-media** | GIMP, Inkscape, Krita, Kdenlive, Blender, Audacity | `ghcr.io/bischoffjeremy/dev-media:latest` |
| **dev-pentest** | Kali MCP Server – HTTP API auf Port 5000 (`http://localhost:5000/mcp`) | `ghcr.io/bischoffjeremy/dev-pentest:latest` |

```bash
distrobox create --name dev-general --image ghcr.io/bischoffjeremy/dev-general:latest
distrobox enter dev-general
```

---

## Supply-Chain Security

All images are signed with [Cosign](https://docs.sigstore.dev/cosign/overview/) and scanned with [Grype](https://github.com/anchore/grype). Builds run daily and on every push.

| Image | Report |
|:------|:------:|
| os-base | [Security Report](https://github.com/bischoffjeremy/home-os/actions/workflows/build.yml) |
| dev-general | [Security Report](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer.yml) |
| dev-docs | [Security Report](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-docs.yml) |
| dev-media | [Security Report](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-media.yml) |
| dev-pentest | [Security Report](https://github.com/bischoffjeremy/home-os/actions/workflows/build-devcontainer-pentest.yml) |

Verify any image:

```bash
cosign verify ghcr.io/bischoffjeremy/os-base:latest \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "github.com/bischoffjeremy/home-os"
```

---

## Fork and Customize

This image is built on top of [Universal Blue](https://universal-blue.org/) using [BlueBuild](https://blue-build.org/). The entire OS is defined in `recipe.yml` -- fork this repo, edit the recipe to your liking, and GitHub Actions will build your own custom image automatically.

---

<!-- For more details, see the Wiki. -->

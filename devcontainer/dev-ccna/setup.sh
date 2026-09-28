#!/usr/bin/env bash
# Creates the dev-ccna box (own home) and installs Cisco Packet Tracer into it.
# First download the Packet Tracer .deb (Ubuntu 64 bit) from netacad.com to ~/Downloads.
# Run in a normal terminal on the host: the installer asks you to accept the EULA.
set -euo pipefail

BOX=dev-ccna
BOX_HOME="$HOME/.local/share/distrobox-homes/$BOX"
DEB="$(ls -t "$HOME"/Downloads/CiscoPacketTracer_*_Ubuntu_64bit.deb | head -n1)"

podman container exists "$BOX" || distrobox create --yes --name "$BOX" \
    --image ghcr.io/bischoffjeremy/dev-ccna:latest --home "$BOX_HOME"

cp "$DEB" "$BOX_HOME/"
distrobox enter "$BOX" -- sh -c "cd ~ && sudo apt-get install -y './$(basename "$DEB")'"
rm -f "$BOX_HOME/$(basename "$DEB")"

# Bridge script module (file mailbox, lets Claude build and read topologies).
# The module cannot create the parent folders of its mailbox itself.
cp "$(dirname "$0")/PT-Bridge.pts" "$BOX_HOME/"
mkdir -p "$BOX_HOME/AppData/Local/packet-tracer-mcp/bridge"

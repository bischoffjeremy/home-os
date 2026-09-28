# dev-ccna

Ubuntu 22.04 box for Cisco Packet Tracer (CCNA practice). The image contains only the runtime:
Packet Tracer can only be downloaded with a NetAcad login and may not be redistributed.
The box has its own home (`~/.local/share/distrobox-homes/dev-ccna`), so Packet Tracer files stay out of your home.

## Setup

1. Download Packet Tracer (**Ubuntu 64 bit, .deb**) from [netacad.com](https://www.netacad.com) to `~/Downloads`.
2. In a normal terminal on the host:
   ```bash
   devcontainer/dev-ccna/setup.sh
   ```
   Creates the box from `ghcr.io/bischoffjeremy/dev-ccna`, installs the newest .deb (EULA: close the text with `q`, then accept)
   and copies the bridge module `PT-Bridge.pts` from this folder into the box home.
3. Start: `distrobox enter dev-ccna -- packettracer`, or export the app with DistroShelf. Multi-user: **No**.
4. Login: the box has no browser. In the login window under *Advanced Settings*, check
   **Use internal web browser for Cisco Networking Academy login**, then *LOGIN*.
5. Bridge: *Extensions → Scripting → Configure PT Script Modules → Add...* → `PT-Bridge.pts`,
   select **MCP-BUILDER** → **Start**, and under *Settings* set startup to **On Startup**.

New Packet Tracer version: download the new .deb and run `setup.sh` again.

## Bridge

`PT-Bridge.pts` is `V5.2.pts` from [Mats2208/MCP-Packet-Tracer](https://github.com/Mats2208/MCP-Packet-Tracer) release v0.9.0
(MIT, see `PT-Bridge.LICENSE`; sha256 `175f7755…d8bc071`).
Only its file mailbox is used, not the MCP server: Packet Tracer runs every `req_*.js` placed in
`<box home>/AppData/Local/packet-tracer-mcp/bridge/` and writes the result to `res_*.txt`.
Its own window (*Extensions → MCP BUILDER*, blue UI, shows "offline") is not needed and can stay closed.
The client script is `bin/pt` in the ccna-lab repo.

## Remove

```bash
distrobox rm -f dev-ccna
rm -rf ~/.local/share/distrobox-homes/dev-ccna
```

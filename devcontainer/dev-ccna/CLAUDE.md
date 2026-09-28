# dev-ccna: Packet Tracer box and bridge

Distrobox with Cisco Packet Tracer 9 for Jeremy's CCNA practice. The labs, tutor rules and the client
script live in `~/Dokumente/repos/ccna-lab` (read its CLAUDE.md for how labs are built and graded).

## Box

- Image: this Containerfile (Ubuntu 22.04, runtime libs only), built by `.github/workflows/build-devcontainer-ccna.yml`.
  Packet Tracer itself must never go into the image (license, public repo).
- `setup.sh` creates the box with its own home `~/.local/share/distrobox-homes/dev-ccna` and installs the .deb.
  PT 9's .deb only contains `/opt/pt/packettracer.AppImage`; its postinst asks for the EULA interactively,
  so setup must run in a real terminal. Claude has no TTY: never run the install yourself.
- The box home is visible from the host under that path. PT's own files: `pt/` (saves, logs are encrypted), `.packettracer/`.

## Bridge (how Claude talks to Packet Tracer)

- Script module **MCP-BUILDER** (`PT-Bridge.pts`, from Mats2208/MCP-Packet-Tracer v0.9.0) must be running in PT.
  Only its file mailbox is used, no MCP server, no HTTP. "offline" in its blue window refers to HTTP and is fine.
- Mailbox: `<box home>/AppData/Local/packet-tracer-mcp/bridge/`. Heartbeat: `alive.txt` (ms timestamp, rewritten every 0.25–1.5 s).
  No fresh `alive.txt` → module not started (*Extensions → Scripting → Configure PT Script Modules → MCP-BUILDER → Start*).
- Protocol: write `req_<id>.js` (write under another name, then rename), PT runs it with a `reportResult(value)` function,
  writes the value to `res_<id>.txt` and deletes the request. Files older than 60 s are purged.
- Use the client `~/Dokumente/repos/ccna-lab/bin/pt` instead of writing files by hand.

## PT 9 IPC pitfalls (verified)

- `lw.addDevice(type, model, x, y)` returns an auto name, rename with `setName`. Call `skipBoot()` on routers/switches.
- CLI: `device.getCommandLine()`, `enterCommand(cmd)`, `getOutput()` (whole history, read the tail), `getPrompt()`.
  New routers sit at the `[yes/no]` initial-config prompt: answer `no` first.
- Never send `end` (or any unknown word) in user mode `R1>`: IOS treats it as a hostname, starts a DNS lookup and the
  console is blocked for a long time. Switch modes based on `getPrompt()`.
- Hosts (PC/Server) have no `getDefaultGateway()`; ports have `getIpAddress()`, `getSubnetMask()`, `setIpSubnetMask()`, `setDefaultGateway()`.
- A new PT 9 file always contains a "Power Distribution Device0".

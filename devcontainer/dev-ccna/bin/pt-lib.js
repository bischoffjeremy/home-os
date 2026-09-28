/* Hilfsfunktionen für build.js, laufen im Script Engine von Packet Tracer 9 (über bin/pt). */
var PT_TYPES = { "1941": 0, "2901": 0, "2911": 0, "ISR4321": 0, "ISR4331": 0,
    "2960-24TT": 1, "3560-24PS": 16, "3650-24PS": 16,
    "PC-PT": 8, "Server-PT": 9, "Laptop-PT": 17 };
var PT_LINKS = { straight: 8100, cross: 8101, roll: 8102, fiber: 8103, serial: 8106, auto: 8107, console: 8108 };

function ptCli(name) {
    var cl = ipc.network().getDevice(name).getCommandLine();
    if (String(cl.getPrompt() || "").indexOf("[yes/no]") >= 0) { cl.enterCommand("no"); }
    cl.enterCommand("");
    return cl;
}

function addDevice(name, model, x, y) {
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace();
    var d = ipc.network().getDevice(lw.addDevice(PT_TYPES[model], model, x, y));
    d.setName(name);
    if (typeof d.skipBoot === "function") { d.skipBoot(); }
}

function addLink(d1, p1, d2, p2, type) {
    ipc.appWindow().getActiveWorkspace().getLogicalWorkspace().createLink(d1, p1, d2, p2, PT_LINKS[type]);
}

function configureIosDevice(name, commands) {
    var cl = ptCli(name);
    cl.enterCommand("enable");
    cl.enterCommand("configure terminal");
    var lines = commands.split("\n");
    for (var i = 0; i < lines.length; i++) { cl.enterCommand(lines[i]); }
    cl.enterCommand("end");
    cl.enterCommand("write memory");
}

function configurePcIp(name, dhcp, ip, mask, gateway, dns) {
    var d = ipc.network().getDevice(name);
    var port = d.getPort("FastEthernet0");
    if (dhcp) { d.setDhcpFlag(true); }
    if (ip && mask) { port.setIpSubnetMask(ip, mask); }
    if (gateway) { port.setDefaultGateway(gateway); }
    if (dns) { port.setDnsServerIp(dns); }
}

/* Aufgabentext als Notiz rechts oben auf die Arbeitsfläche und in die Network Description
   (die Description zeigt PT erst nach Speichern/Neuladen an, die Notiz sofort). */
function setTaskText(text) {
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace();
    var z = (typeof lw.getIncNoteZOrder === "function") ? lw.getIncNoteZOrder() : 0;
    lw.addNote(750, 50, z, text);
    ipc.appWindow().getActiveFile().setNetworkDescription(text);
}

/* Führt einen Befehl auf der CLI aus und gibt nur die neue Ausgabe zurück. */
function runCommand(name, command) {
    var cl = ptCli(name);
    /* nur passend zum Prompt wechseln: "end" im Benutzermodus löst eine DNS-Suche aus */
    var p = String(cl.getPrompt() || "");
    if (p.indexOf("(config") >= 0) { cl.enterCommand("end"); }
    if (/>\s*$/.test(String(cl.getPrompt() || ""))) { cl.enterCommand("enable"); }
    cl.enterCommand("terminal length 0");
    var before = String(cl.getOutput()).length;
    cl.enterCommand(command);
    var out = String(cl.getOutput()).substring(before);
    cl.enterCommand("disable");   /* Gerät wieder im Benutzermodus zurücklassen */
    return out;
}

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

var PT_BUILT_LINKS = [];
function addLink(d1, p1, d2, p2, type) {
    ipc.appWindow().getActiveWorkspace().getLogicalWorkspace().createLink(d1, p1, d2, p2, PT_LINKS[type]);
    PT_BUILT_LINKS.push([d1, d2]);
}

/* Layout prüfen: kein Kabel darf optisch durch ein drittes Gerät laufen (sonst sieht es aus, als hänge es dazwischen) */
function checkLayout() {
    var n = ipc.network(), warn = [];
    function c(name) { var d = n.getDevice(name); return [d.getCenterXCoordinate(), d.getCenterYCoordinate()]; }
    PT_BUILT_LINKS.forEach(function (l) {
        var a = c(l[0]), b = c(l[1]);
        for (var i = 0; i < n.getDeviceCount(); i++) {
            var name = n.getDeviceAt(i).getName();
            if (name === l[0] || name === l[1] || n.getDeviceAt(i).getModel() === "Power Distribution Device") { continue; }
            var p = c(name), dx = b[0] - a[0], dy = b[1] - a[1], len2 = dx * dx + dy * dy;
            var t = len2 ? Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / len2)) : 0;
            var ex = a[0] + t * dx - p[0], ey = a[1] + t * dy - p[1];
            if (Math.sqrt(ex * ex + ey * ey) < 50) { warn.push("Kabel " + l[0] + "–" + l[1] + " läuft durch " + name); }
        }
    });
    return warn.length ? "LAYOUT-FEHLER: " + warn.join("; ") : "Layout ok";
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

/* Zeilen an Wortgrenzen auf höchstens max Zeichen umbrechen, Folgezeilen eingerückt */
function wrapText(text, max) {
    return text.split("\n").map(function (line) {
        if (line.length <= max) { return line; }   /* kurze Zeilen (z. B. ASCII-Topologie) unverändert lassen */
        var out = [], cur = "";
        line.split(" ").forEach(function (w) {
            if (cur && (cur + " " + w).length > max) { out.push(cur); cur = "   " + w; }
            else { cur = cur ? cur + " " + w : w; }
        });
        out.push(cur);
        return out.join("\n");
    }).join("\n");
}

/* Aufgabentext als Notiz rechts oben auf die Arbeitsfläche und in die Network Description
   (die Description zeigt PT erst nach Speichern/Neuladen an, die Notiz sofort). */
function setTaskText(text) {
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace();
    var z = (typeof lw.getIncNoteZOrder === "function") ? lw.getIncNoteZOrder() : 0;
    lw.addNote(750, 50, z, wrapText(text, 75));   /* Notiz wird nicht umbrochen, lange Zeilen laufen sonst aus dem Bild */
    ipc.appWindow().getActiveFile().setNetworkDescription(text);
}

/* Projekt leeren statt File → New: alle Geräte ausser dem Power Distribution Device, Notizen mit Text, Beschreibung */
function clearProject() {
    /* im Simulation-Modus steht die Zeit: Trunks, Pings und DNS-Lookups auf der CLI laufen nie fertig */
    if (ipc.simulation().isSimulationMode()) { ipc.appWindow().getRSSwitch().showRealtimeMode(); }
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace(), n = ipc.network(), names = [], pdd = false;
    for (var i = 0; i < n.getDeviceCount(); i++) {
        var d = n.getDeviceAt(i);
        /* genau ein Power Distribution Device behalten (gehört zu jeder PT-9-Datei) */
        if (d.getModel() === "Power Distribution Device" && !pdd) { pdd = true; continue; }
        names.push(d.getName());
    }
    names.forEach(function (x) { lw.removeDevice(x); });
    var ids = lw.getCanvasNoteIds();
    for (var j = 0; j < ids.length; j++) {
        if (String(lw.getCanvasNoteText(ids[j]) || "").length > 0) { lw.removeCanvasItem(ids[j]); }
    }
    ipc.appWindow().getActiveFile().setNetworkDescription("");
    return names.length;
}

/* PT legt beim Hinzufügen von Geräten manchmal weitere Power Distribution Devices an: alle bis auf das erste entfernen */
function removeExtraPdd() {
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace(), n = ipc.network(), extra = [], pdd = false;
    for (var i = 0; i < n.getDeviceCount(); i++) {
        var d = n.getDeviceAt(i);
        if (d.getModel() !== "Power Distribution Device") { continue; }
        if (pdd) { extra.push(d.getName()); } else { pdd = true; }
    }
    extra.forEach(function (x) { lw.removeDevice(x); });
}

/* Aufgaben-Notiz eines laufenden Labs ersetzen: alle Notizen mit Text entfernen, neue setzen */
function updateTaskText(text) {
    var lw = ipc.appWindow().getActiveWorkspace().getLogicalWorkspace();
    var ids = lw.getCanvasNoteIds();
    for (var i = 0; i < ids.length; i++) {
        if (String(lw.getCanvasNoteText(ids[i]) || "").length > 0) { lw.removeCanvasItem(ids[i]); }
    }
    setTaskText(text);
}

/* Führt einen Befehl auf der CLI aus und gibt nur die neue Ausgabe zurück. */
function runCommand(name, command) {
    var cl = ptCli(name);
    /* nur passend zum Prompt wechseln: "end" im Benutzermodus löst eine DNS-Suche aus */
    var p = String(cl.getPrompt() || "");
    if (p.indexOf("(config") >= 0) { cl.enterCommand("end"); }
    if (/>\s*$/.test(String(cl.getPrompt() || ""))) { cl.enterCommand("enable"); }
    cl.enterCommand("terminal length 0");   /* kennt der 2960 in PT nicht, darum unten weiterblättern */
    var before = String(cl.getOutput()).length;
    cl.enterCommand(command);
    /* bei --More-- mit Leertaste weiter, sonst verschluckt der Pager das erste Zeichen des nächsten Befehls */
    for (var i = 0; i < 500 && /--More--\s*$/.test(String(cl.getOutput())); i++) { cl.enterChar(32, 0); }
    var out = String(cl.getOutput()).substring(before).replace(/ --More-- /g, "");
    cl.enterCommand("disable");   /* Gerät wieder im Benutzermodus zurücklassen */
    return out;
}

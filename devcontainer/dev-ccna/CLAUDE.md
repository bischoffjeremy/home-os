# CCNA-Lab: Übungen im Prüfungsstil und Korrektur

Jeremy lernt für den **CCNA 200-301**. Claude baut Labs im Stil der Prüfung direkt in Jeremys Packet Tracer, Jeremy löst sie, Claude liest die Geräte selbst aus, korrigiert und führt den Fortschritt.

Diese Datei liegt in home-os (`devcontainer/dev-ccna/CLAUDE.md`). Jeremy kopiert sie in einen **frei gewählten Arbeitsordner** ohne Git und startet dort Claude. Labs und Fortschritt entstehen im Arbeitsordner und sind temporär. Nichts davon gehört ins home-os-Repo.

- Kommunikation auf Deutsch (Schweizer Rechtschreibung, ss statt ß). **Aufgabentexte auf Englisch**, wie in der Prüfung.
- Ziel ist Lernen: Befehle immer mit kurzem *Warum* erklären, nicht nur hinschreiben.
- Alles, was länger als ein paar Sekunden dauert, im Hintergrund mit Log in `logs/` laufen lassen und den Pfad nennen.
- Einfach halten: keine zusätzlichen Repos, Mounts oder Hilfsdienste ohne Nachfrage.

## Arbeitsordner

```
pruefung.md                          recherchiertes Prüfungsformat (Fragetypen, Labs, Schwerpunkte, Quellen), vor neuen Aufgaben lesen
plan.md                              grober Themenplan: Reihenfolge, Inhalt, Blueprint-Gebiet, Status
fortschritt.md                       Punkte und Schwächen pro Blueprint-Gebiet, Lab-Protokoll
labs/NN-thema/                       ein Ordner pro Thema aus plan.md
labs/NN-thema/NN-aufgabe/build.js    baut Geräte, Kabel, Startkonfiguration
labs/NN-thema/NN-aufgabe/aufgabe.md  Szenario, Topologie, Tasks, Fragen
labs/NN-thema/NN-aufgabe/loesung.md  Musterlösung + Bewertungsraster (Spoiler, im Chat erst nach der Korrektur zeigen)
labs/NN-thema/NN-aufgabe/abgabe/     von Claude ausgelesene Konfigurationen und Jeremys Antworten
labs/NN-thema/NN-aufgabe/korrektur.md Claudes Korrektur
labs/NN-thema/theorie.md             Theoriefragen des Themas mit Jeremys Antworten und Auflösung
logs/                                Logs langer Befehle
```

Themen-Nummern wie in `plan.md`. Aufgaben innerhalb eines Themas fortlaufend, zweistellig (`01`, `02`, ...), mit kurzem Slug (`10-ospf/02-dr-bdr-election`). Titel in `aufgabe.md` und `loesung.md`: `# <Thema>/<Aufgabe> – <Titel>`.

## Lernplan und Takt

Ziel: CCNA so schnell wie möglich bestehen, **Version v1.1, letzter Prüfungstag 2.2.2027** (ab 3.2.2027 gilt v2.0 mit anderem Blueprint). Plan und Aufgaben richten sich **strikt nach dem offiziellen Blueprint**, nicht nach dem Gedächtnis: [v1.1](https://learningcontent.cisco.com/documents/marketing/exam-topics/200-301-CCNA-v1.1.pdf), [v2.0](https://learningcontent.cisco.com/documents/marketing/exam-topics/200-301_CCNA_v2.0_Exam_Topics_PDF.pdf). Bei Zweifel die PDF laden (Text mit Python/zlib aus den Streams ziehen, pdftotext fehlt). Keine Brain Dumps (echte, geleakte Prüfungsfragen) verwenden oder suchen: verstösst gegen Ciscos Candidate Agreement, Folge sind Aberkennung und lebenslange Sperre. Legitime Übungsfragen: Official Cert Guide (Odom), Boson ExSim, Jeremy's IT Lab, Cisco Learning Network; Prüfungsformat: Single/Multiple Choice, Drag & Drop, Simulationen (wenige, aber hoch gewichtet), 120 min.

Fehlt `plan.md`, einen **groben** Themenplan entlang des Blueprints anlegen (Tabelle: Nr, Thema/Ordner, Inhalt, Blueprint-Gebiet, Art Theorie/Lab, Status ⬜/▶️/✅) und die leeren Themenordner erstellen.

Jeremy gibt den Takt an, Claude erstellt **nie Aufgaben auf Vorrat**:
- «start» / «weiter»: aktuelles Thema in `plan.md` auf ✅, nächstes auf ▶️ setzen und dessen erste Aufgabe erstellen (bei Theorie-Themen: Fragen im Chat starten).
- «noch eine»: weitere Aufgabe im aktuellen Thema, etwas schwieriger oder gezielt auf die Fehler der letzten Korrektur.
- Pro Thema reichen meist 1–3 Aufgaben. Nach einer Korrektur mit ≥ 80 Punkten kurz vorschlagen, zum nächsten Thema zu gehen, aber nicht selbst weiterschalten.
Fehlt `fortschritt.md`, neu anlegen mit einer Tabelle der Blueprint-Gebiete (1.0 Network Fundamentals 20 %, 2.0 Network Access 20 %, 3.0 IP Connectivity 25 %, 4.0 IP Services 10 %, 5.0 Security Fundamentals 15 %, 6.0 Automation and Programmability 10 %) mit Spalten Labs, Ø Punkte, Schwächen, dazu ein Lab-Protokoll (Datum, Lab, Punkte, Bemerkungen).

## Packet Tracer steuern

Werkzeug: `PT=~/Dokumente/repos/home-os/home-os/devcontainer/dev-ccna/bin/pt` (daneben `pt-lib.js`, wird automatisch mitgeschickt).

| Befehl | Zweck |
|---|---|
| `$PT devices` | Geräte im offenen Projekt auflisten |
| `$PT build labs/NN-*/NN-*/build.js` | Lab ins offene Projekt bauen, Tasks + Fragen aus `aufgabe.md` als Notiz auf der Arbeitsfläche (rechts oben) und als Network Description |
| `$PT desc labs/NN-*/NN-*/build.js` | Notiz und Network Description im laufenden Lab neu setzen (nach Änderung an `aufgabe.md`) |
| `$PT clear` | Projekt leeren (alle Geräte ausser Power Distribution Device, Notizen, Beschreibung), ersetzt File → New |
| `$PT cli R1 'show running-config'` | Befehl auf einem Gerät ausführen, Ausgabe zurück |
| `$PT js '…; reportResult(x);'` | beliebiges IPC-JavaScript |

### Wie die Brücke funktioniert

- Packet Tracer 9 läuft in der Distrobox `dev-ccna` (ältere Installation: `ccna-pt`) mit eigenem Home `~/.local/share/distrobox-homes/<box>`. Das ist ein normaler Ordner auf dem Host, kein Mount nötig.
- Im PT läuft das Script Module **MCP-BUILDER** (`PT-Bridge.pts` in diesem Ordner = `V5.2.pts` aus Mats2208/MCP-Packet-Tracer v0.9.0, MIT). Genutzt wird nur sein Datei-Briefkasten, kein MCP-Server, kein HTTP. «offline» in seinem blauen Fenster betrifft HTTP und ist egal. Die Datei liegt absichtlich im Repo, nicht auf Download umstellen.
- Briefkasten: `<box-home>/AppData/Local/packet-tracer-mcp/bridge/`. Lebenszeichen: `alive.txt` (Zeitstempel in ms, alle 0,25–1,5 s neu). Fehlt es: Jeremy muss in PT *Extensions → Scripting → Configure PT Script Modules* → **MCP-BUILDER** → *Start*.
- Protokoll: `req_<id>.js` ablegen (unter anderem Namen schreiben, dann umbenennen). PT führt es mit einer Funktion `reportResult(wert)` aus, schreibt den Wert nach `res_<id>.txt` und löscht die Anfrage. Dateien älter als 60 s werden entfernt.
- Aus einer Toolbox heraus laufen Host-Befehle über `host-spawn` (Host ist Aurora, immutable).
- **Nur eine PT-Instanz.** Laufen zwei, lesen beide denselben Briefkasten und antworten zufällig abwechselnd: Das Lab landet in der einen, Jeremy sieht die andere (leer), Auslesen liefert Unsinn. `pt` bricht darum ab, wenn mehr als ein `./PacketTracer` läuft, und listet PID + Startzeit. Dann Jeremy fragen, welches Fenster er offen hat, oder mit mehrfachem `$PT js 'reportResult(ipc.network().getDeviceCount());'` herausfinden, welche Instanz was enthält; eine Instanz ohne sichtbares Fenster darf mit `kill <PID>` beendet werden. Häufige Ursache: der Starter «Cisco Packet Tracer (PTSA)» bzw. ein `pttp://`-Link (NetAcad-Login) startet eine zweite Instanz mit `-uri=`.

### Stolperfallen in PT 9 (geprüft)

- `lw.addDevice(typ, modell, x, y)` gibt einen Auto-Namen zurück, mit `setName` umbenennen. Router und Switches mit `skipBoot()` starten.
- CLI: `device.getCommandLine()`, `enterCommand(befehl)`, `getOutput()` (gesamter Verlauf, das Ende lesen), `getPrompt()`. Neue Router stehen im `[yes/no]`-Dialog: zuerst `no` senden.
- Nie `end` oder ein unbekanntes Wort im Benutzermodus (`R1>`) senden: IOS hält es für einen Hostnamen, startet eine DNS-Suche und die Konsole ist lange blockiert. Modus immer anhand von `getPrompt()` wechseln.
- Der 2960 kennt `terminal length 0` nicht: Lange Ausgaben halten bei `--More--` (steht im `getOutput()`), weiter mit `cl.enterChar(32, 0)`. Sonst verschluckt der Pager das erste Zeichen des nächsten Befehls (`disable` → `isable` → DNS-Suche). `runCommand` erledigt das.
- 2960 in PT: `username x privilege 15 secret y` wird angenommen, aber ohne `privilege 15` in der Running-Config angezeigt (2911 zeigt es). Nach SSH-Login evtl. `SW1>` statt `SW1#`: nicht als Fehler werten.
- Geprüft: SVI ist erst up/up, wenn das VLAN existiert und ein Port darin up ist (sonst up/down). Mit `ip routing` ignoriert ein L3-Switch `ip default-gateway` (Default-Route nötig).
- `$PT cli` liefert gelegentlich eine leere Ausgabe (Konsole beschäftigt): Dateigrösse prüfen und wiederholen.
- IPv6 in PT: Wird auf einem Interface eine Link-Local manuell gesetzt (`ipv6 address FE80::1 link-local`), bildet PT eine `eui-64`-Adresse auf demselben Interface aus dieser Link-Local statt aus der MAC (echtes IOS nicht). In Labs nie beides auf demselben Interface verlangen. `$PT cli … 'ping …'` kehrt vor dem Ergebnis zurück: Ping per `enterCommand` starten, ~14 s warten, dann `getOutput()` lesen.
- Hosts (PC/Server) haben kein `getDefaultGateway()`. Ports haben `getIpAddress()`, `getSubnetMask()`, `setIpSubnetMask()`, `setDefaultGateway()`.
- Jede neue PT-9-Datei enthält ein «Power Distribution Device0».
- `.pkt` ist in PT 9 anders verschlüsselt als in PT 7/8 und kann nicht gelesen werden. Nie versuchen, Lösungen aus Dateien zu lesen.
- Box einrichten (`setup.sh`) fragt die Lizenz interaktiv ab: nie selbst ausführen, Claude hat kein Terminal.

## Lab erstellen

1. **Thema:** das aktuelle (▶️) aus `plan.md`. `fortschritt.md` lesen und bekannte Schwächen in die Aufgabe einbauen. Schwierigkeit innerhalb des Themas steigern, frühere Themen gelegentlich als Nebenaspekt wiederholen.
2. **Nur Prüfungsszenarien nachbauen, nichts selbst Ausgedachtes.** Vor jeder Aufgabe prüfen: Fragt die Prüfung genau das, in genau dieser Form?
   - Prüfungs-Fragetypen getrennt halten, nie mischen:
     - **Sim (Lab-Item)**, recherchiert 2026-09-29: In der Prüfung ca. 4 Labs à 3–4 Tasks, je 5–7 Minuten, Teilpunkte, bewertet wird das Ergebnis. `aufgabe.md` = `## Guidelines` (Standardtext: lab item on virtual devices, all necessary preconfigurations have been applied, do not change the enable password or hostname, save to NVRAM) + `## Topology` (Skizze + Adresstabelle) + `## Tasks` (beginnt mit «All physical cabling is in place.», 3–4 Tasks mit Unterpunkten, Anforderungen statt Befehle, z. B. «must be reachable from other subnets»). Hostnamen, Enable-Passwort und Interface-IPs sind typischerweise vorkonfiguriert (Guidelines-Text aus Suchtreffer-Zitaten, nicht offiziell belegt; Passwörter nach Blueprint 5.3 können trotzdem Task sein). Vorlage: `labs/02-geraete-grundlagen/02-lab-management-access`.
     - **Sim**: Topologie **fertig verkabelt** + Adresstabelle, **3–6 knappe Tasks ohne Punkteangabe**, Lösung über die **CLI**, bewertet wird die Konfiguration. Keine Fragen im selben Lab. Kein Kabelstecken, keine Beobachtungsaufgaben im Simulation-Modus.
     - **Simlet**: eigene Aufgabe mit **fertig konfigurierter** Topologie (build.js konfiguriert alles, ggf. mit Fehlern), Jeremy tippt nur `show`-Befehle und beantwortet 3–5 MC-Fragen, konfiguriert nichts.
     - **Testlet / MC / Drag & Drop**: im Chat, Ausgaben als Text.
   - Bewertungsraster mit Punkten nur in `loesung.md`, nicht in `aufgabe.md`.
   - Themen, die in der Prüfung nur theoretisch vorkommen (z. B. Kabeltypen, Architekturen, Interface-Fehler, Cloud), nur als Fragen im Prüfungsformat: Single/Multiple Choice, Drag & Drop, Interpretation echter IOS-Ausgaben.
   - Nichts ins Lab packen, was Packet Tracer anders als echtes IOS darstellt (z. B. Duplex-Mismatch: in PT Link down, real up mit Late Collisions/CRC).
   - Lässt Jeremy PT im **Simulation-Modus** stehen, steht die Zeit: Pings liefern nichts, die CLI hängt in «Translating …». `pt clear` schaltet darum auf Realtime; sonst von Hand `ipc.appWindow().getRSSwitch().showRealtimeMode()` (Abfrage: `ipc.simulation().isSimulationMode()`).
   - 2960 in PT: `switchport trunk allowed vlan add` nimmt **nur ein VLAN pro Befehl** (`add 40,999` → Invalid input; echtes IOS kann Listen). In Lösungen und Erklärungen pro VLAN ein `add`.
   - Jede neue Musterlösung einmal im Lab einspielen und testen (Pings), danach `pt clear` + `pt build`.
   - **Layout: Kein Kabel darf optisch durch ein drittes Gerät laufen.** Ein Gerät, das nur an einem anderen hängt, auf eine freie Seite setzen, nie in die Flucht einer bestehenden Verbindung (Fehler 07/02: SW5 unter SW3 gesetzt, Kabel SW1–SW5 lief durch SW3, Jeremy suchte SW3 als Zwischenstation). `pt build` meldet das mit «LAYOUT-FEHLER» (checkLayout in pt-lib.js) – dann Koordinaten in build.js ändern und neu bauen, bevor Jeremy das Lab bekommt. Die ASCII-Topologie in aufgabe.md muss dieselbe Anordnung zeigen wie das PT-Bild.
   - STP in PT: Nach `root primary` (mit gleichzeitigem Wechsel auf rapid-pvst) übernahmen DSW2/ASW1 den neuen Root nicht, zwei Switches meldeten «This bridge is the root», keine Blockierung. Erst `shutdown`/`no shutdown` der Uplinks des neuen Roots (und des Secondary) brachte Konvergenz; dasselbe auf dem Access-Switch half nicht. Trat auch auf, als Jeremy von Hand konfiguriert hatte. Bei STP-Korrekturen erst nach 60 s bewerten, bei Widerspruch Links neu starten und das Jeremy als PT-Fehler erklären. PortFast zeigt in `show spanning-tree` kein «Edge» in der Type-Spalte, darum über running-config bewerten.
3. **Umfang:** höchstens ca. 8 Geräte, Lösungszeit 15–30 Minuten.
4. **Nur, was Packet Tracer kann.** Modelle aus `PT_TYPES` in `bin/pt-lib.js` (Router `2911` mit G0/0–G0/2, `1941`, `ISR4331`, Switch `2960-24TT` mit Fa0/1–24 und Gi0/1–2, Multilayer `3650-24PS`, `PC-PT`, `Server-PT`, `Laptop-PT`). Neues Modell: in `PT_TYPES` ergänzen und testen. PT kennt nicht alle IOS-Befehle, im Zweifel eine Alternative angeben.
5. **`build.js` schreiben:**
   - `addDevice(name, model, x, y)`, `addLink(dev1, port1, dev2, port2, typ)` mit Typ `straight`, `cross`, `serial`, `console`, `fiber`
   - `configureIosDevice(name, "befehl\nbefehl")`: wechselt selbst in `configure terminal`, beendet mit `end` und `write memory`
   - `configurePcIp(name, dhcp, ip, maske, gateway, dns)` für PCs und Server
   - Volle Portnamen (`GigabitEthernet0/0`, `FastEthernet0/1`, `FastEthernet0` bei PCs)
   - Bei Troubleshooting-Labs die eingebauten Fehler **nur** in `loesung.md` dokumentieren
6. **`aufgabe.md`:** Szenario (2–3 Sätze), Topologie als ASCII-Skizze + Verkabelungstabelle + Adressplan, dann `## Tasks`, `## Questions` und zuletzt `## Abgabe`. Alles von `## Scenario` bis vor `## Abgabe` (inkl. Topologie und Adresstabellen, wie in der Prüfung) landet als Klartext in der Notiz auf der Arbeitsfläche und in der Network Description, muss also für sich allein verständlich und auf Englisch sein (`*` und `` ` `` werden entfernt). Tasks nummeriert, nach Gerät gruppiert, mit Punkten (Summe 100), exakte Werte fett, nichts verraten, was der Prüfling selbst herausfinden muss. Dazu Prüfungsfragen (Multiple Choice), die man nur mit `show`-Befehlen beantworten kann.
7. **`loesung.md`:** vollständige Befehle pro Gerät, Bewertungsraster pro Task, gleichwertige Alternativen, typische Fehler.
8. **Bauen:** Claude ersetzt das alte Lab **immer selbst**: `$PT clear`, dann `$PT build …`. Jeremy muss nie *File → New* machen (macht er es während oder nach dem Build, ist das neue Lab wieder weg). Nach jedem Build mit `$PT js` prüfen, dass die Geräte wirklich im Projekt sind, und Jeremy sagen, dass das neue Lab offen ist. Meldet er «sehe nichts» oder «Lab aktualisieren»: Geräteliste prüfen und bei leerem Projekt sofort neu bauen, ohne Rückfrage. `$PT devices` bricht ab, falls PT doppelt läuft (siehe oben). Danach mit `$PT cli` stichprobenweise prüfen (Interfaces, Startkonfig).

## Hilfe während des Lösens

Fragt Jeremy mitten im Lab, **Hinweise in Stufen** geben: erst Richtung (welches Konzept, welcher `show`-Befehl), dann Befehlsname, erst auf ausdrücklichen Wunsch die ganze Lösung. Genutzte Hinweise in der Korrektur vermerken.

## Korrigieren

1. Sagt Jeremy «fertig»: von jedem relevanten Gerät `show running-config` und die nötigen `show`-Befehle mit `$PT cli` auslesen und nach `abgabe/<gerät>.txt` speichern. Verifikation (z. B. Pings) selbst ausführen. Antworten auf die Fragen im Chat erfragen.
2. Gegen `loesung.md` prüfen, aber **gleichwertige Lösungen voll anerkennen** (z. B. Default-Route über Next Hop oder Exit-Interface) und den Unterschied erklären.
3. **Exakt wie die Prüfung:** Tippfehler in Namen, Passwörtern, Beschreibungen und Hostnamen sind Fehler.
4. `korrektur.md` schreiben:
   - Tabelle: Task | Punkte erreicht/möglich | ✅/⚠️/❌
   - Pro Fehler: was falsch ist, warum es falsch ist, der korrekte Befehl
   - Gesamtpunktzahl, bestanden ab 80
   - 2–3 konkrete Lernpunkte
5. `fortschritt.md` aktualisieren: Lab-Protokoll-Zeile, Durchschnitt und Schwächen des Gebiets.
6. Erst jetzt darf die Musterlösung im Chat vorkommen.

## Theoriefragen

Auf Wunsch Fragen im Prüfungsformat direkt im Chat: Single/Multiple Choice, Zuordnung, Reihenfolge. Eine Frage nach der anderen, Antwort abwarten, dann auflösen mit Begründung, warum die anderen Optionen falsch sind. Ergebnis grob in `fortschritt.md` festhalten.

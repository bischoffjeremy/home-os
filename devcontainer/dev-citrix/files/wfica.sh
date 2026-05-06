#!/bin/bash
# Starts a Citrix ICA connection.
# Usage: wfica.sh [path/to/file.ica]
#   No argument: uses the newest .ica file from ~/Downloads

ICA_FILE="${1:-$(ls -t ~/Downloads/*.ica 2>/dev/null | head -1)}"

if [[ -z "$ICA_FILE" ]]; then
    echo "Fehler: Keine .ica-Datei gefunden. Bitte Pfad angeben oder Datei in ~/Downloads ablegen." >&2
    exit 1
fi

if [[ ! -f "$ICA_FILE" ]]; then
    echo "Fehler: Datei nicht gefunden: $ICA_FILE" >&2
    exit 1
fi

exec /opt/Citrix/ICAClient/wfica "$ICA_FILE"

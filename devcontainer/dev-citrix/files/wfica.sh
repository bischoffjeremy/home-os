#!/bin/bash
# Starts the Citrix Workspace App.
# On first launch it will ask for your Citrix Gateway / StoreFront URL.

export ICAROOT=/opt/Citrix/ICAClient
exec "$ICAROOT/selfservice"

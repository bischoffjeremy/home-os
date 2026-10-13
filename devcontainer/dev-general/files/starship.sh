# Starship prompt for interactive bash sessions in this container.
case $- in *i*) ;; *) return ;; esac
[ -n "$BASH_VERSION" ] || return
command -v starship >/dev/null || return

# The config shipped in the image wins over an old ~/.config/starship.toml
# in the shared home; set STARSHIP_CONFIG yourself to override.
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-/etc/starship.toml}"
eval "$(starship init bash)"

if [ -n "${XDG_RUNTIME_DIR}" ] && [ -S "${XDG_RUNTIME_DIR}/podman/podman.sock" ]; then
    export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
    export CONTAINER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
fi

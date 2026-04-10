# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch AS stage-files
COPY ./files /files

# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch AS stage-bins
COPY --from=ghcr.io/sigstore/cosign/cosign:v3.0.2 \
  /ko-app/cosign /bins/cosign
COPY --from=ghcr.io/blue-build/cli:latest-installer \
  /out/bluebuild /bins/bluebuild
# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch AS stage-keys
COPY cosign.pub /keys/os-base.pub


# Main image
FROM ghcr.io/ublue-os/aurora-nvidia-open@sha256:ff89ceb08d74fd9601b25af6849d3937db08e8d96b92a8f451615c378cd2df60 AS os-base
ARG TARGETARCH
ARG RECIPE=recipe.yml
ARG IMAGE_REGISTRY=localhost
ARG BB_BUILD_FEATURES=""
ARG CONFIG_DIRECTORY="/tmp/files"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="os-base"
ARG BASE_IMAGE="ghcr.io/ublue-os/aurora-nvidia-open"
ARG FORCE_COLOR=1
ARG CLICOLOR_FORCE=1
ARG RUST_LOG_STYLE=always
# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /etc/pki/containers/ \
  && cp /tmp/keys/* /etc/pki/containers/
# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/
RUN --mount=type=bind,from=ghcr.io/blue-build/nushell-image:default,src=/nu,dst=/tmp/nu \
  mkdir -p /usr/libexec/bluebuild/nu \
  && cp -r /tmp/nu/* /usr/libexec/bluebuild/nu/
RUN \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/scripts/,ro \
  /scripts/pre_build.sh

# Module RUNs
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/dnf:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/tmp/scripts/,ro \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-os-base-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-os-base-latest,sharing=locked \
/tmp/scripts/run_module.sh 'dnf' '{"type":"dnf","install":{"packages":["passwd","xorg-x11-drv-vmware","qemu-guest-agent","wireguard-tools","podman"]}}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/files:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/tmp/scripts/,ro \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-os-base-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-os-base-latest,sharing=locked \
/tmp/scripts/run_module.sh 'files' '{"type":"files","files":[{"source":"starship.toml","destination":"/usr/etc/starship.toml"},{"source":"default.jxl","destination":"/usr/share/backgrounds/default.jxl"},{"source":"default-dark.jxl","destination":"/usr/share/backgrounds/default-dark.jxl"},{"source":"fedora-user.sysusers","destination":"/usr/lib/sysusers.d/50-fedora.conf"},{"source":"fedora-home.tmpfiles","destination":"/usr/lib/tmpfiles.d/50-fedora-home.conf"},{"source":"subuid","destination":"/usr/etc/subuid"},{"source":"subgid","destination":"/usr/etc/subgid"},{"source":"vconsole.conf","destination":"/etc/vconsole.conf"},{"source":"00-keyboard.conf","destination":"/etc/X11/xorg.conf.d/00-keyboard.conf"},{"source":"locale.conf","destination":"/etc/locale.conf"},{"source":"timezone","destination":"/etc/timezone"}]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/script:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/tmp/scripts/,ro \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-os-base-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-os-base-latest,sharing=locked \
/tmp/scripts/run_module.sh 'script' '{"type":"script","snippets":["echo \"root:root\" | chpasswd","passwd -u root","mkdir -p /etc/wireguard","ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime","echo \"Customizations applied.\""]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/default-flatpaks:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/tmp/scripts/,ro \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-os-base-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-os-base-latest,sharing=locked \
/tmp/scripts/run_module.sh 'default-flatpaks' '{"type":"default-flatpaks","configurations":[{"scope":"system","install":["com.brave.Browser","com.visualstudio.code","md.obsidian.Obsidian","net.ankiweb.Anki","com.github.xournalpp.xournalpp","com.bitwarden.desktop","org.ksnip.ksnip","org.videolan.VLC","app.ytmdesktop.ytmdesktop","net.portswigger.BurpSuite-Community","com.protonvpn.www","com.github.jeromerobert.pdfarranger"]}]}'

RUN \
--mount=type=bind,src=.bluebuild-scripts_9786ec61,dst=/scripts/,ro \
  /scripts/post_build.sh

# Labels are added last since they cause cache misses with buildah
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/blue-build/cli/main/README.md"
LABEL org.blue-build.build-id="e8006f68-8bf9-4060-836d-cf709219c715"
LABEL org.opencontainers.image.base.digest="sha256:ff89ceb08d74fd9601b25af6849d3937db08e8d96b92a8f451615c378cd2df60"
LABEL org.opencontainers.image.base.name="ghcr.io/ublue-os/aurora-nvidia-open:latest"
LABEL org.opencontainers.image.created="2025-12-19T14:56:04.967126661+00:00"
LABEL org.opencontainers.image.description="Custom Aurora NVIDIA System mit Extras, Flatpaks & CH Keyboard"
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.title="os-base"
# Multi-stage build
ARG FEDORA_MAJOR_VERSION=37

## Build ublue-os-base
FROM ghcr.io/ublue-os/kinoite-nvidia:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

# Add Vanilla First Setup
RUN wget https://copr.fedorainfracloud.org/coprs/ublue-os/vanilla-first-setup/repo/fedora-$(rpm -E %fedora)/ublue-os-vanilla-first-setup-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-vanilla-first-setup.repo

COPY etc /etc
COPY usr /usr

COPY ublue-firstboot /usr/bin

RUN rpm-ostree override remove firefox firefox-langpacks && \
	# starship.rs is in the copr repos
	wget -P /etc/yum.repos.d/ https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-${FEDORA_MAJOR_VERSION}/atim-starship-fedora-${FEDORA_MAJOR_VERSION}.repo && \
    rpm-ostree install vte291-gtk4-devel vanilla-first-setup && \
    rpm-ostree install distrobox just rsync btop kitty starship zsh zenity bismuth fish rEFInd && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-automatic.timer && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-vanilla-first-setup.repo && \
    rm -rf \
        /tmp/* \
        /var/* && \
    ostree container commit
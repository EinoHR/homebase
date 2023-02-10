ARG FEDORA_MAJOR_VERSION=37

FROM ghcr.io/ublue-os/kinoite:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

COPY etc /etc

COPY ublue-firstboot /usr/bin

RUN rpm-ostree override remove firefox firefox-langpacks && \
	# starship.rs is in the terra repos
	wget -P /etc/yum.repos.d/ https://terra.fyralabs.com/terra.repo && \
    rpm-ostree install distrobox just rsync btop kitty rust-starship zsh && \
	chsh -s /bin/zsh && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-automatic.timer && \
    ostree container commit

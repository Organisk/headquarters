# headquarters — bare arch container simulating a fresh archinstall VM
# usage: docker build -t headquarters . && docker run -it headquarters
FROM archlinux:latest

# simulate what archinstall gives you: base system + sudo + ssh
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        sudo \
        openssh \
        curl \
        git \
        python \
        which \
    && pacman -Scc --noconfirm

# simulate the skogix user that archinstall creates
RUN useradd -m -G wheel -s /bin/bash skogix && \
    echo "skogix ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/skogix && \
    chmod 0440 /etc/sudoers.d/skogix

WORKDIR /home/skogix
USER skogix
CMD ["/bin/bash"]

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    python3 \
    python3-apt \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Buat user devops dengan akses sudo tanpa password
RUN useradd -m -s /bin/bash devops && \
    echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY managed-entrypoint.sh /managed-entrypoint.sh
RUN chmod +x /managed-entrypoint.sh

ENTRYPOINT ["/managed-entrypoint.sh"]

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ansible \
    openssh-client \
    sshpass \
    git \
    curl \
    nano \
    vim \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Buat user devops untuk simulasi jika diperlukan
RUN useradd -m -s /bin/bash devops

WORKDIR /ansible

COPY control-entrypoint.sh /control-entrypoint.sh
RUN chmod +x /control-entrypoint.sh

ENTRYPOINT ["/control-entrypoint.sh"]

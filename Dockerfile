FROM    ubuntu:latest

ENV     DEBIAN_FRONTEND=noninteractive

## Common tools installation
RUN     apt-get update > /dev/null \
        && apt-get install --no-install-recommends --yes apt-utils ca-certificates curl git tzdata vim \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

## Systemd installation
RUN     echo 'root:root' | chpasswd \
        && printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d \
        && apt-get update \
        && apt-get install --no-install-recommends --yes software-properties-common systemd systemd-sysv systemd-cron dbus dbus-user-session rsyslog sudo \
        && printf "systemctl start systemd-logind" >> /etc/profile \
        && apt-get clean \
        && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
        && rm -rf /var/lib/apt/lists/* \
        && touch -d "2 hours ago" /var/lib/apt/lists \
        && sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf \
        && rm -f /lib/systemd/system/systemd*udev* \
        && rm -f /lib/systemd/system/getty.target

## Docker installation
# We remove old packages
RUN     for pkg in docker.io docker-doc docker-compose podman-docker containerd runc ; do apt-get --yes remove $pkg 2>&1 ; done || true

# Add Docker's official GPG key:
RUN     apt-get update > /dev/null \
        && apt-get install --no-install-recommends --yes gnupg \
        && install -m 0755 -d /etc/apt/keyrings \
        && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
        && chmod a+r /etc/apt/keyrings/docker.gpg \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Add the repository to Apt sources:
RUN     echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Finally install docker  
RUN     apt-get update >/dev/null \
        && apt-get install --no-install-recommends --yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

## Final touch
# Systemd startup script example
RUN     printf '#!/bin/bash\necho "Kernel Version: $(uname -a)" > /etc/kernelinfo.txt\n' > /usr/local/bin/startup.sh && chmod +x /usr/local/bin/startup.sh \
        && printf '[Unit]\nDescription=Custom Startup Script\n[Service]\nExecStart=/usr/local/bin/startup.sh\n[Install]\nWantedBy=default.target' > /etc/systemd/system/startup.service \
	&& chmod 644 /etc/systemd/system/startup.service \
	&& systemctl enable startup.service

COPY    Dockerfile /etc/Dockerfile
RUN     touch /etc/Dockerfile

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

EXPOSE  80 443
WORKDIR /root

ENTRYPOINT [ "/sbin/init" ]

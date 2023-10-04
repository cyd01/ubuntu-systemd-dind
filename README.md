# ubuntu-systemd-dind

How to build and run `systemd` and `dind` (docker in docker) into an `ubuntu` container

## How to build

```bash
docker build . --tag ubuntu-systemd-dind
```

## How to start the container

`ubuntu-systemd-dind` need enhanced capabilities to run:
- privileged mode
- SYS_ADMIN capability
- `host` cgroup namespace

A valid command to start it can be:

```bash
docker run --rm --detach --privileged \
  --cap-add SYS_ADMIN \
  --env TZ=$(cat /etc/timezone) \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  --tmpfs /tmp --tmpfs /run \
  --hostname ubuntu-systemd-dind \
  --name ubuntu-systemd-dind \
  ubuntu-systemd-dind
```

## How to enter the container

```bash
docker exec --interactive --tty \
  ubuntu-systemd-dind /bin/bash
```

## How to test

Here is a command to test the `docker` service status in `systemd` (runing inside the container):

```bash
systemctl status docker.service 
```

```log
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2023-10-04 16:58:45 CEST; 30s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 72 (dockerd)
      Tasks: 22
     Memory: 24.8M
        CPU: 434ms
     CGroup: /system.slice/docker-6b700f957941f688bbb89e0b069f9abeb18173cc58f9793212e5d5985907147c.scope/system.slice/docker.service
             └─72 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```
## How to stop

```bash
docker kill ubuntu-systemd-dind
```


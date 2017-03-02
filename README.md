
# docker-proxy

- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Usage](#usage)
  - [Logs](#logs)

# Introduction

- proxy-server `Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Squid proxy server](http://www.squid-cache.org/) and [Stunnel server](https://www.stunnel.org/index.html).
- proxy-client `Dockerfile` to create a [Docker](https://www.docker.com/) container image for Stunnel client.

# Getting started

## Installation

```bash
docker pull jolestar/proxy-server
docker pull jolestar/proxy-client
```
or check out the code. Then build with:

```bash
cd server && make
cd client && make
```

## Quickstart

Start server using:

```bash
docker run --name proxy-server -d --restart=always -p 5000:5000 \
 -v /srv/docker/docker-proxy/cache:/var/spool/squid \
 -v /srv/docker/docker-proxy/cert:/etc/docker-proxy/cert/ \
jolestar/proxy-server
```

Get auto generated proxy password using:

```bash
docker logs proxy-server 2>&1 |grep docker-proxy

Adding password for user docker-proxy
username: docker-proxy password: <password>
```
The password only generated for proxy-server first start, you can rm /srv/docker/docker-proxy/cert/passwd and restart proxy-server for regenerate.
You also can change password or add more user by:

```bash
htpasswd /srv/docker/docker-proxy/cert/passwd docker-proxy
```

Then copy /srv/docker/docker-proxy/cert/stunnel.pem to your client /srv/docker/docker-proxy/cert/ .

Start client using:

```bash
export PROXY_SERVER=<Your Server IP>
docker run --name proxy-client --add-host server:$PROXY_SERVER -d --restart=always -p 5001:5001 \
 -v /srv/docker/docker-proxy/cert:/etc/docker-proxy/cert/ \
jolestar/proxy-client
```

## Usage

Export env for global using:

```bash
export ftp_proxy=https://docker-proxy:<password>@localhost:5001
export http_proxy=https://docker-proxy:<password>@localhost:5001
export https_proxy=https://docker-proxy:<password>@localhost:5001

```

Command line var for one-time using:

```bash
https_proxy=https://docker-proxy:<password>@localhost:5001 curl https://google.com
```

## Logs

To access the Squid logs, located at `/var/log/squid/`, you can use `docker exec`. For example, if you want to tail the access logs:

```bash
docker exec -it proxy-server tail -f /var/log/squid/access.log
```

You can also mount a volume at `/var/log/squid/` so that the logs are directly accessible on the host.


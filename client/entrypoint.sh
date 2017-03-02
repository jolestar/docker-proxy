#!/bin/bash
set -e

echo "Starting stunnel"
stunnel /etc/docker-proxy/stunnel.conf

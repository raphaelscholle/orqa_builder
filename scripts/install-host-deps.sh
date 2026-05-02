#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  gawk \
  wget \
  git \
  diffstat \
  unzip \
  texinfo \
  gcc \
  build-essential \
  chrpath \
  socat \
  cpio \
  python3 \
  python3-pip \
  python3-pexpect \
  xz-utils \
  debianutils \
  iputils-ping \
  python3-git \
  python3-jinja2 \
  python3-subunit \
  mesa-common-dev \
  zstd \
  liblz4-tool \
  file \
  locales \
  rsync

echo "Install kas with:"
echo "python3 -m pip install --user kas"


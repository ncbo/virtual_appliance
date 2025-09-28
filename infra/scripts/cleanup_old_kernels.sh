#!/usr/bin/env bash
# remove old kernels
set -euo pipefail

echo "Checking current kernel..."
current_kernel="$(uname -r)"
current_image="linux-image-${current_kernel}"
echo "Running kernel: $current_image"

# Determine the latest installed kernel package
latest_installed_kernel="$(dpkg --list 'linux-image-[0-9]*-generic' \
  | awk '/^ii/ && $2 !~ /unsigned/ {print $2}' \
  | sort -V | tail -n1)"

if [[ "$current_image" != "$latest_installed_kernel" ]]; then
  echo "WARNING: A newer kernel ($latest_installed_kernel) is installed but not currently in use."
  echo "Reboot is required before cleanup can proceed safely."
  return 1
fi

echo "Identifying installed kernel images for removal..."
dpkg --list 'linux-image-[0-9]*-generic' \
  | awk '/^ii/ && $2 !~ /unsigned/ {print $2}' \
  | grep -v "$current_image" \
  | while read -r pkg; do
      echo "Purging old kernel: $pkg"
      apt-get purge -y "$pkg"
    done

echo "Running autoremove..."
apt-get autoremove --purge -y

echo "Updating GRUB configuration..."
update-grub

echo "Old kernel cleanup complete. Only the running kernel remains installed."

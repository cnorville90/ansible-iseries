#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Cleaning previous context..."
rm -rf context

echo "==> Generating build context..."
ansible-builder create

echo "==> Patching Containerfile..."
# Use microdnf instead of dnf
sed -i 's|ARG PKGMGR="/usr/bin/dnf"|ARG PKGMGR="/usr/bin/microdnf"|' context/Containerfile

# Strip systemd-python (requires build headers not in the EE base) after introspect generates requirements
sed -i '/^RUN .*introspect\.py/a RUN sed -i '"'"'/systemd-python/d'"'"' /tmp/src/requirements.txt' context/Containerfile

echo "==> Building EE image..."
podman build -t localhost/ee-iseries:latest context/

echo "==> Verifying ibm.power_ibmi collection..."
podman run --rm localhost/ee-iseries:latest ansible-galaxy collection list 2>/dev/null | grep -E "ibm\.power_ibmi|infra\.aap_configuration"

echo "==> Done. Image: localhost/ee-iseries:latest"

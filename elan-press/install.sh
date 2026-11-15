#!/bin/bash
# Install a libfprint built by rebuild.sh, plus the sensor power rule,
# the resume restart, and the short stop timeout. Needs root.
# Leaves enrolled prints in place. Does not re-enroll.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
SO=${1:-}

if [[ $(id -u) -ne 0 ]]; then
  echo "Run as root: sudo $0 /path/to/libfprint-2.so.2.0.0" >&2
  exit 1
fi
if [[ ! -f $SO ]]; then
  echo "Pass the built libfprint-2.so.2.0.0" >&2
  exit 1
fi
strings "$SO" | grep -q "partial press covers"

install -d /etc/udev/rules.d /usr/lib/systemd/system-sleep /etc/systemd/system/fprintd.service.d
install -m 644 "$ROOT/99-elan-0c6e-power.rules" /etc/udev/rules.d/99-elan-0c6e-power.rules
install -m 755 "$ROOT/fprintd-resume" /usr/lib/systemd/system-sleep/fprintd-resume
install -m 644 "$ROOT/10-stop-timeout.conf" /etc/systemd/system/fprintd.service.d/10-stop-timeout.conf
install -m 755 "$SO" /usr/lib/libfprint-2.so.2.0.0

udevadm control --reload
udevadm trigger --subsystem-match=usb --attr-match=idVendor=04f3 --attr-match=idProduct=0c6e || true
systemctl daemon-reload
systemctl try-restart fprintd.service || true
echo INSTALLED

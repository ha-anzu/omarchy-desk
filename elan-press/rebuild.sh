#!/bin/bash
# Build libfprint with the ELAN press driver. Does not install it.
set -euo pipefail

PIN=6f9479c3d55f847c1b3769f28ceb99227f9858cf
ROOT=$(cd "$(dirname "$0")" && pwd)
WORK=${1:-${XDG_CACHE_HOME:-$HOME/.cache}/elan-press-build}

mkdir -p "$WORK"
if [[ ! -d $WORK/libfprint/.git ]]; then
  git clone https://gitlab.freedesktop.org/libfprint/libfprint.git "$WORK/libfprint"
fi
git -C "$WORK/libfprint" fetch --depth 1 origin "$PIN"
git -C "$WORK/libfprint" checkout --detach --force "$PIN"
git -C "$WORK/libfprint" clean -fd
git -C "$WORK/libfprint" apply --check "$ROOT/elanpress.patch"
git -C "$WORK/libfprint" apply "$ROOT/elanpress.patch"

rm -rf "$WORK/build"
meson setup "$WORK/build" "$WORK/libfprint" \
  --prefix=/usr --libdir=lib \
  -Ddrivers=all -Ddoc=false -Dintrospection=false \
  -Dinstalled-tests=false -Dgtk-examples=false
ninja -C "$WORK/build"

SO="$WORK/build/libfprint/libfprint-2.so.2.0.0"
strings "$SO" | grep -q "partial press covers"
echo "Built $SO"
echo "Install with: sudo $ROOT/install.sh $SO"

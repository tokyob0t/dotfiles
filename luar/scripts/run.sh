#!/usr/bin/env bash

sh scripts/build.sh

export GSETTINGS_SCHEMA_DIR="$(pwd)/dist/share/glib-2.0/schemas"
export GBM_BACKEND=nvidia-drm
export GDK_BACKEND=wayland,x11
export GSK_RENDERER=vulkan
export NO_AT_BRIDGE=1

./dist/bin/* "${@}"

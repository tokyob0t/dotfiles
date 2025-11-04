#!/usr/bin/env bash

meson setup --prefix "$(pwd)/dist" build --wipe

meson install -C build

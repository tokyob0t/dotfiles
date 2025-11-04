#!/usr/bin/env bash

meson setup --prefix=/usr/local build --wipe

meson install -C build

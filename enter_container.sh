#!/bin/bash
podman run -v .:/build:Z -it crashpad-builder

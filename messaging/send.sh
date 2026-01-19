#!/bin/bash

# Wrapper para ejecutar send_notification.py sin warnings de hashlib
# Los warnings de blake2 son del entorno Python y no afectan la funcionalidad

cd "$(dirname "$0")"

# Ejecutar y filtrar warnings de blake2 (del entorno Python, no afectan funcionalidad)
uv run python send_notification.py "$@" 2>&1 | sed '/ERROR:root:code for hash/,+10d' | sed '/blake2/d' | sed '/hashlib\.py/d' | sed '/^[[:space:]]*$/d'

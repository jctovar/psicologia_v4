#!/bin/bash

# Archivo de ejemplo para configuración de credenciales
# Copia este archivo como 'config.sh' y completa tus credenciales:
#
#   cp config.example.sh config.sh
#   nano config.sh  # Editar y agregar tus credenciales
#
# IMPORTANTE: config.sh está en .gitignore y NO se subirá a Git

# Server Key de Firebase
# Obtener en: Firebase Console → Project Settings → Cloud Messaging → Server key
export FCM_SERVER_KEY="YOUR_FIREBASE_SERVER_KEY"

# Device Token FCM
# Obtener ejecutando: flutter logs | grep "FCM Token"
export FCM_DEVICE_TOKEN="YOUR_DEVICE_FCM_TOKEN"

# Configuración opcional
export FCM_PROJECT_ID="app-de-psicologia-suayed"
export FCM_NOTIFICATION_DELAY=5  # Segundos entre notificaciones en pruebas

# Validación (no modificar)
if [ "$FCM_SERVER_KEY" = "YOUR_FIREBASE_SERVER_KEY" ]; then
    echo "⚠️  Advertencia: FCM_SERVER_KEY no está configurado"
fi

if [ "$FCM_DEVICE_TOKEN" = "YOUR_DEVICE_FCM_TOKEN" ]; then
    echo "⚠️  Advertencia: FCM_DEVICE_TOKEN no está configurado"
fi

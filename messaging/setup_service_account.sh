#!/bin/bash

# Script para detectar y mover automáticamente el Service Account Key descargado
# Autor: Claude Code
# Fecha: 2026-01-18

DOWNLOADS_DIR="$HOME/Downloads"
TARGET_DIR="/Users/jctovar/Desarrollo/psicologia_v4/messaging"
TARGET_FILE="$TARGET_DIR/service-account.json"

echo "🔍 Buscando Service Account Key en $DOWNLOADS_DIR..."
echo ""

# Buscar archivos que coincidan con el patrón de Firebase Admin SDK
FIREBASE_FILES=($(ls -t "$DOWNLOADS_DIR"/app-de-psicologia-suayed-firebase-adminsdk-*.json 2>/dev/null))

if [ ${#FIREBASE_FILES[@]} -eq 0 ]; then
    echo "❌ No se encontró ningún archivo de Service Account en Downloads"
    echo ""
    echo "Por favor descarga el archivo desde Firebase Console:"
    echo "  1. Ir a: https://console.firebase.google.com/project/app-de-psicologia-suayed/settings/serviceaccounts/adminsdk"
    echo "  2. Click en 'Generate new private key'"
    echo "  3. Click en 'Generate key'"
    echo "  4. Ejecuta este script nuevamente"
    exit 1
fi

# Usar el archivo más reciente
LATEST_FILE="${FIREBASE_FILES[0]}"

echo "✅ Archivo encontrado:"
echo "   📄 $LATEST_FILE"
echo ""

# Verificar que es un Service Account válido
if grep -q '"type": "service_account"' "$LATEST_FILE"; then
    echo "✅ Archivo verificado como Service Account válido"
else
    echo "❌ El archivo no parece ser un Service Account válido"
    exit 1
fi

# Respaldar archivo existente si existe
if [ -f "$TARGET_FILE" ]; then
    BACKUP_FILE="$TARGET_DIR/service-account.backup.$(date +%Y%m%d_%H%M%S).json"
    echo "📦 Respaldando archivo existente a:"
    echo "   $BACKUP_FILE"
    mv "$TARGET_FILE" "$BACKUP_FILE"
fi

# Copiar archivo nuevo
echo "📥 Copiando Service Account Key al proyecto..."
cp "$LATEST_FILE" "$TARGET_FILE"

echo ""
echo "✅ Service Account Key configurado exitosamente!"
echo ""
echo "📍 Ubicación final:"
echo "   $TARGET_FILE"
echo ""
echo "🎯 Ahora puedes ejecutar:"
echo "   cd /Users/jctovar/Desarrollo/psicologia_v4/messaging"
echo "   uv run python send_notification.py --title 'Prueba' --body 'Sistema funcionando'"
echo ""

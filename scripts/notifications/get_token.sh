#!/bin/bash

# Script para obtener el token FCM del dispositivo conectado
# Ejecuta la app en segundo plano y captura el token de los logs

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🔑 Obtener Token FCM del Dispositivo${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verificar que estamos en un proyecto Flutter
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: No se encontró pubspec.yaml${NC}"
    echo -e "${YELLOW}   Ejecuta este script desde el directorio raíz del proyecto Flutter${NC}"
    exit 1
fi

# Verificar si hay dispositivos conectados
DEVICES=$(flutter devices 2>/dev/null)
if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ No hay dispositivos conectados${NC}"
    echo -e "${YELLOW}   Conecta un dispositivo o inicia un emulador${NC}"
    exit 1
fi

echo -e "${YELLOW}📱 Dispositivos disponibles:${NC}"
flutter devices
echo ""

echo -e "${YELLOW}⚙️  Buscando token FCM en los logs...${NC}"
echo -e "${BLUE}   (Esto puede tomar unos segundos)${NC}"
echo ""

# Crear archivo temporal para logs
TEMP_LOG=$(mktemp)

# Ejecutar flutter logs en segundo plano y buscar el token
timeout 30s flutter logs 2>&1 | tee "$TEMP_LOG" | grep -m 1 "FCM Token" &
LOG_PID=$!

# Esperar a que aparezca el token o timeout
wait $LOG_PID 2>/dev/null

# Buscar el token en el archivo de log
TOKEN=$(grep "FCM Token:" "$TEMP_LOG" | sed -n 's/.*FCM Token: \(.*\)/\1/p' | head -1)

# Limpiar archivo temporal
rm -f "$TEMP_LOG"

if [ -n "$TOKEN" ]; then
    echo ""
    echo -e "${GREEN}✅ Token FCM encontrado:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${TOKEN}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}💡 Copia este token y úsalo en los scripts de notificaciones${NC}"
    echo ""

    # Ofrecer guardar en config.sh
    if [ -f "scripts/notifications/config.sh" ]; then
        read -p "¿Actualizar config.sh con este token? (s/n): " UPDATE_CONFIG
        if [ "$UPDATE_CONFIG" = "s" ] || [ "$UPDATE_CONFIG" = "S" ]; then
            # Escapar caracteres especiales para sed
            ESCAPED_TOKEN=$(echo "$TOKEN" | sed 's/[\/&]/\\&/g')
            sed -i.bak "s/export FCM_DEVICE_TOKEN=.*/export FCM_DEVICE_TOKEN=\"$ESCAPED_TOKEN\"/" scripts/notifications/config.sh
            echo -e "${GREEN}✅ config.sh actualizado${NC}"
            rm -f scripts/notifications/config.sh.bak
        fi
    else
        echo -e "${YELLOW}💡 Tip: Crea config.sh para guardar tus credenciales:${NC}"
        echo -e "${BLUE}   cd scripts/notifications${NC}"
        echo -e "${BLUE}   cp config.example.sh config.sh${NC}"
        echo -e "${BLUE}   # Luego edita config.sh con tus valores${NC}"
    fi
else
    echo ""
    echo -e "${RED}❌ No se pudo obtener el token FCM${NC}"
    echo ""
    echo -e "${YELLOW}Posibles causas:${NC}"
    echo -e "  1. La app no está ejecutándose en el dispositivo"
    echo -e "  2. Firebase no está inicializado correctamente"
    echo -e "  3. No hay permisos de notificaciones"
    echo ""
    echo -e "${YELLOW}Soluciones:${NC}"
    echo -e "  1. Ejecuta manualmente: ${BLUE}flutter run${NC}"
    echo -e "  2. Una vez que la app esté corriendo, ejecuta:"
    echo -e "     ${BLUE}flutter logs | grep 'FCM Token'${NC}"
    echo -e "  3. El token aparecerá en los logs al iniciar la app"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

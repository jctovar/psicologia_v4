#!/bin/bash

# Script para enviar notificación push a un tópico (posts o alerts)
# Uso: ./send_to_topic.sh [posts|alerts]

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🔔 Envío de Notificación a Tópico - SUAyED${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Configuración - REEMPLAZAR CON TU VALOR
SERVER_KEY="YOUR_FIREBASE_SERVER_KEY"

# Validar que se haya configurado la credencial
if [ "$SERVER_KEY" = "YOUR_FIREBASE_SERVER_KEY" ]; then
    echo -e "${RED}❌ Error: Debes configurar el SERVER_KEY${NC}"
    echo -e "${YELLOW}   Edita el archivo y reemplaza SERVER_KEY con tu clave de Firebase${NC}"
    echo -e "${YELLOW}   Obtén la clave en: Firebase Console → Project Settings → Cloud Messaging${NC}"
    exit 1
fi

# Determinar tópico
if [ -z "$1" ]; then
    echo -e "${BLUE}Selecciona el tópico:${NC}"
    echo ""
    echo "  1) posts - Publicaciones y noticias"
    echo "  2) alerts - Alertas y avisos importantes"
    echo ""
    read -p "Opción (1-2): " option

    case $option in
        1)
            TOPIC="posts"
            ;;
        2)
            TOPIC="alerts"
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            exit 1
            ;;
    esac
else
    TOPIC="$1"
fi

# Validar tópico
if [ "$TOPIC" != "posts" ] && [ "$TOPIC" != "alerts" ]; then
    echo -e "${RED}❌ Tópico inválido: $TOPIC${NC}"
    echo -e "${YELLOW}   Usa: posts o alerts${NC}"
    exit 1
fi

# Timestamp actual
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Contenido según tópico
if [ "$TOPIC" = "posts" ]; then
    TITLE="📰 Nueva publicación disponible"
    BODY="Revisa el último artículo del portal SUAyED de Psicología"
    DATA='{
        "type": "post",
        "category": "noticias",
        "timestamp": "'"$TIMESTAMP"'"
    }'
else
    TITLE="⚠️ Aviso importante"
    BODY="Mantenimiento programado el domingo 20 de enero de 2025"
    DATA='{
        "type": "alert",
        "priority": "high",
        "scheduled_date": "2025-01-20",
        "timestamp": "'"$TIMESTAMP"'"
    }'
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📤 Enviando notificación al tópico...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Tópico: ${GREEN}$TOPIC${NC}"
echo -e "  Título: ${GREEN}$TITLE${NC}"
echo -e "  Mensaje: $BODY"
echo ""

# Enviar notificación
RESPONSE=$(curl -s -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/'"$TOPIC"'",
    "notification": {
      "title": "'"$TITLE"'",
      "body": "'"$BODY"'",
      "sound": "default"
    },
    "data": '"$DATA"',
    "priority": "high",
    "android": {
      "priority": "high",
      "notification": {
        "sound": "default",
        "color": "#d81b60",
        "tag": "'"$TOPIC"'"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1
        }
      }
    }
  }')

# Verificar respuesta
if echo "$RESPONSE" | grep -q "message_id"; then
    echo -e "${GREEN}✅ Notificación enviada correctamente al tópico: $TOPIC${NC}"
    echo ""
    echo -e "${BLUE}Respuesta de Firebase:${NC}"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}❌ Error al enviar notificación${NC}"
    echo ""
    echo -e "${RED}Respuesta de Firebase:${NC}"
    echo "$RESPONSE"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}💡 Todos los dispositivos suscritos a '$TOPIC' recibirán esta notificación${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

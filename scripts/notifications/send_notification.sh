#!/bin/bash

# Script para enviar notificación push de prueba a un dispositivo específico
# Uso: ./send_notification.sh

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🔔 Envío de Notificación Push - SUAyED Psicología${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Configuración - REEMPLAZAR CON TUS VALORES
SERVER_KEY="YOUR_FIREBASE_SERVER_KEY"
DEVICE_TOKEN="YOUR_DEVICE_FCM_TOKEN"

# Validar que se hayan configurado las credenciales
if [ "$SERVER_KEY" = "YOUR_FIREBASE_SERVER_KEY" ]; then
    echo -e "${RED}❌ Error: Debes configurar el SERVER_KEY${NC}"
    echo -e "${YELLOW}   Edita el archivo y reemplaza SERVER_KEY con tu clave de Firebase${NC}"
    echo -e "${YELLOW}   Obtén la clave en: Firebase Console → Project Settings → Cloud Messaging${NC}"
    exit 1
fi

if [ "$DEVICE_TOKEN" = "YOUR_DEVICE_FCM_TOKEN" ]; then
    echo -e "${RED}❌ Error: Debes configurar el DEVICE_TOKEN${NC}"
    echo -e "${YELLOW}   Edita el archivo y reemplaza DEVICE_TOKEN con el token de tu dispositivo${NC}"
    echo -e "${YELLOW}   Obtén el token ejecutando: flutter logs | grep 'FCM Token'${NC}"
    exit 1
fi

# Timestamp actual
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Opciones de notificación
echo -e "${BLUE}Selecciona el tipo de notificación a enviar:${NC}"
echo ""
echo "  1) 📰 Post nuevo"
echo "  2) 📅 Evento de calendario"
echo "  3) ⚠️  Alerta importante"
echo "  4) 👨‍🏫 Actualización de profesor"
echo "  5) ⚙️  Notificación de sistema"
echo "  6) ✏️  Personalizada"
echo ""
read -p "Opción (1-6): " option

case $option in
    1)
        TITLE="📰 Nueva publicación"
        BODY="Se ha publicado nuevo contenido en el portal SUAyED"
        TYPE="post"
        DATA='{
            "type": "post",
            "post_id": "12345",
            "category": "noticias",
            "timestamp": "'"$TIMESTAMP"'"
        }'
        ;;
    2)
        TITLE="📅 Recordatorio de evento"
        BODY="Los exámenes finales comienzan el próximo lunes"
        TYPE="calendar"
        DATA='{
            "type": "calendar_event",
            "event_id": "exam_final_2025_1",
            "event_type": "Examenes",
            "start_date": "2025-01-20"
        }'
        ;;
    3)
        TITLE="⚠️ ALERTA IMPORTANTE"
        BODY="Cambio en el calendario escolar - Revisa inmediatamente"
        TYPE="alert"
        DATA='{
            "type": "alert",
            "priority": "urgent",
            "action": "open_calendar"
        }'
        ;;
    4)
        TITLE="👨‍🏫 Actualización de profesores"
        BODY="Se ha actualizado la información del profesor Juan Pérez"
        TYPE="teacher"
        DATA='{
            "type": "teacher_update",
            "teacher_id": "12345",
            "area": "Psicología Clínica"
        }'
        ;;
    5)
        TITLE="⚙️ Actualización disponible"
        BODY="Nueva versión de la app disponible en la tienda"
        TYPE="system"
        DATA='{
            "type": "app_update",
            "version": "0.9.31",
            "required": "false"
        }'
        ;;
    6)
        echo ""
        read -p "Título: " TITLE
        read -p "Mensaje: " BODY
        TYPE="custom"
        DATA='{
            "type": "custom",
            "timestamp": "'"$TIMESTAMP"'"
        }'
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📤 Enviando notificación...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Título: ${GREEN}$TITLE${NC}"
echo -e "  Mensaje: $BODY"
echo -e "  Tipo: $TYPE"
echo ""

# Enviar notificación
RESPONSE=$(curl -s -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "'"$DEVICE_TOKEN"'",
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
        "color": "#d81b60"
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
if echo "$RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Notificación enviada correctamente${NC}"
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

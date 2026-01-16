# Guía de Pruebas de Notificaciones Push

Este documento proporciona instrucciones completas para probar las notificaciones push en la aplicación SUAyED de Psicología.

## 📋 Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Obtener Token FCM](#obtener-token-fcm)
3. [Métodos de Prueba](#métodos-de-prueba)
4. [Casos de Prueba](#casos-de-prueba)
5. [Payloads de Ejemplo](#payloads-de-ejemplo)
6. [Scripts de Automatización](#scripts-de-automatización)
7. [Troubleshooting](#troubleshooting)

---

## Requisitos Previos

### Configuración Necesaria

- [ ] Firebase Project configurado: `app-de-psicologia-suayed`
- [ ] Firebase Messaging habilitado en el proyecto
- [ ] Aplicación compilada y ejecutándose en dispositivo real o emulador
- [ ] Permisos de notificación otorgados por el usuario
- [ ] Conexión a internet activa

### Archivos de Configuración

| Plataforma | Archivo | Ubicación |
|------------|---------|-----------|
| Android | `google-services.json` | `android/app/` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |
| macOS | `GoogleService-Info.plist` | `macos/Runner/` |

---

## Obtener Token FCM

### Método 1: Desde los Logs de la Aplicación

1. **Ejecutar la aplicación en modo debug:**
   ```bash
   flutter run
   ```

2. **Buscar el token en los logs:**
   ```bash
   flutter logs | grep "FCM Token"
   ```

3. **Salida esperada:**
   ```
   🔑 FCM Token: dXXXXXXXXXX...XXXXXX
   💡 Use this token for testing push notifications
   ```

### Método 2: Desde la Consola de Flutter

1. Ejecutar la app
2. Abrir la consola de Flutter DevTools
3. Buscar en la pestaña "Logging" el mensaje con el token FCM

### Método 3: Programáticamente (Temporal)

Si necesitas mostrar el token en la UI temporalmente:

```dart
// Agregar temporalmente en HomeScreen o cualquier pantalla
import 'package:firebase_messaging/firebase_messaging.dart';

// En el build method:
FutureBuilder<String?>(
  future: FirebaseMessaging.instance.getToken(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return SelectableText('Token: ${snapshot.data}');
    }
    return const SizedBox.shrink();
  },
)
```

---

## Métodos de Prueba

### 1. Consola de Firebase (Recomendado para Pruebas Rápidas)

**Pasos:**

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto: `app-de-psicologia-suayed`
3. Navegar a **Engage** → **Cloud Messaging**
4. Hacer clic en **Send your first message** o **New campaign**
5. Completar el formulario:
   - **Notification title**: Título de prueba
   - **Notification text**: Cuerpo del mensaje
   - **Notification image** (opcional): URL de imagen
6. Hacer clic en **Next**
7. En **Target**, seleccionar:
   - **User segment** → **All users** (o seleccionar tópico específico)
   - O seleccionar **Single device** y pegar el token FCM
8. Hacer clic en **Next** → **Review** → **Publish**

### 2. Firebase Cloud Messaging API (HTTP v1)

**Obtener Access Token:**

```bash
# Instalar Firebase CLI si no está instalado
npm install -g firebase-tools

# Login
firebase login

# Obtener access token
firebase login:ci
```

**Endpoint:**
```
POST https://fcm.googleapis.com/v1/projects/app-de-psicologia-suayed/messages:send
```

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json
```

**Body de ejemplo:**
```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Nueva publicación",
      "body": "Se ha publicado contenido nuevo en el portal"
    },
    "data": {
      "type": "post",
      "id": "12345",
      "action": "open_detail"
    },
    "android": {
      "priority": "high",
      "notification": {
        "sound": "default",
        "color": "#d81b60",
        "icon": "ic_notification"
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
  }
}
```

### 3. Legacy Server Key (API Antigua - Más Simple)

**Obtener Server Key:**
1. Firebase Console → Project Settings → Cloud Messaging
2. Copiar **Server key** (en la sección "Cloud Messaging API (Legacy)")

**Endpoint:**
```
POST https://fcm.googleapis.com/fcm/send
```

**Headers:**
```
Authorization: key=YOUR_SERVER_KEY
Content-Type: application/json
```

**Body:**
```json
{
  "to": "DEVICE_FCM_TOKEN",
  "notification": {
    "title": "Título de prueba",
    "body": "Cuerpo del mensaje",
    "sound": "default"
  },
  "data": {
    "type": "alert",
    "message_id": "test_123"
  },
  "priority": "high"
}
```

### 4. Envío a Tópicos

La aplicación está suscrita a los siguientes tópicos:
- `posts` - Publicaciones nuevas
- `alerts` - Alertas importantes

**Payload para tópico:**
```json
{
  "to": "/topics/posts",
  "notification": {
    "title": "Nueva publicación",
    "body": "Se ha publicado nuevo contenido en Psicología SUAyED"
  },
  "data": {
    "type": "post",
    "post_id": "12345"
  }
}
```

---

## Casos de Prueba

### Caso 1: Notificación Simple
**Objetivo:** Verificar que se recibe y muestra una notificación básica

**Estados a probar:**
- [ ] App en primer plano (foreground)
- [ ] App en segundo plano (background)
- [ ] App cerrada (terminated)

**Payload:**
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "Prueba simple",
    "body": "Esta es una notificación de prueba"
  }
}
```

**Comportamiento esperado:**
- **Foreground**: SnackBar con título y botón "Ver"
- **Background**: Notificación del sistema
- **Terminated**: Notificación del sistema, al tocar abre la app

---

### Caso 2: Notificación con Datos Personalizados
**Objetivo:** Verificar que los datos personalizados se guardan correctamente

**Payload:**
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "Evento importante",
    "body": "Revisa el nuevo evento del calendario"
  },
  "data": {
    "type": "event",
    "event_id": "ev_2025_01",
    "event_name": "Exámenes finales",
    "priority": "high"
  }
}
```

**Verificación:**
1. Ir a la pantalla de Notificaciones
2. Verificar que aparece la notificación
3. Verificar que el badge de "no leídas" aumenta
4. Tocar la notificación y verificar que se marca como leída

---

### Caso 3: Notificación con Imagen
**Objetivo:** Probar notificaciones con contenido multimedia

**Payload:**
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "Nueva imagen",
    "body": "Mira esta nueva publicación",
    "image": "https://picsum.photos/600/400"
  },
  "data": {
    "type": "post",
    "has_image": "true"
  }
}
```

---

### Caso 4: Notificación Urgente (Alta Prioridad)
**Objetivo:** Verificar que notificaciones urgentes llegan inmediatamente

**Payload:**
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "⚠️ ALERTA IMPORTANTE",
    "body": "Cambio en el calendario escolar - Revisa inmediatamente"
  },
  "data": {
    "type": "alert",
    "priority": "urgent",
    "action": "open_calendar"
  },
  "priority": "high",
  "android": {
    "priority": "high",
    "notification": {
      "sound": "default",
      "channel_id": "high_importance_channel"
    }
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    },
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1,
        "alert": {
          "title": "⚠️ ALERTA IMPORTANTE",
          "body": "Cambio en el calendario escolar"
        }
      }
    }
  }
}
```

---

### Caso 5: Notificación a Tópico
**Objetivo:** Verificar suscripción a tópicos

**Payload (posts):**
```json
{
  "to": "/topics/posts",
  "notification": {
    "title": "Nueva publicación disponible",
    "body": "Revisa el último artículo del portal SUAyED"
  },
  "data": {
    "type": "post",
    "category": "noticias"
  }
}
```

**Payload (alerts):**
```json
{
  "to": "/topics/alerts",
  "notification": {
    "title": "Aviso del sistema",
    "body": "Mantenimiento programado el domingo 20 de enero"
  },
  "data": {
    "type": "maintenance",
    "scheduled_date": "2025-01-20"
  }
}
```

---

### Caso 6: Notificación Silenciosa (Solo Datos)
**Objetivo:** Enviar datos sin mostrar notificación

**Payload:**
```json
{
  "to": "DEVICE_TOKEN",
  "data": {
    "type": "sync",
    "action": "update_calendar",
    "silent": "true"
  },
  "priority": "high"
}
```

**Nota:** Solo llega cuando la app está en foreground o background.

---

### Caso 7: Múltiples Notificaciones
**Objetivo:** Probar acumulación y badge counter

**Pasos:**
1. Enviar 5 notificaciones diferentes con delay de 5 segundos
2. Verificar que el badge muestra el número correcto
3. Ir a la pantalla de notificaciones
4. Verificar que todas aparecen ordenadas por fecha
5. Marcar todas como leídas
6. Verificar que el badge desaparece

---

## Payloads de Ejemplo

### Plantillas Listas para Usar

#### Notificación de Post Nuevo
```json
{
  "to": "/topics/posts",
  "notification": {
    "title": "📰 Nueva publicación",
    "body": "Descubre las últimas noticias de Psicología SUAyED"
  },
  "data": {
    "type": "post",
    "post_id": "987654",
    "category": "noticias",
    "timestamp": "2025-01-15T10:30:00Z"
  },
  "android": {
    "priority": "high",
    "notification": {
      "color": "#d81b60",
      "sound": "default",
      "tag": "posts"
    }
  }
}
```

#### Notificación de Evento del Calendario
```json
{
  "to": "/topics/alerts",
  "notification": {
    "title": "📅 Recordatorio de evento",
    "body": "Los exámenes finales comienzan el próximo lunes"
  },
  "data": {
    "type": "calendar_event",
    "event_id": "exam_final_2025_1",
    "event_type": "Examenes",
    "start_date": "2025-01-20"
  }
}
```

#### Notificación de Profesor
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "👨‍🏫 Actualización de profesores",
    "body": "Se ha actualizado la información del profesor Juan Pérez"
  },
  "data": {
    "type": "teacher_update",
    "teacher_id": "12345",
    "area": "Psicología Clínica"
  }
}
```

#### Notificación de Sistema
```json
{
  "to": "/topics/alerts",
  "notification": {
    "title": "⚙️ Actualización disponible",
    "body": "Nueva versión de la app disponible en la tienda"
  },
  "data": {
    "type": "app_update",
    "version": "0.9.31",
    "required": "false",
    "update_url": "https://play.google.com/store/apps/..."
  }
}
```

---

## Scripts de Automatización

### Script cURL - Notificación Simple

Guardar como `send_notification.sh`:

```bash
#!/bin/bash

# Configuración
SERVER_KEY="YOUR_FIREBASE_SERVER_KEY"
DEVICE_TOKEN="YOUR_DEVICE_FCM_TOKEN"

# Payload
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "'"$DEVICE_TOKEN"'",
    "notification": {
      "title": "Prueba desde script",
      "body": "Esta notificación fue enviada desde un script bash"
    },
    "data": {
      "type": "test",
      "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
    },
    "priority": "high"
  }'

echo -e "\n✅ Notificación enviada"
```

**Uso:**
```bash
chmod +x send_notification.sh
./send_notification.sh
```

---

### Script cURL - Notificación a Tópico

Guardar como `send_to_topic.sh`:

```bash
#!/bin/bash

SERVER_KEY="YOUR_FIREBASE_SERVER_KEY"
TOPIC="${1:-posts}"  # Default: posts

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/'"$TOPIC"'",
    "notification": {
      "title": "🔔 Notificación al tópico '"$TOPIC"'",
      "body": "Este mensaje fue enviado a todos los suscriptores del tópico '"$TOPIC"'"
    },
    "data": {
      "type": "topic_message",
      "topic": "'"$TOPIC"'",
      "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
    }
  }'

echo -e "\n✅ Notificación enviada al tópico: $TOPIC"
```

**Uso:**
```bash
chmod +x send_to_topic.sh
./send_to_topic.sh posts
./send_to_topic.sh alerts
```

---

### Script Python - Envío Masivo de Pruebas

Guardar como `test_notifications.py`:

```python
#!/usr/bin/env python3
import requests
import json
import time
from datetime import datetime

# Configuración
SERVER_KEY = "YOUR_FIREBASE_SERVER_KEY"
DEVICE_TOKEN = "YOUR_DEVICE_FCM_TOKEN"
FCM_URL = "https://fcm.googleapis.com/fcm/send"

headers = {
    "Authorization": f"key={SERVER_KEY}",
    "Content-Type": "application/json"
}

# Casos de prueba
test_cases = [
    {
        "name": "Post nuevo",
        "payload": {
            "to": DEVICE_TOKEN,
            "notification": {
                "title": "📰 Nueva publicación",
                "body": "Contenido nuevo disponible"
            },
            "data": {"type": "post", "test": "true"}
        }
    },
    {
        "name": "Evento calendario",
        "payload": {
            "to": DEVICE_TOKEN,
            "notification": {
                "title": "📅 Recordatorio",
                "body": "Evento del calendario próximo"
            },
            "data": {"type": "calendar", "test": "true"}
        }
    },
    {
        "name": "Alerta importante",
        "payload": {
            "to": DEVICE_TOKEN,
            "notification": {
                "title": "⚠️ Alerta",
                "body": "Mensaje importante del sistema"
            },
            "data": {"type": "alert", "priority": "high", "test": "true"},
            "priority": "high"
        }
    }
]

def send_notification(payload, name):
    try:
        response = requests.post(FCM_URL, headers=headers, json=payload)
        if response.status_code == 200:
            print(f"✅ {name}: Enviada correctamente")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ {name}: Error {response.status_code}")
            print(f"   {response.text}")
    except Exception as e:
        print(f"❌ {name}: Excepción - {str(e)}")

if __name__ == "__main__":
    print("🚀 Iniciando pruebas de notificaciones...")
    print(f"⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    for i, test in enumerate(test_cases, 1):
        print(f"[{i}/{len(test_cases)}] Enviando: {test['name']}")
        send_notification(test['payload'], test['name'])

        if i < len(test_cases):
            print("⏳ Esperando 5 segundos...\n")
            time.sleep(5)

    print("\n✅ Pruebas completadas")
```

**Uso:**
```bash
chmod +x test_notifications.py
python3 test_notifications.py
```

---

## Troubleshooting

### Problema 1: No se recibe el token FCM

**Síntomas:**
- Logs muestran error al obtener token
- Token es null

**Soluciones:**
1. Verificar que `google-services.json` / `GoogleService-Info.plist` están correctamente ubicados
2. Verificar que Firebase está inicializado en `main.dart`
3. En iOS, verificar que las capabilities de Push Notifications están habilitadas
4. Limpiar build: `flutter clean && flutter pub get`
5. Reinstalar la app completamente

---

### Problema 2: Las notificaciones no llegan

**Síntomas:**
- Script envía notificación pero no aparece en el dispositivo

**Verificaciones:**

1. **Token FCM válido:**
   ```bash
   # El token debe tener ~150+ caracteres
   echo "Token length: ${#TOKEN}"
   ```

2. **App tiene permisos:**
   - Android: Settings → Apps → SUAyED → Notifications → Permitido
   - iOS: Settings → SUAyED → Notifications → Permitido

3. **Conexión a internet:**
   - Verificar que el dispositivo tiene internet
   - Probar con WiFi y datos móviles

4. **Firebase Project ID correcto:**
   - Verificar en Firebase Console que el proyecto es `app-de-psicologia-suayed`

5. **Server Key correcto:**
   - Verificar que el Server Key es del proyecto correcto

---

### Problema 3: Notificaciones solo llegan en foreground

**Síntomas:**
- En foreground funciona (SnackBar)
- En background/terminated no llega

**Soluciones Android:**

1. **Deshabilitar optimización de batería:**
   - Settings → Battery → Battery optimization
   - Buscar SUAyED → Don't optimize

2. **Verificar prioridad:**
   ```json
   {
     "priority": "high",
     "android": {
       "priority": "high"
     }
   }
   ```

**Soluciones iOS:**

1. **Verificar capabilities:**
   - Xcode → Project → Signing & Capabilities
   - Agregar Push Notifications
   - Agregar Background Modes → Remote notifications

2. **Verificar APNs certificate:**
   - Firebase Console → Project Settings → Cloud Messaging
   - Verificar que APNs está configurado

---

### Problema 4: Notificaciones duplicadas

**Síntomas:**
- Aparece la misma notificación múltiples veces

**Soluciones:**

1. **Agregar tag en Android:**
   ```json
   {
     "android": {
       "notification": {
         "tag": "unique_tag_id"
       }
     }
   }
   ```

2. **Verificar lógica de guardado:**
   - Revisar `NotificationProvider.addNotification()`
   - Debe evitar duplicados por `id`

---

### Problema 5: Badge counter incorrecto

**Síntomas:**
- El número de notificaciones no leídas no coincide

**Verificaciones:**

1. **Revisar logs:**
   ```bash
   flutter logs | grep "notification"
   ```

2. **Limpiar storage local:**
   ```dart
   // Temporal - en NotificationProvider
   await _db.collection('notifications').delete();
   ```

3. **Verificar método `unreadCount`:**
   - Debe contar solo `isRead: false`

---

### Problema 6: Notificaciones no se guardan

**Síntomas:**
- Notificación llega pero no aparece en la pantalla de notificaciones

**Verificaciones:**

1. **Revisar logs de guardado:**
   ```bash
   flutter logs | grep "saved to storage"
   ```

2. **Verificar permisos de Localstore:**
   - Asegurar que Localstore está inicializado
   - Verificar que no hay errores de escritura

3. **Verificar formato de datos:**
   ```dart
   // En firebase_service.dart - _saveNotificationToStorage
   print('Saving notification: ${notification.toJson()}');
   ```

---

## Checklist de Pruebas Completas

Antes de liberar a producción, verificar:

- [ ] **Foreground**: SnackBar aparece correctamente
- [ ] **Background**: Notificación del sistema aparece
- [ ] **Terminated**: App se abre al tocar notificación
- [ ] **Badge counter**: Actualiza correctamente
- [ ] **Marcar como leída**: Funciona individual y masivo
- [ ] **Eliminar**: Funciona individual y masivo
- [ ] **Tópicos**: Suscripción a `posts` y `alerts` funciona
- [ ] **Datos personalizados**: Se guardan correctamente
- [ ] **Persistencia**: Notificaciones persisten después de cerrar app
- [ ] **Navegación**: Al tocar notificación navega correctamente
- [ ] **iOS**: Funciona en dispositivos iOS
- [ ] **Android**: Funciona en dispositivos Android
- [ ] **Prioridad alta**: Notificaciones urgentes llegan inmediatamente
- [ ] **Analytics**: Eventos de notificación se registran

---

## Recursos Adicionales

### Enlaces Útiles

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [FCM HTTP v1 API Reference](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)

### Comandos Útiles

```bash
# Ver logs en tiempo real
flutter logs

# Filtrar solo notificaciones
flutter logs | grep -i "notification\|fcm\|firebase"

# Ver token FCM
flutter logs | grep "FCM Token"

# Limpiar y reconstruir
flutter clean && flutter pub get && flutter run

# Ver información del dispositivo
flutter devices
```

---

## Notas Finales

- Siempre prueba en dispositivos reales, no solo emuladores
- Las notificaciones en iOS requieren dispositivo físico (no funcionan en simulador)
- Guarda los tokens FCM de tus dispositivos de prueba
- Usa tópicos para enviar a múltiples dispositivos simultáneamente
- Revisa los logs regularmente para detectar problemas temprano

---

**Última actualización:** 2025-01-15
**Versión de la app:** 0.9.30+20260110
**Firebase Project:** app-de-psicologia-suayed

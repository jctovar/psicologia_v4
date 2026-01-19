# Sistema Manual para Envío de Notificaciones Push FCM

Sistema de notificaciones push manual para la aplicación SUAyED Psicología FES Iztacala usando Firebase Cloud Messaging (FCM) HTTP v1 API.

## 📋 Descripción

Herramienta en Python para enviar notificaciones push de forma manual a dispositivos específicos o grupos de usuarios. Útil para:

- Testing de notificaciones durante desarrollo
- Envío de notificaciones administrativas puntuales
- Pruebas de formato y comportamiento de notificaciones
- Debugging de tokens FCM

## 🏗️ Arquitectura

```
messaging/
├── PLAN.md                 # Este archivo
├── README.md               # Documentación de uso
├── pyproject.toml          # Configuración de proyecto UV
├── send_notification.py    # Script principal
├── .env.example            # Template de variables de entorno
├── .env                    # Variables de entorno (gitignored)
├── .gitignore              # Archivos a ignorar
└── service-account.json    # Credenciales Firebase (gitignored)
```

## 🔧 Tecnologías

- **Python 3.12+**: Lenguaje de programación
- **UV**: Gestor de paquetes Python moderno y rápido
- **Firebase Admin SDK**: Para autenticación y envío FCM
- **python-dotenv**: Gestión de variables de entorno
- **requests**: Cliente HTTP para llamadas a FCM API

## 📦 Dependencias

```toml
[project]
dependencies = [
    "firebase-admin>=6.5.0",
    "python-dotenv>=1.0.0",
    "google-auth>=2.35.0",
]
```

## 🔐 Autenticación Firebase

### Paso 1: Obtener Service Account Key

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto: `app-de-psicologia-suayed`
3. Ir a **Project Settings** → **Service Accounts**
4. Click en **Generate New Private Key**
5. Guardar archivo JSON como `service-account.json` en este directorio

### Paso 2: Configurar Variables de Entorno

Crear archivo `.env` basado en `.env.example`:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=app-de-psicologia-suayed
FIREBASE_SERVICE_ACCOUNT=./service-account.json

# FCM Tokens (separados por comas para múltiples dispositivos)
FCM_TOKEN=d3L0Hy_HQxmsm7bsx09R_M:APA91bGukufLhe9Rgi7rxGH1kPEXgWJMPxbWDznKOEGYzJkoYJaPodEhfsl3v0Tq_t_AEkG4fZ6UWTQUwrQd_sFEhjk5gVzs6R1fiC_JvPcOhSeGjJd7lkQ

# Configuración de Notificación por Defecto
DEFAULT_TITLE=Psicología SUAyED
DEFAULT_BODY=Mensaje de prueba desde el sistema manual
DEFAULT_ICON=notification_icon
DEFAULT_SOUND=default
```

## 🚀 Instalación

### 1. Instalar UV (si no está instalado)

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Inicializar proyecto

```bash
cd messaging
uv sync
```

## 📤 Uso

### Enviar Notificación Simple

```bash
uv run python send_notification.py \
  --title "Nuevo Evento" \
  --body "Se ha publicado un nuevo evento académico"
```

### Enviar Notificación con Datos Personalizados

```bash
uv run python send_notification.py \
  --title "Nueva Noticia" \
  --body "Revisa la última noticia en la app" \
  --data '{"type": "post", "id": "12345", "action": "view"}'
```

### Enviar a Token Específico

```bash
uv run python send_notification.py \
  --token "OTRO_TOKEN_FCM_AQUI" \
  --title "Mensaje Personal" \
  --body "Este es un mensaje de prueba"
```

### Enviar con Imagen

```bash
uv run python send_notification.py \
  --title "Evento con Imagen" \
  --body "Mira esta imagen del evento" \
  --image "https://suayed.iztacala.unam.mx/wp-content/uploads/evento.jpg"
```

## 🎯 Funcionalidades del Script

- ✅ Autenticación con Service Account
- ✅ Obtención automática de Access Token
- ✅ Envío a tokens FCM específicos
- ✅ Soporte para notificaciones multicast (múltiples tokens)
- ✅ Payload personalizado con datos adicionales
- ✅ Configuración de título, cuerpo, icono y sonido
- ✅ Soporte para imágenes en notificaciones
- ✅ Logging detallado de éxitos y errores
- ✅ Validación de tokens FCM
- ✅ Manejo de errores robusto

## 📊 Estructura del Payload FCM

```json
{
  "message": {
    "token": "FCM_DEVICE_TOKEN",
    "notification": {
      "title": "Título de la Notificación",
      "body": "Cuerpo del mensaje",
      "image": "https://url-imagen.jpg"
    },
    "data": {
      "type": "post",
      "id": "12345",
      "action": "view",
      "timestamp": "2026-01-18T12:00:00Z"
    },
    "android": {
      "priority": "high",
      "notification": {
        "icon": "notification_icon",
        "sound": "default",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "channel_id": "high_importance_channel"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1,
          "content-available": 1
        }
      }
    }
  }
}
```

## 🧪 Mensajes de Prueba

### Prueba Básica
```bash
uv run python send_notification.py
# Usa valores por defecto del .env
```

### Prueba de Post/Noticia
```bash
uv run python send_notification.py \
  --title "Nueva Publicación" \
  --body "Se publicó un nuevo artículo sobre Psicología Clínica" \
  --data '{"type": "post", "id": "456", "category": "noticias"}'
```

### Prueba de Evento
```bash
uv run python send_notification.py \
  --title "Evento Próximo" \
  --body "Conferencia sobre Neuropsicología - 25 de Enero" \
  --data '{"type": "event", "id": "789", "date": "2026-01-25"}'
```

### Prueba de Calificaciones
```bash
uv run python send_notification.py \
  --title "Calificaciones Disponibles" \
  --body "Ya puedes consultar tus calificaciones del semestre 2025-2" \
  --data '{"type": "grades", "semester": "2025-2"}'
```

## 🔍 Obtener FCM Tokens

### Desde la App Flutter

Los tokens FCM se imprimen en los logs cuando la app inicia. Buscar en logs:

```
[Firebase Messaging] FCM Token: XXXXX...
```

### Programáticamente

Agregar código temporal en `lib/services/firebase_service.dart`:

```dart
static Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  AppLogger.i('FCM Token: $token');
  return token;
}
```

### Desde Firebase Console

1. Ir a **Firebase Console** → **Cloud Messaging**
2. Ver tokens registrados en **Device Groups**
3. Exportar tokens para testing

## ⚠️ Seguridad

### Archivos Sensibles (NUNCA commitear)

- `service-account.json` - Credenciales de Firebase
- `.env` - Variables de entorno con tokens
- `*.log` - Archivos de log

### Buenas Prácticas

1. ✅ Usar `.env` para configuración
2. ✅ Nunca compartir Service Account Keys
3. ✅ Rotar tokens FCM periódicamente
4. ✅ Validar tokens antes de enviar
5. ✅ Usar tópicos FCM para envíos masivos en producción
6. ❌ NO hardcodear credenciales en código
7. ❌ NO commitear archivos sensibles

## 🐛 Debugging

### Token Inválido

```bash
Error: Invalid FCM token format
```
**Solución**: Verificar que el token FCM sea válido y esté completo.

### Access Token Expirado

```bash
Error: 401 Unauthorized
```
**Solución**: Regenerar Access Token. El script lo hace automáticamente.

### Service Account No Encontrado

```bash
Error: Service account file not found
```
**Solución**: Verificar ruta en `.env` y que `service-account.json` exista.

### Notificación No Llega

1. Verificar que la app tenga permisos de notificación
2. Verificar que el token FCM sea actual
3. Revisar logs de FCM en Firebase Console
4. Verificar conectividad de red del dispositivo

## 📈 Siguiente Fase: Sistema Automatizado

Para producción, considerar:

- **Cloud Functions**: Triggers automáticos para eventos
- **Cloud Scheduler**: Notificaciones programadas
- **Pub/Sub**: Cola de mensajes para envíos masivos
- **Firestore**: Almacenar tokens y preferencias de usuario
- **Admin Panel**: UI web para gestión de notificaciones
- **Segmentación**: Envío por grupos, cursos, intereses
- **Analytics**: Tracking de apertura y engagement

## 📚 Referencias

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [Firebase Admin SDK Python](https://firebase.google.com/docs/admin/setup#python)
- [UV Documentation](https://docs.astral.sh/uv/)

## 📝 Notas

- Los tokens FCM pueden cambiar si el usuario reinstala la app
- Las notificaciones en iOS requieren certificados APN configurados
- El límite de FCM es 500 dispositivos por llamada multicast
- Los mensajes data-only no muestran notificación visible automáticamente

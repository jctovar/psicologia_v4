# 🔔 Sistema Manual de Notificaciones FCM

Sistema manual para envío de notificaciones push usando Firebase Cloud Messaging (FCM) para la aplicación SUAyED Psicología FES Iztacala.

## 📋 Descripción

Herramienta en Python para enviar notificaciones push de forma manual a dispositivos específicos o grupos de usuarios. Ideal para:

- ✅ **Testing**: Probar notificaciones durante el desarrollo
- ✅ **Debugging**: Verificar formato y comportamiento de notificaciones
- ✅ **Administrativo**: Enviar notificaciones puntuales a usuarios específicos
- ✅ **QA**: Validar tokens FCM y configuración de Firebase

## 🚀 Inicio Rápido

### 1. Requisitos Previos

- **Python 3.12+** instalado
- **UV** (gestor de paquetes Python) instalado
- Acceso a **Firebase Console** del proyecto
- Archivo **Service Account Key** de Firebase

### 2. Instalar UV

Si aún no tienes UV instalado:

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Verificar instalación
uv --version
```

### 3. Configurar Firebase

#### a) Descargar Service Account Key

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto: **app-de-psicologia-suayed**
3. Ir a **⚙️ Project Settings** → **Service Accounts**
4. Click en **Generate New Private Key**
5. Guardar archivo como `service-account.json` en este directorio (`messaging/`)

#### b) Configurar Variables de Entorno

```bash
# Copiar template de configuración
cp .env.example .env

# Editar .env con tus valores
nano .env
# o
code .env
```

Configurar al menos:
- `FIREBASE_PROJECT_ID`: ID de tu proyecto Firebase
- `FIREBASE_SERVICE_ACCOUNT`: Ruta al archivo service-account.json
- `FCM_TOKEN`: Token FCM del dispositivo de prueba

### 4. Instalar Dependencias

```bash
# Inicializar proyecto e instalar dependencias
uv sync
```

Esto instalará automáticamente:
- `firebase-admin>=6.5.0` - SDK de Firebase Admin
- `python-dotenv>=1.0.1` - Gestión de variables de entorno
- `google-auth>=2.35.0` - Autenticación de Google

## 📤 Uso

### Ejemplos Básicos

#### Envío Simple (usa valores del .env)

```bash
uv run python send_notification.py
```

#### Notificación Personalizada

```bash
uv run python send_notification.py \
  --title "Nueva Publicación" \
  --body "Se ha publicado un nuevo artículo sobre Psicología Clínica"
```

#### Con Token Específico

```bash
uv run python send_notification.py \
  --token "TU_TOKEN_FCM_AQUI" \
  --title "Hola" \
  --body "Este es un mensaje de prueba"
```

#### Con Datos Personalizados (Deep Linking)

```bash
uv run python send_notification.py \
  --title "Nueva Noticia" \
  --body "Revisa la última noticia en la app" \
  --data '{"type":"post","id":"12345","action":"view"}'
```

#### Con Imagen

```bash
uv run python send_notification.py \
  --title "Evento con Imagen" \
  --body "Mira esta imagen del evento" \
  --image "https://suayed.iztacala.unam.mx/wp-content/uploads/evento.jpg"
```

#### Envío Multicast (Múltiples Dispositivos)

```bash
uv run python send_notification.py \
  --tokens "TOKEN1,TOKEN2,TOKEN3" \
  --title "Aviso Importante" \
  --body "Este mensaje es para todos"
```

### Casos de Uso Reales

#### 📰 Notificación de Nueva Publicación

```bash
uv run python send_notification.py \
  --title "Nueva Publicación: Neuropsicología Cognitiva" \
  --body "Descubre los últimos avances en neuropsicología" \
  --data '{"type":"post","id":"456","category":"noticias"}' \
  --image "https://suayed.iztacala.unam.mx/wp-content/uploads/neuropsicologia.jpg"
```

#### 📅 Notificación de Evento Próximo

```bash
uv run python send_notification.py \
  --title "Evento Próximo: Conferencia sobre Psicología Social" \
  --body "25 de Enero, 10:00 AM - Auditorio Principal" \
  --data '{"type":"event","id":"789","date":"2026-01-25","location":"Auditorio"}'
```

#### 📊 Notificación de Calificaciones

```bash
uv run python send_notification.py \
  --title "Calificaciones Disponibles" \
  --body "Ya puedes consultar tus calificaciones del semestre 2025-2" \
  --data '{"type":"grades","semester":"2025-2","action":"view_grades"}'
```

#### ⏰ Recordatorio de Inscripción

```bash
uv run python send_notification.py \
  --title "Recordatorio: Inscripciones Abiertas" \
  --body "Tienes hasta el 31 de Enero para inscribirte" \
  --data '{"type":"reminder","deadline":"2026-01-31","action":"open_calendar"}'
```

#### 🎓 Notificación de Recursos Educativos

```bash
uv run python send_notification.py \
  --title "Nuevos Recursos Disponibles" \
  --body "Se han agregado materiales de estudio para el módulo de Psicopatología" \
  --data '{"type":"resource","module":"psicopatologia","action":"view_resources"}'
```

## 🔍 Obtener Tokens FCM

### Método 1: Desde Logs de la App Flutter

1. Ejecutar la app en modo debug
2. Buscar en logs:
```
[Firebase Messaging] FCM Token: d3L0Hy_HQxmsm7bsx09R_M...
```

### Método 2: Agregar Código Temporal

En `lib/services/firebase_service.dart`:

```dart
static Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  AppLogger.i('FCM Token: $token');
  return token;
}
```

Llamar desde `main.dart` o cualquier pantalla.

### Método 3: Firebase Console

1. Ir a **Firebase Console** → **Cloud Messaging**
2. Ver tokens en **Device Groups** o **Topics**

## 📊 Estructura del Payload

El script genera automáticamente un payload FCM v1 completo:

```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Título",
      "body": "Cuerpo del mensaje",
      "image": "https://url-imagen.jpg"
    },
    "data": {
      "type": "post",
      "id": "12345",
      "timestamp": "2026-01-18T12:00:00",
      "sent_from": "manual_system"
    },
    "android": {
      "priority": "high",
      "notification": {
        "icon": "notification_icon",
        "sound": "default",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "channel_id": "high_importance_channel",
        "color": "#d81b60"
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

## 🔧 Opciones de Línea de Comando

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `--token` | Token FCM destino | `--token "d3L0Hy_HQxm..."` |
| `--tokens` | Múltiples tokens (multicast) | `--tokens "TOKEN1,TOKEN2"` |
| `--title` | Título de notificación | `--title "Nuevo Evento"` |
| `--body` | Cuerpo del mensaje | `--body "Descripción aquí"` |
| `--data` | Datos JSON personalizados | `--data '{"type":"post"}'` |
| `--image` | URL de imagen | `--image "https://..."` |
| `--icon` | Icono Android | `--icon "notification_icon"` |
| `--sound` | Sonido de notificación | `--sound "default"` |

Si no se especifica una opción, se usa el valor del archivo `.env`.

## 📝 Archivo de Configuración (.env)

Variables principales:

```bash
# Firebase
FIREBASE_PROJECT_ID=app-de-psicologia-suayed
FIREBASE_SERVICE_ACCOUNT=./service-account.json

# Token FCM de prueba
FCM_TOKEN=d3L0Hy_HQxmsm7bsx09R_M:APA91b...

# Valores por defecto
DEFAULT_TITLE=Psicología SUAyED
DEFAULT_BODY=Tienes una nueva notificación
DEFAULT_ICON=notification_icon
DEFAULT_SOUND=default
```

Ver `.env.example` para todas las opciones disponibles.

## 📂 Estructura de Archivos

```
messaging/
├── README.md                   # Este archivo
├── PLAN.md                     # Plan técnico detallado
├── pyproject.toml              # Configuración del proyecto UV
├── send_notification.py        # Script principal
├── .env.example                # Template de configuración
├── .env                        # Tu configuración (gitignored)
├── .gitignore                  # Archivos ignorados
├── service-account.json        # Credenciales Firebase (gitignored)
├── notification.log            # Log de ejecuciones (gitignored)
└── uv.lock                     # Lock de dependencias (auto-generado)
```

## 🐛 Troubleshooting

### Error: Service account file not found

**Causa**: El archivo `service-account.json` no existe o la ruta es incorrecta.

**Solución**:
1. Verificar que descargaste el Service Account Key de Firebase Console
2. Verificar que el archivo esté en `messaging/service-account.json`
3. Verificar la ruta en `.env` en la variable `FIREBASE_SERVICE_ACCOUNT`

### Error: Invalid FCM token format

**Causa**: El token FCM es inválido, incompleto o expiró.

**Solución**:
1. Obtener un token FCM actualizado desde la app
2. Verificar que copiaste el token completo (suelen ser muy largos)
3. Verificar que no haya espacios o saltos de línea en el token

### Error: 401 Unauthorized

**Causa**: Problema con las credenciales del Service Account.

**Solución**:
1. Regenerar Service Account Key en Firebase Console
2. Verificar que el proyecto Firebase es correcto
3. Verificar que el Service Account tiene permisos de Cloud Messaging

### Notificación no llega al dispositivo

**Causas posibles**:

1. **Permisos**: Verificar que la app tenga permisos de notificación
2. **Token expirado**: Obtener un token FCM actualizado
3. **Conectividad**: Verificar que el dispositivo tenga conexión a internet
4. **Foreground/Background**: En iOS, las notificaciones se comportan diferente según el estado de la app

**Soluciones**:

```bash
# Verificar que el script se ejecutó sin errores
uv run python send_notification.py --title "Test" --body "Prueba"

# Revisar logs
cat notification.log

# Probar con otro token
uv run python send_notification.py --token "OTRO_TOKEN" --title "Test"
```

### Error: Package dependencies not found

**Causa**: Las dependencias no están instaladas.

**Solución**:
```bash
# Sincronizar dependencias
uv sync

# Reinstalar todo
rm -rf .venv uv.lock
uv sync
```

## 🔒 Seguridad

### ⚠️ Archivos Sensibles (NUNCA commitear)

- ❌ `service-account.json` - Credenciales de Firebase
- ❌ `.env` - Variables de entorno con tokens
- ❌ `*.log` - Archivos de log pueden contener información sensible

### ✅ Buenas Prácticas

1. **Usar `.env`** para toda la configuración sensible
2. **Rotar tokens** FCM periódicamente
3. **Validar tokens** antes de enviar notificaciones masivas
4. **Limitar acceso** al Service Account Key
5. **NO hardcodear** credenciales en el código
6. **Usar tópicos FCM** para envíos masivos en producción (en lugar de tokens individuales)
7. **Revisar logs** regularmente y limpiar información sensible

## 📊 Logs y Monitoreo

### Ver Logs en Tiempo Real

```bash
tail -f notification.log
```

### Buscar Errores en Logs

```bash
grep "ERROR" notification.log
grep "❌" notification.log
```

### Limpiar Logs

```bash
> notification.log  # Vaciar archivo
# o
rm notification.log  # Eliminar archivo (se creará de nuevo)
```

## 🔄 Siguientes Pasos (Producción)

Para un sistema de notificaciones en producción, considerar:

1. **Cloud Functions**: Automatizar envío con triggers
2. **Cloud Scheduler**: Notificaciones programadas
3. **Firestore**: Almacenar tokens y preferencias de usuario
4. **Topics FCM**: Segmentación por grupos (estudiantes, profesores, etc.)
5. **Admin Panel Web**: UI para gestionar notificaciones
6. **Analytics**: Tracking de apertura y engagement
7. **A/B Testing**: Probar diferentes mensajes
8. **Localización**: Soporte multiidioma
9. **Rate Limiting**: Prevenir spam
10. **Unsubscribe**: Permitir opt-out de notificaciones

## 📚 Referencias

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [Firebase Admin SDK Python](https://firebase.google.com/docs/admin/setup#python)
- [UV Documentation](https://docs.astral.sh/uv/)
- [Python dotenv](https://github.com/theskumar/python-dotenv)

## 🤝 Contribuir

Para contribuir al proyecto:

1. Crear branch desde `main`
2. Hacer cambios y probar localmente
3. Asegurar que el código pasa linting: `uv run ruff check .`
4. Formatear código: `uv run black .`
5. Crear pull request con descripción clara

## 📄 Licencia

MIT License - SUAyED Psicología FES Iztacala UNAM

---

**Desarrollado con ❤️ para la comunidad SUAyED**

Para soporte técnico: suayed@iztacala.unam.mx

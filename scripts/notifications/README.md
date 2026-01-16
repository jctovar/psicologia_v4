# Scripts de Prueba de Notificaciones Push

Este directorio contiene scripts para probar las notificaciones push de la aplicación SUAyED Psicología.

## 📁 Archivos

| Archivo | Descripción |
|---------|-------------|
| `send_notification.sh` | Envía notificación a un dispositivo específico |
| `send_to_topic.sh` | Envía notificación a un tópico (posts o alerts) |
| `test_notifications.py` | Suite de pruebas automatizadas con múltiples casos |

## 🚀 Configuración Inicial

### 1. Obtener Server Key de Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto: `app-de-psicologia-suayed`
3. Ir a **Project Settings** (⚙️) → **Cloud Messaging**
4. Copiar el **Server key** (sección "Cloud Messaging API (Legacy)")

### 2. Obtener Token FCM del Dispositivo

**Opción A - Desde los logs:**

```bash
# Terminal 1: Ejecutar la app
flutter run

# Terminal 2: Filtrar logs para encontrar el token
flutter logs | grep "FCM Token"
```

**Opción B - Desde la consola de Flutter:**

1. Ejecutar `flutter run`
2. Buscar en los logs el mensaje:
   ```
   🔑 FCM Token: dXXXXXXXXXXX...XXXXXX
   ```

### 3. Configurar los Scripts

Editar cada script y reemplazar:

```bash
# En send_notification.sh y send_to_topic.sh
SERVER_KEY="TU_SERVER_KEY_AQUI"
DEVICE_TOKEN="TU_DEVICE_TOKEN_AQUI"  # Solo en send_notification.sh
```

```python
# En test_notifications.py
SERVER_KEY = "TU_SERVER_KEY_AQUI"
DEVICE_TOKEN = "TU_DEVICE_TOKEN_AQUI"
```

### 4. Dar Permisos de Ejecución

```bash
chmod +x send_notification.sh
chmod +x send_to_topic.sh
chmod +x test_notifications.py
```

## 📝 Uso de los Scripts

### send_notification.sh - Notificación a Dispositivo Específico

Envía una notificación a un dispositivo específico con opciones predefinidas.

**Uso básico:**

```bash
./send_notification.sh
```

**Opciones disponibles:**

1. 📰 Post nuevo
2. 📅 Evento de calendario
3. ⚠️ Alerta importante
4. 👨‍🏫 Actualización de profesor
5. ⚙️ Notificación de sistema
6. ✏️ Personalizada (tú defines título y mensaje)

**Ejemplo de salida:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔔 Envío de Notificación Push - SUAyED Psicología
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Selecciona el tipo de notificación a enviar:

  1) 📰 Post nuevo
  2) 📅 Evento de calendario
  3) ⚠️ Alerta importante
  ...

Opción (1-6): 1
✅ Notificación enviada correctamente
```

---

### send_to_topic.sh - Notificación a Tópico

Envía una notificación a todos los dispositivos suscritos a un tópico.

**Tópicos disponibles:**

- `posts` - Publicaciones y noticias
- `alerts` - Alertas y avisos importantes

**Uso:**

```bash
# Modo interactivo (te pregunta el tópico)
./send_to_topic.sh

# Especificar tópico directamente
./send_to_topic.sh posts
./send_to_topic.sh alerts
```

**Ejemplo:**

```bash
./send_to_topic.sh posts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔔 Envío de Notificación a Tópico - SUAyED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📤 Enviando notificación al tópico...

  Tópico: posts
  Título: 📰 Nueva publicación disponible
  Mensaje: Revisa el último artículo del portal SUAyED

✅ Notificación enviada correctamente al tópico: posts
```

---

### test_notifications.py - Suite de Pruebas Automatizadas

Ejecuta múltiples casos de prueba automáticamente con delays configurables.

**Casos de prueba incluidos:**

1. 📰 Post nuevo
2. 📅 Evento calendario
3. ⚠️ Alerta importante
4. 👨‍🏫 Actualización profesor
5. ⚙️ Notificación sistema
6. 📚 Recursos educativos
7. 🔔 Notificación simple

**Uso básico:**

```bash
# Ejecutar todos los casos con delay de 5 segundos
python3 test_notifications.py

# Ejecutar con delay personalizado (10 segundos)
python3 test_notifications.py --delay 10

# Ejecutar solo casos específicos
python3 test_notifications.py --cases 1,2,3

# Ejecutar casos específicos con delay personalizado
python3 test_notifications.py --cases 1,3,5 --delay 8
```

**Ejemplo de salida:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔔 Pruebas Automatizadas de Notificaciones Push
  📱 SUAyED Psicología FES Iztacala
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏰ Inicio: 2025-01-15 10:30:00
📦 Casos a ejecutar: 7
⏱️  Delay entre notificaciones: 5s

[1/7] 📰 Post nuevo
  Notificación de publicación nueva
✅ 📰 Post nuevo: Enviada correctamente
   Message ID: 0:1705315800:1234567

⏳ Esperando 5 segundos...

[2/7] 📅 Evento calendario
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 Resumen de Pruebas
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total enviadas:  7
  ✅ Exitosas:      7
  ❌ Fallidas:      0
  📈 Tasa de éxito: 100.0%
```

**Parámetros:**

- `--delay N`: Segundos de espera entre notificaciones (default: 5)
- `--cases 1,2,3`: Ejecutar solo los casos especificados (default: todos)

**Ejemplos:**

```bash
# Solo pruebas críticas (alertas y posts)
python3 test_notifications.py --cases 1,3

# Pruebas rápidas con delay de 2 segundos
python3 test_notifications.py --delay 2

# Prueba completa con delay largo para verificar manualmente
python3 test_notifications.py --delay 15
```

## 🧪 Casos de Prueba Recomendados

### Prueba Básica (5 minutos)

Verificar funcionalidad básica:

```bash
# 1. Enviar notificación simple
./send_notification.sh
# Seleccionar opción 1 (Post nuevo)

# 2. Verificar en la app:
#    - La notificación apareció
#    - El badge se actualizó
#    - Se puede marcar como leída
```

### Prueba Completa (15 minutos)

Verificar todos los estados de la app:

```bash
# 1. App en foreground
#    - Ejecutar la app y dejarla abierta
python3 test_notifications.py --cases 1 --delay 5
#    - Verificar que aparece SnackBar con botón "Ver"

# 2. App en background
#    - Minimizar la app (no cerrarla)
python3 test_notifications.py --cases 2 --delay 5
#    - Verificar notificación del sistema

# 3. App cerrada (terminated)
#    - Cerrar completamente la app
python3 test_notifications.py --cases 3 --delay 5
#    - Tocar la notificación
#    - Verificar que abre la app
```

### Prueba de Tópicos (10 minutos)

```bash
# 1. Enviar a tópico posts
./send_to_topic.sh posts

# 2. Enviar a tópico alerts
./send_to_topic.sh alerts

# 3. Verificar que ambas llegaron
```

### Prueba de Estrés (20 minutos)

Enviar múltiples notificaciones para probar límites:

```bash
# Ejecutar suite completa
python3 test_notifications.py --delay 3

# Verificar:
# - Todas las notificaciones aparecen
# - Badge counter es correcto
# - Orden cronológico correcto
# - Marcar todas como leídas funciona
# - Eliminar todas funciona
```

## 🐛 Troubleshooting

### Error: "Authorization key not valid"

**Causa:** Server Key incorrecto

**Solución:**

1. Verificar que copiaste el Server Key completo
2. Asegurarte de que es del proyecto correcto
3. El key debe empezar con "AAAAxxxxxx..."

---

### Error: "InvalidRegistration"

**Causa:** Device Token inválido

**Solución:**

1. Obtener un token nuevo desde los logs
2. El token cambia si reinstalaste la app
3. Verificar que copiaste el token completo (~150+ caracteres)

---

### Las notificaciones no llegan

**Verificar:**

```bash
# 1. App tiene permisos
# Android: Settings → Apps → SUAyED → Notifications
# iOS: Settings → SUAyED → Notifications

# 2. App está ejecutándose o el dispositivo está conectado a internet

# 3. Ver logs de Firebase
flutter logs | grep -i "fcm\|notification\|firebase"

# 4. Token es válido
echo "Token length: ${#DEVICE_TOKEN}"
# Debe ser > 100 caracteres
```

---

### Script de Python no funciona

**Instalar requests:**

```bash
pip3 install requests
```

**O usar el instalado con el sistema:**

```bash
python3 -m pip install --user requests
```

---

### Permisos denegados al ejecutar script

```bash
# Dar permisos de ejecución
chmod +x send_notification.sh
chmod +x send_to_topic.sh
chmod +x test_notifications.py

# Ejecutar
./send_notification.sh
```

## 📚 Documentación Adicional

Para más información, consulta:

- [PRUEBAS_NOTIFICACIONES.md](../../PRUEBAS_NOTIFICACIONES.md) - Guía completa de pruebas
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)

## 💡 Tips

1. **Guarda tu Server Key y Device Token** en un archivo de configuración local (no lo subas a Git)

2. **Usa variables de entorno:**

   ```bash
   export FCM_SERVER_KEY="tu_server_key"
   export FCM_DEVICE_TOKEN="tu_device_token"

   # Modificar scripts para usar $FCM_SERVER_KEY y $FCM_DEVICE_TOKEN
   ```

3. **Automatiza con cron** (para pruebas programadas):

   ```bash
   # Enviar notificación de prueba cada día a las 10:00
   0 10 * * * cd /path/to/scripts && ./send_to_topic.sh posts
   ```

4. **Logs en archivo:**

   ```bash
   python3 test_notifications.py 2>&1 | tee test_results.log
   ```

## 🔒 Seguridad

**IMPORTANTE:**

- ❌ **NUNCA** subas a Git archivos con Server Key o tokens
- ✅ Agrega `*.key`, `*.token` a `.gitignore`
- ✅ Usa variables de entorno para datos sensibles
- ✅ Rota el Server Key periódicamente en Firebase Console

---

**Última actualización:** 2025-01-15
**Versión:** 1.0.0

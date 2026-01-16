# 🚀 Inicio Rápido - Pruebas de Notificaciones Push

Guía rápida de 5 minutos para comenzar a probar notificaciones push.

## ✅ Pre-requisitos

- [x] Aplicación SUAyED instalada en dispositivo/emulador
- [x] Acceso a Firebase Console
- [x] Terminal con bash
- [x] Python 3 instalado (para pruebas automatizadas)

---

## 📝 Paso 1: Configurar Credenciales (2 minutos)

### 1.1 Obtener Server Key de Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Proyecto: `app-de-psicologia-suayed`
3. ⚙️ **Project Settings** → **Cloud Messaging**
4. Copiar **Server key** (comienza con "AAAA...")

### 1.2 Obtener Token FCM del Dispositivo

**Opción A - Usar script automático (recomendado):**

```bash
cd scripts/notifications
./get_token.sh
```

**Opción B - Manual:**

```bash
# Terminal 1
flutter run

# Terminal 2
flutter logs | grep "FCM Token"
```

Buscar línea:
```
🔑 FCM Token: dXXXXXXXXXX...XXXXXX
```

### 1.3 Crear archivo de configuración

```bash
cd scripts/notifications
cp config.example.sh config.sh
nano config.sh  # O usa tu editor favorito
```

Editar y pegar:
```bash
export FCM_SERVER_KEY="AAAA_TU_SERVER_KEY_AQUI"
export FCM_DEVICE_TOKEN="dXXX_TU_DEVICE_TOKEN_AQUI"
```

Guardar: `Ctrl+O`, `Enter`, `Ctrl+X`

---

## 🎯 Paso 2: Primera Prueba (1 minuto)

### Opción 1: Usando el menú interactivo (recomendado)

```bash
./menu.sh
```

Seleccionar opción `2` → Enviar notificación a dispositivo

### Opción 2: Comando directo

```bash
./send_notification.sh
```

Seleccionar opción `1` (Post nuevo)

**✅ Verificar:**
- [ ] Notificación apareció en el dispositivo
- [ ] Badge counter se actualizó
- [ ] Notificación aparece en la app

---

## 🧪 Paso 3: Pruebas Avanzadas (2 minutos)

### Prueba de todos los estados

#### 3.1 App en Foreground

```bash
# Mantener la app abierta y visible
./send_notification.sh
```

Seleccionar opción `1`

**Esperar:** SnackBar con botón "Ver"

#### 3.2 App en Background

```bash
# Minimizar la app (no cerrar)
./send_notification.sh
```

Seleccionar opción `2`

**Esperar:** Notificación del sistema

#### 3.3 App Cerrada

```bash
# Cerrar completamente la app
./send_notification.sh
```

Seleccionar opción `3`

**Tocar la notificación** → App debe abrir

---

## 🔥 Pruebas Rápidas Adicionales

### Enviar a tópico (todos los usuarios)

```bash
./send_to_topic.sh posts
```

### Suite completa de pruebas

```bash
python3 test_notifications.py --delay 5
```

### Solo pruebas críticas

```bash
python3 test_notifications.py --cases 1,3 --delay 3
```

---

## 📊 Verificación de Resultados

Después de enviar notificaciones, verificar en la app:

1. **Pantalla de Notificaciones:**
   - [ ] Notificaciones aparecen en la lista
   - [ ] Badge muestra número correcto de no leídas
   - [ ] Orden cronológico correcto

2. **Marcar como leída:**
   - [ ] Tocar notificación → se marca como leída
   - [ ] Badge se actualiza
   - [ ] Color/estilo cambia

3. **Persistencia:**
   - [ ] Cerrar y abrir app → notificaciones siguen ahí
   - [ ] Reinstalar app → notificaciones se pierden (correcto)

---

## ❓ Problemas Comunes

### "Authorization key not valid"

```bash
# Verificar Server Key
source config.sh
echo "Server Key: ${FCM_SERVER_KEY:0:20}..."
```

**Solución:** Copiar de nuevo el Server Key desde Firebase Console

---

### "InvalidRegistration"

```bash
# Obtener nuevo token
./get_token.sh
```

**Solución:** Actualizar `FCM_DEVICE_TOKEN` en `config.sh`

---

### Las notificaciones no llegan

**Checklist:**

```bash
# 1. Verificar configuración
./menu.sh → Opción 7 (Estado de configuración)

# 2. Verificar permisos
# Android: Settings → Apps → SUAyED → Notifications ✅
# iOS: Settings → SUAyED → Notifications ✅

# 3. Ver logs
flutter logs | grep -i "notification"

# 4. Probar con Firebase Console
# Ir a Firebase Console → Cloud Messaging → Send test message
```

---

### Python requests no instalado

```bash
pip3 install requests

# O
python3 -m pip install --user requests
```

---

## 🎓 Próximos Pasos

Una vez que las pruebas básicas funcionen:

1. **Leer documentación completa:**
   ```bash
   less README.md
   # O
   cat README.md
   ```

2. **Revisar guía de pruebas:**
   ```bash
   less ../../PRUEBAS_NOTIFICACIONES.md
   ```

3. **Personalizar notificaciones:**
   - Editar payloads en `test_notifications.py`
   - Crear tus propias plantillas

4. **Automatizar:**
   - Crear scripts personalizados
   - Integrar con CI/CD

---

## 📞 Recursos

| Recurso | Ubicación |
|---------|-----------|
| Menú interactivo | `./menu.sh` |
| Documentación completa | `README.md` |
| Guía de pruebas | `../../PRUEBAS_NOTIFICACIONES.md` |
| Firebase Console | https://console.firebase.google.com/ |

---

## 🎯 Checklist Final

Antes de considerar las pruebas completas:

- [ ] Notificación en foreground ✅
- [ ] Notificación en background ✅
- [ ] Notificación con app cerrada ✅
- [ ] Notificación a tópico `posts` ✅
- [ ] Notificación a tópico `alerts` ✅
- [ ] Badge counter funciona ✅
- [ ] Marcar como leída funciona ✅
- [ ] Persistencia funciona ✅
- [ ] Navegación al tocar funciona ✅
- [ ] Suite de pruebas completa ✅

---

**Tiempo total estimado:** 5-10 minutos

**¡Listo para probar! 🚀**

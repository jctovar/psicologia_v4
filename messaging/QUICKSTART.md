# 🚀 Guía Rápida - Sistema de Notificaciones Push

Sistema manual de notificaciones FCM para SUAyED Psicología - **FUNCIONANDO ✅**

## ✅ Estado del Sistema

- **Configurado**: ✅ Service Account Key instalado
- **Probado**: ✅ Notificaciones enviadas y recibidas exitosamente
- **Operativo**: ✅ Listo para uso en producción

## 📤 Enviar Notificaciones

### Comando Básico

```bash
cd /Users/jctovar/Desarrollo/psicologia_v4/messaging
./send.sh --title "Tu Título" --body "Tu Mensaje"
```

### Ejemplos Reales

#### 📰 Nueva Publicación (Navega a Home)

```bash
./send.sh \
  --title "Nueva Publicación: Psicología Clínica" \
  --body "Descubre los últimos avances en el área" \
  --data '{"type":"post","id":"456","category":"noticias"}'
```

**Navegación**: Al tocar la notificación → Pantalla de Inicio

#### 📅 Evento Próximo (Navega a Calendario)

```bash
./send.sh \
  --title "Conferencia sobre Neuropsicología" \
  --body "25 de Enero, 10:00 AM - Auditorio Principal" \
  --data '{"type":"event","id":"789","date":"2026-01-25"}'
```

**Navegación**: Al tocar la notificación → Pantalla de Calendario

#### 📊 Calificaciones Disponibles

```bash
./send.sh \
  --title "Calificaciones Publicadas" \
  --body "Ya puedes consultar tus calificaciones del semestre 2025-2" \
  --data '{"type":"grades","semester":"2025-2"}'
```

#### 🖼️ Con Imagen

```bash
./send.sh \
  --title "Evento Especial" \
  --body "Mira los detalles del evento" \
  --image "https://suayed.iztacala.unam.mx/wp-content/uploads/evento.jpg"
```

#### 📱 A Token Específico

```bash
./send.sh \
  --token "OTRO_TOKEN_FCM_AQUI" \
  --title "Mensaje Personal" \
  --body "Este mensaje es solo para ti"
```

#### 👥 Multicast (Varios Dispositivos)

```bash
./send.sh \
  --tokens "TOKEN1,TOKEN2,TOKEN3" \
  --title "Aviso General" \
  --body "Mensaje para múltiples usuarios"
```

## 🔧 Configuración Actual

**Proyecto Firebase**: `app-de-psicologia-suayed`
**Service Account**: Configurado ✅
**Token de Prueba**: Configurado en `.env` ✅

## ⚠️ Importante

### Datos JSON (--data)

Los valores en JSON **DEBEN ser strings**:

✅ **Correcto**:
```json
{"type":"post","id":"123","active":"true"}
```

❌ **Incorrecto**:
```json
{"type":"post","id":123,"active":true}
```

### Archivos Sensibles

Nunca commitear a git:
- `service-account.json`
- `.env`
- `*.log`

Ya están protegidos en `.gitignore` ✅

## 📋 Argumentos Disponibles

| Argumento | Descripción | Ejemplo |
|-----------|-------------|---------|
| `--title` | Título de la notificación | `--title "Hola"` |
| `--body` | Cuerpo del mensaje | `--body "Mensaje aquí"` |
| `--data` | Datos JSON personalizados | `--data '{"key":"value"}'` |
| `--image` | URL de imagen | `--image "https://..."` |
| `--token` | Token FCM específico | `--token "TOKEN_AQUI"` |
| `--tokens` | Múltiples tokens (multicast) | `--tokens "T1,T2,T3"` |
| `--icon` | Icono Android | `--icon "notification_icon"` |
| `--sound` | Sonido | `--sound "default"` |

## 🔍 Obtener Tokens FCM

### Desde Logs de la App

Buscar en logs al iniciar la app Flutter:
```
[Firebase Messaging] FCM Token: d3L0Hy_HQxmsm7bsx...
```

### Agregar Código Temporal

En `lib/services/firebase_service.dart`:

```dart
static Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  AppLogger.i('FCM Token: $token');
  return token;
}
```

Llamar desde cualquier pantalla para imprimir el token.

## 📖 Documentación Completa

- **README.md**: Guía completa con troubleshooting
- **PLAN.md**: Detalles técnicos y arquitectura
- **Este archivo (QUICKSTART.md)**: Referencia rápida

## ✅ Verificación

El sistema fue probado exitosamente el **18 de Enero de 2026**:

- ✅ Service Account Key configurado
- ✅ Dependencias instaladas
- ✅ Notificación enviada
- ✅ Notificación recibida en dispositivo
- ✅ Message ID confirmado: `0:1768781915923162%57569b1057569b10`

## 🆘 Soporte

Si tienes problemas:

1. Verifica que el archivo `.env` tiene el token FCM correcto
2. Verifica que `service-account.json` existe
3. Revisa logs en `notification.log`
4. Consulta la sección de Troubleshooting en `README.md`

---

**Desarrollado por**: Claude Code
**Para**: SUAyED Psicología FES Iztacala UNAM
**Fecha**: Enero 2026

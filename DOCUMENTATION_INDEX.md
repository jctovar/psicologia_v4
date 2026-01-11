# Índice de Documentación - SUAyED v0.9.30

Guía completa de documentación para el proyecto de la aplicación móvil Psicología SUAyED.

## Documentación Principal

### CLAUDE.md (Principal)

Archivo de configuración de IA con información completa del proyecto.

**Contiene:**
- Resumen del proyecto y versión actual
- Comandos de desarrollo y construcción
- Arquitectura de capas (UI → State → Service → Data)
- Gestión de estado con Provider
- Tabla de servicios (HTTP, Firebase, Logger, etc.)
- **Sistema de Analytics centralizado** (NUEVO)
- Sistema tipográfico Material Design 3 con WCAG AAA
- Convenciones de código (naming, patrones, logging)
- Dependencias clave (con versiones actualizadas)
- Configuración de Firebase
- Patrones comunes (agregar pantalla, obtener datos, marcadores, errores)
- Assets y recursos
- Notas importantes reorganizadas por categorías
- Testing
- Flujos de datos importantes
- Inicialización mejorada de la app

**Últimas actualizaciones:**
- Versión: 0.9.30+20260110
- Analytics service documentation
- Sistema tipográfico mejorado con accesibilidad
- Notas de caché y persistencia
- Monitoreo con Crashlytics y logging

---

## Documentación de Características Recientes

### 1. CHANGELOG_RECENT.md

Registro detallado de cambios recientes del proyecto (v0.9.30).

**Cubre:**
- Sistema centralizado de Analytics en lib/utils/analytics.dart
- Métodos de rastreo: logEvent, logScreenView, logSearch, logViewContent, etc.
- Mejoras en manejo de errores con mensajes en español
- Cambio de dependencia: http_cache_hive_store v5.0.1 (nueva)
- Refactorización de colores del tema (WCAG AA/AAA)
- Mejoras en UI responsiva (teacher_detail.dart)
- Mejoras en PostCard
- Tabla de dependencias actualizadas
- Cómo usar los nuevos features
- Testing
- Próximos pasos recomendados
- Notas de migración

**Cuándo leer:** Cuando necesites entender qué cambió en la versión reciente.

---

### 2. ANALYTICS_GUIDE.md

Guía completa de Firebase Analytics y el servicio Analytics centralizado.

**Cubre:**
- Resumen e integración automática
- 8 eventos disponibles con ejemplos:
  1. logEvent - Evento personalizado
  2. logScreenView - Vista de pantalla
  3. logSearch - Búsquedas
  4. logViewContent - Visualización de contenido
  5. logBookmarkAdded - Marcadores
  6. logNotificationOpened - Notificaciones
  7. logShare - Compartir contenido
  8. logAppError - Errores de app
- Manejo de errores sin interrupciones
- Buenas prácticas (nombres descriptivos, parámetros útiles, privacidad)
- Casos de uso comunes
- Dashboard en Firebase Console
- Debugging en logs
- Limitaciones y consideraciones
- Testing

**Cuándo leer:**
- Cuando agregues nuevas pantallas que necesiten rastreo
- Cuando implementes nuevas funcionalidades con Analytics
- Para entender cómo rastrear eventos de usuario

---

### 3. THEME_ACCESSIBILITY_GUIDE.md

Documentación del sistema de temas mejorado con cumplimiento WCAG AA/AAA.

**Cubre:**
- Colores base (seed, secundario, terciario)
- Paleta de colores WCAG AA/AAA:
  - Tema claro: Textos oscuros con contraste 7:1+
  - Tema oscuro: Textos claros con contraste 7:1+
- Jerarquía tipográfica completa (Display, Headline, Title, Body, Label)
- Estándares WCAG (AA mínimo, AAA recomendado)
- Implementación técnica con Theme.of(context)
- Temas dinámicos (Material You)
- Transiciones suaves (300ms)
- Componentes personalizados (AppBar, Cards, Buttons)
- Testing de accesibilidad
- Mejores prácticas
- Debugging de temas
- Checklist de accesibilidad

**Cuándo leer:**
- Cuando diseñes nuevos componentes
- Cuando necesites verificar contraste
- Para entender Material Design 3 en la app
- Para cumplir con estándares WCAG

---

### 4. HTTP_SERVICE_GUIDE.md

Documentación del servicio HTTP centralizado con cache persistente.

**Cubre:**
- Configuración de Dio (base URL, timeouts)
- Inicialización asincrónica con Hive
- CacheOptions (7 días max-stale, HiveCacheStore)
- Interceptadores:
  - DioCacheInterceptor (manejo automático de cache)
  - LoggingInterceptor (registro de requests/responses)
- Uso en servicios y main.dart
- Ejemplo completo de flujo de carga de posts
- Manejo de DioException (timeout, error responses)
- Testing con memory cache
- Performance y optimización
- Monitoreo y debugging
- Buenas prácticas
- Limpieza de cache

**Cuándo leer:**
- Cuando necesites entender cómo funciona el cache HTTP
- Cuando agregues nuevos endpoints
- Cuando debuggees problemas de red
- Para optimizar peticiones HTTP

---

## Estructura de Directorios Documentado

### Código Fuente

```
lib/
├── main.dart                      # Inicialización con Analytics observer
├── theme.dart                     # Temas con WCAG AAA + transiciones
├── routes/
│   └── routes.dart               # Rutas centralizadas
├── screens/                       # Pantallas principales
│   ├── home_screen.dart
│   ├── post_detail.dart
│   └── teacher_detail.dart       # Mejorado con responsividad
├── widgets/
│   ├── post_card.dart            # Mejorado con animaciones
│   ├── app_drawer.dart
│   └── ...
├── providers/                     # State management (Provider)
│   ├── home_provider.dart
│   ├── bookmark_provider.dart
│   ├── theme_provider.dart
│   └── notification_provider.dart
├── services/
│   ├── http_service.dart         # Actualizado con http_cache_hive_store
│   ├── posts_service.dart
│   ├── firebase_service.dart
│   ├── crashlytics_service.dart
│   ├── logger_service.dart
│   └── local_service.dart
├── utils/
│   ├── analytics.dart            # NUEVO: Analytics centralizado
│   ├── app_constants.dart
│   ├── html_styles.dart          # Estilos para HTML de WordPress
│   └── url_launcher_utils.dart
├── models/
│   ├── post_model.dart
│   ├── storage_post_model.dart
│   ├── teacher_model.dart
│   ├── area_model.dart
│   └── notification_model.dart
└── assets/
    ├── images/
    ├── icon/
    └── ...
```

### Documentación

```
root/
├── CLAUDE.md                     # Principal - Toda la información del proyecto
├── DOCUMENTATION_INDEX.md        # Este archivo
├── CHANGELOG_RECENT.md           # Cambios recientes v0.9.30
├── ANALYTICS_GUIDE.md            # Guía de Firebase Analytics
├── THEME_ACCESSIBILITY_GUIDE.md  # Temas WCAG AA/AAA
└── HTTP_SERVICE_GUIDE.md         # Servicio HTTP y cache
```

---

## Quick Links por Tarea

### Si quieres...

#### Agregar un nuevo evento de Analytics

Leer: [ANALYTICS_GUIDE.md → Eventos Disponibles](#eventos-disponibles)

1. Elegir tipo de evento (logEvent, logSearch, logViewContent, etc.)
2. Llamar desde tu código
3. Verificar en Firebase Console → Analytics → Events

---

#### Entender el caché HTTP

Leer: [HTTP_SERVICE_GUIDE.md](#guía-de-servicio-http-y-cache)

Puntos clave:
- Cache persiste 7 días (maxStale)
- Automático con DioCacheInterceptor
- Solo cachea GET, no POST
- Puedes ver logs: `adb logcat | grep "HTTP"`

---

#### Diseñar un nuevo componente accesible

Leer: [THEME_ACCESSIBILITY_GUIDE.md → Jerarquía Tipográfica](#jerarquía-tipográfica)

1. Usar Theme.of(context).textTheme.ESTILO
2. Verificar contraste en WCAG Contrast Checker
3. Asegurar mínimo WCAG AA (4.5:1)
4. Mejor: Cumplir WCAG AAA (7:1)

---

#### Rastrear error importante

Leer: [ANALYTICS_GUIDE.md → Rastrear Error de la App](#8-error-de-la-app)

```dart
Analytics.logAppError(
  errorType: 'mi_error',
  errorMessage: 'Descripción del error',
);
```

---

#### Cambiar tema claro/oscuro

Leer: [THEME_ACCESSIBILITY_GUIDE.md → Control del Modo Tema](#control-del-modo-tema)

```dart
context.read<ThemeProvider>().toggleTheme();
```

---

#### Agregar nuevo endpoint API

Leer: [HTTP_SERVICE_GUIDE.md → Uso en la Aplicación](#uso-en-la-aplicación)

1. Crear servicio en lib/services/
2. Usar `dio.get()` o `dio.post()`
3. Cacheo automático para GET
4. Manejo de DioException

---

## Convenciones a Seguir

### Idioma

- **Todo en español (es-MX):**
  - Mensajes de error para usuario
  - Comentarios en código
  - Logs informativos
  - Nombres de eventos analytics

### Nombramiento

- Archivos: snake_case (post_model.dart)
- Clases: PascalCase (PostModel)
- Variables: camelCase (isLoading)
- Eventos analytics: snake_case (post_opened)
- Métodos privados: _camelCase (_buildTheme)

### Estilos

- WCAG AAA cuando sea posible (7:1 de contraste)
- Mínimo WCAG AA (4.5:1)
- Usar Theme.of(context), nunca hardcodear colores
- Tiempos de animación: 300ms (suave)

### Logging

- AppLogger para todos los logs
- Niveles: d, i, w, e, f
- Emojis para visualización rápida en logcat
- Nunca registrar datos personales

---

## Versiones de Dependencias Clave

| Paquete | Versión | Actualizado |
|---------|---------|------------|
| flutter | ^3.9.2 | - |
| provider | ^6.1.2 | - |
| dio | ^5.9.0 | - |
| dio_cache_interceptor | ^4.0.5 | - |
| http_cache_hive_store | ^5.0.1 | ✅ 2024 |
| hive_flutter | ^1.1.0 | - |
| firebase_analytics | ^12.0.3 | - |
| firebase_crashlytics | ^5.0.6 | - |
| google_fonts | ^7.0.0 | - |

---

## Checklist de Implementación

### Agregar Nueva Pantalla

- [ ] Crear archivo en lib/screens/
- [ ] Documentar con comentarios Dartdoc
- [ ] Agregar routeName estático
- [ ] Registrar ruta en lib/routes/routes.dart
- [ ] Agregar icono en AppDrawer
- [ ] Implementar Analytics.logScreenView()
- [ ] Usar estilos de Theme.of(context)
- [ ] Manejar errores con mensajes en español
- [ ] Agregar pruebas en test/

### Agregar Nuevo Evento Analytics

- [ ] Identificar tipo de evento
- [ ] Llamar Analytics.logEvent() o método específico
- [ ] Agregar en Firebase Console
- [ ] Documentar parámetros en código
- [ ] Verificar en logcat
- [ ] Crear dashboard en Firebase

### Agregar Nuevo Endpoint API

- [ ] Crear servicio en lib/services/
- [ ] Usar http_service.dart (Dio)
- [ ] Implementar manejo de errores (DioException)
- [ ] Mensajes de error en español
- [ ] Logging con AppLogger
- [ ] Crear test unitario
- [ ] Documentar parámetros

---

## Recursos Externos

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Firebase Analytics Docs](https://firebase.google.com/docs/analytics)
- [Flutter Theme Documentation](https://flutter.dev/docs/cookbook/design/themes)
- [Dio Documentation](https://pub.dev/packages/dio)

---

## Soporte y Contacto

### Para preguntas sobre...

**Arquitectura y estructura:** Ver CLAUDE.md
**Analytics:** Ver ANALYTICS_GUIDE.md
**Temas y accesibilidad:** Ver THEME_ACCESSIBILITY_GUIDE.md
**HTTP y cache:** Ver HTTP_SERVICE_GUIDE.md
**Cambios recientes:** Ver CHANGELOG_RECENT.md

---

## Última Actualización

- **Fecha:** 10 de Enero de 2026
- **Versión:** 0.9.30+20260110
- **Cambios:** Analytics, HTTP cache, Temas WCAG AAA
- **Documentación creada:** 5 archivos
- **Total de documentación:** CLAUDE.md + 4 guías especializadas

---

**Creado por:** Documentation Expert Agent
**Actualizado:** 2026-01-10
**Estado:** Completo y actualizado

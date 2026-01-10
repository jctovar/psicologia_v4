# Guía de Tipografía - App Psicología SUAyED

## Fuentes Utilizadas

La aplicación utiliza dos fuentes complementarias de Google Fonts:

### 1. **Poppins** (Fuente Principal)
- **Uso**: Títulos grandes, encabezados, elementos destacados
- **Características**: Moderna, geométrica, con personalidad académica
- **Pesos disponibles**: Regular (400), Medium (500), SemiBold (600), Bold (700), ExtraBold (800)

### 2. **Montserrat** (Fuente Secundaria)
- **Uso**: Texto de cuerpo, UI general, subtítulos
- **Características**: Excelente legibilidad en pantallas, versatil
- **Pesos disponibles**: Regular (400), Medium (500), SemiBold (600), Bold (700), ExtraBold (800)

## Jerarquía Tipográfica (Material Design 3)

### Display (Títulos Muy Grandes)
Para pantallas de bienvenida, elementos hero, títulos principales de landing

```dart
// Display Large - 57px
Text('Bienvenido', style: Theme.of(context).textTheme.displayLarge)

// Display Medium - 45px
Text('Psicología SUAyED', style: Theme.of(context).textTheme.displayMedium)

// Display Small - 36px
Text('FES Iztacala', style: Theme.of(context).textTheme.displaySmall)
```

### Headline (Encabezados)
Para títulos de página, encabezados de sección

```dart
// Headline Large - 32px
Text('Noticias Recientes', style: Theme.of(context).textTheme.headlineLarge)

// Headline Medium - 28px
Text('Eventos Destacados', style: Theme.of(context).textTheme.headlineMedium)

// Headline Small - 24px
Text('Áreas de Conocimiento', style: Theme.of(context).textTheme.headlineSmall)
```

### Title (Títulos de Componentes)
Para títulos de tarjetas, diálogos, items de lista

```dart
// Title Large - 22px
Text('Título Principal', style: Theme.of(context).textTheme.titleLarge)

// Title Medium - 16px (MÁS USADO)
Text('Título de Tarjeta', style: Theme.of(context).textTheme.titleMedium)

// Title Small - 14px
Text('Subtítulo', style: Theme.of(context).textTheme.titleSmall)
```

### Body (Texto de Contenido)
Para párrafos, contenido principal, descripciones

```dart
// Body Large - 16px (RECOMENDADO para párrafos)
Text('Contenido principal...', style: Theme.of(context).textTheme.bodyLarge)

// Body Medium - 14px (texto secundario)
Text('Información adicional...', style: Theme.of(context).textTheme.bodyMedium)

// Body Small - 12px (metadatos, fechas)
Text('Hace 2 días', style: Theme.of(context).textTheme.bodySmall)
```

### Label (Etiquetas)
Para botones, chips, tabs, badges

```dart
// Label Large - 14px (botones grandes)
Text('Guardar Cambios', style: Theme.of(context).textTheme.labelLarge)

// Label Medium - 12px (chips, tabs)
Text('Categoría', style: Theme.of(context).textTheme.labelMedium)

// Label Small - 11px (badges, etiquetas pequeñas)
Text('Nuevo', style: Theme.of(context).textTheme.labelSmall)
```

## Características de Legibilidad

### Line Height (Altura de Línea)
Todos los estilos tienen `height` optimizado para lectura:
- **Títulos grandes**: 1.12 - 1.33 (más compacto)
- **Texto de cuerpo**: 1.43 - 1.5 (más espaciado para lectura extendida)
- **Labels**: 1.33 - 1.45 (balanceado)

### Letter Spacing (Espaciado de Letras)
Ajustado según el tamaño y peso de la fuente:
- **Títulos grandes**: -0.25 a 0 (más compacto)
- **Texto medio**: 0.1 a 0.25 (neutral)
- **Texto pequeño**: 0.4 a 0.5 (más espaciado para legibilidad)

## Uso Correcto

### ✅ CORRECTO
```dart
// Usar estilos del tema
Text(
  'Título de Noticia',
  style: Theme.of(context).textTheme.titleMedium,
)

// Modificar propiedades específicas manteniendo la base
Text(
  'Título Personalizado',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    color: Colors.red,
    fontWeight: FontWeight.w700,
  ),
)
```

### ❌ INCORRECTO
```dart
// NO hacer llamadas directas a GoogleFonts (más lento)
Text(
  'Título',
  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
)

// NO usar TextStyle sin base del tema
Text(
  'Título',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

## Accesibilidad

### Respeto al Tamaño del Sistema
Flutter respeta automáticamente las preferencias de tamaño de texto del usuario mediante `MediaQuery.textScaleFactorOf(context)`.

**NO bloquees el escalado** a menos que sea absolutamente necesario:

```dart
// ❌ NO hacer esto
Text(
  'Título',
  textScaleFactor: 1.0, // Bloquea el escalado
)

// ✅ Dejar que Flutter maneje el escalado
Text(
  'Título',
  style: Theme.of(context).textTheme.titleMedium,
)
```

### Contraste de Color
Todos los colores de texto cumplen con WCAG AA/AAA:
- **Texto normal**: ratio ≥ 4.5:1 (AA)
- **Texto grande**: ratio ≥ 3:1 (AA)
- Los colores del tema están optimizados para cumplir AAA

## Performance

### Precarga de Fuentes
Las fuentes se precargan en `main.dart` para:
- Evitar flickering al cambiar entre estilos
- Mejorar rendimiento en modo offline
- Reducir llamadas a la red

```dart
await AppFonts.preloadFonts();
```

### Uso de fontFamily Estática
Los estilos del tema usan `fontFamily` estática en lugar de llamadas dinámicas a `GoogleFonts`, lo que mejora el performance significativamente.

## Ejemplos Prácticos

### Tarjeta de Noticia
```dart
Card(
  child: Column(
    children: [
      // Imagen
      Image.network(imageUrl),

      // Título de la noticia
      Text(
        'Nueva Investigación en Psicología Cognitiva',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      // Fecha de publicación
      Text(
        'Hace 2 días',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  ),
)
```

### Pantalla de Detalle
```dart
Column(
  children: [
    // Título principal
    Text(
      'Título del Artículo',
      style: Theme.of(context).textTheme.headlineMedium,
    ),

    // Contenido del artículo
    Text(
      'Lorem ipsum dolor sit amet...',
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  ],
)
```

### Botón con Etiqueta
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(
    'Guardar Cambios',
    style: Theme.of(context).textTheme.labelLarge,
  ),
)
```

## Recursos Adicionales

- [Material Design 3 Typography](https://m3.material.io/styles/typography/overview)
- [Google Fonts](https://fonts.google.com/)
- [WCAG Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

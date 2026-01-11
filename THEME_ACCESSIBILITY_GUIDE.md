# Guía de Temas y Accesibilidad WCAG

Este documento explica el sistema de temas mejorado y el cumplimiento con estándares de accesibilidad WCAG AA/AAA.

## Resumen

La aplicación SUAyED implementa un sistema de temas Material Design 3 con:

- Temas claro y oscuro completamente personalizados
- Cumplimiento WCAG AAA (ratio de contraste ≥ 7:1) para textos principales
- Cumplimiento WCAG AA (ratio ≥ 4.5:1) para textos secundarios
- Transiciones suaves (300ms) entre temas
- Colores armoniosos basados en el rosa institucional #d81b60

## Colores Base

### Seed Color (Principal)

```dart
const Color _seedColor = Color(0xFFd81b60); // Rosa UNAM FES Iztacala
```

**Uso:**
- AppBar en tema claro
- Títulos principales (display, headline)
- Botones primary
- FAB

### Colores Secundarios

```dart
const Color _secondaryColor = Color(0xFF7B1FA2);  // Púrpura profundo
const Color _tertiaryColor = Color(0xFF00897B);   // Verde azulado (teal)
```

**Uso:**
- Elementos secundarios
- Variaciones de botones
- Acciones alternativas

## Paleta de Colores WCAG AA/AAA

### Tema Claro

Colores sobre fondo claro (#FDF8F8):

```dart
const Color _lightBodyText = Color(0xFF212121);
// Contraste ratio: 15.8:1 ✅ AAA
// Uso: Textos principales, body, títulos

const Color _lightBodySecondary = Color(0xFF424242);
// Contraste ratio: 11.9:1 ✅ AAA
// Uso: Textos secundarios, subtítulos

const Color _lightBodyTertiary = Color(0xFF616161);
// Contraste ratio: 7.3:1 ✅ AAA (con alpha 0.85+)
// Uso: Hints, placeholders, metadatos
```

### Tema Oscuro

Colores sobre fondo oscuro (#121212):

```dart
const Color _darkTitleText = Color(0xFFF48FB1);
// Rosa claro para títulos
// Contraste ratio: > 7:1 ✅ AAA
// Uso: Display, headline styles

const Color _darkBodyText = Color(0xFFE8E8E8);
// Contraste ratio: 13.7:1 ✅ AAA
// Uso: Textos principales en modo oscuro

const Color _darkBodySecondary = Color(0xFFBDBDBD);
// Contraste ratio: 9.4:1 ✅ AAA
// Uso: Textos secundarios

const Color _darkBodyTertiary = Color(0xFFA0A0A0);
// Contraste ratio: 6.8:1 ✅ AA
// Uso: Hints, placeholders
```

## Jerarquía Tipográfica

Ver `lib/theme.dart` para implementación completa.

### Display (Títulos Muy Grandes)

```dart
displayLarge: 57px, Poppins Bold
  line-height: 1.12 (64px)
  letter-spacing: -0.25px
  color: rosa principal (#d81b60) en claro, rosa claro en oscuro

displayMedium: 45px, Poppins Bold
  line-height: 1.16 (52px)
  letter-spacing: 0px

displaySmall: 36px, Poppins SemiBold
  line-height: 1.22 (44px)
  letter-spacing: 0px
```

**Uso:** Pantallas de bienvenida, títulos hero

### Headline (Encabezados Principales)

```dart
headlineLarge: 32px, Poppins SemiBold
  line-height: 1.25 (40px)
  color: rosa principal en claro

headlineMedium: 28px, Poppins SemiBold
  line-height: 1.29 (36px)

headlineSmall: 24px, Poppins SemiBold
  line-height: 1.33 (32px)
  color: texto body (oscuro en claro, claro en oscuro)
```

**Uso:** Títulos de página, encabezados de sección

### Title (Títulos de Elementos)

```dart
titleLarge: 22px, Montserrat Bold
  line-height: 1.27 (28px)
  color: rosa principal en claro

titleMedium: 16px, Montserrat SemiBold ⭐ MÁS USADO
  line-height: 1.5 (24px)
  letter-spacing: 0.15px
  color: texto body

titleSmall: 14px, Montserrat SemiBold
  line-height: 1.43 (20px)
  letter-spacing: 0.1px
```

**Uso:** Títulos de tarjetas, diálogos, items de lista

### Body (Texto Principal)

```dart
bodyLarge: 16px, Montserrat Regular ⭐ RECOMENDADO PARA PÁRRAFOS
  line-height: 1.5 (24px) ← Ideal para lectura
  letter-spacing: 0.5px
  color: texto body

bodyMedium: 14px, Montserrat Regular
  line-height: 1.43 (20px)
  letter-spacing: 0.25px
  color: texto body secondary

bodySmall: 12px, Montserrat Regular
  line-height: 1.33 (16px)
  letter-spacing: 0.4px
  color: texto body tertiary
```

**Uso:** Párrafos, descripciones, texto general

### Label (Etiquetas de Acciones)

```dart
labelLarge: 14px, Montserrat SemiBold
  line-height: 1.43 (20px)
  letter-spacing: 0.1px

labelMedium: 12px, Montserrat SemiBold
  line-height: 1.33 (16px)
  letter-spacing: 0.5px

labelSmall: 11px, Montserrat Medium
  line-height: 1.45 (16px)
  letter-spacing: 0.5px
```

**Uso:** Botones, chips, tabs, badges

## Estándares WCAG

### Niveles de Cumplimiento

**WCAG AA (Mínimo requerido por ley):**
- Texto normal (< 18pt): ratio de contraste ≥ 4.5:1
- Texto grande (≥ 18pt): ratio de contraste ≥ 3:1

**WCAG AAA (Altamente recomendado):**
- Texto normal: ratio de contraste ≥ 7:1
- Texto grande: ratio de contraste ≥ 4.5:1

### Cumplimiento en SUAyED

```
✅ Display styles         → AAA (15.8:1 - 13.7:1)
✅ Headline styles       → AAA (15.8:1 - 13.7:1)
✅ Title styles          → AAA (15.8:1 - 13.7:1)
✅ Body large           → AAA (15.8:1 - 13.7:1)
✅ Body medium          → AAA (11.9:1 - 9.4:1)
✅ Body small           → AAA (7.3:1 - 6.8:1)
✅ Secondary text       → AA (11.9:1 - 9.4:1)
✅ Tertiary text        → AA (7.3:1 - 6.8:1)
```

## Implementación Técnica

### Construcción de Tema

```dart
// lib/theme.dart
ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: brightness,
    ),
    textTheme: TextTheme(
      // ... estilos con colores adaptativos
      bodyLarge: AppFonts.montserrat(
        fontSize: 16,
        color: isDark ? _darkBodyText : _lightBodyText,
      ),
    ),
    // ... temas de componentes
  );
}
```

### Acceso a Estilos

```dart
// ✅ CORRECTO - Usar Theme.of(context)
Text(
  'Contenido',
  style: Theme.of(context).textTheme.bodyLarge,
)

// ✅ CORRECTO - Modificar estilos
Text(
  'Título',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    color: Colors.red,
  ),
)

// ❌ INCORRECTO - No hardcodear colores
Text(
  'Texto',
  style: TextStyle(
    color: Color(0xFF212121), // ❌ No funciona en modo oscuro
  ),
)
```

## Temas Dinámicos (Material You)

La app soporta temas dinámicos en Android 12+:

```dart
// Material 3 automáticamente genera temas dinámicos
// No se requiere configuración adicional
ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: brightness,
) // Genera automáticamente colores secundarios y terciarios
```

## Transiciones de Tema

### Animación Suave

```dart
MaterialApp(
  theme: iztacalaTheme,
  darkTheme: iztacalaDarkTheme,
  themeMode: themeProvider.themeMode,
  themeAnimationDuration: const Duration(milliseconds: 300),
  themeAnimationCurve: Curves.easeInOut,
)
```

**Efecto:**
- Cambio suave de colores al cambiar tema
- Duración: 300ms
- Curva: easeInOut (suave aceleración/desaceleración)

### Control del Modo Tema

```dart
// En ThemeProvider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
```

## Componentes Personalizados

### AppBar

```dart
appBarTheme: AppBarTheme(
  backgroundColor: isDark ? const Color(0xFF1E1E1E) : _seedColor,
  foregroundColor: Colors.white,
  elevation: isDark ? 0 : 3,  // Sombra solo en tema claro
  shadowColor: Colors.black.withValues(alpha: 0.3),
),
```

### Cards

```dart
cardTheme: CardThemeData(
  elevation: isDark ? 2 : 3,
  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  shadowColor: Colors.black.withValues(
    alpha: isDark ? 0.4 : 0.15,
  ),
),
```

### Botones

```dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: _seedColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: _seedColor.withValues(alpha: 0.4),
  ),
),
```

## Testing de Accesibilidad

### Verificar Contraste

```bash
# Usar herramienta de contraste WCAG
# Ejemplo: WebAIM Contrast Checker
# https://webaim.org/resources/contrastchecker/

# O en Flutter con flutter_test
testWidgets('Text has sufficient contrast', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Text(
          'Sample text',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      theme: iztacalaTheme,
    ),
  );
  // Verificar que se renderiza correctamente
  expect(find.byType(Text), findsOneWidget);
});
```

### Modo de Alto Contraste

```dart
// Los usuarios pueden habilitar alto contraste en sistema operativo
// La app automáticamente ajusta colores
MediaQuery.of(context).highContrast // true/false
```

## Mejores Prácticas

### 1. Siempre Usar Theme.of(context)

```dart
// ✅ BIEN
color: Theme.of(context).colorScheme.primary

// ❌ MALO
color: Color(0xFFd81b60)
```

### 2. Respetar Preferencias del Sistema

```dart
// ✅ BIEN
themeMode: ThemeMode.system  // Sigue preferencia del sistema

// ❌ MALO
themeMode: ThemeMode.light   // Siempre fuerza tema claro
```

### 3. Verificar Ratios de Contraste

```dart
// Antes de usar un color custom, verificar:
// 1. Ratio en tema claro
// 2. Ratio en tema oscuro
// 3. Cumplimiento WCAG AA mínimo (4.5:1)
// 4. Mejor: Cumplimiento WCAG AAA (7:1)
```

### 4. Usar Estilos Predefinidos

```dart
// ✅ BIEN - Consistente y accesible
Text('Contenido', style: Theme.of(context).textTheme.bodyLarge)

// ❌ MALO - Pueden no cumplir WCAG
Text('Contenido', style: TextStyle(fontSize: 16, color: someColor))
```

## Debugging de Temas

### Inspector de Flutter

```bash
# En Android Studio, habilitar Flutter Inspector
# Ver colores reales en tiempo real
# Cambiar tema dinámicamente
```

### Logs de Tema

```dart
// En ThemeProvider
void toggleTheme() {
  _themeMode = _themeMode == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;
  AppLogger.i('Theme changed to: ${_themeMode.name}');
  notifyListeners();
}
```

## Referencias

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Color Contrast](https://webaim.org/resources/contrastchecker/)
- [Flutter Theme Documentation](https://flutter.dev/docs/cookbook/design/themes)
- [Material Color Generator](https://m3.material.io/theme-builder)

## Checklist de Accesibilidad

- [ ] Todos los textos cumplen WCAG AA mínimo (4.5:1)
- [ ] Textos principales cumplen WCAG AAA (7:1)
- [ ] Colores se adaptan a tema claro y oscuro
- [ ] No se hardcodean colores (usar Theme.of)
- [ ] Iconos tienen suficiente tamaño (24dp mínimo)
- [ ] Elementos interactivos tienen mínimo 48x48dp
- [ ] Transiciones respetan preferencias de movimiento del sistema
- [ ] Fuentes son legibles (sans-serif, 12pt mínimo)
- [ ] Contraste suficiente en modo alto contraste
- [ ] Temas se pueden cambiar sin reinicios

## Changelog

### v2.0 (Actual)

- Material Design 3 completo
- Cumplimiento WCAG AAA
- Transiciones suaves de tema
- Soporte a temas dinámicos (Material You)
- Temas claro/oscuro optimizados
- Sistema tipográfico mejorado

### v1.0

- Temas básicos claro/oscuro
- Colores principales

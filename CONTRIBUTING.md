# Guia de Contribucion

Gracias por tu interes en contribuir a la aplicacion de Psicologia SUAyED. Este documento proporciona directrices para contribuir al proyecto.

---

## Tabla de Contenidos

- [Codigo de Conducta](#codigo-de-conducta)
- [Como Contribuir](#como-contribuir)
- [Configuracion del Entorno](#configuracion-del-entorno)
- [Flujo de Trabajo](#flujo-de-trabajo)
- [Estandares de Codigo](#estandares-de-codigo)
- [Commits y Mensajes](#commits-y-mensajes)
- [Pull Requests](#pull-requests)
- [Reportar Bugs](#reportar-bugs)
- [Solicitar Funcionalidades](#solicitar-funcionalidades)

---

## Codigo de Conducta

Este proyecto se adhiere a un codigo de conducta profesional. Al participar, se espera que mantengas este codigo. Por favor, reporta cualquier comportamiento inaceptable.

### Principios Basicos

- Se respetuoso y constructivo en tus interacciones
- Acepta criticas constructivas con gracia
- Enfocate en lo que es mejor para la comunidad estudiantil
- Muestra empatia hacia otros contribuidores

---

## Como Contribuir

Hay varias formas de contribuir:

1. **Reportar bugs** - Ayuda a identificar problemas
2. **Sugerir mejoras** - Proponer nuevas funcionalidades
3. **Mejorar documentacion** - Corregir errores o agregar claridad
4. **Escribir codigo** - Corregir bugs o implementar nuevas funcionalidades
5. **Revisar Pull Requests** - Ayudar a revisar cambios propuestos

---

## Configuracion del Entorno

### Requisitos Previos

| Requisito | Version |
|-----------|---------|
| Flutter SDK | 3.9.2 o superior |
| Dart SDK | 3.0.0 o superior |
| Git | 2.x o superior |
| Android Studio / VS Code | Ultima version |
| Xcode (solo macOS) | 14.0 o superior |

### Pasos de Instalacion

1. **Fork del repositorio**

   Haz clic en el boton "Fork" en la pagina del repositorio.

2. **Clonar tu fork**
   ```bash
   git clone https://github.com/TU_USUARIO/psicologia_v4.git
   cd psicologia_v4
   ```

3. **Agregar el repositorio original como upstream**
   ```bash
   git remote add upstream https://github.com/ORIGINAL/psicologia_v4.git
   ```

4. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

5. **Verificar la instalacion**
   ```bash
   flutter doctor
   dart analyze
   flutter test
   ```

6. **Configurar Firebase (opcional)**

   Si vas a trabajar con funcionalidades de Firebase, necesitaras acceso a los archivos de configuracion.

---

## Flujo de Trabajo

### 1. Sincronizar con upstream

Antes de crear una nueva rama, sincroniza con el repositorio original:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

### 2. Crear una rama

Crea una rama descriptiva para tu trabajo:

```bash
# Para nuevas funcionalidades
git checkout -b feature/nombre-descriptivo

# Para correcciones de bugs
git checkout -b fix/descripcion-del-bug

# Para documentacion
git checkout -b docs/que-documentas

# Para refactorizacion
git checkout -b refactor/que-refactorizas
```

**Ejemplos:**
```bash
git checkout -b feature/pantalla-videos
git checkout -b fix/cache-no-limpia
git checkout -b docs/actualizar-readme
git checkout -b refactor/simplificar-providers
```

### 3. Hacer cambios

- Realiza cambios pequenos y enfocados
- Sigue los [Estandares de Codigo](#estandares-de-codigo)
- Escribe o actualiza pruebas segun sea necesario
- Asegurate de que todas las pruebas pasen

### 4. Verificar cambios

Antes de hacer commit:

```bash
# Ejecutar linter
dart analyze

# Formatear codigo
dart format lib/

# Ejecutar pruebas
flutter test
```

### 5. Hacer commit

Sigue las [convenciones de commits](#commits-y-mensajes).

### 6. Push y Pull Request

```bash
git push origin nombre-de-tu-rama
```

Luego crea un Pull Request en GitHub.

---

## Estandares de Codigo

### Estructura de Archivos

```
lib/
├── main.dart           # Solo punto de entrada
├── theme.dart          # Configuracion de temas
├── models/             # Modelos de datos (solo data classes)
├── providers/          # Gestion de estado (ChangeNotifier)
├── services/           # Logica de negocio y APIs
├── screens/            # Pantallas de la aplicacion
├── widgets/            # Componentes reutilizables
├── routes/             # Definicion de rutas
└── utils/              # Utilidades y constantes
```

### Convenciones de Nombrado

| Tipo | Convencion | Ejemplo |
|------|------------|---------|
| Archivos | snake_case | `home_screen.dart` |
| Clases | PascalCase | `HomeScreen` |
| Variables | camelCase | `isLoading` |
| Constantes | camelCase | `maxPostsInMemory` |
| Metodos privados | _camelCase | `_buildWidget()` |

### Patrones Obligatorios

#### Screens

```dart
class MiScreen extends StatelessWidget {
  static const String routeName = '/mi-screen';

  final String title;

  const MiScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: // ...
    );
  }
}
```

#### Providers

```dart
class MiProvider extends ChangeNotifier {
  // Estado privado
  List<MiModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters publicos
  List<MiModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Metodos
  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await MiService.getItems();
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.e('Error', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Idioma

- **Codigo**: En ingles (nombres de variables, clases, metodos)
- **Comentarios**: En espanol o ingles (preferiblemente espanol)
- **Mensajes de error para usuario**: En espanol (es-MX)
- **Logs de desarrollo**: En ingles o espanol

### Documentacion de Codigo

Documenta funciones complejas:

```dart
/// Obtiene los posts de la API con soporte para paginacion.
///
/// Parametros:
/// - [page]: Numero de pagina a obtener (por defecto 1)
/// - [perPage]: Cantidad de posts por pagina (por defecto 15)
/// - [refreshCache]: Si es true, ignora el cache y obtiene datos frescos
///
/// Retorna un [PostsResponse] con los posts y metadatos de paginacion.
///
/// Lanza [Exception] si hay un error de red o del servidor.
static Future<PostsResponse> getPosts({
  int page = 1,
  int perPage = 15,
  bool refreshCache = false,
}) async {
  // ...
}
```

### Widgets Preferidos

| En lugar de | Usa |
|-------------|-----|
| `FutureBuilder` | `Consumer` con Provider |
| `setState` | `ChangeNotifier.notifyListeners()` |
| `print()` | `AppLogger.d()` |
| Colores hardcoded | `Theme.of(context).colorScheme` |

---

## Commits y Mensajes

### Formato de Mensaje

```
<tipo>(<alcance>): <descripcion breve>

[cuerpo opcional]

[notas al pie opcionales]
```

### Tipos de Commit

| Tipo | Descripcion |
|------|-------------|
| `feat` | Nueva funcionalidad |
| `fix` | Correccion de bug |
| `docs` | Cambios en documentacion |
| `style` | Formateo (sin cambios en codigo) |
| `refactor` | Refactorizacion de codigo |
| `test` | Agregar o corregir pruebas |
| `chore` | Tareas de mantenimiento |
| `perf` | Mejoras de rendimiento |

### Ejemplos

```bash
# Nueva funcionalidad
git commit -m "feat(screens): agregar pantalla de videos"

# Correccion de bug
git commit -m "fix(cache): corregir cache que no se limpia al cerrar"

# Documentacion
git commit -m "docs(readme): actualizar instrucciones de instalacion"

# Refactorizacion
git commit -m "refactor(providers): simplificar logica de HomeProvider"

# Pruebas
git commit -m "test(models): agregar pruebas para PostModel"
```

### Buenas Practicas

- Usa verbos en infinitivo: "agregar", "corregir", "actualizar"
- Manten la primera linea bajo 72 caracteres
- Referencia issues cuando aplique: `fix(api): corregir timeout (#123)`

---

## Pull Requests

### Antes de Crear un PR

- [ ] El codigo pasa `dart analyze` sin errores
- [ ] El codigo esta formateado con `dart format`
- [ ] Todas las pruebas pasan (`flutter test`)
- [ ] Has agregado pruebas para nuevo codigo
- [ ] Has actualizado la documentacion si es necesario

### Plantilla de PR

Al crear un PR, incluye:

```markdown
## Descripcion
[Describe brevemente los cambios]

## Tipo de Cambio
- [ ] Bug fix (cambio que corrige un issue)
- [ ] Nueva funcionalidad (cambio que agrega funcionalidad)
- [ ] Breaking change (cambio que afectaria funcionalidad existente)
- [ ] Documentacion

## Como Probar
1. [Paso 1]
2. [Paso 2]
3. [Resultado esperado]

## Capturas de Pantalla (si aplica)
[Imagenes del cambio visual]

## Checklist
- [ ] Mi codigo sigue las convenciones del proyecto
- [ ] He realizado una auto-revision de mi codigo
- [ ] He agregado comentarios en codigo complejo
- [ ] He actualizado la documentacion
- [ ] Mis cambios no generan nuevas advertencias
- [ ] He agregado pruebas que demuestran que mi fix/feature funciona
- [ ] Las pruebas existentes siguen pasando
```

### Proceso de Revision

1. Un mantenedor revisara tu PR
2. Puede solicitar cambios o aclaraciones
3. Realiza los cambios solicitados
4. Una vez aprobado, el PR sera mergeado

---

## Reportar Bugs

### Antes de Reportar

1. Verifica que el bug no haya sido reportado
2. Intenta reproducir el bug en la ultima version
3. Recolecta informacion relevante

### Informacion a Incluir

```markdown
**Descripcion del Bug**
[Descripcion clara y concisa]

**Pasos para Reproducir**
1. Ir a '...'
2. Hacer clic en '...'
3. Ver error

**Comportamiento Esperado**
[Que esperabas que pasara]

**Comportamiento Actual**
[Que paso realmente]

**Capturas de Pantalla**
[Si aplica]

**Entorno**
- Dispositivo: [ej. iPhone 12, Pixel 6]
- SO: [ej. iOS 16, Android 13]
- Version de la App: [ej. 0.8.120]

**Logs (si aplica)**
[Incluye logs relevantes]

**Contexto Adicional**
[Cualquier otra informacion]
```

---

## Solicitar Funcionalidades

### Antes de Solicitar

1. Verifica que no exista una solicitud similar
2. Considera si la funcionalidad beneficia a la mayoria de usuarios

### Formato de Solicitud

```markdown
**Descripcion de la Funcionalidad**
[Descripcion clara]

**Problema que Resuelve**
[Que problema o necesidad atiende]

**Solucion Propuesta**
[Como imaginas que funcionaria]

**Alternativas Consideradas**
[Otras soluciones que consideraste]

**Contexto Adicional**
[Mockups, ejemplos, etc.]
```

---

## Recursos Adicionales

- [Documentacion de Flutter](https://docs.flutter.dev/)
- [Pub.dev - Paquetes de Dart](https://pub.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Provider Package](https://pub.dev/packages/provider)

---

## Contacto

Para preguntas sobre contribucion, abre un Issue con la etiqueta `question`.

---

Gracias por contribuir a mejorar la experiencia de los estudiantes de Psicologia SUAyED.

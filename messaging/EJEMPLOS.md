# 📱 Ejemplos de Notificaciones - SUAyED Psicología

Casos de uso reales para envío de notificaciones push en la aplicación SUAyED.

## 📰 Noticias y Publicaciones

### Nueva Noticia General

```bash
./send.sh \
  --title "Nueva Publicación en SUAyED" \
  --body "Conoce los últimos acontecimientos de la facultad" \
  --data '{"type":"post","id":"1234","category":"noticias","action":"view"}' \
  --image "https://suayed.iztacala.unam.mx/wp-content/uploads/2026/01/noticia.jpg"
```

### Artículo Académico

```bash
./send.sh \
  --title "Nuevo Artículo: Psicología del Desarrollo" \
  --body "Explorando las etapas del desarrollo cognitivo en la adolescencia" \
  --data '{"type":"post","id":"1235","category":"academico","area":"desarrollo"}'
```

### Entrevista con Docente

```bash
./send.sh \
  --title "Entrevista Exclusiva" \
  --body "Conversamos con la Dra. María González sobre Neuropsicología" \
  --data '{"type":"post","id":"1236","category":"entrevista","teacher_id":"101"}'
```

## 📅 Eventos y Calendario

### Conferencia

```bash
./send.sh \
  --title "Conferencia: Psicología Social Contemporánea" \
  --body "25 de Enero, 10:00 AM - Auditorio Principal. ¡No te lo pierdas!" \
  --data '{"type":"event","id":"567","date":"2026-01-25","time":"10:00","location":"Auditorio"}' \
  --image "https://suayed.iztacala.unam.mx/eventos/conferencia-social.jpg"
```

### Taller

```bash
./send.sh \
  --title "Taller de Técnicas de Evaluación Psicológica" \
  --body "Inscripciones abiertas hasta el 30 de Enero. Cupo limitado" \
  --data '{"type":"event","id":"568","event_type":"workshop","deadline":"2026-01-30"}'
```

### Recordatorio de Evento

```bash
./send.sh \
  --title "Recordatorio: Sesión en 1 hora" \
  --body "Tu sesión de asesoría con el Dr. Ramírez comienza pronto" \
  --data '{"type":"reminder","event_id":"569","time":"1hour","action":"prepare"}'
```

## 📊 Calificaciones y Académico

### Calificaciones Publicadas

```bash
./send.sh \
  --title "Calificaciones Disponibles" \
  --body "Ya puedes consultar tus calificaciones del semestre 2025-2" \
  --data '{"type":"grades","semester":"2025-2","action":"view_grades"}'
```

### Recordatorio de Examen

```bash
./send.sh \
  --title "Examen Próximo: Psicopatología" \
  --body "Tu examen es mañana a las 16:00 hrs. ¡Mucho éxito!" \
  --data '{"type":"exam_reminder","subject":"psicopatologia","date":"2026-01-19","time":"16:00"}'
```

### Resultado de Examen

```bash
./send.sh \
  --title "Resultado Disponible" \
  --body "El resultado de tu examen de Psicología Clínica ya está disponible" \
  --data '{"type":"exam_result","subject":"clinica","action":"view_result"}'
```

## 📝 Inscripciones y Trámites

### Periodo de Inscripciones

```bash
./send.sh \
  --title "Inscripciones Abiertas" \
  --body "Inscríbete al semestre 2026-1 del 20 al 31 de Enero" \
  --data '{"type":"enrollment","semester":"2026-1","start_date":"2026-01-20","end_date":"2026-01-31"}'
```

### Recordatorio de Plazo

```bash
./send.sh \
  --title "Último Día de Inscripciones" \
  --body "Hoy es el último día para inscribirte. ¡No lo dejes pasar!" \
  --data '{"type":"deadline_reminder","process":"enrollment","deadline":"2026-01-31","urgency":"high"}'
```

### Trámite Aprobado

```bash
./send.sh \
  --title "Trámite Aprobado" \
  --body "Tu solicitud de constancia de estudios ha sido aprobada" \
  --data '{"type":"process_status","process":"certificate","status":"approved","id":"TR-1234"}'
```

## 🎓 Recursos Educativos

### Nuevos Materiales

```bash
./send.sh \
  --title "Nuevos Recursos Disponibles" \
  --body "Se agregaron materiales de estudio para Psicología Educativa" \
  --data '{"type":"resources","subject":"educativa","resource_type":"study_material"}'
```

### Biblioteca Digital

```bash
./send.sh \
  --title "Libro Digital Disponible" \
  --body "Nuevo libro: 'Fundamentos de Neurociencia Cognitiva'" \
  --data '{"type":"library","resource_type":"book","category":"neurociencia"}'
```

### Video Tutorial

```bash
./send.sh \
  --title "Nuevo Tutorial: Análisis Estadístico en SPSS" \
  --body "Aprende a usar SPSS para análisis de datos psicológicos" \
  --data '{"type":"tutorial","topic":"statistics","tool":"spss"}' \
  --image "https://suayed.iztacala.unam.mx/recursos/tutorial-spss.jpg"
```

## 👨‍🏫 Profesores y Asesorías

### Nueva Disponibilidad de Profesor

```bash
./send.sh \
  --title "Horarios de Asesoría Actualizados" \
  --body "El Dr. López agregó nuevos horarios para asesoría" \
  --data '{"type":"teacher_update","teacher_id":"102","update_type":"schedule"}'
```

### Cancelación de Asesoría

```bash
./send.sh \
  --title "Asesoría Cancelada" \
  --body "La asesoría del miércoles 22 con la Dra. Martínez ha sido cancelada" \
  --data '{"type":"advisory_cancelled","teacher_id":"103","date":"2026-01-22","reason":"emergency"}'
```

## 🔔 Avisos Administrativos

### Mantenimiento del Sistema

```bash
./send.sh \
  --title "Mantenimiento Programado" \
  --body "La plataforma no estará disponible el sábado de 10:00 a 14:00 hrs" \
  --data '{"type":"maintenance","date":"2026-01-25","start":"10:00","end":"14:00"}'
```

### Actualización de la App

```bash
./send.sh \
  --title "Nueva Versión Disponible" \
  --body "Actualiza la app SUAyED para acceder a nuevas funciones" \
  --data '{"type":"app_update","version":"0.9.31","required":"false","action":"update"}'
```

### Aviso Importante

```bash
./send.sh \
  --title "⚠️ Aviso Importante" \
  --body "Cambio de fecha para entrega de documentos. Nueva fecha: 5 de Febrero" \
  --data '{"type":"important_notice","category":"deadline_change","new_date":"2026-02-05"}'
```

## 📚 Áreas de Conocimiento

### Nuevo Contenido en Área

```bash
./send.sh \
  --title "Psicología Clínica: Nuevo Contenido" \
  --body "Explora los nuevos casos de estudio agregados al área" \
  --data '{"type":"area_update","area":"clinica","content_type":"case_study"}'
```

### Actividad en Área

```bash
./send.sh \
  --title "Foro Activo: Psicología Social" \
  --body "Únete a la discusión sobre identidad social en grupos" \
  --data '{"type":"area_activity","area":"social","activity_type":"forum","topic":"identity"}'
```

## 📖 Marcadores y Favoritos

### Recordatorio de Contenido Guardado

```bash
./send.sh \
  --title "Contenido Guardado Actualizado" \
  --body "Un artículo que guardaste tiene nueva información disponible" \
  --data '{"type":"bookmark_update","post_id":"1234","update_type":"new_content"}'
```

## 🎯 Notificaciones Personalizadas

### Bienvenida a Nuevo Usuario

```bash
./send.sh \
  --title "¡Bienvenido a SUAyED!" \
  --body "Explora todo el contenido académico disponible para ti" \
  --data '{"type":"welcome","user_type":"new","action":"explore"}'
```

### Logro Desbloqueado

```bash
./send.sh \
  --title "🏆 ¡Logro Desbloqueado!" \
  --body "Has completado el 50% de los materiales del módulo" \
  --data '{"type":"achievement","achievement_id":"half_module","module":"psicopatologia"}'
```

### Encuesta de Satisfacción

```bash
./send.sh \
  --title "Tu Opinión es Importante" \
  --body "Ayúdanos a mejorar. Responde nuestra encuesta de satisfacción" \
  --data '{"type":"survey","survey_id":"satisfaccion_2026_1","action":"open_survey"}'
```

## 🧪 Pruebas y Desarrollo

### Notificación de Prueba

```bash
./send.sh \
  --title "🧪 Prueba de Notificación" \
  --body "Esta es una notificación de prueba del sistema" \
  --data '{"type":"test","environment":"development","timestamp":"2026-01-18"}'
```

### Debug con Todos los Campos

```bash
./send.sh \
  --title "Debug: Notificación Completa" \
  --body "Probando todos los campos disponibles" \
  --data '{"type":"debug","feature":"all_fields","priority":"normal"}' \
  --image "https://via.placeholder.com/400x200?text=Debug+Image" \
  --icon "notification_icon" \
  --sound "default"
```

## 💡 Tips de Uso

### Formato de Datos JSON

**Siempre usa strings en valores JSON**:

✅ Correcto:
```json
{"id":"123","active":"true","priority":"high"}
```

❌ Incorrecto:
```json
{"id":123,"active":true,"priority":5}
```

### Imágenes

- Usar URLs completas y accesibles públicamente
- Formato recomendado: JPG o PNG
- Tamaño recomendado: 1024x512px
- Peso máximo: 1MB

### Títulos y Cuerpos

- **Título**: Máximo 65 caracteres
- **Cuerpo**: Máximo 240 caracteres
- Usar emojis con moderación (1-2 máximo)
- Ser claro y directo

### Acciones (Deep Linking)

Los datos `type` y `action` permiten que la app abra directamente la pantalla correcta:

```json
{
  "type": "post",        // Tipo de contenido
  "id": "123",           // ID del recurso
  "action": "view"       // Acción a realizar
}
```

---

**Tip**: Guarda tus comandos favoritos en un archivo `.txt` para reutilizarlos fácilmente.

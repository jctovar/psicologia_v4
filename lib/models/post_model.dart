/// Modelo que representa un post/noticia obtenido de la API de WordPress.
///
/// Este modelo se utiliza para mapear los datos de la API REST de WordPress
/// a objetos Dart. Los campos [title] y [content] contienen HTML renderizado
/// que puede mostrarse usando el paquete `flutter_widget_from_html_core`.
///
/// Ejemplo de uso:
/// ```dart
/// final response = await dio.get('wp-json/wp/v2/posts');
/// final posts = (response.data as List)
///     .map((json) => PostModel.fromJson(json))
///     .toList();
/// ```
class PostModel {
  /// Crea una instancia de [PostModel].
  ///
  /// Todos los parametros son requeridos ya que representan datos
  /// esenciales de un post de WordPress.
  PostModel({
    required this.id,
    required this.date,
    required this.title,
    required this.link,
    required this.image,
    required this.content,
  });

  /// Identificador unico del post en WordPress.
  final int id;

  /// Fecha de publicacion del post.
  final DateTime date;

  /// Titulo del post (puede contener HTML entities).
  final String title;

  /// URL permanente al post en el sitio web.
  final String link;

  /// URL de la imagen destacada del post (via Jetpack).
  /// Puede estar vacia si el post no tiene imagen.
  final String image;

  /// Contenido completo del post en formato HTML.
  final String content;

  /// Crea un [PostModel] a partir de un mapa JSON de la API de WordPress.
  ///
  /// Espera la estructura estandar de la API REST de WordPress v2:
  /// - `id`: Entero con el ID del post
  /// - `date`: String ISO 8601 con la fecha
  /// - `title.rendered`: String con el titulo renderizado
  /// - `link`: String con la URL del post
  /// - `jetpack_featured_media_url`: String con la URL de la imagen (Jetpack)
  /// - `content.rendered`: String con el contenido HTML
  ///
  /// Lanza [FormatException] si el JSON no tiene el formato esperado.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title']['rendered'],
      link: json['link'].toString(),
      image: json['jetpack_featured_media_url'] ?? '',
      content: json['content']['rendered'],
    );
  }

  /// Convierte el modelo a un mapa JSON para almacenamiento local.
  ///
  /// Nota: Esta estructura es diferente a la de la API de WordPress.
  /// Se usa para guardar bookmarks en almacenamiento local con una
  /// estructura simplificada.
  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toString(),
    "title": title,
    "link": link,
    "image": image,
    "content": content,
  };
}
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Modelo raíz del calendario escolar.
///
/// Contiene toda la información del calendario académico incluyendo
/// metadatos institucionales, periodos/semestres, y días inhábiles.
class CalendarioModel {
  final String nombre;
  final String programa;
  final String anio;
  final String institucion;
  final String universidad;
  final ContactoModel contacto;
  final List<PeriodoModel> periodos;
  final List<DiaInhabilModel> diasInhabiles;

  CalendarioModel({
    required this.nombre,
    required this.programa,
    required this.anio,
    required this.institucion,
    required this.universidad,
    required this.contacto,
    required this.periodos,
    required this.diasInhabiles,
  });

  factory CalendarioModel.fromJson(Map<String, dynamic> json) {
    try {
      return CalendarioModel(
        nombre: json['nombre']?.toString() ?? '',
        programa: json['programa']?.toString() ?? '',
        anio: json['año']?.toString() ?? '',
        institucion: json['institucion']?.toString() ?? '',
        universidad: json['universidad']?.toString() ?? '',
        contacto: json['contacto'] != null
            ? ContactoModel.fromJson(json['contacto'])
            : ContactoModel(
                departamento: '',
                telefono: '',
                email: '',
                sitioWeb: '',
              ),
        periodos: json['periodos'] != null
            ? (json['periodos'] as List)
                .map((x) => PeriodoModel.fromJson(x))
                .toList()
            : [],
        diasInhabiles: json['diasInhabiles'] != null
            ? (json['diasInhabiles'] as List)
                .map((x) => DiaInhabilModel.fromJson(x))
                .toList()
            : [],
      );
    } catch (e, stackTrace) {
      // Log detallado del error
      print('Error parsing CalendarioModel: $e');
      print('JSON keys: ${json.keys}');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'programa': programa,
      'año': anio,
      'institucion': institucion,
      'universidad': universidad,
      'contacto': contacto.toJson(),
      'periodos': periodos.map((x) => x.toJson()).toList(),
      'diasInhabiles': diasInhabiles.map((x) => x.toJson()).toList(),
    };
  }
}

/// Modelo de información de contacto institucional.
class ContactoModel {
  final String departamento;
  final String telefono;
  final String email;
  final String sitioWeb;

  ContactoModel({
    required this.departamento,
    required this.telefono,
    required this.email,
    required this.sitioWeb,
  });

  factory ContactoModel.fromJson(Map<String, dynamic> json) {
    try {
      return ContactoModel(
        departamento: json['departamento']?.toString() ?? '',
        telefono: json['telefono']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        sitioWeb: json['sitioWeb']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing ContactoModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'departamento': departamento,
      'telefono': telefono,
      'email': email,
      'sitioWeb': sitioWeb,
    };
  }
}

/// Modelo de periodo o semestre académico.
///
/// Contiene la información del periodo y una lista de eventos asociados.
class PeriodoModel {
  final String id;
  final String nombre;
  final String semestre;
  final String fechaInicio;
  final String fechaFin;
  final String tipo;
  final List<EventoModel> eventos;

  PeriodoModel({
    required this.id,
    required this.nombre,
    required this.semestre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.tipo,
    required this.eventos,
  });

  factory PeriodoModel.fromJson(Map<String, dynamic> json) {
    try {
      return PeriodoModel(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        semestre: json['semestre']?.toString() ?? '',
        fechaInicio: json['fechaInicio']?.toString() ?? '',
        fechaFin: json['fechaFin']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? '',
        eventos: json['eventos'] != null
            ? (json['eventos'] as List)
                .map((x) => EventoModel.fromJson(x))
                .toList()
            : [],
      );
    } catch (e) {
      print('Error parsing PeriodoModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'semestre': semestre,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'tipo': tipo,
      'eventos': eventos.map((x) => x.toJson()).toList(),
    };
  }
}

/// Modelo de evento del calendario.
///
/// Maneja estructura variable con campos opcionales según el tipo de evento.
/// Algunos eventos tienen fecha única, otros rangos, y algunos incluyen
/// sub-periodos anidados.
class EventoModel {
  // Campos comunes (siempre presentes)
  final String nombre;
  final String tipo;
  final String? descripcion;

  // Fechas (puede ser única o rango)
  final String? fecha;
  final String? fechaInicio;
  final String? fechaFin;

  // Campos opcionales según tipo de evento
  final String? sistema;
  final String? importante;
  final String? requisito;
  final String? condicion;
  final String? notaAdicional;
  final String? medio;
  final String? lugar;
  final String? url;
  final String? duracion;

  // Flags condicionales
  final bool? noAplicaNuevoIngreso;
  final bool? soloNuevoIngreso;
  final bool? soloExtraordinariosCortos;

  // Arrays opcionales
  final List<String>? aplica;
  final List<String>? tipoCalificacion;
  final List<PeriodoFechaModel>? periodos;

  EventoModel({
    required this.nombre,
    required this.tipo,
    this.descripcion,
    this.fecha,
    this.fechaInicio,
    this.fechaFin,
    this.sistema,
    this.importante,
    this.requisito,
    this.condicion,
    this.notaAdicional,
    this.medio,
    this.lugar,
    this.url,
    this.duracion,
    this.noAplicaNuevoIngreso,
    this.soloNuevoIngreso,
    this.soloExtraordinariosCortos,
    this.aplica,
    this.tipoCalificacion,
    this.periodos,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    try {
      return EventoModel(
        nombre: json['nombre']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? '',
        descripcion: json['descripcion']?.toString(),
        fecha: json['fecha']?.toString(),
        fechaInicio: json['fechaInicio']?.toString(),
        fechaFin: json['fechaFin']?.toString(),
        sistema: json['sistema']?.toString(),
        importante: json['importante']?.toString(),
        requisito: json['requisito']?.toString(),
        condicion: json['condicion']?.toString(),
        notaAdicional: json['notaAdicional']?.toString(),
        medio: json['medio']?.toString(),
        lugar: json['lugar']?.toString(),
        url: json['url']?.toString(),
        duracion: json['duracion']?.toString(),
        noAplicaNuevoIngreso: json['noAplicaNuevoIngreso'] as bool?,
        soloNuevoIngreso: json['soloNuevoIngreso'] as bool?,
        soloExtraordinariosCortos: json['soloExtraordinariosCortos'] as bool?,
        aplica: json['aplica'] != null
            ? (json['aplica'] is List
                ? List<String>.from(json['aplica'])
                : null)
            : null,
        tipoCalificacion: json['tipoCalificacion'] != null
            ? (json['tipoCalificacion'] is List
                ? List<String>.from(json['tipoCalificacion'])
                : null)
            : null,
        periodos: json['periodos'] != null
            ? (json['periodos'] is List
                ? (json['periodos'] as List)
                    .map((x) => PeriodoFechaModel.fromJson(x))
                    .toList()
                : null)
            : null,
      );
    } catch (e) {
      print('Error parsing EventoModel: $e');
      print('JSON nombre: ${json['nombre']}');
      print('JSON tipo: ${json['tipo']}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'sistema': sistema,
      'importante': importante,
      'requisito': requisito,
      'condicion': condicion,
      'notaAdicional': notaAdicional,
      'medio': medio,
      'lugar': lugar,
      'url': url,
      'duracion': duracion,
      'noAplicaNuevoIngreso': noAplicaNuevoIngreso,
      'soloNuevoIngreso': soloNuevoIngreso,
      'soloExtraordinariosCortos': soloExtraordinariosCortos,
      'aplica': aplica,
      'tipoCalificacion': tipoCalificacion,
      'periodos': periodos?.map((x) => x.toJson()).toList(),
    };
  }

  /// Obtiene la fecha formateada para mostrar.
  ///
  /// Retorna la fecha en formato legible en español.
  /// Si es un rango, retorna "inicio - fin".
  /// Si es fecha única, retorna solo la fecha.
  String getFechaDisplay() {
    if (fecha != null && fecha!.isNotEmpty) {
      return _formatDate(fecha!);
    } else if (fechaInicio != null &&
        fechaInicio!.isNotEmpty &&
        fechaFin != null &&
        fechaFin!.isNotEmpty) {
      return '${_formatDate(fechaInicio!)} - ${_formatDate(fechaFin!)}';
    }
    return 'Fecha no especificada';
  }

  /// Verifica si el evento tiene un rango de fechas.
  bool get isRangeFecha =>
      fechaInicio != null &&
      fechaInicio!.isNotEmpty &&
      fechaFin != null &&
      fechaFin!.isNotEmpty;

  /// Formatea una fecha ISO 8601 a formato español legible.
  ///
  /// Ejemplo: "2026-01-20" → "20 de enero, 2026"
  static String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      // Inicializar locale español si no está inicializado
      initializeDateFormatting('es_MX', null);

      // Formato: "20 de enero, 2026"
      final formatter = DateFormat('d \'de\' MMMM, y', 'es_MX');
      return formatter.format(date);
    } catch (e) {
      // Si falla el parsing, retornar la fecha original
      return isoDate;
    }
  }
}

/// Modelo para sub-periodos anidados dentro de eventos.
///
/// Algunos eventos (como inscripciones) tienen múltiples periodos
/// de registro con fechas específicas.
class PeriodoFechaModel {
  final String fechaInicio;
  final String fechaFin;
  final String? descripcion;

  PeriodoFechaModel({
    required this.fechaInicio,
    required this.fechaFin,
    this.descripcion,
  });

  factory PeriodoFechaModel.fromJson(Map<String, dynamic> json) {
    try {
      return PeriodoFechaModel(
        fechaInicio: json['fechaInicio']?.toString() ?? '',
        fechaFin: json['fechaFin']?.toString() ?? '',
        descripcion: json['descripcion']?.toString(),
      );
    } catch (e) {
      print('Error parsing PeriodoFechaModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'descripcion': descripcion,
    };
  }

  /// Obtiene el rango de fechas formateado.
  String getFechaDisplay() {
    try {
      final inicio = DateTime.parse(fechaInicio);
      final fin = DateTime.parse(fechaFin);

      initializeDateFormatting('es_MX', null);
      final formatter = DateFormat('d \'de\' MMMM', 'es_MX');

      return '${formatter.format(inicio)} - ${formatter.format(fin)}';
    } catch (e) {
      return '$fechaInicio - $fechaFin';
    }
  }
}

/// Modelo para días inhábiles o no laborables.
///
/// Representa vacaciones, días festivos, y otros períodos sin actividades.
class DiaInhabilModel {
  final String nombre;
  final String? fecha;
  final String? fechaInicio;
  final String? fechaFin;
  final String semestre;
  final String? descripcion;

  DiaInhabilModel({
    required this.nombre,
    this.fecha,
    this.fechaInicio,
    this.fechaFin,
    required this.semestre,
    this.descripcion,
  });

  factory DiaInhabilModel.fromJson(Map<String, dynamic> json) {
    try {
      return DiaInhabilModel(
        nombre: json['nombre']?.toString() ?? '',
        fecha: json['fecha']?.toString(),
        fechaInicio: json['fechaInicio']?.toString(),
        fechaFin: json['fechaFin']?.toString(),
        semestre: json['semestre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString(),
      );
    } catch (e) {
      print('Error parsing DiaInhabilModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'fecha': fecha,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'semestre': semestre,
      'descripcion': descripcion,
    };
  }

  /// Obtiene la fecha formateada para mostrar.
  ///
  /// Similar a EventoModel.getFechaDisplay()
  String getFechaDisplay() {
    if (fecha != null && fecha!.isNotEmpty) {
      return _formatDate(fecha!);
    } else if (fechaInicio != null &&
        fechaInicio!.isNotEmpty &&
        fechaFin != null &&
        fechaFin!.isNotEmpty) {
      return '${_formatDate(fechaInicio!)} - ${_formatDate(fechaFin!)}';
    }
    return 'Fecha no especificada';
  }

  /// Formatea una fecha ISO 8601 a formato español legible.
  static String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      initializeDateFormatting('es_MX', null);
      final formatter = DateFormat('d \'de\' MMMM, y', 'es_MX');
      return formatter.format(date);
    } catch (e) {
      return isoDate;
    }
  }
}

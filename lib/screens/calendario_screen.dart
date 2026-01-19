import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/models/calendario_model.dart';
import 'package:suayed/services/calendario_service.dart';
import 'package:suayed/services/logger_service.dart';
import 'package:suayed/utils/analytics.dart';
import 'package:suayed/widgets/app_drawer.dart';
import 'package:suayed/widgets/empty_state.dart' show EmptyState, ErrorState;
import 'package:suayed/widgets/shimmer_placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla del Calendario Escolar con eventos académicos organizados por semestre.
///
/// Características:
/// - Carga datos desde URL externa (https://jctovar.github.io/calendario.json)
/// - Cache persistente (7 días) para funcionamiento offline
/// - Agrupación por semestre con ExpansionTile
/// - Filtrado por tipo de evento
/// - Pull-to-refresh para actualizar
/// - Búsqueda por nombre y descripción
/// - Manejo de estados: loading, error, empty, data
class CalendarioScreen extends StatefulWidget {
  static const String routeName = 'calendario';

  const CalendarioScreen({super.key, required this.title});

  final String title;

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  CalendarioModel? _calendario;
  bool _isLoading = false;
  String? _errorMessage;

  // Filtro por tipo de evento
  String? _selectedTipoEvento;
  List<String> _tiposEventos = ['Todos'];

  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadCalendario();
    _searchController.addListener(_onSearchChanged);

    // Tracking de analytics
    Analytics.logScreenView(
      screenName: 'calendario',
      screenClass: 'CalendarioScreen',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  /// Carga el calendario desde el servicio.
  Future<void> _loadCalendario({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calendario = await CalendarioService.getCalendario(
        forceRefresh: forceRefresh,
      );

      setState(() {
        _calendario = calendario;
        _extractTiposEventos();
      });

      AppLogger.i('✅ Calendario loaded successfully');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      AppLogger.e('❌ Error loading calendario', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Extrae todos los tipos únicos de eventos para el filtro.
  void _extractTiposEventos() {
    if (_calendario == null) return;

    final Set<String> tipos = {'Todos'};
    for (var periodo in _calendario!.periodos) {
      for (var evento in periodo.eventos) {
        tipos.add(_capitalizeTipo(evento.tipo));
      }
    }

    setState(() {
      _tiposEventos = tipos.toList()..sort();
      _selectedTipoEvento = 'Todos';
    });
  }

  /// Capitaliza el tipo de evento para display.
  String _capitalizeTipo(String tipo) {
    if (tipo.isEmpty) return tipo;
    return tipo[0].toUpperCase() + tipo.substring(1);
  }

  /// Filtra eventos según búsqueda y tipo seleccionado.
  List<EventoModel> _filterEventos(List<EventoModel> eventos) {
    return eventos.where((evento) {
      // Filtro por tipo
      final matchesTipo = _selectedTipoEvento == null ||
          _selectedTipoEvento == 'Todos' ||
          _capitalizeTipo(evento.tipo) == _selectedTipoEvento;

      // Filtro por búsqueda
      final matchesSearch = _searchText.isEmpty ||
          evento.nombre.toLowerCase().contains(_searchText) ||
          (evento.descripcion?.toLowerCase().contains(_searchText) ?? false);

      return matchesTipo && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: const Icon(LineIcons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Buscar eventos',
          ),
          // Botón de filtro
          IconButton(
            icon: const Icon(LineIcons.filter),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar por tipo',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Estado: Loading
    if (_isLoading && _calendario == null) {
      return _buildLoadingState();
    }

    // Estado: Error
    if (_errorMessage != null && _calendario == null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: () => _loadCalendario(forceRefresh: true),
      );
    }

    // Estado: Empty (no debería pasar, pero por si acaso)
    if (_calendario == null) {
      return const EmptyState(
        icon: Icons.calendar_today,
        title: 'Sin datos',
        message: 'No se pudo cargar el calendario escolar.',
      );
    }

    // Estado: Data
    return _buildCalendarioList();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerPlaceholder(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildCalendarioList() {
    return RefreshIndicator(
      onRefresh: () => _loadCalendario(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con información institucional
          _buildHeader(),
          const SizedBox(height: 16),

          // Indicador de filtro activo
          if (_selectedTipoEvento != null && _selectedTipoEvento != 'Todos')
            _buildActiveFilterChip(),

          // Lista de periodos/semestres
          ..._calendario!.periodos.map((periodo) {
            final eventosFiltrados = _filterEventos(periodo.eventos);

            // Ocultar periodo si no hay eventos tras filtrar
            if (eventosFiltrados.isEmpty) return const SizedBox.shrink();

            return _buildPeriodoCard(periodo, eventosFiltrados);
          }),

          const SizedBox(height: 16),

          // Días inhábiles (opcional, en ExpansionTile separado)
          if (_calendario!.diasInhabiles.isNotEmpty) _buildDiasInhabilesCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _calendario!.nombre,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_calendario!.programa} • ${_calendario!.anio}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _calendario!.institucion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Chip(
        avatar: const Icon(LineIcons.filter, size: 18),
        label: Text('Filtrando: $_selectedTipoEvento'),
        onDeleted: () {
          setState(() {
            _selectedTipoEvento = 'Todos';
          });
        },
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }

  Widget _buildPeriodoCard(
    PeriodoModel periodo,
    List<EventoModel> eventos,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        // Título del periodo/semestre
        title: Text(
          periodo.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        // Subtítulo con fechas del periodo
        subtitle: Text(
          '${periodo.fechaInicio} - ${periodo.fechaFin}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        // Icono indicador
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            LineIcons.calendarWithDayFocus,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        // Badge con cantidad de eventos
        trailing: Chip(
          label: Text(
            '${eventos.length}',
            style: const TextStyle(fontSize: 12),
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        // Lista de eventos del periodo
        children: eventos.map((evento) {
          return _buildEventoTile(evento);
        }).toList(),
      ),
    );
  }

  Widget _buildEventoTile(EventoModel evento) {
    final theme = Theme.of(context);

    return ListTile(
      // Icono según tipo de evento
      leading: _getIconForTipo(evento.tipo),

      // Nombre del evento
      title: Text(
        evento.nombre,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Fecha(s) del evento
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                LineIcons.calendar,
                size: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  evento.getFechaDisplay(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (evento.descripcion != null) ...[
            const SizedBox(height: 4),
            Text(
              evento.descripcion!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),

      // Badge de tipo
      trailing: _buildTipoBadge(evento.tipo),

      // Tap para ver detalles en diálogo
      onTap: () => _showEventoDetailDialog(evento),

      // Visual density
      isThreeLine: evento.descripcion != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _getIconForTipo(String tipo) {
    final theme = Theme.of(context);
    IconData iconData;
    Color iconColor;

    switch (tipo.toLowerCase()) {
      case 'vacaciones':
        iconData = LineIcons.umbrellaBeach;
        iconColor = Colors.orange;
        break;
      case 'examenes':
      case 'evaluacion':
        iconData = LineIcons.fileAlt;
        iconColor = Colors.red;
        break;
      case 'inscripcion':
      case 'registro':
        iconData = LineIcons.userPlus;
        iconColor = Colors.blue;
        break;
      case 'calificaciones':
        iconData = LineIcons.tasks;
        iconColor = Colors.green;
        break;
      case 'administrativo':
        iconData = LineIcons.cog;
        iconColor = Colors.purple;
        break;
      default:
        iconData = LineIcons.calendarCheck;
        iconColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildTipoBadge(String tipo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _capitalizeTipo(tipo),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }

  Widget _buildDiasInhabilesCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        title: Text(
          'Días Inhábiles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LineIcons.ban, color: Colors.grey),
        ),
        trailing: Chip(
          label: Text(
            '${_calendario!.diasInhabiles.length}',
            style: const TextStyle(fontSize: 12),
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        children: _calendario!.diasInhabiles.map((dia) {
          return ListTile(
            leading: const Icon(LineIcons.ban, size: 20),
            title: Text(dia.nombre),
            subtitle: Text(dia.getFechaDisplay()),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          );
        }).toList(),
      ),
    );
  }

  /// Muestra diálogo con detalles completos del evento.
  void _showEventoDetailDialog(EventoModel evento) {
    // Tracking de analytics
    Analytics.logEvent(
      name: 'calendario_evento_viewed',
      parameters: {
        'evento_tipo': evento.tipo,
        'evento_nombre': evento.nombre,
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evento.nombre),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fecha
              _buildDetailRow('Fecha', evento.getFechaDisplay()),

              // Tipo
              _buildDetailRow('Tipo', _capitalizeTipo(evento.tipo)),

              // Descripción
              if (evento.descripcion != null)
                _buildDetailRow('Descripción', evento.descripcion!),

              // Sistema
              if (evento.sistema != null)
                _buildDetailRow('Sistema', evento.sistema!),

              // Información importante
              if (evento.importante != null)
                _buildHighlightedInfo(evento.importante!),

              // Requisito
              if (evento.requisito != null)
                _buildDetailRow('Requisito', evento.requisito!),

              // Condición
              if (evento.condicion != null)
                _buildDetailRow('Condición', evento.condicion!),

              // Medio
              if (evento.medio != null) _buildDetailRow('Medio', evento.medio!),

              // Lugar
              if (evento.lugar != null)
                _buildDetailRow('Lugar', evento.lugar!),

              // Duración
              if (evento.duracion != null)
                _buildDetailRow('Duración', evento.duracion!),

              // Aplica a
              if (evento.aplica != null && evento.aplica!.isNotEmpty)
                _buildDetailRow('Aplica a', evento.aplica!.join(', ')),

              // Tipos de calificación
              if (evento.tipoCalificacion != null &&
                  evento.tipoCalificacion!.isNotEmpty)
                _buildDetailRow('Tipos de calificación',
                    evento.tipoCalificacion!.join(', ')),

              // Nota adicional
              if (evento.notaAdicional != null)
                _buildDetailRow('Nota', evento.notaAdicional!),

              // Sub-periodos anidados
              if (evento.periodos != null && evento.periodos!.isNotEmpty)
                _buildSubPeriodos(evento.periodos!),

              // URL (si existe, mostrar como botón)
              if (evento.url != null) _buildUrlButton(evento.url!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedInfo(String info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPeriodos(List<PeriodoFechaModel> periodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periodos',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        ...periodos.asMap().entries.map((entry) {
          final index = entry.key;
          final periodo = entry.value;
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              '${index + 1}. ${periodo.getFechaDisplay()}${periodo.descripcion != null ? ' - ${periodo.descripcion}' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildUrlButton(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Abrir enlace'),
      ),
    );
  }

  /// Abre una URL externa en el navegador.
  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el enlace'),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.e('Error launching URL', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el enlace: $e'),
          ),
        );
      }
    }
  }

  /// Muestra diálogo de búsqueda.
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar eventos'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escribe para buscar...',
            prefixIcon: Icon(LineIcons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de filtro por tipo.
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por tipo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: _tiposEventos
                    .map(
                      (tipo) => ButtonSegment(
                        value: tipo,
                        label: Text(tipo),
                      ),
                    )
                    .toList(),
                selected: <String>{_selectedTipoEvento ?? 'Todos'},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedTipoEvento = newSelection.first;
                  });

                  // Tracking de analytics
                  Analytics.logEvent(
                    name: 'calendario_filter_applied',
                    parameters: {'tipo_evento': newSelection.first},
                  );

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

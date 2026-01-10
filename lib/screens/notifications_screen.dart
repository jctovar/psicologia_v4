import 'package:flutter/material.dart';
import 'package:suayed/models/notification_model.dart';
import 'package:suayed/providers/notification_provider.dart';
import 'package:suayed/widgets/app_drawer.dart';
import 'package:suayed/widgets/empty_state.dart';
import 'package:suayed/widgets/shimmer_placeholder.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  static const String routeName = 'notifications';
  const NotificationsScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Opciones de notificaciones',
                onSelected: (value) async {
                  switch (value) {
                    case 'mark_all_read':
                      await provider.markAllAsRead();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Todas las notificaciones marcadas como leídas'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      break;
                    case 'delete_read':
                      final readCount = provider.readNotifications.length;
                      if (readCount == 0) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No hay notificaciones leídas para eliminar'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        return;
                      }

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar notificaciones leídas'),
                          content: Text(
                            'Se eliminarán $readCount notificación${readCount != 1 ? 'es' : ''} leída${readCount != 1 ? 's' : ''}. Esta acción no se puede deshacer.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await provider.deleteReadNotifications();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$readCount notificación${readCount != 1 ? 'es' : ''} eliminada${readCount != 1 ? 's' : ''}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                      break;
                    case 'delete_all':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar todas las notificaciones'),
                          content: const Text(
                            'Se eliminarán todas las notificaciones. Esta acción no se puede deshacer.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await provider.deleteAllNotifications();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Todas las notificaciones eliminadas'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (provider.unreadCount > 0)
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all),
                          SizedBox(width: 8),
                          Text('Marcar todas como leídas'),
                        ],
                      ),
                    ),
                  if (provider.readNotifications.isNotEmpty)
                    const PopupMenuItem(
                      value: 'delete_read',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep),
                          SizedBox(width: 8),
                          Text('Eliminar leídas'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Eliminar todas'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          // Estado de carga
          if (notificationProvider.isLoading &&
              notificationProvider.notifications.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: 6,
              itemBuilder: (context, index) => const NotificationItemShimmer(),
              separatorBuilder: (context, index) => const Divider(),
            );
          }

          // Estado vacío
          if (notificationProvider.notifications.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'Sin notificaciones',
              message:
                  'No tienes notificaciones en este momento.\nTe avisaremos cuando haya novedades.',
            );
          }

          // Lista de notificaciones
          return NotificationList(
            notifications: notificationProvider.notifications,
          );
        },
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  const NotificationList({super.key, required this.notifications});

  final List<NotificationModel> notifications;

  String _datePub(DateTime date) {
    return timeago.format(date, locale: 'es');
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.post:
        return Icons.article_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(BuildContext context, NotificationType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case NotificationType.post:
        return colorScheme.primary;
      case NotificationType.alert:
        return colorScheme.error;
      case NotificationType.event:
        return colorScheme.tertiary;
      case NotificationType.general:
        return colorScheme.secondary;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.post:
        return 'publicación';
      case NotificationType.alert:
        return 'alerta';
      case NotificationType.event:
        return 'evento';
      case NotificationType.general:
        return 'notificación general';
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    // Marcar como leída si no lo está
    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
    }

    // Mostrar detalle
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => NotificationDetailSheet(notification: notification),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final iconColor = _getColorForType(context, notification.type);

        return Semantics(
          label: '${notification.isRead ? 'Notificación leída' : 'Notificación nueva'}: ${notification.title}. ${notification.message}. Recibida ${_datePub(notification.date)}',
          hint: 'Toca para ver detalles. Desliza hacia la izquierda para eliminar',
          button: true,
          child: Dismissible(
            key: Key(notification.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar notificación'),
                  content: const Text(
                    '¿Deseas eliminar esta notificación? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              Provider.of<NotificationProvider>(context, listen: false)
                  .deleteNotification(notification.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificación eliminada'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              leading: Semantics(
                label: 'Icono de ${_getTypeLabel(notification.type)}',
                child: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: iconColor,
                  ),
                ),
              ),
              title: Text(
                notification.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _datePub(notification.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: !notification.isRead
                  ? Semantics(
                      label: 'No leída',
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
              isThreeLine: true,
              onTap: () => _handleNotificationTap(context, notification),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Theme.of(context).dividerColor,
          height: 1,
        );
      },
    );
  }
}

class NotificationDetailSheet extends StatelessWidget {
  const NotificationDetailSheet({super.key, required this.notification});

  final NotificationModel notification;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.post:
        return Icons.article_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(BuildContext context, NotificationType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case NotificationType.post:
        return colorScheme.primary;
      case NotificationType.alert:
        return colorScheme.error;
      case NotificationType.event:
        return colorScheme.tertiary;
      case NotificationType.general:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForType(context, notification.type);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Asa de arrastre
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Contenido
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Icono
                    Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: iconColor.withValues(alpha: 0.1),
                        child: Icon(
                          _getIconForType(notification.type),
                          color: iconColor,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Título
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Fecha
                    Text(
                      _formatDate(notification.date),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Mensaje
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    // Datos adicionales si están disponibles
                    if (notification.data != null && notification.data!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Información adicional',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...notification.data!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              // Botón cerrar
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationItemShimmer extends StatelessWidget {
  const NotificationItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: const ShimmerPlaceholder(
        width: 40,
        height: 40,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerPlaceholder(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          ShimmerPlaceholder(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          ShimmerPlaceholder(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          ShimmerPlaceholder(
            width: 100,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api/notificacoes_service.dart';

/// Ícone de sino com badge de contagem de notificações não lidas.
/// Ao tocar, navega para a inbox de notificações (`/notifications`).
class NotificationsBellButton extends StatefulWidget {
  const NotificationsBellButton({super.key});

  @override
  State<NotificationsBellButton> createState() =>
      _NotificationsBellButtonState();
}

class _NotificationsBellButtonState extends State<NotificationsBellButton> {
  final NotificacoesService _service = NotificacoesService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _service.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (_unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () async {
        await context.push('/notifications');
        _loadUnreadCount();
      },
    );
  }
}

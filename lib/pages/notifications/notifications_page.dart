import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api/notificacoes_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificacoesService _service = NotificacoesService();
  bool _loading = true;
  List<Map<String, dynamic>> _notificacoes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _service.getNotificacoes();
    if (!mounted) return;
    setState(() {
      _notificacoes = (result['data'] as List<Map<String, dynamic>>?) ?? [];
      _loading = false;
    });
  }

  Future<void> _onTapNotificacao(Map<String, dynamic> notificacao) async {
    if (notificacao['lida'] != true) {
      await _service.markAsRead(notificacao['id'] as String);
      if (!mounted) return;
      setState(() => notificacao['lida'] = true);
    }
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
    if (!mounted) return;
    setState(() {
      for (final n in _notificacoes) {
        n['lida'] = true;
      }
    });
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day/$month às $hour:$min';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notificacoes.any((n) => n['lida'] != true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/home');
            }
          },
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas como lidas'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _notificacoes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'Nenhuma notificação por aqui.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _notificacoes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final n = _notificacoes[index];
                        final lida = n['lida'] == true;
                        return ListTile(
                          onTap: () => _onTapNotificacao(n),
                          leading: Icon(
                            lida
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: lida ? Colors.grey : const Color(0xFF00994B),
                          ),
                          title: Text(
                            n['titulo'] as String? ?? '',
                            style: TextStyle(
                              fontWeight:
                                  lida ? FontWeight.normal : FontWeight.w700,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(n['descricao'] as String? ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(n['created_at'] as String?),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

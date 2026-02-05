import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/api/api_service.dart';

/// Avatar do usuário (médico) para o header das páginas do médico.
/// Carrega [avatar_url] ou [foto_perfil_url] do profile e exibe a imagem;
/// em erro ou sem URL exibe ícone placeholder (sem desenhar ícone por cima da foto).
class DoctorAppBarAvatar extends StatefulWidget {
  const DoctorAppBarAvatar({super.key});

  @override
  State<DoctorAppBarAvatar> createState() => _DoctorAppBarAvatarState();
}

class _DoctorAppBarAvatarState extends State<DoctorAppBarAvatar> {
  final ApiService _api = ApiService();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = _api.currentUser;
    if (user == null) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final result = await _api.getFiltered(
        'profiles',
        filters: {'id': user.id},
        limit: 1,
      );
      if (!mounted) return;
      String? url;
      if (result['success'] == true && result['data'] != null) {
        final list = result['data'] as List;
        if (list.isNotEmpty) {
          final profile = list[0] as Map<String, dynamic>;
          url = profile['avatar_url'] as String? ??
              profile['foto_perfil_url'] as String?;
          if (url != null) {
            url = url.trim().isEmpty ? null : _resolveAvatarUrl(url);
          }
        }
      }
      setState(() => _avatarUrl = url);
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  /// Se for path (não http), converte para URL pública do bucket avatars.
  static String? _resolveAvatarUrl(String value) {
    final s = value.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    try {
      return Supabase.instance.client.storage.from('avatars').getPublicUrl(s);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = _avatarUrl != null &&
        _avatarUrl!.trim().isNotEmpty &&
        (_avatarUrl!.startsWith('http') || _avatarUrl!.startsWith('https'));
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/profile'),
        behavior: HitTestBehavior.opaque,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: hasValidUrl ? NetworkImage(_avatarUrl!) : null,
          onBackgroundImageError: hasValidUrl ? (_, __) {} : null,
          child: hasValidUrl
              ? null
              : const Icon(Icons.person, color: Colors.black54, size: 22),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // Aguarda um pouco para mostrar o splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Verificar se há sessão ativa
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Usuário está logado, verificar tipo e redirecionar
        final userId = session.user.id;

        // Buscar profile para determinar tipo de usuário
        final profileResult = await ApiService().getFiltered(
          'profiles',
          filters: {'id': userId},
          limit: 1,
        );

        if (profileResult['success'] == true && profileResult['data'] != null) {
          final profiles = profileResult['data'] as List;
          if (profiles.isNotEmpty) {
            final profile = profiles[0] as Map<String, dynamic>;
            final tipoUsuario = profile['tipo_usuario'] as String?;

            if (tipoUsuario == 'paciente') {
              context.go('/patient/home');
              return;
            } else if (tipoUsuario == 'medico' || tipoUsuario == 'prescritor') {
              context.go('/home');
              return;
            }
          }
        }

        // Se não conseguir determinar, assumir paciente
        context.go('/patient/home');
      } else {
        // Usuário não está logado, ir para seleção
        context.go('/user-selection');
      }
    } catch (e) {
      // Em caso de erro, ir para seleção
      if (mounted) {
        context.go('/user-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canfyGreen,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/Logo Canfy.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

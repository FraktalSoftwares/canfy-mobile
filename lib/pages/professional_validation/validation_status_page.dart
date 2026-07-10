import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/medico_service.dart';
import '../../services/api/api_service.dart';

class ValidationStatusPage extends StatefulWidget {
  const ValidationStatusPage({super.key});

  @override
  State<ValidationStatusPage> createState() => _ValidationStatusPageState();
}

class _ValidationStatusPageState extends State<ValidationStatusPage> {
  final MedicoService _medicoService = MedicoService();
  final ApiService _apiService = ApiService();
  bool _loading = true;
  String _status = 'pendente_aprovacao';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final result = await _medicoService.getMedicoByCurrentUser();
    if (!mounted) return;
    setState(() {
      if (result['success'] == true && result['data'] != null) {
        _status = (result['data'] as Map<String, dynamic>)['status'] as String? ??
            'pendente_aprovacao';
      }
      _loading = false;
    });
  }

  bool get _isAprovado => _status == 'ativo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Disponibilidade de atendimento',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadStatus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF),
                          borderRadius: BorderRadius.circular(117.647),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF66DDA2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _isAprovado
                            ? 'Boas notícias!'
                            : 'Sua documentação foi enviada com sucesso!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.truculenta(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isAprovado
                              ? const Color(0xFFE6F8EF)
                              : const Color(0xFFF9E68C),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _isAprovado ? 'Aprovado' : 'Em análise',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isAprovado
                                ? AppTheme.canfyGreen
                                : const Color(0xFF654C01),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isAprovado)
                        Text(
                          'Sua conta foi validada. Agora você já pode\ncomeçar a atender pacientes na Canfy.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            color: const Color(0xFF5E5E5B),
                          ),
                        )
                      else
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              color: const Color(0xFF5E5E5B),
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'Agora vamos validar suas informações e documentos.\n\n',
                              ),
                              const TextSpan(
                                text: 'Estamos analisando seus documentos. \n',
                              ),
                              const TextSpan(
                                text:
                                    'Normalmente é rápido, mas pode levar mais tempo dependendo da fila de validações.\n\n',
                              ),
                              TextSpan(
                                text:
                                    'Você receberá uma notificação assim que sua conta\nfor aprovada.',
                                style: AppTextStyles.arimo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 64),
                      if (_isAprovado)
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: ElevatedButton(
                            onPressed: () => context.go('/home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.canfyGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Entrar',
                              style: AppTextStyles.arimo(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: TextButton.icon(
                          onPressed: () {
                            // Abrir WhatsApp ou canal de suporte
                          },
                          icon: const Icon(
                            Icons.headphones,
                            size: 18,
                            color: AppTheme.canfyGreen,
                          ),
                          label: Text(
                            'Entrar em contato com o suporte',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              color: AppTheme.canfyGreen,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.canfyGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _apiService.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        child: Text(
                          'Sair da conta',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            color: const Color(0xFF9A9A97),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

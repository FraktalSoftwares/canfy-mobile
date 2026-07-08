import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinishAppointmentPage extends StatefulWidget {
  const FinishAppointmentPage({super.key});

  @override
  State<FinishAppointmentPage> createState() => _FinishAppointmentPageState();
}

class _FinishAppointmentPageState extends State<FinishAppointmentPage> {
  final MedicoService _medicoService = MedicoService();
  final TextEditingController _resumo = TextEditingController();
  bool _finalizando = false;
  String? _consultaId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final extra = GoRouterState.of(context).extra;
    if (extra is String) _consultaId = extra;
    if (extra is Map) _consultaId = (extra['consultaId'] ?? extra['id']) as String?;
  }

  @override
  void dispose() {
    _resumo.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (_consultaId == null) {
      context.go('/appointment');
      return;
    }
    setState(() => _finalizando = true);
    final res = await _medicoService.finalizarAtendimento(
      _consultaId!,
      resumo: _resumo.text.trim().isEmpty ? null : _resumo.text.trim(),
    );
    if (!mounted) return;
    setState(() => _finalizando = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atendimento finalizado.')),
      );
      context.go('/appointment');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível finalizar o atendimento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTokens.neutral900),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/appointment');
            }
          },
        ),
        title: Text(
          'Finalização do atendimento',
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral900,
            weight: AppTokens.weightSemibold,
          ),
        ),
        centerTitle: true,
        actions: const [DoctorAppBarAvatar()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Resumo do atendimento',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900)),
            const SizedBox(height: 8),
            Text(
              'Registre um resumo do que foi tratado na consulta.',
              style: AppTextStyles.bodySm(color: AppTokens.neutral600),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _resumo,
              maxLines: 8,
              style: AppTextStyles.bodySm(color: AppTokens.neutral900),
              decoration: InputDecoration(
                hintText: 'Descreva o atendimento...',
                hintStyle: AppTextStyles.bodySm(color: AppTokens.neutral500),
                filled: true,
                fillColor: AppTokens.neutral050,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radius16),
                  borderSide: const BorderSide(color: AppTokens.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radius16),
                  borderSide: const BorderSide(color: AppTokens.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radius16),
                  borderSide: const BorderSide(color: AppTokens.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Finalizar atendimento',
              isLoading: _finalizando,
              onPressed: _finalizar,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
    );
  }
}

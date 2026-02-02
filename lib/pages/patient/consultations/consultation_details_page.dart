import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class ConsultationDetailsPage extends StatefulWidget {
  final String consultationId;
  const ConsultationDetailsPage({super.key, required this.consultationId});

  @override
  State<ConsultationDetailsPage> createState() =>
      _ConsultationDetailsPageState();
}

class _ConsultationDetailsPageState extends State<ConsultationDetailsPage> {
  static final PatientService _patientService = PatientService();

  bool _receitaExpanded = true;
  bool _justificativaExpanded = true;
  String? _patientAvatarUrl;

  /// Future da consulta criado uma vez para não dar refresh ao expandir/recolher seções.
  late final Future<Map<String, dynamic>> _consultationFuture;

  @override
  void initState() {
    super.initState();
    _consultationFuture =
        _patientService.getConsultationById(widget.consultationId);
    _loadPatientProfile();
  }

  Future<void> _loadPatientProfile() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && result['data'] != null && mounted) {
        final data = result['data'] as Map<String, dynamic>;
        final profile = data['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          setState(() {
            _patientAvatarUrl = profile['foto_perfil_url'] as String?;
          });
        }
      }
    } catch (_) {}
  }

  String _displayStatus(String? status) {
    if (status == null) return 'Agendada';
    if (status == 'Finalizada') return 'Realizada';
    return status;
  }

  /// Cores das tags de agendamento – design Figma (node 2770-19007)
  Color _statusColor(String? status) {
    final display = _displayStatus(status);
    switch (display) {
      case 'Agendada':
        return AppColors.neutral100;
      case 'Em andamento':
        return AppColors.statusYellow;
      case 'Realizada':
        return AppColors.statusGrey;
      case 'Cancelada':
        return AppColors.statusCancelBg;
      default:
        return AppColors.statusGrey;
    }
  }

  Color _statusTextColor(String? status) {
    final display = _displayStatus(status);
    switch (display) {
      case 'Agendada':
        return AppColors.canfyGreen;
      case 'Em andamento':
        return AppColors.statusYellowDark;
      case 'Realizada':
        return AppColors.statusGreyDark;
      case 'Cancelada':
        return AppColors.statusCancelText;
      default:
        return AppColors.statusGreyDark;
    }
  }

  ImageProvider _avatarImageProvider(dynamic url) {
    if (url != null && url is String && url.startsWith('http')) {
      return NetworkImage(url);
    }
    return const AssetImage('assets/images/avatar_pictures.png');
  }

  /// Sheet de confirmação de cancelamento (design Figma)
  void _showCancelConsultationSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Deseja cancelar a consulta?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8, top: 2),
                      child: Icon(
                        Icons.close,
                        color: AppColors.neutral900,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta consulta será removida da sua agenda e não poderá ser recuperada. Caso precise, será necessário agendar uma nova consulta.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neutral900,
                        side: const BorderSide(color: AppColors.neutral300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // TODO: chamar API para cancelar consulta
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD372F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar consulta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral050,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.neutral900,
                  size: 24,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 16),
            content,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Detalhes da consulta',
        fallbackRoute: '/patient/consultations',
        avatarUrl: _patientAvatarUrl,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _consultationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.canfyGreen),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!['success'] != true) {
            final message = snapshot.data?['message'] ??
                snapshot.error?.toString() ??
                'Consulta não encontrada';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/patient/consultations'),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final consultation = snapshot.data!['data'] as Map<String, dynamic>;
          final status = consultation['status'] as String?;
          final displayStatus = _displayStatus(status);
          final prescription =
              consultation['prescription'] as Map<String, dynamic>?;

          // Cancelar permitido até 12h antes do horário agendado
          bool canCancel = false;
          if (status == 'Agendada') {
            final raw = consultation['data_consulta_raw'];
            if (raw != null) {
              try {
                final scheduled =
                    raw is String ? DateTime.parse(raw) : raw as DateTime;
                final diff = scheduled.difference(DateTime.now());
                canCancel = diff.inHours >= 12;
              } catch (_) {}
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalhes da consulta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 20),
                // Card resumo da consulta
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.neutral050,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7E7E5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${consultation['date']} • ${consultation['time']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusTextColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.neutral200,
                            backgroundImage: _avatarImageProvider(
                                consultation['doctorAvatar']),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  consultation['doctorName'] as String? ??
                                      'Médico',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  consultation['doctorSpecialty'] as String? ??
                                      '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (consultation['mainComplaint'] != null &&
                          (consultation['mainComplaint'] as String)
                              .isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            text: 'Principal queixa: ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral600,
                            ),
                            children: [
                              TextSpan(
                                text: consultation['mainComplaint'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Seção Informações sobre a receita
                if (prescription != null) ...[
                  const SizedBox(height: 16),
                  _buildCollapsibleSection(
                    title: 'Informações sobre a receita',
                    expanded: _receitaExpanded,
                    onToggle: () =>
                        setState(() => _receitaExpanded = !_receitaExpanded),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription['product'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.canfyGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (prescription['quantity'] != null &&
                            prescription['quantity'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Quantidade: ${prescription['quantity']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ),
                        const Text(
                          'Observações:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prescription['observations'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Observações da receita:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prescription['observations'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: download/share receita
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.canfyGreen, width: 1.5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download,
                                    color: AppColors.canfyGreen,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Receita_médica.pdf',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.canfyGreen,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.send,
                                    color: AppColors.canfyGreen,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Seção Justificativa clínica
                const SizedBox(height: 16),
                _buildCollapsibleSection(
                  title: 'Justificativa clínica',
                  expanded: _justificativaExpanded,
                  onToggle: () => setState(
                      () => _justificativaExpanded = !_justificativaExpanded),
                  content: Text(
                    consultation['doctorNotes'] != null &&
                            (consultation['doctorNotes'] as String).isNotEmpty
                        ? 'Observações do médico: ${consultation['doctorNotes']}'
                        : 'Observações do médico: Não informado.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Iniciar consulta (Agendada ou Em andamento)
                if (status == 'Agendada' || status == 'Em andamento') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                            '/patient/consultations/live/${widget.consultationId}');
                      },
                      icon: const Icon(Icons.videocam,
                          color: Colors.white, size: 22),
                      label: const Text(
                        'Iniciar consulta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.canfyGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Botão Agendar retorno (apenas quando a consulta está finalizada)
                if (status == 'Finalizada') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/patient/consultations/new/step1');
                      },
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.white, size: 22),
                      label: const Text(
                        'Agendar retorno',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.canfyGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Botão Cancelar consulta (sempre visível; desativado se não puder cancelar)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    onPressed: canCancel
                        ? () => _showCancelConsultationSheet(context)
                        : null,
                    icon: Icon(
                      Icons.close,
                      color: canCancel ? AppColors.error : AppColors.neutral600,
                      size: 22,
                    ),
                    label: Text(
                      'Cancelar consulta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            canCancel ? AppColors.error : AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 2),
    );
  }
}

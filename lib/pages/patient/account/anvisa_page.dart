import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PatientAnvisaPage extends StatefulWidget {
  const PatientAnvisaPage({super.key});

  @override
  State<PatientAnvisaPage> createState() => _PatientAnvisaPageState();
}

class _PatientAnvisaPageState extends State<PatientAnvisaPage> {
  final PatientService _patientService = PatientService();

  Map<String, dynamic>? _paciente;
  String? _documentoUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _patientService.getCurrentPatient();
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() => _loading = false);
      return;
    }
    final data = res['data'] as Map<String, dynamic>?;
    final paciente = data?['paciente'] as Map<String, dynamic>?;
    String? documentoUrl;
    final pacienteId = paciente?['id'] as String?;
    if (pacienteId != null) {
      final receita = await _patientService.getMostRecentReceita(pacienteId);
      documentoUrl = receita?['documento_url'] as String?;
    }
    if (!mounted) return;
    setState(() {
      _paciente = paciente;
      _documentoUrl = documentoUrl;
      _loading = false;
    });
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '--';
    final d = DateTime.tryParse(iso);
    if (d == null) return '--';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  /// Deriva o status a partir dos campos reais, já que `pacientes` não tem
  /// uma coluna dedicada de status da autorização Anvisa.
  ({String label, Color bg, Color fg}) get _status {
    final numero = _paciente?['anvisa_numero_registro']?.toString();
    final validadeIso = _paciente?['anvisa_validade_data'] as String?;
    final validade = validadeIso != null ? DateTime.tryParse(validadeIso) : null;
    if (numero == null || numero.isEmpty) {
      return (
        label: 'Pendente',
        bg: const Color(0xFFFDF7E3),
        fg: const Color(0xFF9E831B),
      );
    }
    if (validade != null && validade.isBefore(DateTime.now())) {
      return (
        label: 'Expirado',
        bg: const Color(0xFFFCE4E4),
        fg: const Color(0xFFB3261E),
      );
    }
    return (
      label: 'Aprovado',
      bg: const Color(0xFF66DDA2),
      fg: const Color(0xFF174F38),
    );
  }

  Future<void> _abrirDocumento() async {
    if (_documentoUrl == null || _documentoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum documento disponível ainda.'),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(_documentoUrl!);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF33CC80),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00994B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: PatientAppBar(
          title: 'Autorização Anvisa',
          fallbackRoute: '/patient/account',
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final status = _status;
    final inscricao = _fmtDate(_paciente?['anvisa_inscricao_data']?.toString());
    final expedicao = _fmtDate(_paciente?['anvisa_expedicao_data']?.toString());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Autorização Anvisa',
        fallbackRoute: '/patient/account',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anvisa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 24, width: double.infinity),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Última solicitação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inscricao,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atualizações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 124,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 124,
                        child: Text(
                          'Data\nda solicitação',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          expedicao,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5E5E5B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(
                    icon: Icons.visibility,
                    label: 'Visualizar documento',
                    onPressed: _abrirDocumento,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Declaração da Anvisa',
                    onPressed: _abrirDocumento,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

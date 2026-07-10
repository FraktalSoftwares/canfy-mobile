import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class CanfyIdPage extends StatefulWidget {
  const CanfyIdPage({super.key});

  @override
  State<CanfyIdPage> createState() => _CanfyIdPageState();
}

class _CanfyIdPageState extends State<CanfyIdPage> {
  final PatientService _patientService = PatientService();

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _paciente;
  Map<String, dynamic>? _receita;
  bool _loading = true;
  bool _gerandoPdf = false;

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
    final profile = data?['profile'] as Map<String, dynamic>?;
    final paciente = data?['paciente'] as Map<String, dynamic>?;
    Map<String, dynamic>? receita;
    final pacienteId = paciente?['id'] as String?;
    if (pacienteId != null) {
      receita = await _patientService.getMostRecentReceita(pacienteId);
    }
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _paciente = paciente;
      _receita = receita;
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

  bool get _validadeExpirada {
    final v = _paciente?['anvisa_validade_data'] as String?;
    final d = v != null ? DateTime.tryParse(v) : null;
    return d != null && d.isBefore(DateTime.now());
  }

  Future<void> _adicionarWallet() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Integração pendente'),
        content: const Text(
          'A adição do Canfy ID à Wallet (Apple/Google) depende de uma integração externa ainda não configurada. Use "Baixar em PDF" para guardar seu cartão offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _baixarPdf() async {
    setState(() => _gerandoPdf = true);
    try {
      final nome = _profile?['nome_completo']?.toString() ?? '--';
      final cpf = _paciente?['cpf']?.toString() ?? '--';
      final nascimento = _fmtDate(_paciente?['data_nascimento']?.toString());
      final nacionalidade =
          _paciente?['nacionalidade']?.toString() ?? 'Brasileiro';
      final inscricao =
          _fmtDate(_paciente?['anvisa_inscricao_data']?.toString());
      final numeroRegistro =
          _paciente?['anvisa_numero_registro']?.toString() ?? '--';
      final expedicao =
          _fmtDate(_paciente?['anvisa_expedicao_data']?.toString());
      final validade =
          _fmtDate(_paciente?['anvisa_validade_data']?.toString());
      final qrData = (_receita?['documento_url'] as String?) ??
          'https://canfy.app/paciente/${_paciente?['id']}';

      final qrImage = await QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
      ).toImageData(600);
      final qrBytes = qrImage!.buffer.asUint8List();

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Canfy',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#00994B'))),
                pw.SizedBox(height: 8),
                pw.Text('Paciente Registrado | Cannabis Medicinal',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 24),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfField('Nome', nome),
                          _pdfField('CPF', cpf),
                          _pdfField('Data nascimento', nascimento),
                          _pdfField('Nacionalidade', nacionalidade),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 24),
                    pw.Image(pw.MemoryImage(qrBytes), width: 140, height: 140),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 16),
                _pdfField('Inscrição Anvisa', inscricao),
                _pdfField('Número de registro', numeroRegistro),
                _pdfField('Expedição Anvisa', expedicao),
                _pdfField('Validade Anvisa', validade),
              ],
            ),
          ),
        ),
      );

      final bytes = await doc.save();
      if (!mounted) return;
      await Printing.sharePdf(bytes: bytes, filename: 'canfy_id.pdf');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o PDF.')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  pw.Widget _pdfField(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final nome = _profile?['nome_completo']?.toString() ?? '--';
    final cpf = _paciente?['cpf']?.toString() ?? '--';
    final nascimento = _fmtDate(_paciente?['data_nascimento']?.toString());
    final nacionalidade =
        _paciente?['nacionalidade']?.toString() ?? '--';
    final inscricao = _fmtDate(_paciente?['anvisa_inscricao_data']?.toString());
    final numeroRegistro =
        _paciente?['anvisa_numero_registro']?.toString() ?? '--';
    final expedicao = _fmtDate(_paciente?['anvisa_expedicao_data']?.toString());
    final validade = _fmtDate(_paciente?['anvisa_validade_data']?.toString());
    final avatarUrl = _profile?['foto_perfil_url'] as String?;
    final qrData = (_receita?['documento_url'] as String?) ??
        'https://canfy.app/paciente/${_paciente?['id']}';

    return Scaffold(
      backgroundColor: AppColors.neutral000,
      appBar: PatientAppBar(
        title: 'Canfy ID',
        fallbackRoute: '/patient/account',
        avatarUrl: avatarUrl,
        avatarTappable: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.neutral000,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 20,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.canfyPurpleLight,
                          AppColors.neutral000,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Canfy',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.canfyGreen,
                              ),
                            ),
                            const Icon(Icons.eco,
                                color: AppColors.canfyGreen, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Paciente Registrado | Cannabis Medicinal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.neutral200,
                              backgroundImage: avatarUrl != null &&
                                      avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null || avatarUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      color: AppColors.neutral600)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.canfyPurpleMedium
                                          .withOpacity(0.7),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Paciente',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4E3390),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                          child:
                                              _cardField('Nome', nome)),
                                      Expanded(
                                          child: _cardField('CPF', cpf)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _cardField(
                                              'Data nascimento',
                                              nascimento)),
                                      Expanded(
                                          child: _cardField(
                                              'Nacionalidade',
                                              nacionalidade)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _cardField(
                                      'Inscrição Anvisa', inscricao),
                                  const SizedBox(height: 12),
                                  _cardField('Número de registro',
                                      numeroRegistro),
                                  const SizedBox(height: 12),
                                  _cardField(
                                      'Expedição Anvisa', expedicao),
                                  const SizedBox(height: 12),
                                  _cardField(
                                    'Validade Anvisa',
                                    validade,
                                    valueColor: _validadeExpirada
                                        ? AppColors.error
                                        : AppColors.neutral900,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: QrImageView(
                                data: qrData,
                                size: 120,
                                gapless: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Canfy ID',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O Canfy ID é um cartão de identificação que você pode '
                    'adicionar na Wallet do seu celular ou baixar como '
                    'arquivo PDF para ter sempre com você, mesmo off-line.',
                    style: TextStyle(fontSize: 14, color: AppColors.neutral600),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _adicionarWallet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.canfyGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Adicionar a Wallet'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _gerandoPdf ? null : _baixarPdf,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.canfyGreen,
                        side: const BorderSide(color: AppColors.canfyGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _gerandoPdf
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.canfyGreen,
                              ),
                            )
                          : const Text('Baixar em PDF'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _cardField(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.neutral600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

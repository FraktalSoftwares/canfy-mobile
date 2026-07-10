import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../services/api/medico_service.dart';

/// Prontuário do Paciente — wizard de 5 blocos (Figma 12.1.2.2).
class ProntuarioPage extends StatefulWidget {
  final String consultaId;
  const ProntuarioPage({super.key, required this.consultaId});

  @override
  State<ProntuarioPage> createState() => _ProntuarioPageState();
}

class _ProntuarioPageState extends State<ProntuarioPage> {
  final MedicoService _medicoService = MedicoService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int _currentBlock = 1;

  String? _prontuarioId;
  Map<String, dynamic>? _consulta;
  Map<String, dynamic>? _paciente;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _anamnese;
  Map<String, dynamic>? _medico;
  String _status = 'rascunho';

  final _alergiasController = TextEditingController();
  final _evolucaoController = TextEditingController();
  final _posologiaController = TextEditingController();
  final _instrucoesController = TextEditingController();
  final _recomendacoesController = TextEditingController();
  final _observacoesController = TextEditingController();
  bool _lgpdConsentimento = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _alergiasController.dispose();
    _evolucaoController.dispose();
    _posologiaController.dispose();
    _instrucoesController.dispose();
    _recomendacoesController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final contextoResult =
        await _medicoService.getProntuarioContexto(widget.consultaId);
    if (contextoResult['success'] != true) {
      setState(() {
        _errorMessage =
            contextoResult['message'] as String? ?? 'Erro ao carregar dados';
        _isLoading = false;
      });
      return;
    }

    final data = contextoResult['data'] as Map<String, dynamic>;
    final anamnese = data['anamnese'] as Map<String, dynamic>?;

    final prontuarioResult =
        await _medicoService.getProntuario(widget.consultaId);
    final prontuario = prontuarioResult['success'] == true
        ? prontuarioResult['data'] as Map<String, dynamic>?
        : null;
    final conteudo = prontuario?['conteudo'] as Map<String, dynamic>?;

    if (!mounted) return;
    setState(() {
      _consulta = data['consulta'] as Map<String, dynamic>?;
      _paciente = data['paciente'] as Map<String, dynamic>?;
      _profile = data['profile'] as Map<String, dynamic>?;
      _anamnese = anamnese;
      _medico = data['medico'] as Map<String, dynamic>?;
      _prontuarioId = prontuario?['id'] as String?;
      _status = prontuario?['status'] as String? ?? 'rascunho';

      _alergiasController.text = conteudo?['alergias_registro'] as String? ??
          _defaultAlergiasText(anamnese);
      _evolucaoController.text = conteudo?['evolucao_clinica'] as String? ?? '';
      _posologiaController.text = conteudo?['posologia_geral'] as String? ?? '';
      _instrucoesController.text =
          conteudo?['instrucoes_complementares'] as String? ?? '';
      _recomendacoesController.text =
          conteudo?['recomendacoes_gerais'] as String? ?? '';
      _observacoesController.text =
          conteudo?['observacoes_especificas'] as String? ?? '';
      _lgpdConsentimento =
          conteudo?['lgpd_consentimento'] as bool? ?? false;

      _isLoading = false;
    });
  }

  String _defaultAlergiasText(Map<String, dynamic>? anamnese) {
    if (anamnese == null) return '';
    final temAlergias = anamnese['tem_alergias'] as bool? ?? false;
    if (!temAlergias) return 'Paciente não relatou alergias.';
    return anamnese['alergias_detalhes'] as String? ?? '';
  }

  Map<String, dynamic> _buildConteudo() {
    return {
      'alergias_registro': _alergiasController.text.trim(),
      'evolucao_clinica': _evolucaoController.text.trim(),
      'posologia_geral': _posologiaController.text.trim(),
      'instrucoes_complementares': _instrucoesController.text.trim(),
      'recomendacoes_gerais': _recomendacoesController.text.trim(),
      'observacoes_especificas': _observacoesController.text.trim(),
      'lgpd_consentimento': _lgpdConsentimento,
    };
  }

  Future<bool> _save({String? status}) async {
    final consulta = _consulta;
    if (consulta == null) return false;
    setState(() => _isSaving = true);

    final result = await _medicoService.upsertProntuario(
      prontuarioId: _prontuarioId,
      consultaId: widget.consultaId,
      pacienteId: consulta['paciente_id'] as String,
      medicoId: consulta['medico_id'] as String,
      conteudo: _buildConteudo(),
      status: status ?? _status,
    );

    if (!mounted) return false;
    setState(() => _isSaving = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ??
              'Erro ao salvar prontuário'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final savedId = (result['data'] is Map)
        ? (result['data'] as Map)['id'] as String?
        : null;
    setState(() {
      _prontuarioId ??= savedId;
      if (status != null) _status = status;
    });
    return true;
  }

  Future<void> _goNext() async {
    final ok = await _save();
    if (!ok || !mounted) return;
    if (_currentBlock < 5) {
      setState(() => _currentBlock++);
    }
  }

  void _goBack() {
    if (_currentBlock > 1) {
      setState(() => _currentBlock--);
    } else {
      context.pop();
    }
  }

  Future<void> _concluir() async {
    if (!_lgpdConsentimento) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'É necessário autorizar o tratamento dos dados (LGPD) para concluir.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final ok = await _save(status: 'finalizado');
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prontuário concluído com sucesso.')),
    );
    context.pop();
  }

  void _showNuvieIndisponivel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assinatura digital indisponível'),
        content: const Text(
            'A integração com o provedor de assinatura digital (Nuvie) ainda não foi configurada. '
            'Por enquanto, a conclusão do prontuário é registrada apenas com a autorização LGPD abaixo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.canfyGreen)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _goBack,
        ),
        title: const Text(
          'Prontuário do Paciente',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 16),
              const Text(
                'Prontuário do Paciente',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              _buildBlockTag(),
              const SizedBox(height: 24),
              _buildCurrentBlock(),
              const SizedBox(height: 24),
              _buildActionButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (index) {
        final active = index < _currentBlock;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.canfyGreen
                  : const Color(0xFFD6D6D3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBlockTag() {
    const labels = {
      1: 'Bloco 1 - Dados do Paciente e da Consulta',
      2: 'Bloco 2 - Anamnese do Paciente',
      3: 'Bloco 3 - Evolução Clínica',
      4: 'Bloco 4 - Conduta e Orientações',
      5: 'Bloco 5 - Aspectos Legais',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0EE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labels[_currentBlock]!,
        style: const TextStyle(fontSize: 12, color: Color(0xFF3F3F3D)),
      ),
    );
  }

  Widget _buildCurrentBlock() {
    switch (_currentBlock) {
      case 1:
        return _buildBlock1();
      case 2:
        return _buildBlock2();
      case 3:
        return _buildTextBlock(
          title: 'Evolução clínica',
          hint:
              'Utilize este campo para inserir o histórico da moléstia atual, sintomas relevantes descritos pelo paciente, achados clínicos decorrentes da conversa e seu raciocínio clínico.',
          controller: _evolucaoController,
        );
      case 4:
        return _buildBlock4();
      default:
        return _buildBlock5();
    }
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ',
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121))),
          ),
        ],
      ),
    );
  }

  String get _pacienteNome =>
      _profile?['nome_completo'] as String? ?? 'Paciente';

  String _formatIdade(String? dataNascimento) {
    if (dataNascimento == null) return '—';
    final nasc = DateTime.tryParse(dataNascimento);
    if (nasc == null) return '—';
    final hoje = DateTime.now();
    int anos = hoje.year - nasc.year;
    int meses = hoje.month - nasc.month;
    int dias = hoje.day - nasc.day;
    if (dias < 0) {
      meses--;
      final diasNoMesAnterior =
          DateTime(hoje.year, hoje.month, 0).day;
      dias += diasNoMesAnterior;
    }
    if (meses < 0) {
      anos--;
      meses += 12;
    }
    return '$anos anos, $meses meses e $dias dias';
  }

  Widget _buildBlock1() {
    final consulta = _consulta ?? {};
    final dataConsulta = DateTime.tryParse(
        consulta['data_consulta']?.toString() ?? '');
    final numero = widget.consultaId.substring(0, 5).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(children: [
          const Text('Dados do paciente',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 16),
          const Text('Paciente',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
          Text(_pacienteNome,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          const SizedBox(height: 16),
          _labelValue('Documento:', '${_paciente?['cpf'] ?? '—'} (CPF)'),
          _labelValue('Data de nascimento',
              _paciente?['data_nascimento'] as String? ?? '—'),
          _labelValue(
              'Idade:', _formatIdade(_paciente?['data_nascimento'] as String?)),
          const SizedBox(height: 12),
          _labelValue('Telefone:', _profile?['telefone'] as String? ?? '—'),
          _labelValue('E-mail:', _profile?['email'] as String? ?? '—'),
          const SizedBox(height: 12),
          _labelValue('CEP:', _paciente?['cep'] as String? ?? '—'),
          _labelValue(
              'Endereço:', _paciente?['endereco_completo'] as String? ?? '—'),
          _labelValue('Complemento:',
              _paciente?['endereco_complemento'] as String? ?? '—'),
        ]),
        const SizedBox(height: 24),
        _sectionCard(children: [
          const Text('Dados da consulta',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('#$numero • ',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
              const Text('Teleconsulta',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _labelColumn('Data',
                    dataConsulta != null
                        ? '${dataConsulta.day.toString().padLeft(2, '0')}/${dataConsulta.month.toString().padLeft(2, '0')}/${dataConsulta.year}'
                        : '—'),
              ),
              Expanded(
                child: _labelColumn(
                    'Hora',
                    dataConsulta != null
                        ? '${dataConsulta.hour.toString().padLeft(2, '0')}:${dataConsulta.minute.toString().padLeft(2, '0')}'
                        : '—'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_medico?['nome'] as String? ?? 'Médico',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          Text('CRM ${_medico?['crm'] ?? '—'}',
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF7C7C79))),
        ]),
      ],
    );
  }

  Widget _labelColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F3F3D))),
      ],
    );
  }

  Widget _buildBlock2() {
    final peso = _anamnese?['peso'];
    final altura = _anamnese?['altura'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(children: [
          const Text('Peso e altura',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 12),
          _labelValue('Peso:', peso != null ? '$peso kg' : 'Não informado'),
          _labelValue(
              'Altura:', altura != null ? '$altura cm' : 'Não informado'),
          const SizedBox(height: 12),
          _aiBanner(),
        ]),
        const SizedBox(height: 24),
        _sectionCard(children: [
          const Text('Alergias',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 12),
          const Text('Registro de alergias para este atendimento',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
          const SizedBox(height: 8),
          TextField(
            controller: _alergiasController,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6D6D3)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _aiBanner(
              text:
                  'Conteúdo pré-preenchido a partir da anamnese do paciente. Edite conforme necessário.'),
        ]),
      ],
    );
  }

  Widget _buildBlock4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldSection('Posologia geral', _posologiaController),
        const SizedBox(height: 20),
        _textFieldSection(
            'Instruções complementares', _instrucoesController),
        const SizedBox(height: 20),
        _textFieldSection('Recomendações gerais', _recomendacoesController),
        const SizedBox(height: 20),
        _textFieldSection(
            'Observações específicas', _observacoesController),
      ],
    );
  }

  Widget _textFieldSection(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F3F3D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextBlock({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return _sectionCard(children: [
      const Text('Dados do paciente',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F3F3D))),
      Text(_pacienteNome,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
      const SizedBox(height: 20),
      Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F3F3D))),
      const SizedBox(height: 6),
      Text(hint,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7C7C79))),
      const SizedBox(height: 12),
      TextField(
        controller: controller,
        maxLines: 6,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD6D6D3)),
          ),
        ),
      ),
    ]);
  }

  Widget _buildBlock5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(children: [
          const Text('Dados do paciente',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3F3D))),
          Text(_pacienteNome,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
        ]),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _lgpdConsentimento,
              activeColor: AppColors.canfyGreen,
              onChanged: (v) =>
                  setState(() => _lgpdConsentimento = v ?? false),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Autorizo o tratamento dos dados, nos termos da Lei Geral de Proteção de Dados (LGPD), para as finalidades relacionadas ao uso desta plataforma.',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF3F3F3D)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: OutlinedButton.icon(
            onPressed: _showNuvieIndisponivel,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Assinar com Nuvie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.canfyGreen,
              side: const BorderSide(color: AppColors.canfyGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Assinatura digital em conformidade com ICP-Brasil (integração pendente de configuração).',
          style: TextStyle(fontSize: 11, color: Color(0xFF9A9A97)),
        ),
      ],
    );
  }

  Widget _aiBanner({String? text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFC3A6F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text ?? 'Conteúdo pré-preenchido automaticamente',
              style: const TextStyle(fontSize: 12, color: Color(0xFF4E3390)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isLast = _currentBlock == 5;
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton(
        onPressed: _isSaving ? null : (isLast ? _concluir : _goNext),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.canfyGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(isLast ? 'Concluir prontuário' : 'Próximo'),
      ),
    );
  }
}

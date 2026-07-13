import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/consultation/consultation_model.dart';
import '../../../widgets/consultation/consultation_widgets.dart';
import '../../../services/api/configuracoes_service.dart';

const _naoFizExameRecentemente = 'Não fiz nenhum exame recentemente';
const _nuncaUtilizeiProdutos = 'Nunca utilizei';

/// Etapa 1 (continuação) do fluxo de nova consulta: histórico de saúde
/// (exames recentes, produtos de cannabis já utilizados, reações adversas e
/// preferência por produtos nacionais).
class NewConsultationHealthHistoryPage extends StatefulWidget {
  final NewConsultationFormData? formData;

  const NewConsultationHealthHistoryPage({super.key, this.formData});

  @override
  State<NewConsultationHealthHistoryPage> createState() =>
      _NewConsultationHealthHistoryPageState();
}

class _NewConsultationHealthHistoryPageState
    extends State<NewConsultationHealthHistoryPage> {
  final TextEditingController _reacoesController = TextEditingController();
  final ConfiguracoesService _configuracoesService = ConfiguracoesService();

  final List<String> _exames = [];
  final List<String> _produtos = [];
  bool? _prefereNacionais;
  String? _valorConsultaText;

  @override
  void initState() {
    super.initState();
    _loadValorConsulta();
  }

  Future<void> _loadValorConsulta() async {
    final result = await _configuracoesService.getValorConsultaPadrao();
    if (!mounted) return;
    if (result['success'] == true && result['data'] != null) {
      final valor = result['data'] as double;
      setState(() {
        _valorConsultaText =
            'Valor: R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
      });
    }
  }

  static const _examesOptions = [
    'Exame de sangue',
    'Exame de urina',
    'Exame de imagem',
    'Outros',
  ];

  static const _produtosOptions = [
    'Óleo de CBD isolado (sem THC)',
    'Óleo Full Spectrum (CBD + THC)',
    'Óleo CBD: THC em outras concentrações',
    'Flor de cannabis',
    'Comestíveis',
    'Nano caplets',
    'Produtos de uso tópico',
    'Uso recreativo',
    'Outros',
  ];

  bool get _nenhumExameRecente => _exames.contains(_naoFizExameRecentemente);
  bool get _nuncaUtilizouProdutos =>
      _produtos.contains(_nuncaUtilizeiProdutos);

  @override
  void dispose() {
    _reacoesController.dispose();
    super.dispose();
  }

  void _toggleExclusive(List<String> list, String exclusiveOption) {
    setState(() {
      if (list.contains(exclusiveOption)) {
        list.remove(exclusiveOption);
      } else {
        list
          ..clear()
          ..add(exclusiveOption);
      }
    });
  }

  void _toggleOption(List<String> list, String option, String exclusiveOption) {
    setState(() {
      list.remove(exclusiveOption);
      if (list.contains(option)) {
        list.remove(option);
      } else {
        list.add(option);
      }
    });
  }

  void _goToNextStep() {
    final updatedFormData =
        (widget.formData ?? NewConsultationFormData()).copyWith(
      examesRecentes: List<String>.from(_exames),
      produtosUtilizados: List<String>.from(_produtos),
      reacoesAdversas: _reacoesController.text.trim().isEmpty
          ? null
          : _reacoesController.text.trim(),
      prefereProdutosNacionais: _prefereNacionais,
    );
    context.push(
      '/patient/consultations/new/step2',
      extra: updatedFormData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ConsultationAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ConsultationStepIndicator(currentStep: 1),
                  const SizedBox(height: 20),
                  ConsultationStepHeader(
                    stepNumber: 1,
                    stepTitle: 'Motivo da consulta',
                    valueText: _valorConsultaText,
                  ),
                  const SizedBox(height: 24),
                  ConsultationSectionCard(
                    title: 'Exames recentes',
                    subtitle:
                        'Marque todos os exames que você realizou recentemente',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ConsultationSymptomTag(
                          symptom: _naoFizExameRecentemente,
                          isSelected: _nenhumExameRecente,
                          onTap: () => _toggleExclusive(
                              _exames, _naoFizExameRecentemente),
                        ),
                        for (final opcao in _examesOptions)
                          ConsultationSymptomTag(
                            symptom: opcao,
                            isSelected: _exames.contains(opcao),
                            onTap: () => _toggleOption(
                                _exames, opcao, _naoFizExameRecentemente),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConsultationSectionCard(
                    title: 'Produtos utilizados',
                    subtitle:
                        'Marque todos os produtos à base de cannabis dos quais você já fez uso',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ConsultationSymptomTag(
                          symptom: _nuncaUtilizeiProdutos,
                          isSelected: _nuncaUtilizouProdutos,
                          onTap: () => _toggleExclusive(
                              _produtos, _nuncaUtilizeiProdutos),
                        ),
                        for (final opcao in _produtosOptions)
                          ConsultationSymptomTag(
                            symptom: opcao,
                            isSelected: _produtos.contains(opcao),
                            onTap: () => _toggleOption(
                                _produtos, opcao, _nuncaUtilizeiProdutos),
                          ),
                      ],
                    ),
                  ),
                  if (!_nuncaUtilizouProdutos) ...[
                    const SizedBox(height: 16),
                    ConsultationSectionCard(
                      title: 'Reações Adversas',
                      subtitle:
                          'Você já experimentou alguma reação adversa ao usar produtos à base de cannabis?',
                      child: ConsultationTextField(
                        label: '',
                        controller: _reacoesController,
                        hintText:
                            'Que tipo de reação?\nQuais foram os sintomas?',
                        maxLines: 5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ConsultationSectionCard(
                    title: 'Preferência de produtos',
                    subtitle:
                        'Selecione se você prefere comprar produtos nacionais para tratamento com de cannabis medicinal.',
                    child: Row(
                      children: [
                        ConsultationSymptomTag(
                          symptom: 'Sim',
                          isSelected: _prefereNacionais == true,
                          onTap: () =>
                              setState(() => _prefereNacionais = true),
                        ),
                        const SizedBox(width: 12),
                        ConsultationSymptomTag(
                          symptom: 'Não',
                          isSelected: _prefereNacionais == false,
                          onTap: () =>
                              setState(() => _prefereNacionais = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ConsultationPrimaryButton(
                text: 'Próximo',
                onPressed: _goToNextStep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

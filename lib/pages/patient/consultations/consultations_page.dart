import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../services/api/patient_service.dart';

class ConsultationsPage extends StatefulWidget {
  const ConsultationsPage({super.key});

  @override
  State<ConsultationsPage> createState() => _ConsultationsPageState();
}

class _ConsultationsPageState extends State<ConsultationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _upcomingConsultations = [];
  List<Map<String, dynamic>> _pastConsultations = [];
  List<Map<String, dynamic>> _prescriptions = [];
  bool _isLoading = true;
  bool _prescriptionsLoading = false;
  String? _errorMessage;
  String? _patientAvatarUrl;

  /// Próxima consulta que inicia em breve (para o banner). Null se não houver.
  Map<String, dynamic>? _imminentConsultation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadConsultations();
    _loadPatientProfile();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 &&
        _prescriptions.isEmpty &&
        !_prescriptionsLoading) {
      _loadPrescriptions();
    }
  }

  Future<void> _loadPatientProfile() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final profile = data['profile'] as Map<String, dynamic>?;
        if (profile != null && mounted) {
          setState(() {
            _patientAvatarUrl = profile['foto_perfil_url'] as String?;
          });
        }
      }
    } catch (_) {}
  }

  /// Consulta para o CTA fixo: apenas consultas "Agendada" ou "Em andamento".
  /// Consultas canceladas ou finalizadas não devem mostrar o banner de "vai iniciar".
  void _computeImminentConsultation() {
    // Busca apenas consultas que vão realmente acontecer
    final validStatuses = ['Agendada', 'Em andamento'];

    // Primeiro, verifica nas consultas futuras (upcoming)
    for (final consultation in _upcomingConsultations) {
      final status = consultation['status'] as String?;
      if (status != null && validStatuses.contains(status)) {
        _imminentConsultation = consultation;
        return;
      }
    }

    // Se não encontrou em upcoming, não faz sentido buscar em past
    // porque consultas passadas não "vão iniciar"
    _imminentConsultation = null;
  }

  Future<void> _loadConsultations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _patientService.getConsultations();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _upcomingConsultations =
              List<Map<String, dynamic>>.from(data['upcoming'] ?? []);
          _pastConsultations =
              List<Map<String, dynamic>>.from(data['past'] ?? []);
          _isLoading = false;
          _computeImminentConsultation();
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Erro ao carregar consultas';
          _isLoading = false;
          _imminentConsultation = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar consultas: ${e.toString()}';
        _isLoading = false;
        _imminentConsultation = null;
      });
    }
  }

  Future<void> _loadPrescriptions() async {
    if (_prescriptions.isNotEmpty && !_prescriptionsLoading) return;
    setState(() => _prescriptionsLoading = true);
    try {
      final result = await _patientService.getPrescriptions(onlyActive: false);
      if (result['success'] == true && result['data'] != null && mounted) {
        setState(() {
          _prescriptions =
              List<Map<String, dynamic>>.from(result['data'] ?? []);
          _prescriptionsLoading = false;
        });
      } else {
        setState(() => _prescriptionsLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _prescriptionsLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  ImageProvider _avatarImageProvider(dynamic url) {
    if (url != null && url is String && url.startsWith('http')) {
      return NetworkImage(url);
    }
    return const AssetImage('assets/images/avatar_pictures.png');
  }

  /// Exibe "Realizada" no design quando o status da API é "Finalizada".
  String _displayStatus(String? status) {
    if (status == null) return 'Agendada';
    if (status == 'Finalizada') return 'Realizada';
    return status;
  }

  Widget _buildConsultationCard(
      BuildContext context, Map<String, dynamic> consultation) {
    final status = consultation['status'] as String?;
    final displayStatus = _displayStatus(status);

    // Tags de agendamento – design Figma (node 2770-19007)
    Color statusColor;
    Color statusTextColor;
    switch (displayStatus) {
      case 'Agendada':
        statusColor = AppColors.neutral100;
        statusTextColor = AppColors.canfyGreen;
        break;
      case 'Em andamento':
        statusColor = AppColors.statusYellow;
        statusTextColor = AppColors.statusYellowDark;
        break;
      case 'Realizada':
        statusColor = AppColors.statusGrey;
        statusTextColor = AppColors.statusGreyDark;
        break;
      case 'Cancelada':
        statusColor = AppColors.statusCancelBg;
        statusTextColor = AppColors.statusCancelText;
        break;
      default:
        statusColor = AppColors.statusGrey;
        statusTextColor = AppColors.statusGreyDark;
    }

    return GestureDetector(
      onTap: () {
        context.push('/patient/consultations/${consultation['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.neutral050,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7E5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1: #id • data • hora | tag status (oval)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${consultation['date']} • ${consultation['time']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linha 2: avatar | nome + especialidade | círculo com seta (branca)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.neutral200,
                  backgroundImage:
                      _avatarImageProvider(consultation['doctorAvatar']),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation['doctorName'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        consultation['doctorSpecialty'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.canfyGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
            if (consultation['mainComplaint'] != null &&
                consultation['mainComplaint'].toString().isNotEmpty) ...[
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
                      text: consultation['mainComplaint'].toString(),
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
            if (consultation['isReturn'] == true) ...[
              const SizedBox(height: 8),
              const Text(
                'Consulta de retorno',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
      BuildContext context, Map<String, dynamic> prescription) {
    return GestureDetector(
      onTap: () {
        context.push('/patient/prescriptions');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral050,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emissão: ${prescription['issueDate'] ?? '--'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.neutral900,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              prescription['product'] as String? ?? '--',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prescrito por ${prescription['doctor'] ?? '--'}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Validade ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  prescription['validity'] as String? ?? '--',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- CTA fixo Figma node 2175-1547 ---
  // Especificações: cápsula verde, ícone video_call 40x40, texto branco, chevron 22px

  /// CTA "Sua próxima consulta vai iniciar em X min" (Figma 2175-1547).
  /// Sempre usa o ícone de video_call e o texto conforme Figma quando há consulta.
  Widget _buildImminentBanner(BuildContext context) {
    final c = _imminentConsultation;
    if (c == null) return const SizedBox.shrink();

    // Calcular minutos até a consulta
    int minutes = 10;
    final raw = c['data_consulta_raw'];
    if (raw != null) {
      try {
        DateTime dt = raw is String ? DateTime.parse(raw) : raw as DateTime;
        final nowLocal = DateTime.now();
        if (dt.isUtc) dt = dt.toLocal();
        final diff = dt.difference(nowLocal);
        minutes = diff.inMinutes;
        if (minutes < 1) minutes = 1;
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: const Color(0xFF33CC80), // green-500 do Figma
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () => context.push('/patient/consultations/live/${c['id']}'),
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Ícone video_call (40x40) conforme Figma
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child:
                        Icon(Icons.video_call, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 17),
                  // Texto conforme Figma: normal + "X min" em semi-bold
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                              text: 'Sua próxima consulta vai iniciar em '),
                          TextSpan(
                            text: '$minutes min',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chevron 22x22 conforme Figma
                  const Icon(Icons.chevron_right,
                      color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// CTA "Agende sua próxima consulta" (mesmo estilo Figma).
  Widget _buildScheduleNextBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: const Color(0xFF33CC80), // green-500 do Figma
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () => context.push('/patient/consultations/new/step1'),
          borderRadius: BorderRadius.circular(999),
          child: const SizedBox(
            height: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 17),
                  Expanded(
                    child: Text(
                      'Agende sua próxima consulta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Consultas',
        showLeading: true,
        fallbackRoute: '/patient/home',
        avatarUrl: _patientAvatarUrl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título grande + botão verde (nova consulta)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consultas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/patient/consultations/new/step1');
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.canfyGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.canfyGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs: Histórico de consultas | Receitas
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.canfyGreen,
              labelColor: AppColors.canfyGreen,
              unselectedLabelColor: AppColors.neutral600,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Histórico de consultas'),
                Tab(text: 'Receitas'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.canfyGreen))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.neutral600),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _loadConsultations,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Histórico de consultas (próximas + passadas em uma lista)
                          Builder(
                            builder: (context) {
                              final allConsultations = [
                                ..._upcomingConsultations,
                                ..._pastConsultations,
                              ];
                              return RefreshIndicator(
                                onRefresh: _loadConsultations,
                                color: AppColors.canfyGreen,
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    if (allConsultations.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 32),
                                        child: Center(
                                          child: Text(
                                            'Nenhuma consulta no histórico.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.neutral600,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...allConsultations.map((c) =>
                                          _buildConsultationCard(context, c)),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Receitas
                          Builder(
                            builder: (context) {
                              if (_prescriptionsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.canfyGreen),
                                );
                              }
                              return RefreshIndicator(
                                onRefresh: _loadPrescriptions,
                                color: AppColors.canfyGreen,
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  children: _prescriptions.isEmpty
                                      ? [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 32),
                                            child: Center(
                                              child: Text(
                                                'Nenhuma receita encontrada.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.neutral600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                      : _prescriptions
                                          .map((p) => _buildPrescriptionCard(
                                              context, p))
                                          .toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_imminentConsultation != null)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              color: Colors.transparent,
              child: _buildImminentBanner(context),
            )
          else if (!_isLoading && _errorMessage == null)
            _buildScheduleNextBanner(context),
          const PatientBottomNavigationBar(
            currentIndex: 2,
          ),
        ],
      ),
    );
  }
}

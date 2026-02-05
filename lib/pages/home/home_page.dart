import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api/api_service.dart';
import '../../services/api/medico_service.dart';
import '../../utils/product_image_utils.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/safe_image_asset.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  final MedicoService _medicoService = MedicoService();
  String? _nomeCompleto;
  String? _avatarUrl;
  bool _loading = true;
  String? _error;

  // Dados reais da home
  final String _totalReceber = 'R\$ 0,00';
  int _consultasRealizadas = 0;
  int _atendimentosSemana = 0;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _catalogProducts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  static DateTime? _parseDataConsulta(dynamic dataConsulta) {
    if (dataConsulta == null) return null;
    try {
      if (dataConsulta is String) {
        return DateTime.parse(dataConsulta.trim()).toUtc();
      }
      if (dataConsulta is DateTime) return dataConsulta.toUtc();
      return DateTime.tryParse(dataConsulta.toString())?.toUtc();
    } catch (_) {
      return null;
    }
  }

  static String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString().substring(2);
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$min';
  }

  /// Carrega profile, médico, consultas e catálogo.
  Future<void> _loadUserData() async {
    final user = _api.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Usuário não autenticado';
        });
      }
      return;
    }
    try {
      final profileFuture = _api.getFiltered(
        'profiles',
        filters: {'id': user.id},
        limit: 1,
      );
      final medicoFuture = _medicoService.getMedicoByCurrentUser();

      final profileResult = await profileFuture;
      final medicoResult = await medicoFuture;

      if (!mounted) return;

      String? nome;
      String? avatarUrl;
      String? medicoId;

      if (profileResult['success'] == true && profileResult['data'] != null) {
        final list = profileResult['data'] as List;
        if (list.isNotEmpty) {
          final profile = list[0] as Map<String, dynamic>;
          nome = profile['nome_completo'] as String?;
          avatarUrl = profile['avatar_url'] as String? ??
              profile['foto_perfil_url'] as String?;
          if (avatarUrl != null) avatarUrl = _resolveAvatarUrl(avatarUrl);
        }
      }
      if ((nome == null || nome.trim().isEmpty) &&
          medicoResult['success'] == true &&
          medicoResult['data'] != null) {
        final medico = medicoResult['data'] as Map<String, dynamic>;
        nome = medico['nome'] as String?;
        medicoId = medico['id'] as String?;
      } else if (medicoResult['success'] == true &&
          medicoResult['data'] != null) {
        medicoId =
            (medicoResult['data'] as Map<String, dynamic>)['id'] as String?;
      }

      setState(() {
        _nomeCompleto = nome?.trim().isNotEmpty == true ? nome : null;
        _avatarUrl = avatarUrl?.trim().isNotEmpty == true ? avatarUrl : null;
      });

      if (medicoId != null) {
        await _loadHomeStats(medicoId);
        await _loadCatalog();
      }

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadHomeStats(String medicoId) async {
    try {
      final result = await _medicoService.getConsultasByMedico(medicoId);
      if (result['success'] != true || result['data'] == null || !mounted) {
        return;
      }
      final list = result['data'] as List;
      final nowUtc = DateTime.now().toUtc();
      final startOfWeekUtc = nowUtc.subtract(const Duration(days: 7));
      int realizadas = 0;
      int semana = 0;
      final upcoming = <Map<String, dynamic>>[];

      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final c = raw;
        final dt = _parseDataConsulta(c['data_consulta']);
        if (dt == null) continue;
        final status = (c['status'] as String? ?? '').toLowerCase();
        if (status == 'cancelada' || status == 'cancelado') continue;

        if (dt.isBefore(nowUtc)) {
          realizadas++;
          if (!dt.isBefore(startOfWeekUtc)) semana++;
        } else {
          if (upcoming.length < 10) {
            upcoming.add({
              'id': c['id'],
              'data_consulta': c['data_consulta'],
              'dt': dt,
              'paciente_id': c['paciente_id'],
              'status': c['status'],
            });
          }
        }
      }

      upcoming.sort((a, b) {
        final da = a['dt'] as DateTime?;
        final db = b['dt'] as DateTime?;
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });

      final withNames = <Map<String, dynamic>>[];
      for (final a in upcoming.take(5)) {
        final pacienteId = a['paciente_id'] as String?;
        String patientName = 'Paciente';
        if (pacienteId != null) {
          patientName = await _medicoService.getPacienteNome(pacienteId);
        }
        withNames.add({
          'dateTime': _formatDateTime(a['dt'] as DateTime),
          'patient': patientName,
          'value': 'R\$ —',
          'consultaId': a['id'],
        });
      }

      if (mounted) {
        setState(() {
          _consultasRealizadas = realizadas;
          _atendimentosSemana = semana;
          _upcomingAppointments = withNames;
        });
      }
    } catch (_) {
      // mantém valores padrão
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final result = await _medicoService.getProdutosCatalogo(limit: 8);
      if (result['success'] != true || result['data'] == null || !mounted) {
        return;
      }
      final list = result['data'] as List;
      final products = <Map<String, dynamic>>[];
      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final p = raw;
        final name =
            p['nome_comercial'] as String? ?? p['nome'] as String? ?? 'Produto';
        final tipo = p['tipo'] as String? ?? p['forma'] as String? ?? '—';
        final indications =
            p['indications'] ?? p['indicacoes'] ?? p['indicacao'];
        List<String> indList = [];
        if (indications is List) {
          indList = indications.map((e) => e.toString()).toList();
        } else if (indications is String && indications.isNotEmpty) {
          indList = [indications];
        }
        final imageValue = ProductImageUtils.getProductImageValue(p);
        final resolvedUrl =
            ProductImageUtils.resolveProductImageUrl(imageValue);
        products.add({
          'id': p['id'],
          'name': name,
          'type': tipo,
          'indications': indList,
          'price': p['preco'],
          'imageUrl': resolvedUrl,
        });
      }
      if (mounted) {
        setState(() => _catalogProducts = products);
      }
    } catch (_) {}
  }

  /// Retorna URL exibível: se já for http(s) devolve como está; senão trata como path no bucket avatars.
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

  String _buildGreeting() {
    if (_nomeCompleto != null && _nomeCompleto!.trim().isNotEmpty) {
      final nome = _nomeCompleto!.trim();
      final primeiroNome = nome.contains(' ') ? nome.split(' ').first : nome;
      return 'Boas vindas, Dr(a). $primeiroNome!';
    }
    return 'Boas vindas!';
  }

  Widget _buildAppBarAvatar() {
    final hasValidUrl = _avatarUrl != null &&
        _avatarUrl!.trim().isNotEmpty &&
        _avatarUrl!.startsWith('http');
    final avatar = hasValidUrl
        ? CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(_avatarUrl!),
            onBackgroundImageError: (_, __) {},
          )
        : CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.black54, size: 22),
          );
    return GestureDetector(
      onTap: () => context.push('/profile'),
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7E7F1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment['dateTime'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE6E6E3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paciente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['patient'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: 1.5708, // 90 graus
                  child: IconButton(
                    icon: Transform.rotate(
                      angle: 4.7124, // 270 graus
                      child:
                          const Icon(Icons.chevron_right, color: Colors.black),
                    ),
                    onPressed: () {
                      context.push('/appointment/pre-consultation');
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F8EF),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Valor da consulta:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  appointment['value'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: 144,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFC3A6F9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const SafeImageAsset(
              imagePath:
                  'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
              fit: BoxFit.contain,
              placeholderIcon: Icons.local_pharmacy,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              children: [
                TextSpan(text: 'Canabidiol\n'),
                TextSpan(
                  text: 'Óleo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardFromMap(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? 'Produto';
    final type = product['type'] as String? ?? '—';
    final imageUrl = product['imageUrl'] as String?;
    final url = imageUrl != null && imageUrl.toString().trim().isNotEmpty
        ? imageUrl.toString().trim()
        : null;
    return GestureDetector(
      onTap: () => context.push('/catalog/product-details'),
      child: Container(
        width: 144,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFC3A6F9),
                borderRadius: BorderRadius.circular(999),
              ),
              clipBehavior: Clip.antiAlias,
              child: url != null
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: 96,
                      height: 96,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_pharmacy,
                        size: 48,
                        color: Color(0xFF212121),
                      ),
                    )
                  : const Icon(
                      Icons.local_pharmacy,
                      size: 48,
                      color: Color(0xFF212121),
                    ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
                children: [
                  TextSpan(text: '$name\n'),
                  TextSpan(
                    text: type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildAppBarAvatar(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saudação
                      Text(
                        _buildGreeting(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Card Total a receber
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE7E7F1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total a receber',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7C7C79),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _totalReceber,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3F3F3D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.rotate(
                              angle: 1.5708,
                              child: IconButton(
                                icon: Transform.rotate(
                                  angle: 4.7124,
                                  child: const Icon(Icons.chevron_right,
                                      color: Colors.black),
                                ),
                                onPressed: () {
                                  context.push('/financial');
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFE6F8EF),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cards de estatísticas
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Consultas realizadas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3F3F3D),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_consultasRealizadas',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3F3F3D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Atendimentos\nda semana',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3F3F3D),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_atendimentosSemana',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3F3F3D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Próximos atendimentos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Próximos atendimentos',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/appointment');
                            },
                            child: const Text(
                              'Ver tudo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7048C3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Lista de atendimentos
                      ..._upcomingAppointments.map((appointment) =>
                          _buildAppointmentCard(context, appointment)),
                      const SizedBox(height: 32),
                      // Catálogo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Catálogo',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/catalog');
                            },
                            child: const Text(
                              'Ver tudo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7048C3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Lista horizontal de produtos
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final product in _catalogProducts) ...[
                              _buildProductCardFromMap(product),
                              const SizedBox(width: 16),
                            ],
                            if (_catalogProducts.isEmpty) _buildProductCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 0),
    );
  }
}

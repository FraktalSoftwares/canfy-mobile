import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/api_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiService _apiService = ApiService();

  // Preferências de notificação
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _pushAlerts = true;

  // Tipos de notificações
  bool _consultationAlerts = true;
  bool _deliveryAlerts = true;
  bool _anvisaAlerts = true;
  bool _newPrescriptionAlerts = true;

  bool _isLoading = true;
  String? _preferencesId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final result = await _apiService.getFiltered(
        'preferencias_notificacoes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      if (result['success'] == true && result['data'] != null) {
        final prefs = result['data'] as List;
        if (prefs.isNotEmpty && mounted) {
          final pref = prefs[0] as Map<String, dynamic>;
          _preferencesId = pref['id'] as String?;
          setState(() {
            _emailAlerts = pref['notif_email'] as bool? ?? true;
            _smsAlerts = pref['notif_sms'] as bool? ?? false;
            _pushAlerts = pref['notif_push'] as bool? ?? true;
            _consultationAlerts = pref['tipos_consultas'] as bool? ?? true;
            _deliveryAlerts = pref['tipos_entregas'] as bool? ?? true;
            _anvisaAlerts = pref['tipos_anvisa'] as bool? ?? true;
            _newPrescriptionAlerts = pref['tipos_novas_receitas'] as bool? ?? true;
            _isLoading = false;
          });
        } else {
          await _createDefaultPreferences(user.id);
        }
      } else {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) await _createDefaultPreferences(user.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar preferências: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Cria preferências padrão e retorna o id do registro (ou null).
  /// Se já existir registro para o user (ex.: unique violation), busca e retorna o id.
  Future<String?> _createDefaultPreferences(String userId) async {
    try {
      // Usar insertWithReturn para receber o id do registro criado
      final result = await _apiService.insertWithReturn(
        'preferencias_notificacoes',
        {
          'user_id': userId,
          'notif_email': true,
          'notif_sms': false,
          'notif_push': true,
          'tipos_consultas': true,
          'tipos_entregas': true,
          'tipos_anvisa': true,
          'tipos_novas_receitas': true,
        },
      );

      if (result['success'] == true && result['data'] != null && mounted) {
        final data = result['data'];
        Map<String, dynamic> pref;
        if (data is List && data.isNotEmpty) {
          pref = data[0] as Map<String, dynamic>;
        } else if (data is Map) {
          pref = data as Map<String, dynamic>;
        } else {
          pref = await _fetchPreferencesByUserId(userId);
          if (pref.isEmpty) {
            if (mounted) setState(() => _isLoading = false);
            return null;
          }
        }
        final id = pref['id'] as String?;
        setState(() {
          _preferencesId = id;
          _emailAlerts = pref['notif_email'] as bool? ?? true;
          _smsAlerts = pref['notif_sms'] as bool? ?? false;
          _pushAlerts = pref['notif_push'] as bool? ?? true;
          _consultationAlerts = pref['tipos_consultas'] as bool? ?? true;
          _deliveryAlerts = pref['tipos_entregas'] as bool? ?? true;
          _anvisaAlerts = pref['tipos_anvisa'] as bool? ?? true;
          _newPrescriptionAlerts = pref['tipos_novas_receitas'] as bool? ?? true;
          _isLoading = false;
        });
        return id;
      }
      // Inserção falhou (ex.: já existe por user_id) — buscar registro existente
      final pref = await _fetchPreferencesByUserId(userId);
      if (pref.isNotEmpty && mounted) {
        final id = pref['id'] as String?;
        setState(() {
          _preferencesId = id;
          _emailAlerts = pref['notif_email'] as bool? ?? true;
          _smsAlerts = pref['notif_sms'] as bool? ?? false;
          _pushAlerts = pref['notif_push'] as bool? ?? true;
          _consultationAlerts = pref['tipos_consultas'] as bool? ?? true;
          _deliveryAlerts = pref['tipos_entregas'] as bool? ?? true;
          _anvisaAlerts = pref['tipos_anvisa'] as bool? ?? true;
          _newPrescriptionAlerts = pref['tipos_novas_receitas'] as bool? ?? true;
          _isLoading = false;
        });
        return id;
      }
      if (mounted) setState(() => _isLoading = false);
      return null;
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar preferências: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchPreferencesByUserId(String userId) async {
    final res = await _apiService.getFiltered(
      'preferencias_notificacoes',
      filters: {'user_id': userId},
      limit: 1,
    );
    if (res['success'] != true || res['data'] == null) return {};
    final list = res['data'] as List;
    if (list.isEmpty) return {};
    return list[0] as Map<String, dynamic>;
  }

  Future<void> _savePreferences() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    String? id = _preferencesId;
    if (id == null) {
      id = await _createDefaultPreferences(user.id);
      if (id != null) setState(() => _preferencesId = id);
    }
    if (id == null) return;

    try {
      final result = await _apiService.put(
        'preferencias_notificacoes',
        {'id': id},
        {
          'notif_email': _emailAlerts,
          'notif_sms': _smsAlerts,
          'notif_push': _pushAlerts,
          'tipos_consultas': _consultationAlerts,
          'tipos_entregas': _deliveryAlerts,
          'tipos_anvisa': _anvisaAlerts,
          'tipos_novas_receitas': _newPrescriptionAlerts,
        },
      );

      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro ao salvar preferências'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Transform.rotate(
              angle: 1.5708,
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ),
            onPressed: () {
              if (context.canPop()) context.pop();
              else context.go('/profile');
            },
          ),
          title: const Text(
            'Preferências',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: const [DoctorAppBarAvatar()],
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 0),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Preferências',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          DoctorAppBarAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: AppTextStyles.truculenta(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Preferências de notificação
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferências de notificação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por e-mail',
                    _emailAlerts,
                    (value) {
                      setState(() => _emailAlerts = value);
                      _savePreferences();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por SMS',
                    _smsAlerts,
                    (value) {
                      setState(() => _smsAlerts = value);
                      _savePreferences();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por push',
                    _pushAlerts,
                    (value) {
                      setState(() => _pushAlerts = value);
                      _savePreferences();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tipos de notificações
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipos de notificações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre consultas',
                    _consultationAlerts,
                    (value) {
                      setState(() => _consultationAlerts = value);
                      _savePreferences();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre entregas',
                    _deliveryAlerts,
                    (value) {
                      setState(() => _deliveryAlerts = value);
                      _savePreferences();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre a Anvisa',
                    _anvisaAlerts,
                    (value) {
                      setState(() => _anvisaAlerts = value);
                      _savePreferences();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre novas receitas',
                    _newPrescriptionAlerts,
                    (value) {
                      setState(() => _newPrescriptionAlerts = value);
                      _savePreferences();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildSwitchRow(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F3F3D),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF00994B),
        ),
      ],
    );
  }
}

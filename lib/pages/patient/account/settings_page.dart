import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/api/api_service.dart';

class PatientSettingsPage extends StatefulWidget {
  const PatientSettingsPage({super.key});

  @override
  State<PatientSettingsPage> createState() => _PatientSettingsPageState();
}

class _PatientSettingsPageState extends State<PatientSettingsPage> {
  final ApiService _apiService = ApiService();
  
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _pushAlerts = true;
  bool _consultationAlerts = true;
  bool _deliveryAlerts = true;
  bool _anvisaAlerts = true;
  bool _prescriptionAlerts = true;
  
  bool _isLoading = true;
  String? _preferencesId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Buscar preferências do usuário
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
            _prescriptionAlerts = pref['tipos_novas_receitas'] as bool? ?? true;
            _isLoading = false;
          });
        } else {
          // Criar preferências padrão se não existirem
          await _createDefaultPreferences(user.id);
        }
      } else {
        // Criar preferências padrão se não existirem
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          await _createDefaultPreferences(user.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar preferências: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createDefaultPreferences(String userId) async {
    try {
      final result = await _apiService.post(
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
        
        // O Supabase pode retornar um objeto único ou uma lista
        if (data is List && data.isNotEmpty) {
          pref = data[0] as Map<String, dynamic>;
        } else if (data is Map) {
          pref = data as Map<String, dynamic>;
        } else {
          // Se não conseguiu obter o ID, buscar novamente
          final fetchResult = await _apiService.getFiltered(
            'preferencias_notificacoes',
            filters: {'user_id': userId},
            limit: 1,
          );
          if (fetchResult['success'] == true && 
              fetchResult['data'] != null && 
              (fetchResult['data'] as List).isNotEmpty) {
            pref = (fetchResult['data'] as List)[0] as Map<String, dynamic>;
          } else {
            // Se não conseguiu buscar, usar valores padrão
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        
        setState(() {
          _preferencesId = pref['id'] as String?;
          _emailAlerts = pref['notif_email'] as bool? ?? true;
          _smsAlerts = pref['notif_sms'] as bool? ?? false;
          _pushAlerts = pref['notif_push'] as bool? ?? true;
          _consultationAlerts = pref['tipos_consultas'] as bool? ?? true;
          _deliveryAlerts = pref['tipos_entregas'] as bool? ?? true;
          _anvisaAlerts = pref['tipos_anvisa'] as bool? ?? true;
          _prescriptionAlerts = pref['tipos_novas_receitas'] as bool? ?? true;
          _isLoading = false;
        });
      } else if (mounted) {
        // Se não conseguiu criar, manter valores padrão e parar loading
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar preferências: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    if (_preferencesId == null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _createDefaultPreferences(user.id);
      }
      return;
    }

    try {
      final result = await _apiService.put(
        'preferencias_notificacoes',
        {'id': _preferencesId!},
        {
          'notif_email': _emailAlerts,
          'notif_sms': _smsAlerts,
          'notif_push': _pushAlerts,
          'tipos_consultas': _consultationAlerts,
          'tipos_entregas': _deliveryAlerts,
          'tipos_anvisa': _anvisaAlerts,
          'tipos_novas_receitas': _prescriptionAlerts,
        },
      );

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
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
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildNotificationSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          onChanged: (newValue) {
            onChanged(newValue);
            _savePreferences(); // Salvar automaticamente ao alterar
          },
          activeColor: const Color(0xFF00994B),
        ),
      ],
    );
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
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/patient/account');
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
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/account');
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
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
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por e-mail',
                    value: _emailAlerts,
                    onChanged: (value) {
                      setState(() {
                        _emailAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por SMS',
                    value: _smsAlerts,
                    onChanged: (value) {
                      setState(() {
                        _smsAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por push',
                    value: _pushAlerts,
                    onChanged: (value) {
                      setState(() {
                        _pushAlerts = value;
                      });
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
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre consultas',
                    value: _consultationAlerts,
                    onChanged: (value) {
                      setState(() {
                        _consultationAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre entregas',
                    value: _deliveryAlerts,
                    onChanged: (value) {
                      setState(() {
                        _deliveryAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre a Anvisa',
                    value: _anvisaAlerts,
                    onChanged: (value) {
                      setState(() {
                        _anvisaAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre novas receitas',
                    value: _prescriptionAlerts,
                    onChanged: (value) {
                      setState(() {
                        _prescriptionAlerts = value;
                      });
                    },
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







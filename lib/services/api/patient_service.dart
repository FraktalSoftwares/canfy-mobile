import '../api/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para operações relacionadas a pacientes
class PatientService {
  final ApiService _apiService = ApiService();

  /// Obter dados do paciente atual (profile + dados do paciente)
  Future<Map<String, dynamic>> getCurrentPatient() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Buscar profile
      final profileResult = await _apiService.getFiltered(
        'profiles',
        filters: {'id': user.id},
        limit: 1,
      );

      // Buscar dados específicos do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      final profiles = profileResult['success'] && profileResult['data'] != null
          ? profileResult['data'] as List
          : [];
      final pacientes =
          pacienteResult['success'] && pacienteResult['data'] != null
              ? pacienteResult['data'] as List
              : [];

      if (profiles.isNotEmpty) {
        return {
          'success': true,
          'data': {
            'profile': profiles[0],
            'paciente': pacientes.isNotEmpty ? pacientes[0] : null,
          },
        };
      }

      return {
        'success': false,
        'message': 'Perfil não encontrado',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar dados do paciente: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar pedidos recentes do paciente
  Future<Map<String, dynamic>> getRecentOrders({int limit = 5}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Primeiro, buscar o ID do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      if (!pacienteResult['success'] || pacienteResult['data'] == null) {
        return {
          'success': false,
          'message': 'Paciente não encontrado',
          'data': null,
        };
      }

      final pacientes = pacienteResult['data'] as List;
      if (pacientes.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pacienteId = pacientes[0]['id'] as String;

      // Buscar pedidos do paciente
      final pedidosResult = await _apiService.getFiltered(
        'pedidos',
        filters: {'paciente_id': pacienteId},
        limit: limit,
        orderBy: 'data_pedido',
        ascending: false,
      );

      if (!pedidosResult['success'] || pedidosResult['data'] == null) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pedidos = pedidosResult['data'] as List;

      // Para cada pedido, buscar os itens e o primeiro produto
      final pedidosCompletos = <Map<String, dynamic>>[];

      for (var pedido in pedidos) {
        final pedidoId = pedido['id'] as String;

        // Buscar itens do pedido
        final itensResult = await _apiService.getFiltered(
          'pedido_itens',
          filters: {'pedido_id': pedidoId},
          limit: 1,
        );

        String? productName;
        if (itensResult['success'] && itensResult['data'] != null) {
          final itens = itensResult['data'] as List;
          if (itens.isNotEmpty) {
            final produtoId = itens[0]['produto_id'] as String;

            // Buscar dados do produto
            final produtoResult = await _apiService.getFiltered(
              'produtos',
              filters: {'id': produtoId},
              limit: 1,
            );

            if (produtoResult['success'] && produtoResult['data'] != null) {
              final produtos = produtoResult['data'] as List;
              if (produtos.isNotEmpty) {
                productName = produtos[0]['nome_comercial'] as String?;
              }
            }
          }
        }

        pedidosCompletos.add({
          'id': pedidoId,
          'numero_pedido': pedido['numero_pedido'],
          'status': pedido['status'],
          'valor_total': pedido['valor_total'],
          'data_pedido': pedido['data_pedido'],
          'productName': productName ?? 'Produto',
        });
      }

      return {
        'success': true,
        'data': pedidosCompletos,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar pedidos: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar todos os pedidos do paciente com dados completos
  Future<Map<String, dynamic>> getAllOrders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Primeiro, buscar o ID do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      if (!pacienteResult['success'] || pacienteResult['data'] == null) {
        return {
          'success': false,
          'message': 'Paciente não encontrado',
          'data': null,
        };
      }

      final pacientes = pacienteResult['data'] as List;
      if (pacientes.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pacienteId = pacientes[0]['id'] as String;

      // Buscar todos os pedidos do paciente
      final pedidosResult = await _apiService.getFiltered(
        'pedidos',
        filters: {'paciente_id': pacienteId},
        orderBy: 'data_pedido',
        ascending: false,
      );

      if (!pedidosResult['success'] || pedidosResult['data'] == null) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pedidos = pedidosResult['data'] as List;
      final pedidosCompletos = <Map<String, dynamic>>[];

      for (var pedido in pedidos) {
        final pedidoId = pedido['id'] as String;

        // Buscar o primeiro item do pedido para obter o produto
        final itensResult = await _apiService.getFiltered(
          'pedido_itens',
          filters: {'pedido_id': pedidoId},
          limit: 1,
        );

        String productName = 'Produto não especificado';
        if (itensResult['success'] && itensResult['data'] != null) {
          final itens = itensResult['data'] as List;
          if (itens.isNotEmpty) {
            final produtoId = itens[0]['produto_id'] as String?;

            if (produtoId != null) {
              // Buscar dados do produto
              final produtoResult = await _apiService.getFiltered(
                'produtos',
                filters: {'id': produtoId},
                limit: 1,
              );

              if (produtoResult['success'] && produtoResult['data'] != null) {
                final produtos = produtoResult['data'] as List;
                if (produtos.isNotEmpty) {
                  productName = produtos[0]['nome_comercial'] as String? ??
                      'Produto não especificado';
                }
              }
            }
          }
        }

        // Mapear status do banco para o formato da UI
        String statusText = _mapStatusToText(pedido['status'] as String?);

        // Mapear canal de aquisição
        String channelText =
            _mapChannelToText(pedido['canal_aquisicao'] as String?);

        // Formatar valor
        String valueText = _formatValue(pedido['valor_total']);

        // Formatar data
        String dateText = _formatDate(pedido['data_pedido']);

        pedidosCompletos.add({
          'id': pedidoId,
          'number': pedido['numero_pedido'] ?? '#N/A',
          'date': dateText,
          'status': statusText,
          'product': productName,
          'channel': channelText,
          'value': valueText,
        });
      }

      return {
        'success': true,
        'data': pedidosCompletos,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar pedidos: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Mapeia o status do banco para o texto da UI
  String _mapStatusToText(String? status) {
    if (status == null) return 'Em análise';

    switch (status.toLowerCase()) {
      case 'em_analise':
      case 'pendente':
        return 'Em análise';
      case 'aprovado':
        return 'Aprovado';
      case 'em_separacao':
        return 'Em separação';
      case 'enviado':
        return 'Enviado';
      case 'entregue':
        return 'Entregue';
      case 'recusado':
        return 'Recusado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Em análise';
    }
  }

  /// Mapeia o canal de aquisição do banco para o texto da UI
  String _mapChannelToText(String? channel) {
    if (channel == null) return 'associação';

    switch (channel.toLowerCase()) {
      case 'associacao':
        return 'associação';
      case 'marca':
        return 'marca';
      case 'outro':
        return 'outro';
      default:
        return 'associação';
    }
  }

  /// Converte texto de canal para o enum do Supabase: associacao | marca | outro
  String _normalizeCanalAquisicao(String? canal) {
    if (canal == null || canal.isEmpty) return 'associacao';
    final c = canal.toLowerCase();
    if (c.contains('marca')) return 'marca';
    if (c.contains('associacao') ||
        c.contains('associação') ||
        c.contains('abc')) {
      return 'associacao';
    }
    return 'outro';
  }

  /// Formata o valor monetário
  String _formatValue(dynamic value) {
    if (value == null) return 'R\$ 0,00';

    try {
      final numValue = value is String ? double.parse(value) : value as num;
      return 'R\$ ${numValue.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  /// Formata a data (aceita String ISO, DateTime ou valor retornado pelo Supabase)
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Data não disponível';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        date = DateTime.parse(dateValue.toString());
      }

      // Formato DD/MM/YY
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString().substring(2);

      return '$day/$month/$year';
    } catch (e) {
      return 'Data não disponível';
    }
  }

  /// Mapeia status da consulta do banco para o texto da UI
  String _mapConsultationStatusToText(String? status) {
    if (status == null) return 'Agendada';
    switch (status.toLowerCase()) {
      case 'agendada':
        return 'Agendada';
      case 'em_andamento':
        return 'Em andamento';
      case 'finalizada':
        return 'Finalizada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  /// Formata hora (HH:mm) a partir de datetime
  String _formatTime(dynamic dateValue) {
    if (dateValue == null) return '--:--';
    try {
      DateTime dt;
      if (dateValue is String) {
        dt = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        dt = dateValue;
      } else {
        return '--:--';
      }
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  /// Buscar todas as consultas do paciente (próximas + histórico)
  Future<Map<String, dynamic>> getConsultations() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Buscar paciente direto no Supabase (mesma sessão auth que consultas)
      List<dynamic> pacientesList;
      try {
        final res = await Supabase.instance.client
            .from('pacientes')
            .select('id')
            .eq('user_id', user.id)
            .limit(1);
        pacientesList = List<dynamic>.from(res as List);
      } catch (e) {
        return {
          'success': false,
          'message': 'Erro ao buscar paciente: $e',
          'data': null,
          'error': e.toString(),
        };
      }

      if (pacientesList.isEmpty) {
        return {
          'success': true,
          'data': {'upcoming': [], 'past': []},
        };
      }

      final firstPaciente = pacientesList[0];
      if (firstPaciente is! Map) {
        return {
          'success': false,
          'message': 'Resposta inválida de pacientes',
          'data': null,
        };
      }
      final rawPacienteId = (firstPaciente)['id'];
      final pacienteId = rawPacienteId is String
          ? rawPacienteId
          : rawPacienteId?.toString() ?? '';
      if (pacienteId.isEmpty) {
        return {
          'success': false,
          'message': 'Paciente sem id',
          'data': null,
        };
      }

      // Busca direta no Supabase para garantir query e parsing corretos
      List<dynamic> consultas;
      try {
        final response = await Supabase.instance.client
            .from('consultas')
            .select()
            .eq('paciente_id', pacienteId)
            .order('data_consulta', ascending: false);
        consultas = List<dynamic>.from(response as List);
      } catch (e) {
        return {
          'success': false,
          'message': 'Erro ao buscar consultas: $e',
          'data': null,
          'error': e.toString(),
        };
      }

      final upcoming = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];

      final nowUtc = DateTime.now().toUtc();
      for (var raw in consultas) {
        if (raw is! Map) continue;
        final c = Map<String, dynamic>.from(raw);
        final statusRaw = c['status'];
        final status = statusRaw is String
            ? statusRaw.toLowerCase()
            : statusRaw?.toString().toLowerCase();
        final dataConsulta = c['data_consulta'];
        DateTime? dt;
        if (dataConsulta != null) {
          try {
            if (dataConsulta is String) {
              // Sem 'Z'/offset o Dart interpreta como hora local (evita marcar como passado)
              dt = DateTime.parse(dataConsulta.trim());
            } else if (dataConsulta is DateTime) {
              dt = dataConsulta;
            } else {
              dt = DateTime.tryParse(dataConsulta.toString());
            }
            if (dt != null && !dt.isUtc) dt = dt.toUtc();
          } catch (_) {
            dt = null;
          }
        }

        String doctorName = 'Médico não informado';
        String doctorSpecialty = 'Especialidade não informada';
        String? doctorAvatar;

        final medicoId = c['medico_id'] as String?;
        if (medicoId != null) {
          final medicoResult = await _apiService.getFiltered(
            'medicos',
            filters: {'id': medicoId},
            limit: 1,
          );
          if (medicoResult['success'] == true && medicoResult['data'] != null) {
            final medicos = medicoResult['data'] as List;
            if (medicos.isNotEmpty) {
              final medico = medicos[0];
              doctorName = medico['nome'] as String? ?? doctorName;
              final espId = medico['especialidade_id'] as String?;
              if (espId != null) {
                final espResult = await _apiService.getFiltered(
                  'especialidades',
                  filters: {'id': espId},
                  limit: 1,
                );
                if (espResult['success'] == true &&
                    espResult['data'] != null &&
                    (espResult['data'] as List).isNotEmpty) {
                  doctorSpecialty =
                      (espResult['data'] as List)[0]['nome'] as String? ??
                          doctorSpecialty;
                }
              }
              final userId = medico['user_id'] as String?;
              if (userId != null) {
                final profileResult = await _apiService.getFiltered(
                  'profiles',
                  filters: {'id': userId},
                  limit: 1,
                );
                if (profileResult['success'] == true &&
                    profileResult['data'] != null &&
                    (profileResult['data'] as List).isNotEmpty) {
                  doctorAvatar = (profileResult['data'] as List)[0]
                      ['foto_perfil_url'] as String?;
                }
              }
            }
          }
        }

        final consultaId = c['id'];
        final item = {
          'id': consultaId is String ? consultaId : consultaId?.toString(),
          'date': dt != null ? _formatDate(dt.toIso8601String()) : '--',
          'time': _formatTime(dataConsulta),
          'status': _mapConsultationStatusToText(status),
          'doctorName': doctorName,
          'doctorSpecialty': doctorSpecialty,
          'specialty': doctorSpecialty,
          'doctorAvatar': doctorAvatar,
          'mainComplaint': c['queixa_principal'] as String?,
          'isReturn': c['eh_retorno'] == true,
          'data_consulta_raw': dataConsulta,
          'status_raw': status,
        };

        final isPast = status == 'finalizada' ||
            status == 'cancelada' ||
            (dt != null && dt.toUtc().isBefore(nowUtc));
        if (isPast) {
          past.add(item);
        } else {
          upcoming.add(item);
        }
      }

      // Próximas: ordenar por data crescente; histórico: já vem decrescente
      upcoming.sort((a, b) {
        final da = a['data_consulta_raw'];
        final db = b['data_consulta_raw'];
        if (da == null || db == null) return 0;
        final dta = da is String ? DateTime.parse(da) : da as DateTime;
        final dtb = db is String ? DateTime.parse(db) : db as DateTime;
        return dta.compareTo(dtb);
      });

      return {
        'success': true,
        'data': {'upcoming': upcoming, 'past': past},
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar consultas: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar consultas próximas do paciente (para home)
  Future<Map<String, dynamic>> getUpcomingConsultations({int limit = 5}) async {
    try {
      final result = await getConsultations();
      if (result['success'] != true || result['data'] == null) {
        return result;
      }
      final data = result['data'] as Map<String, dynamic>;
      final upcoming = data['upcoming'] as List? ?? [];
      final limited =
          upcoming.length > limit ? upcoming.sublist(0, limit) : upcoming;
      return {
        'success': true,
        'data': limited,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar consultas: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Cria uma nova consulta (registro na tabela consultas) e retorna o id.
  /// Deve ser chamado antes de criar o pagamento no Asaas, para vincular
  /// reference_id ao id da consulta.
  Future<Map<String, dynamic>> createConsultation({
    required String pacienteId,
    required String dataConsultaIso,
    required String queixaPrincipal,
    String? medicoId,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      final row = <String, dynamic>{
        'paciente_id': pacienteId,
        'data_consulta': dataConsultaIso,
        'status': 'agendada',
        'queixa_principal':
            queixaPrincipal.isNotEmpty ? queixaPrincipal : 'Consulta agendada',
        'eh_retorno': false,
        if (medicoId != null && medicoId.isNotEmpty) 'medico_id': medicoId,
      };

      final result = await _apiService.insertWithReturn('consultas', row);
      if (result['success'] != true) {
        return {
          'success': false,
          'message': result['message'] as String? ?? 'Erro ao criar consulta',
          'data': null,
          'error': result['error'],
        };
      }

      final inserted = result['data'] as Map<String, dynamic>?;
      final id = inserted?['id'] as String?;
      if (id == null) {
        return {
          'success': false,
          'message': 'Resposta inválida ao criar consulta',
          'data': null,
        };
      }

      return {
        'success': true,
        'data': {'id': id},
        'message': 'Consulta criada',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar consulta: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar detalhes de uma consulta por ID
  Future<Map<String, dynamic>> getConsultationById(
      String consultationId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      final consultaResult = await _apiService.getFiltered(
        'consultas',
        filters: {'id': consultationId},
        limit: 1,
      );

      if (!consultaResult['success'] || consultaResult['data'] == null) {
        return {
          'success': false,
          'message': 'Consulta não encontrada',
          'data': null,
        };
      }

      final list = consultaResult['data'] as List;
      if (list.isEmpty) {
        return {
          'success': false,
          'message': 'Consulta não encontrada',
          'data': null,
        };
      }

      final c = list[0];

      // Garantir que é do paciente logado
      final pacienteId = c['paciente_id'] as String?;
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'id': pacienteId, 'user_id': user.id},
        limit: 1,
      );
      if (!pacienteResult['success'] ||
          pacienteResult['data'] == null ||
          (pacienteResult['data'] as List).isEmpty) {
        return {
          'success': false,
          'message': 'Consulta não encontrada',
          'data': null,
        };
      }

      String doctorName = 'Médico não informado';
      String doctorSpecialty = 'Especialidade não informada';
      String? doctorAvatar;

      final medicoId = c['medico_id'] as String?;
      if (medicoId != null) {
        final medicoResult = await _apiService.getFiltered(
          'medicos',
          filters: {'id': medicoId},
          limit: 1,
        );
        if (medicoResult['success'] == true && medicoResult['data'] != null) {
          final medicos = medicoResult['data'] as List;
          if (medicos.isNotEmpty) {
            final medico = medicos[0];
            doctorName = medico['nome'] as String? ?? doctorName;
            final espId = medico['especialidade_id'] as String?;
            if (espId != null) {
              final espResult = await _apiService.getFiltered(
                'especialidades',
                filters: {'id': espId},
                limit: 1,
              );
              if (espResult['success'] == true &&
                  espResult['data'] != null &&
                  (espResult['data'] as List).isNotEmpty) {
                doctorSpecialty =
                    (espResult['data'] as List)[0]['nome'] as String? ??
                        doctorSpecialty;
              }
            }
            final userId = medico['user_id'] as String?;
            if (userId != null) {
              final profileResult = await _apiService.getFiltered(
                'profiles',
                filters: {'id': userId},
                limit: 1,
              );
              if (profileResult['success'] == true &&
                  profileResult['data'] != null &&
                  (profileResult['data'] as List).isNotEmpty) {
                doctorAvatar = (profileResult['data'] as List)[0]
                    ['foto_perfil_url'] as String?;
              }
            }
          }
        }
      }

      final dataConsulta = c['data_consulta'];
      DateTime? dt;
      if (dataConsulta != null) {
        dt = dataConsulta is String
            ? DateTime.parse(dataConsulta)
            : dataConsulta as DateTime;
      }

      Map<String, dynamic>? prescription;
      final receitaId = c['receita_id'] as String?;
      if (receitaId != null) {
        final receitaResult = await _apiService.getFiltered(
          'receitas',
          filters: {'id': receitaId},
          limit: 1,
        );
        if (receitaResult['success'] == true &&
            receitaResult['data'] != null &&
            (receitaResult['data'] as List).isNotEmpty) {
          final rec = (receitaResult['data'] as List)[0];
          final medicoIdRec = rec['medico_id'] as String?;
          String prescribedBy = doctorName;
          if (medicoIdRec != null) {
            final mRes = await _apiService.getFiltered(
              'medicos',
              filters: {'id': medicoIdRec},
              limit: 1,
            );
            if (mRes['success'] == true &&
                mRes['data'] != null &&
                (mRes['data'] as List).isNotEmpty) {
              prescribedBy =
                  (mRes['data'] as List)[0]['nome'] as String? ?? doctorName;
            }
          }
          final itensResult = await _apiService.getFiltered(
            'receita_itens',
            filters: {'receita_id': receitaId},
            limit: 1,
          );
          String product = 'Produto não especificado';
          if (itensResult['success'] == true &&
              itensResult['data'] != null &&
              (itensResult['data'] as List).isNotEmpty) {
            final item = (itensResult['data'] as List)[0];
            final prodId = item['produto_id'] as String?;
            if (prodId != null) {
              final prodRes = await _apiService.getFiltered(
                'produtos',
                filters: {'id': prodId},
                limit: 1,
              );
              if (prodRes['success'] == true &&
                  prodRes['data'] != null &&
                  (prodRes['data'] as List).isNotEmpty) {
                product =
                    (prodRes['data'] as List)[0]['nome_comercial'] as String? ??
                        product;
              }
            }
          }
          prescription = {
            'emissionDate': _formatDate(rec['data_emissao']),
            'validityDate': _formatDate(rec['validade']),
            'product': product,
            'prescribedBy': prescribedBy,
            'observations': rec['observacoes'] as String? ?? '',
          };
        }
      }

      final statusText = _mapConsultationStatusToText(c['status'] as String?);

      return {
        'success': true,
        'data': {
          'id': c['id'],
          'date': dt != null ? _formatDate(dt.toIso8601String()) : '--',
          'time': _formatTime(dataConsulta),
          'status': statusText,
          'status_raw': c['status'],
          'data_consulta_raw': dataConsulta,
          'doctorName': doctorName,
          'doctorSpecialty': doctorSpecialty,
          'doctorAvatar': doctorAvatar,
          'mainComplaint': c['queixa_principal'] as String? ?? '',
          'prescription': prescription,
          'isReturn': c['eh_retorno'] == true,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar consulta: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar receitas do paciente (ativas e válidas)
  Future<Map<String, dynamic>> getPrescriptions(
      {bool onlyActive = true}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Primeiro, buscar o ID do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      if (!pacienteResult['success'] || pacienteResult['data'] == null) {
        return {
          'success': false,
          'message': 'Paciente não encontrado',
          'data': null,
        };
      }

      final pacientes = pacienteResult['data'] as List;
      if (pacientes.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pacienteId = pacientes[0]['id'] as String;

      // Buscar receitas do paciente
      Map<String, dynamic> filters = {'paciente_id': pacienteId};
      if (onlyActive) {
        filters['status'] = 'ativa';
      }

      final receitasResult = await _apiService.getFiltered(
        'receitas',
        filters: filters,
        orderBy: 'data_emissao',
        ascending: false,
      );

      if (!receitasResult['success'] || receitasResult['data'] == null) {
        return {
          'success': true,
          'data': [],
        };
      }

      final receitas = receitasResult['data'] as List;
      final receitasCompletas = <Map<String, dynamic>>[];
      final hoje = DateTime.now();

      for (var receita in receitas) {
        final receitaId = receita['id'] as String;
        final medicoId = receita['medico_id'] as String?;

        // Verificar se a receita ainda está válida (não expirou)
        if (onlyActive) {
          final validade = receita['validade'];
          if (validade != null) {
            try {
              DateTime validadeDate;
              if (validade is String) {
                validadeDate = DateTime.parse(validade);
              } else if (validade is DateTime) {
                validadeDate = validade;
              } else {
                continue; // Pular se não conseguir parsear a data
              }

              // Comparar apenas a data (sem hora)
              final validadeDateOnly = DateTime(
                  validadeDate.year, validadeDate.month, validadeDate.day);
              final hojeDateOnly = DateTime(hoje.year, hoje.month, hoje.day);

              if (validadeDateOnly.isBefore(hojeDateOnly)) {
                continue; // Pular receitas expiradas
              }
            } catch (e) {
              // Se houver erro ao parsear a data, continuar com a receita
            }
          }
        }

        // Buscar dados do médico
        String medicoNome = 'Médico não especificado';
        if (medicoId != null) {
          final medicoResult = await _apiService.getFiltered(
            'medicos',
            filters: {'id': medicoId},
            limit: 1,
          );

          if (medicoResult['success'] && medicoResult['data'] != null) {
            final medicos = medicoResult['data'] as List;
            if (medicos.isNotEmpty) {
              medicoNome =
                  medicos[0]['nome'] as String? ?? 'Médico não especificado';
            }
          }
        }

        // Buscar produtos da receita
        final itensResult = await _apiService.getFiltered(
          'receita_itens',
          filters: {'receita_id': receitaId},
        );

        String produtoNome = 'Produto não especificado';
        double valorTotal = 0.0;

        if (itensResult['success'] && itensResult['data'] != null) {
          final itens = itensResult['data'] as List;
          if (itens.isNotEmpty) {
            final primeiroItem = itens[0];
            final produtoId = primeiroItem['produto_id'] as String?;

            if (produtoId != null) {
              final produtoResult = await _apiService.getFiltered(
                'produtos',
                filters: {'id': produtoId},
                limit: 1,
              );

              double precoUnitario = 0.0;
              if (produtoResult['success'] && produtoResult['data'] != null) {
                final produtos = produtoResult['data'] as List;
                if (produtos.isNotEmpty) {
                  produtoNome = produtos[0]['nome_comercial'] as String? ??
                      'Produto não especificado';
                  // Usar preço do produto (campo preco na tabela produtos)
                  final precoProduto = produtos[0]['preco'];
                  if (precoProduto != null) {
                    try {
                      precoUnitario = precoProduto is String
                          ? double.tryParse(precoProduto) ?? 0.0
                          : (precoProduto as num).toDouble();
                    } catch (_) {
                      precoUnitario = 0.0;
                    }
                  }
                }
              }
              // Fallback: preço do último pedido_itens se produto.preco não estiver definido
              if (precoUnitario <= 0) {
                final precoResult = await _apiService.getFiltered(
                  'pedido_itens',
                  filters: {'produto_id': produtoId},
                  orderBy: 'created_at',
                  ascending: false,
                  limit: 1,
                );
                if (precoResult['success'] &&
                    precoResult['data'] != null &&
                    (precoResult['data'] as List).isNotEmpty &&
                    (precoResult['data'] as List)[0]['preco_unitario'] !=
                        null) {
                  try {
                    final p =
                        (precoResult['data'] as List)[0]['preco_unitario'];
                    precoUnitario = p is String
                        ? double.tryParse(p) ?? 0.0
                        : (p as num).toDouble();
                  } catch (_) {
                    precoUnitario = 0.0;
                  }
                }
              }

              // Calcular valor total: somar todos os itens da receita
              for (var item in itens) {
                final quantidade = item['quantidade_prescrita'] as int? ?? 0;
                if (precoUnitario > 0) {
                  valorTotal += precoUnitario * quantidade;
                }
              }
            }
          }
        }

        // Formatar datas
        String dataEmissao = _formatDateDDMMYYYY(receita['data_emissao']);
        String validade = _formatDateDDMMYYYY(receita['validade']);

        receitasCompletas.add({
          'id': receitaId,
          'product': produtoNome,
          'doctor': medicoNome,
          'issueDate': dataEmissao,
          'validity': validade,
          'valorTotal': valorTotal,
        });
      }

      return {
        'success': true,
        'data': receitasCompletas,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar receitas: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Últimos documentos do paciente por tipo (identidade, comprovante_residencia).
  /// Usado no step3 do novo pedido para pré-preencher RG/CNH e Comprovante.
  Future<Map<String, dynamic>> getLastPatientDocuments() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null
        };
      }
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );
      if (!pacienteResult['success'] || pacienteResult['data'] == null) {
        return {
          'success': true,
          'data': {'identidade': null, 'comprovante_residencia': null}
        };
      }
      final pacientes = pacienteResult['data'] as List;
      if (pacientes.isEmpty) {
        return {
          'success': true,
          'data': {'identidade': null, 'comprovante_residencia': null}
        };
      }
      final pacienteId = pacientes[0]['id'] as String;
      final docsResult = await _apiService.getFiltered(
        'documentos',
        filters: {'paciente_id': pacienteId},
        orderBy: 'created_at',
        ascending: false,
      );
      Map<String, dynamic>? identidade;
      Map<String, dynamic>? comprovanteResidencia;
      if (docsResult['success'] == true && docsResult['data'] != null) {
        final list = docsResult['data'] as List;
        for (var doc in list) {
          final tipo = doc['tipo'] as String?;
          if (tipo == 'identidade' && identidade == null) {
            identidade = {
              'arquivo_url': doc['arquivo_url'],
              'nome_arquivo': doc['nome_arquivo'] ?? 'Documento',
            };
          } else if (tipo == 'comprovante_residencia' &&
              comprovanteResidencia == null) {
            comprovanteResidencia = {
              'arquivo_url': doc['arquivo_url'],
              'nome_arquivo': doc['nome_arquivo'] ?? 'Documento',
            };
          }
          if (identidade != null && comprovanteResidencia != null) break;
        }
      }
      return {
        'success': true,
        'data': {
          'identidade': identidade,
          'comprovante_residencia': comprovanteResidencia,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar documentos: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Lista apenas dois documentos na tela Meus dados: o mais recente RG/CNH (identidade)
  /// e o mais recente Comprovante de endereço (comprovante_residencia).
  Future<Map<String, dynamic>> getPatientDocuments() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );
      if (!pacienteResult['success'] ||
          pacienteResult['data'] == null ||
          (pacienteResult['data'] as List).isEmpty) {
        return {'success': true, 'data': <Map<String, dynamic>>[]};
      }
      final pacienteId = (pacienteResult['data'] as List)[0]['id'] as String;
      final docsResult = await _apiService.getFiltered(
        'documentos',
        filters: {'paciente_id': pacienteId},
        orderBy: 'created_at',
        ascending: false,
        limit: 20,
      );
      if (!docsResult['success'] || docsResult['data'] == null) {
        return {'success': true, 'data': <Map<String, dynamic>>[]};
      }
      final list = docsResult['data'] as List;
      final allDocs = list.map<Map<String, dynamic>>((d) {
        final doc = d as Map<String, dynamic>;
        return {
          'id': doc['id'],
          'tipo': doc['tipo'] ?? 'outro',
          'nome_arquivo': doc['nome_arquivo'] ?? 'Documento',
          'arquivo_url': doc['arquivo_url'],
        };
      }).toList();

      // Apenas RG/CNH (identidade) e Comprovante (comprovante_residencia); um de cada, o mais recente
      Map<String, dynamic>? identidade;
      Map<String, dynamic>? comprovante;
      for (final d in allDocs) {
        final tipo = d['tipo'] as String?;
        if (tipo == 'identidade' && identidade == null) {
          identidade = d;
        } else if (tipo == 'comprovante_residencia' && comprovante == null) {
          comprovante = d;
        }
        if (identidade != null && comprovante != null) break;
      }
      final docs = <Map<String, dynamic>>[];
      if (identidade != null) docs.add(identidade);
      if (comprovante != null) docs.add(comprovante);

      return {'success': true, 'data': docs};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar documentos: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Buscar detalhes de uma receita por ID (para novo pedido)
  /// Retorna receita + itens com produto_id, quantidade_prescrita, preco_unitario
  Future<Map<String, dynamic>> getPrescriptionDetails(String receitaId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      final receitaResult = await _apiService.getFiltered(
        'receitas',
        filters: {'id': receitaId},
        limit: 1,
      );

      if (!receitaResult['success'] || receitaResult['data'] == null) {
        return {
          'success': false,
          'message': 'Receita não encontrada',
          'data': null,
        };
      }

      final receitas = receitaResult['data'] as List;
      if (receitas.isEmpty) {
        return {
          'success': false,
          'message': 'Receita não encontrada',
          'data': null,
        };
      }

      final receita = receitas[0];
      final medicoId = receita['medico_id'] as String?;

      String medicoNome = 'Médico não especificado';
      if (medicoId != null) {
        final medicoResult = await _apiService.getFiltered(
          'medicos',
          filters: {'id': medicoId},
          limit: 1,
        );
        if (medicoResult['success'] &&
            medicoResult['data'] != null &&
            (medicoResult['data'] as List).isNotEmpty) {
          medicoNome = (medicoResult['data'] as List)[0]['nome'] as String? ??
              medicoNome;
        }
      }

      final itensResult = await _apiService.getFiltered(
        'receita_itens',
        filters: {'receita_id': receitaId},
      );

      final itens = <Map<String, dynamic>>[];
      String produtoNome = 'Produto não especificado';
      String? primeiroProdutoId;
      double precoUnitario = 0.0;

      if (itensResult['success'] && itensResult['data'] != null) {
        final itensList = itensResult['data'] as List;
        if (itensList.isNotEmpty) {
          final primeiroItem = itensList[0];
          primeiroProdutoId = primeiroItem['produto_id'] as String?;

          if (primeiroProdutoId != null) {
            final produtoResult = await _apiService.getFiltered(
              'produtos',
              filters: {'id': primeiroProdutoId},
              limit: 1,
            );
            if (produtoResult['success'] &&
                produtoResult['data'] != null &&
                (produtoResult['data'] as List).isNotEmpty) {
              final produto = (produtoResult['data'] as List)[0];
              produtoNome = produto['nome_comercial'] as String? ?? produtoNome;
              // Usar preço do produto (campo preco na tabela produtos)
              final precoProduto = produto['preco'];
              if (precoProduto != null) {
                precoUnitario = precoProduto is String
                    ? double.tryParse(precoProduto) ?? 0.0
                    : (precoProduto as num).toDouble();
              }
            }
            // Fallback: preço do último pedido_itens se produto.preco não estiver definido
            if (precoUnitario <= 0) {
              final precoResult = await _apiService.getFiltered(
                'pedido_itens',
                filters: {'produto_id': primeiroProdutoId},
                orderBy: 'created_at',
                ascending: false,
                limit: 1,
              );
              if (precoResult['success'] &&
                  precoResult['data'] != null &&
                  (precoResult['data'] as List).isNotEmpty) {
                final p = (precoResult['data'] as List)[0]['preco_unitario'];
                if (p != null) {
                  precoUnitario = p is String
                      ? double.tryParse(p) ?? 0.0
                      : (p as num).toDouble();
                }
              }
            }
          }

          for (var item in itensList) {
            final prodId = item['produto_id'] as String?;
            final qtd = item['quantidade_prescrita'] as int? ?? 0;
            itens.add({
              'produto_id': prodId,
              'quantidade_prescrita': qtd,
              'produto_nome': produtoNome,
              'preco_unitario': precoUnitario,
            });
          }
        }
      }

      return {
        'success': true,
        'data': {
          'id': receita['id'],
          'data_emissao': receita['data_emissao'],
          'validade': receita['validade'],
          'medico_nome': medicoNome,
          'issueDate': _formatDateDDMMYYYY(receita['data_emissao']),
          'validity': _formatDateDDMMYYYY(receita['validade']),
          'itens': itens,
          'produto_nome': produtoNome,
          'produto_id': primeiroProdutoId,
          'preco_unitario': precoUnitario,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar receita: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Criar novo pedido (paciente)
  Future<Map<String, dynamic>> createOrder({
    required String receitaId,
    required String pacienteId,
    required int quantity,
    required double valorTotal,
    required String canalAquisicao,
    required String formaPagamento,
    required String? produtoId,
    required double precoUnitario,
    String? rgDocumentUrl,
    String? addressProofUrl,
    String? anvisaDocumentUrl,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // canal_aquisicao no Supabase é enum: 'associacao' | 'marca' | 'outro'
      final canalNormalizado = _normalizeCanalAquisicao(canalAquisicao);

      final numeroPedido = 'CAN-${DateTime.now().millisecondsSinceEpoch}';
      final dataPedido = DateTime.now().toIso8601String();

      final pedidoData = {
        'paciente_id': pacienteId,
        'receita_id': receitaId,
        'status': 'pendente',
        'valor_total': valorTotal,
        'data_pedido': dataPedido,
        'canal_aquisicao': canalNormalizado,
        'forma_pagamento': formaPagamento,
        'numero_pedido': numeroPedido,
      };

      final insertResult = await _apiService.insertWithReturn(
        'pedidos',
        pedidoData,
      );

      if (!insertResult['success'] || insertResult['data'] == null) {
        return {
          'success': false,
          'message': insertResult['message'] ?? 'Erro ao criar pedido',
          'data': null,
        };
      }

      final pedido = insertResult['data'] as Map<String, dynamic>;
      final pedidoId = pedido['id'] as String?;

      if (pedidoId == null) {
        return {
          'success': false,
          'message': 'Pedido criado mas ID não retornado',
          'data': null,
        };
      }

      // pedido_itens.produto_id é UUID obrigatório no Supabase
      if (produtoId != null && produtoId.isNotEmpty) {
        final precoTotal = precoUnitario * quantity;
        final itemData = {
          'pedido_id': pedidoId,
          'produto_id': produtoId,
          'quantidade': quantity,
          'preco_unitario': precoUnitario,
          'preco_total': precoTotal,
        };
        await _apiService.post('pedido_itens', itemData);
      }

      // documentos.tipo no Supabase é enum: identidade | comprovante_residencia | autorizacao_anvisa | laudo_medico | exame | outro
      // Vincula cada documento ao pedido (pedido_id) para exibir só os docs deste pedido na tela de detalhes.
      if (rgDocumentUrl != null ||
          addressProofUrl != null ||
          anvisaDocumentUrl != null) {
        final docTypes = <String, String?>{
          'identidade': rgDocumentUrl,
          'comprovante_residencia': addressProofUrl,
          'autorizacao_anvisa': anvisaDocumentUrl,
        };
        for (final entry in docTypes.entries) {
          if (entry.value != null && entry.value!.isNotEmpty) {
            await _apiService.post('documentos', {
              'paciente_id': pacienteId,
              'pedido_id': pedidoId,
              'arquivo_url': entry.value,
              'tipo': entry.key,
              'nome_arquivo': '${entry.key}.pdf',
            });
          }
        }
      }

      return {
        'success': true,
        'message': 'Pedido criado com sucesso',
        'data': {
          'id': pedidoId,
          'numero_pedido': numeroPedido,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar pedido: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar detalhes completos de um pedido específico
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Buscar o pedido pelo ID
      final pedidoResult = await _apiService.getFiltered(
        'pedidos',
        filters: {'id': orderId},
        limit: 1,
      );

      if (!pedidoResult['success'] || pedidoResult['data'] == null) {
        return {
          'success': false,
          'message': 'Pedido não encontrado',
          'data': null,
        };
      }

      final pedidos = pedidoResult['data'] as List;
      if (pedidos.isEmpty) {
        return {
          'success': false,
          'message': 'Pedido não encontrado',
          'data': null,
        };
      }

      final pedido = pedidos[0] as Map<String, dynamic>;
      final pedidoId = pedido['id']?.toString() ?? '';
      final receitaId = pedido['receita_id']?.toString();

      // Buscar todos os itens do pedido
      final itensResult = await _apiService.getFiltered(
        'pedido_itens',
        filters: {'pedido_id': pedidoId},
      );

      final itens = <Map<String, dynamic>>[];
      String? primeiroProdutoNome;

      if (itensResult['success'] && itensResult['data'] != null) {
        final itensList = itensResult['data'] as List;

        for (var item in itensList) {
          final produtoId = item['produto_id'] as String?;

          if (produtoId != null) {
            // Buscar dados do produto
            final produtoResult = await _apiService.getFiltered(
              'produtos',
              filters: {'id': produtoId},
              limit: 1,
            );

            String productName = 'Produto não especificado';
            if (produtoResult['success'] && produtoResult['data'] != null) {
              final produtos = produtoResult['data'] as List;
              if (produtos.isNotEmpty) {
                productName = produtos[0]['nome_comercial'] as String? ??
                    'Produto não especificado';
                primeiroProdutoNome ??= productName;
              }
            }

            itens.add({
              'id': item['id'],
              'produto_id': produtoId,
              'produto_nome': productName,
              'quantidade': item['quantidade'] ?? 0,
              'preco_unitario': item['preco_unitario'],
              'preco_total': item['preco_total'],
            });
          }
        }
      }

      // Buscar receita vinculada se existir
      Map<String, dynamic>? receitaData;
      if (receitaId != null) {
        final receitaResult = await _apiService.getFiltered(
          'receitas',
          filters: {'id': receitaId},
          limit: 1,
        );

        if (receitaResult['success'] && receitaResult['data'] != null) {
          final receitas = receitaResult['data'] as List;
          if (receitas.isNotEmpty) {
            final rec = receitas[0] as Map<String, dynamic>;
            // Tabela receitas usa documento_url (singular)
            receitaData = {
              'id': rec['id'],
              'numero_receita': rec['numero_receita'],
              'documento_url': rec['documento_url'],
              'data_emissao': rec['data_emissao'],
              'validade': rec['validade'],
            };
          }
        }
      }

      // Buscar apenas os documentos enviados NESTE pedido (pedido_id), não todos do paciente
      final documentos = <Map<String, dynamic>>[];
      final documentosResult = await _apiService.getFiltered(
        'documentos',
        filters: {'pedido_id': pedidoId},
      );

      if (documentosResult['success'] && documentosResult['data'] != null) {
        final docsList = documentosResult['data'] as List;
        for (var doc in docsList) {
          final docMap = doc as Map<String, dynamic>;
          documentos.add({
            'id': docMap['id'],
            'nome_arquivo': docMap['nome_arquivo'] ?? 'Documento',
            'arquivo_url': docMap['arquivo_url'],
            'tipo': docMap['tipo'],
          });
        }
      }

      // Buscar histórico do pedido para timeline
      final historicoResult = await _apiService.getFiltered(
        'pedido_historico',
        filters: {'pedido_id': pedidoId},
        orderBy: 'created_at',
        ascending: true,
      );

      final historico = <Map<String, dynamic>>[];
      if (historicoResult['success'] && historicoResult['data'] != null) {
        final historicoList = historicoResult['data'] as List;
        for (var h in historicoList) {
          historico.add({
            'status_anterior': h['status_anterior'],
            'status_novo': h['status_novo'],
            'created_at': h['created_at'],
          });
        }
      }

      // Mapear status do banco para o formato da UI (status vem como enum/string do Supabase)
      final statusRaw = pedido['status']?.toString();
      String statusText = _mapStatusToText(statusRaw);

      // Mapear canal de aquisição (canal_aquisicao é enum no Supabase)
      final canalRaw = pedido['canal_aquisicao']?.toString();
      String channelText = _mapChannelToText(canalRaw);

      // Formatar valor (valor_total é numeric no Supabase)
      String valueText = _formatValue(pedido['valor_total']);

      // Formatar data (data_pedido é timestamptz; Supabase pode retornar string ISO ou objeto)
      String dateText = _formatDate(pedido['data_pedido']);
      final dataPedidoRaw = pedido['data_pedido'];

      return {
        'success': true,
        'data': {
          'id': pedidoId,
          'numero_pedido': pedido['numero_pedido']?.toString() ?? '#N/A',
          'data_pedido': dateText,
          'data_pedido_raw': dataPedidoRaw,
          'status': statusText,
          'status_raw': statusRaw,
          'canal_aquisicao': channelText,
          'valor_total': valueText,
          'valor_total_raw': pedido['valor_total'],
          'forma_pagamento': pedido['forma_pagamento']?.toString(),
          'itens': itens,
          'primeiro_produto_nome':
              primeiroProdutoNome ?? 'Produto não especificado',
          'receita': receitaData,
          'documentos': documentos,
          'historico': historico,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar detalhes do pedido: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Formata a data no formato DD/MM/YYYY
  String _formatDateDDMMYYYY(dynamic dateValue) {
    if (dateValue == null) return 'Data não disponível';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Data não disponível';
      }

      // Formato DD/MM/YYYY
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      return 'Data não disponível';
    }
  }
}

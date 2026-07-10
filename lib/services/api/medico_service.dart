import 'api_service.dart';

/// Serviço para dados do médico (validação profissional e perfil).
class MedicoService {
  final ApiService _api = ApiService();

  /// Retorna o médico do usuário logado (user_id = auth.uid()).
  Future<Map<String, dynamic>> getMedicoByCurrentUser() async {
    final user = _api.currentUser;
    if (user == null) {
      return {
        'success': false,
        'message': 'Usuário não autenticado',
        'data': null,
      };
    }
    return getMedicoByUserId(user.id);
  }

  /// Busca médico por user_id (profiles.id = auth.uid()).
  Future<Map<String, dynamic>> getMedicoByUserId(String userId) async {
    final result = await _api.getFiltered(
      'medicos',
      filters: {'user_id': userId},
      limit: 1,
    );
    if (result['success'] != true || result['data'] == null) {
      return result;
    }
    final list = result['data'] as List;
    return {
      'success': true,
      'data': list.isNotEmpty ? list[0] : null,
      'message':
          list.isNotEmpty ? 'Médico encontrado' : 'Médico não encontrado',
    };
  }

  /// Atualiza o registro do médico (apenas campos permitidos).
  Future<Map<String, dynamic>> updateMedico(
    String medicoId, {
    String? crm,
    String? ufCrm,
    String? cpf,
    String? especialidadeId,
    String? tempoAtuacao,
    String? enderecoCompleto,
    String? dataNascimento,
    List<String>? queixasAtendidas,
    String? observacoesPrescritorCannabis,
  }) async {
    final Map<String, dynamic> data = {};
    if (crm != null) data['crm'] = crm;
    if (ufCrm != null) data['uf_crm'] = ufCrm;
    if (cpf != null) data['cpf'] = cpf;
    if (especialidadeId != null) data['especialidade_id'] = especialidadeId;
    if (tempoAtuacao != null) data['tempo_atuacao'] = tempoAtuacao;
    if (enderecoCompleto != null) data['endereco_completo'] = enderecoCompleto;
    if (dataNascimento != null) data['data_nascimento'] = dataNascimento;
    if (queixasAtendidas != null) data['queixas_atendidas'] = queixasAtendidas;
    if (observacoesPrescritorCannabis != null) {
      data['observacoes_prescritor_cannabis'] = observacoesPrescritorCannabis;
    }
    if (data.isEmpty) {
      return {'success': true, 'data': null, 'message': 'Nada a atualizar'};
    }
    return _api.put('medicos', {'id': medicoId}, data);
  }

  /// Atualiza disponibilidade de atendimento (Etapa 3 da validação profissional).
  Future<Map<String, dynamic>> updateMedicoDisponibilidade(
    String medicoId, {
    String? disponibilidadeDias,
    String? disponibilidadeRecorrencia,
    String? disponibilidadeHorarios,
    String? disponibilidadeIntervalo,
    bool? autorizaCompartilhamentoDados,
  }) async {
    final Map<String, dynamic> data = {};
    if (disponibilidadeDias != null) {
      data['disponibilidade_dias'] = disponibilidadeDias;
    }
    if (disponibilidadeRecorrencia != null) {
      data['disponibilidade_recorrencia'] = disponibilidadeRecorrencia;
    }
    if (disponibilidadeHorarios != null) {
      data['disponibilidade_horarios'] = disponibilidadeHorarios;
    }
    if (disponibilidadeIntervalo != null) {
      data['disponibilidade_intervalo'] = disponibilidadeIntervalo;
    }
    if (autorizaCompartilhamentoDados != null) {
      data['autoriza_compartilhamento_dados'] = autorizaCompartilhamentoDados;
    }
    if (data.isEmpty) {
      return {'success': true, 'data': null, 'message': 'Nada a atualizar'};
    }
    return _api.put('medicos', {'id': medicoId}, data);
  }

  /// Lista especialidades ativas para dropdown.
  Future<Map<String, dynamic>> getEspecialidades() async {
    return _api.getFiltered(
      'especialidades',
      filters: {'ativo': true},
      orderBy: 'nome',
      limit: 100,
    );
  }

  /// Tipos de documento da validação profissional (etapa 2).
  static const List<String> documentoTiposObrigatorios = [
    'rg_ou_cnh',
    'comprovante_residencia',
    'comprovante_crm_cro',
    'diploma',
  ];
  static const List<String> documentoTiposOpcionais = [
    'certificado_complementar',
    'outros_documentos',
  ];

  /// Lista documentos do médico por medico_id.
  Future<Map<String, dynamic>> getMedicoDocumentos(String medicoId) async {
    final result = await _api.getFiltered(
      'medico_documentos',
      filters: {'medico_id': medicoId},
      orderBy: 'tipo',
      limit: 50,
    );
    if (result['success'] != true || result['data'] == null) {
      return result;
    }
    final list = result['data'] as List;
    final byTipo = <String, Map<String, dynamic>>{};
    for (final doc in list) {
      final map = doc as Map<String, dynamic>;
      final tipo = map['tipo'] as String?;
      if (tipo != null) {
        byTipo[tipo] = map;
      }
    }
    return {
      'success': true,
      'data': byTipo,
      'message': 'Documentos carregados',
    };
  }

  /// Salva ou atualiza um documento do médico (upsert por medico_id + tipo).
  Future<Map<String, dynamic>> saveMedicoDocumento(
    String medicoId, {
    required String tipo,
    required String arquivoUrl,
    String? nomeArquivo,
  }) async {
    final existing = await _api.getFiltered(
      'medico_documentos',
      filters: {'medico_id': medicoId, 'tipo': tipo},
      limit: 1,
    );
    final payload = {
      'medico_id': medicoId,
      'tipo': tipo,
      'arquivo_url': arquivoUrl,
      'nome_arquivo': nomeArquivo ?? tipo,
    };
    if (existing['success'] == true &&
        existing['data'] != null &&
        (existing['data'] as List).isNotEmpty) {
      final row = (existing['data'] as List).first as Map<String, dynamic>;
      final id = row['id'] as String?;
      if (id != null) {
        return _api.put('medico_documentos', {
          'id': id
        }, {
          'arquivo_url': arquivoUrl,
          'nome_arquivo': nomeArquivo ?? tipo,
        });
      }
    }
    return _api.insertWithReturn('medico_documentos', payload);
  }

  /// Remove um documento do médico por id.
  Future<Map<String, dynamic>> deleteMedicoDocumento(String documentId) async {
    return _api.delete('medico_documentos', {'id': documentId});
  }

  /// Lista consultas do médico (medico_id). Ordenado por data_consulta desc.
  /// Requer política RLS "Medicos podem ver próprias consultas".
  Future<Map<String, dynamic>> getConsultasByMedico(String medicoId) async {
    final result = await _api.getFiltered(
      'consultas',
      filters: {'medico_id': medicoId},
      orderBy: 'data_consulta',
      ascending: false,
      limit: 200,
    );
    return result;
  }

  /// Lista produtos para catálogo (home do médico). Limite opcional.
  Future<Map<String, dynamic>> getProdutosCatalogo({int limit = 20}) async {
    return _api.getFiltered(
      'produtos',
      limit: limit,
    );
  }

  // ---------------------------------------------------------------------------
  // Loop médico↔paciente (RPCs medico_* — migration 018).
  // Cada RPC é SECURITY DEFINER e valida internamente que o chamador é o médico.
  // ---------------------------------------------------------------------------

  /// Wrapper padrão para chamadas RPC, normalizando o retorno em
  /// {success, data, message} e tratando exceções.
  Future<Map<String, dynamic>> _rpc(
    String fn, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final data = await ApiService.client.rpc(fn, params: params);
      return {'success': true, 'data': data, 'message': 'OK'};
    } catch (e) {
      return {'success': false, 'data': null, 'message': e.toString()};
    }
  }

  /// Lista os atendimentos (consultas) do médico logado.
  /// [incluirFila] inclui consultas agendadas sem médico (fila para assumir).
  Future<Map<String, dynamic>> listarAtendimentos({
    String? status,
    bool incluirFila = false,
    int limit = 100,
  }) {
    return _rpc('medico_listar_atendimentos', params: {
      'p_status': status,
      'p_incluir_fila': incluirFila,
      'p_limit': limit,
    });
  }

  /// Médico assume uma consulta da fila (medico_id ainda nulo).
  Future<Map<String, dynamic>> assumirConsulta(String consultaId) {
    return _rpc('medico_assumir_consulta', params: {
      'p_consulta_id': consultaId,
    });
  }

  /// Atualiza o status de uma consulta do médico
  /// (agendada | em_andamento | finalizada).
  Future<Map<String, dynamic>> atualizarStatusConsulta(
    String consultaId,
    String status,
  ) {
    return _rpc('medico_atualizar_status_consulta', params: {
      'p_consulta_id': consultaId,
      'p_status': status,
    });
  }

  /// Finaliza o atendimento, gravando um resumo opcional.
  Future<Map<String, dynamic>> finalizarAtendimento(
    String consultaId, {
    String? resumo,
    int? avaliacaoNota,
    String? avaliacaoComentario,
  }) {
    return _rpc('medico_finalizar_atendimento', params: {
      'p_consulta_id': consultaId,
      'p_resumo': resumo,
      'p_avaliacao_nota': avaliacaoNota,
      'p_avaliacao_comentario': avaliacaoComentario,
    });
  }

  /// Emite uma receita (receitas + receita_itens) para um paciente.
  ///
  /// [itens] é uma lista de mapas:
  /// { 'produto_id', 'posologia', 'quantidade_prescrita', 'duracao_tratamento' }.
  /// [validade] no formato ISO 'yyyy-MM-dd'. Se [consultaId] for informado, a
  /// receita é vinculada à consulta e o paciente é derivado dela.
  Future<Map<String, dynamic>> emitirReceita({
    String? pacienteId,
    required String validade,
    required List<Map<String, dynamic>> itens,
    String? consultaId,
    String? observacoes,
  }) {
    assert(pacienteId != null || consultaId != null,
        'Informe pacienteId ou consultaId');
    return _rpc('medico_emitir_receita', params: {
      'p_paciente_id': pacienteId,
      'p_validade': validade,
      'p_itens': itens,
      'p_consulta_id': consultaId,
      'p_observacoes': observacoes,
    });
  }

  /// Lista os repasses financeiros do médico logado.
  Future<Map<String, dynamic>> listarRepasses({int limit = 100}) {
    return _rpc('medico_listar_repasses', params: {'p_limit': limit});
  }

  /// Resumo financeiro do médico (total recebido, pendente, nº de atendimentos).
  Future<Map<String, dynamic>> resumoFinanceiro() {
    return _rpc('medico_resumo_financeiro');
  }

  /// Detalhe de um atendimento do médico: resumo + receita + itens.
  /// Usa o SELECT permitido ao médico sobre suas consultas/receitas (RLS).
  Future<Map<String, dynamic>> getAtendimentoDetalhe(String consultaId) async {
    final cRes = await _api.getFiltered('consultas',
        filters: {'id': consultaId}, limit: 1);
    String? resumo;
    String? receitaId;
    if (cRes['success'] == true &&
        cRes['data'] is List &&
        (cRes['data'] as List).isNotEmpty) {
      final row = (cRes['data'] as List).first as Map<String, dynamic>;
      resumo = row['resumo_atendimento'] as String?;
      receitaId = row['receita_id'] as String?;
    }

    Map<String, dynamic>? receita;
    final itens = <Map<String, dynamic>>[];
    if (receitaId != null) {
      final rRes = await _api.getFiltered('receitas',
          filters: {'id': receitaId}, limit: 1);
      if (rRes['success'] == true &&
          rRes['data'] is List &&
          (rRes['data'] as List).isNotEmpty) {
        receita = (rRes['data'] as List).first as Map<String, dynamic>;
      }
      final iRes = await _api.getFiltered('receita_itens',
          filters: {'receita_id': receitaId}, limit: 50);
      if (iRes['success'] == true && iRes['data'] is List) {
        for (final raw in (iRes['data'] as List)) {
          final item = raw as Map<String, dynamic>;
          String nome = 'Produto';
          final prodId = item['produto_id'] as String?;
          if (prodId != null) {
            final pRes = await _api.getFiltered('produtos',
                filters: {'id': prodId}, limit: 1);
            if (pRes['success'] == true &&
                pRes['data'] is List &&
                (pRes['data'] as List).isNotEmpty) {
              nome = (pRes['data'] as List).first['nome_comercial'] as String? ??
                  nome;
            }
          }
          itens.add({
            'produto_nome': nome,
            'posologia': item['posologia'],
            'quantidade_prescrita': item['quantidade_prescrita'],
            'duracao_tratamento': item['duracao_tratamento'],
          });
        }
      }
    }

    return {
      'success': true,
      'data': {
        'resumo': resumo,
        'receita': receita,
        'itens': itens,
      },
    };
  }

  /// Retorna o nome do paciente (nome_completo do profile) a partir do paciente_id.
  Future<String> getPacienteNome(String pacienteId) async {
    final pac = await _api.getFiltered(
      'pacientes',
      filters: {'id': pacienteId},
      limit: 1,
    );
    if (pac['success'] != true || pac['data'] == null) return 'Paciente';
    final list = pac['data'] as List;
    if (list.isEmpty) return 'Paciente';
    final userId = (list[0] as Map<String, dynamic>)['user_id'] as String?;
    if (userId == null) return 'Paciente';
    final prof = await _api.getFiltered(
      'profiles',
      filters: {'id': userId},
      limit: 1,
    );
    if (prof['success'] != true || prof['data'] == null) return 'Paciente';
    final pl = prof['data'] as List;
    if (pl.isEmpty) return 'Paciente';
    final nome = (pl[0] as Map<String, dynamic>)['nome_completo'] as String?;
    return nome?.trim().isNotEmpty == true ? nome! : 'Paciente';
  }

  /// Contexto completo para o Prontuário do Paciente: dados da consulta,
  /// do paciente (profile + anamnese) e do médico responsável.
  Future<Map<String, dynamic>> getProntuarioContexto(String consultaId) async {
    final cRes = await _api.getFiltered('consultas',
        filters: {'id': consultaId}, limit: 1);
    if (cRes['success'] != true ||
        cRes['data'] == null ||
        (cRes['data'] as List).isEmpty) {
      return {'success': false, 'message': 'Consulta não encontrada'};
    }
    final consulta = (cRes['data'] as List).first as Map<String, dynamic>;
    final pacienteId = consulta['paciente_id'] as String?;
    final medicoId = consulta['medico_id'] as String?;

    Map<String, dynamic>? pacienteRow;
    Map<String, dynamic>? profile;
    Map<String, dynamic>? anamnese;
    if (pacienteId != null) {
      final pRes = await _api.getFiltered('pacientes',
          filters: {'id': pacienteId}, limit: 1);
      if (pRes['success'] == true &&
          pRes['data'] != null &&
          (pRes['data'] as List).isNotEmpty) {
        pacienteRow = (pRes['data'] as List).first as Map<String, dynamic>;
        final userId = pacienteRow['user_id'] as String?;
        if (userId != null) {
          final profRes = await _api.getFiltered('profiles',
              filters: {'id': userId}, limit: 1);
          if (profRes['success'] == true &&
              profRes['data'] != null &&
              (profRes['data'] as List).isNotEmpty) {
            profile = (profRes['data'] as List).first as Map<String, dynamic>;
          }
        }
      }
      final anaRes = await _api.getFiltered('paciente_anamnese',
          filters: {'paciente_id': pacienteId}, limit: 1);
      if (anaRes['success'] == true &&
          anaRes['data'] != null &&
          (anaRes['data'] as List).isNotEmpty) {
        anamnese = (anaRes['data'] as List).first as Map<String, dynamic>;
      }
    }

    Map<String, dynamic>? medico;
    if (medicoId != null) {
      final mRes = await _api.getFiltered('medicos',
          filters: {'id': medicoId}, limit: 1);
      if (mRes['success'] == true &&
          mRes['data'] != null &&
          (mRes['data'] as List).isNotEmpty) {
        medico = (mRes['data'] as List).first as Map<String, dynamic>;
      }
    }

    return {
      'success': true,
      'data': {
        'consulta': consulta,
        'paciente': pacienteRow,
        'profile': profile,
        'anamnese': anamnese,
        'medico': medico,
      },
    };
  }

  /// Consultas anteriores finalizadas do paciente (exceto [excludeConsultaId]),
  /// cada uma com a receita vinculada (se houver), para a tela de pré-consulta.
  Future<List<Map<String, dynamic>>> getConsultasAnteriores(
    String pacienteId, {
    String? excludeConsultaId,
  }) async {
    final res = await _api.getFiltered(
      'consultas',
      filters: {'paciente_id': pacienteId, 'status': 'finalizada'},
      orderBy: 'data_consulta',
      ascending: false,
      limit: 10,
    );
    if (res['success'] != true || res['data'] == null) return [];
    final consultas = (res['data'] as List)
        .cast<Map<String, dynamic>>()
        .where((c) => c['id'] != excludeConsultaId)
        .toList();

    final result = <Map<String, dynamic>>[];
    for (final c in consultas) {
      String? documentoUrl;
      final receitaId = c['receita_id'] as String?;
      if (receitaId != null) {
        final rRes = await _api.getFiltered('receitas',
            filters: {'id': receitaId}, limit: 1);
        if (rRes['success'] == true &&
            rRes['data'] != null &&
            (rRes['data'] as List).isNotEmpty) {
          documentoUrl = (rRes['data'] as List).first['documento_url']
              as String?;
        }
      }
      result.add({
        'id': c['id'],
        'data_consulta': c['data_consulta'],
        'queixa_principal': c['queixa_principal'],
        'documento_url': documentoUrl,
      });
    }
    return result;
  }

  /// Busca o prontuário existente de uma consulta (ou null se ainda não criado).
  Future<Map<String, dynamic>> getProntuario(String consultaId) async {
    final res = await _api.getFiltered('prontuarios',
        filters: {'consulta_id': consultaId}, limit: 1);
    if (res['success'] != true) return res;
    final list = (res['data'] as List?) ?? [];
    return {
      'success': true,
      'data': list.isNotEmpty ? list.first as Map<String, dynamic> : null,
    };
  }

  /// Cria ou atualiza o prontuário de uma consulta.
  Future<Map<String, dynamic>> upsertProntuario({
    String? prontuarioId,
    required String consultaId,
    required String pacienteId,
    required String medicoId,
    required Map<String, dynamic> conteudo,
    required String status,
  }) async {
    if (prontuarioId != null) {
      return _api.put('prontuarios', {'id': prontuarioId}, {
        'conteudo': conteudo,
        'status': status,
      });
    }
    return _api.insertWithReturn('prontuarios', {
      'consulta_id': consultaId,
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'conteudo': conteudo,
      'status': status,
    });
  }
}

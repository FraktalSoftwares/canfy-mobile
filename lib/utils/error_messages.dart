/// Utilitário para formatar mensagens de erro em mensagens amigáveis ao usuário
class ErrorMessages {
  /// Traduz erros do Supabase para mensagens amigáveis
  static String formatError(dynamic error) {
    if (error == null) {
      return 'Ocorreu um erro desconhecido. Tente novamente.';
    }

    final errorString = error.toString().toLowerCase();

    // Erros de autenticação
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid_credentials') ||
        errorString.contains('email not confirmed')) {
      return 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.';
    }

    if (errorString.contains('user already registered') ||
        errorString.contains('user already exists') ||
        errorString.contains('email already registered')) {
      return 'Este email já está cadastrado. Tente fazer login ou recuperar sua senha.';
    }

    if (errorString.contains('password')) {
      if (errorString.contains('weak') || errorString.contains('too short')) {
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      }
      return 'Erro relacionado à senha. Verifique se a senha está correta.';
    }

    // Erros de rede/conexão
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    // Erros de validação
    if (errorString.contains('duplicate key') ||
        errorString.contains('unique constraint')) {
      if (errorString.contains('cpf')) {
        return 'Este CPF já está cadastrado. Use outro CPF ou faça login.';
      }
      if (errorString.contains('email')) {
        return 'Este email já está cadastrado. Tente fazer login.';
      }
      return 'Os dados informados já estão em uso. Verifique e tente novamente.';
    }

    // Erros de banco de dados
    if (errorString.contains('database error') ||
        errorString.contains('relation') ||
        errorString.contains('column')) {
      return 'Erro ao processar sua solicitação. Tente novamente em alguns instantes.';
    }

    // Erros de permissão
    if (errorString.contains('permission denied') ||
        errorString.contains('row-level security') ||
        errorString.contains('policy')) {
      return 'Você não tem permissão para realizar esta ação.';
    }

    // Erros de formato
    if (errorString.contains('invalid') && errorString.contains('email')) {
      return 'Email inválido. Verifique o formato do email.';
    }

    if (errorString.contains('invalid') && errorString.contains('phone')) {
      return 'Telefone inválido. Verifique o número informado.';
    }

    // Erros genéricos do Supabase
    if (errorString.contains('supabase') || errorString.contains('auth')) {
      return 'Erro ao processar sua solicitação. Tente novamente.';
    }

    // Se a mensagem já estiver em português e for amigável, retornar como está
    if (errorString.contains('é obrigatório') ||
        errorString.contains('inválido') ||
        errorString.contains('não encontrado') ||
        errorString.contains('já está cadastrado')) {
      // Capitalizar primeira letra
      final message = error.toString();
      if (message.isNotEmpty) {
        return message[0].toUpperCase() + message.substring(1);
      }
      return message;
    }

    // Mensagem genérica para erros não mapeados
    return 'Ocorreu um erro. Tente novamente. Se o problema persistir, entre em contato com o suporte.';
  }

  /// Extrai mensagem de erro de um resultado da API
  static String extractErrorMessage(Map<String, dynamic> result) {
    // Tentar obter mensagem do resultado
    final message = result['message'] as String?;
    if (message != null && message.isNotEmpty) {
      return formatError(message);
    }

    // Tentar obter erro do resultado
    final error = result['error'] as String?;
    if (error != null && error.isNotEmpty) {
      return formatError(error);
    }

    // Mensagem padrão
    return 'Ocorreu um erro. Tente novamente.';
  }
}

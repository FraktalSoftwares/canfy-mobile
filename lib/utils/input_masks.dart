import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Utilitários para máscaras de input
class InputMasks {
  /// Máscara para CPF: 000.000.000-00
  static MaskTextInputFormatter cpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para telefone: (00) 00000-0000
  static MaskTextInputFormatter phone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para data: DD/MM/AAAA
  static MaskTextInputFormatter date = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CEP: 00000-000
  static MaskTextInputFormatter cep = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CRM + UF: 123456/SP (6 dígitos + / + 2 letras)
  static MaskTextInputFormatter crmUf = MaskTextInputFormatter(
    mask: '######/??',
    filter: {
      "#": RegExp(r'[0-9]'),
      "?": RegExp(r'[A-Za-z]'),
    },
  );

  /// Máscara para UF (Estado): 2 letras (ex: SP)
  static MaskTextInputFormatter uf = MaskTextInputFormatter(
    mask: '??',
    filter: {"?": RegExp(r'[A-Za-z]')},
  );

  /// Máscara para número de cartão: 0000 0000 0000 0000
  static MaskTextInputFormatter cardNumber = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para validade do cartão: MM/AA
  static MaskTextInputFormatter cardValidity = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Máscara para CVV: 3 ou 4 dígitos
  static MaskTextInputFormatter cvv = MaskTextInputFormatter(
    mask: '####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Remove caracteres não numéricos
  static String removeNonNumeric(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Formata CPF para exibição (11 dígitos -> ###.###.###-##)
  static String formatCpfForDisplay(String? value) {
    if (value == null || value.isEmpty) return '';
    final d = removeNonNumeric(value);
    if (d.length > 11) {
      return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9, 11)}';
    }
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
    if (d.length <= 9) {
      return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
    }
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  /// Formata CEP para exibição (8 dígitos -> #####-###)
  static String formatCepForDisplay(String? value) {
    if (value == null || value.isEmpty) return '';
    final d = removeNonNumeric(value);
    if (d.length > 8) return '${d.substring(0, 5)}-${d.substring(5, 8)}';
    if (d.length <= 5) return d;
    return '${d.substring(0, 5)}-${d.substring(5)}';
  }

  /// Valida CPF
  static bool isValidCPF(String cpf) {
    final numbers = removeNonNumeric(cpf);
    if (numbers.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) return false;

    // Validação dos dígitos verificadores
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(numbers[i]) * (10 - i);
    }
    int digit1 = (sum * 10) % 11;
    if (digit1 == 10) digit1 = 0;
    if (digit1 != int.parse(numbers[9])) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(numbers[i]) * (11 - i);
    }
    int digit2 = (sum * 10) % 11;
    if (digit2 == 10) digit2 = 0;
    if (digit2 != int.parse(numbers[10])) return false;

    return true;
  }

  /// Valida data no formato DD/MM/AAAA
  static bool isValidDate(String date) {
    final numbers = removeNonNumeric(date);
    if (numbers.length != 8) return false;

    final day = int.parse(numbers.substring(0, 2));
    final month = int.parse(numbers.substring(2, 4));
    final year = int.parse(numbers.substring(4, 8));

    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    if (year < 1900 || year > DateTime.now().year) return false;

    try {
      final dateTime = DateTime(year, month, day);
      // Verifica se a data é válida (ex: 31/02 não existe)
      if (dateTime.year != year ||
          dateTime.month != month ||
          dateTime.day != day) {
        return false;
      }
      // Verifica se não é data futura
      if (dateTime.isAfter(DateTime.now())) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Valida telefone (mínimo 10 dígitos)
  static bool isValidPhone(String phone) {
    final numbers = removeNonNumeric(phone);
    return numbers.length >= 10 && numbers.length <= 11;
  }

  /// Valida CEP (8 dígitos)
  static bool isValidCEP(String cep) {
    final numbers = removeNonNumeric(cep);
    return numbers.length == 8;
  }
}

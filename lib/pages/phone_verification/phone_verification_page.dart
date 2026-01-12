import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String? phoneNumber;

  const PhoneVerificationPage({super.key, this.phoneNumber});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isCodeValid = false;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _codeControllers.map((c) => c.text).join();
    setState(() {
      _isCodeValid = code.length == 4;
    });

    if (code.length == 4) {
      // Auto-validar quando todos os campos estiverem preenchidos
      // context.go('/pending-review');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/register');
            }
          },
        ),
        title: Text(
          'Verificação',
          style: AppTextStyles.truculenta(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 54),
              // Ícone de verificação
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.canfyGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.message,
                  size: 36,
                  color: AppTheme.canfyGreen,
                ),
              ),
              const SizedBox(height: 40),
              // Título
              Text(
                'Confirme seu número',
                style: AppTextStyles.truculenta(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enviamos um código de verificação para o seu número',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: const Color(0xFF9A9A97),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Campos de código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTextStyles.arimo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.canfyGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        _onCodeChanged();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Botão de reenviar código (quando código estiver preenchido)
              if (_isCodeValid) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não recebeu o código? ',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: const Color(0xFF9A9A97),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Lógica para reenviar código
                      },
                      child: Text(
                        'Reenviar',
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.canfyGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
              // Botão Confirmar
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: _isCodeValid
                      ? () {
                          // Validar código e navegar
                          // Pacientes vão direto para home, médicos vão para análise
                          // Por enquanto, redirecionar pacientes para home
                          context.go('/patient/home');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.canfyGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirmar',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

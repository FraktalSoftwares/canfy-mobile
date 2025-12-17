import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

// Note: This page needs to be a StatefulWidget to properly handle the userType changes
// For now, keeping it as is but the tab switching logic needs to be fixed

class RegisterPage extends StatefulWidget {
  final String? userType;
  
  const RegisterPage({
    super.key,
    this.userType,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRegisterTab = true;
  
  // Controllers dos campos
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _crmController = TextEditingController();
  final _croController = TextEditingController();
  
  // Estados de visibilidade de senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Estados dos checkboxes
  bool _agreeTerms = false;
  bool _authorizeDataSharing = false;
  
  String? _selectedGender;
  bool _isDoctor = false;
  final List<String> _genders = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar',
  ];

  @override
  void initState() {
    super.initState();
    _isDoctor = widget.userType == 'doctor';
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isRegisterTab = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _loginController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _crmController.dispose();
    _croController.dispose();
    super.dispose();
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
              context.go('/user-selection');
            }
          },
        ),
        title: Text(
          'Cadastro',
          style: AppTextStyles.truculenta(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Vamos começar?',
                style: AppTextStyles.truculenta(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Leva só alguns minutos.\nVocê pode atualizar seus dados depois.',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: const Color(0xFF5E5E5B),
                ),
              ),
              const SizedBox(height: 24),
              // Tabs Cadastro/Login
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8EF), // green-100
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.canfyGreen,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  unselectedLabelStyle: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: 'Cadastro'),
                    Tab(text: 'Login'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Campos do formulário
              if (_isRegisterTab) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Nome completo',
                  hint: 'Digite seu nome completo',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _loginController,
                  label: 'Login',
                  hint: 'Digite seu login',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Digite seu email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Crie uma senha segura',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  hint: 'Repita sua senha',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _birthDateController,
                  label: 'Data de nascimento',
                  hint: 'DD/MM/AAAA',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cpfController,
                  label: 'CPF',
                  hint: 'Digite seu CPF',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Telefone',
                  hint: 'Digite seu telefone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Gênero',
                  value: _selectedGender,
                  items: _genders,
                  hint: 'Selecione seu gênero',
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cepController,
                  label: 'CEP',
                  hint: 'Digite seu CEP',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Endereço',
                  hint: 'Digite seu endereço',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _numberController,
                  label: 'Número',
                  hint: 'Digite o número',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _complementController,
                  label: 'Complemento',
                  hint: 'Digite o complemento (opcional)',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _neighborhoodController,
                  label: 'Bairro',
                  hint: 'Digite o bairro',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  hint: 'Digite a cidade',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _stateController,
                  label: 'Estado',
                  hint: 'Digite o estado',
                ),
                if (_isDoctor) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _crmController,
                    label: 'CRM',
                    hint: 'Digite seu CRM',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _croController,
                    label: 'CRO',
                    hint: 'Digite seu CRO',
                  ),
                ],
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Criar senha',
                  hint: 'Crie uma senha segura',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  hint: 'Repita sua senha',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Checkboxes
                _buildCheckbox(
                  value: _agreeTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeTerms = value ?? false;
                    });
                  },
                  text: 'Concordo com os ',
                  linkText: 'termos de uso',
                  linkText2: ' e a ',
                  linkText3: 'política de privacidade',
                  onLinkTap: () {
                    // Navegar para termos
                  },
                ),
                const SizedBox(height: 16),
                _buildCheckbox(
                  value: _authorizeDataSharing,
                  onChanged: (value) {
                    setState(() {
                      _authorizeDataSharing = value ?? false;
                    });
                  },
                  text: 'Autorizo o compartilhamento de dados com médicos e associações, quando necessário para meu tratamento.',
                ),
                const SizedBox(height: 32),
                // Botão Criar conta
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: _agreeTerms ? () {
                      // Lógica de cadastro - navegar para validação de telefone
                      context.go('/phone-verification');
                    } : null,
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
                      'Criar conta',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Tela de Login dentro do RegisterPage
                _buildTextField(
                  controller: _emailController,
                  label: 'E-mail ou telefone',
                  hint: 'Insira seu e-mail ou telefone',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Insira sua senha',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA64740), // orange-900
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/user-selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.canfyGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Entrar',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Já está na tela de cadastro, apenas mudar tab
                    _tabController.animateTo(0);
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Não tem uma conta? '),
                        TextSpan(
                          text: 'Crie agora',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.canfyGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.arimo(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.arimo(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    String? linkText,
    String? linkText2,
    String? linkText3,
    VoidCallback? onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.canfyGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: text),
                  if (linkText != null)
                    TextSpan(
                      text: linkText,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: Colors.blue,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: onLinkTap != null
                          ? (TapGestureRecognizer()..onTap = onLinkTap)
                          : null,
                    ),
                  if (linkText2 != null) TextSpan(text: linkText2),
                  if (linkText3 != null)
                    TextSpan(
                      text: linkText3,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: Colors.blue,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: onLinkTap != null
                          ? (TapGestureRecognizer()..onTap = onLinkTap)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.arimo(
                fontSize: 16,
                color: const Color(0xFF9E9E9E),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


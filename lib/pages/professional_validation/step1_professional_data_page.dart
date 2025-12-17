import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class Step1ProfessionalDataPage extends StatefulWidget {
  const Step1ProfessionalDataPage({super.key});

  @override
  State<Step1ProfessionalDataPage> createState() => _Step1ProfessionalDataPageState();
}

class _Step1ProfessionalDataPageState extends State<Step1ProfessionalDataPage> {
  // Controllers
  final _cpfController = TextEditingController();
  final _crmController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cepController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();

  String? _selectedYearsOfExperience;

  @override
  void dispose() {
    _cpfController.dispose();
    _crmController.dispose();
    _specialtyController.dispose();
    _yearsOfExperienceController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cepController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
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
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-selection');
            }
          },
        ),
        title: Text(
          'Dados profissionais',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de progresso
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BB5A), // green-700
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D3), // neutral-300
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D3), // neutral-300
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Título e badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validação profissional',
                    style: AppTextStyles.truculenta(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0EE), // neutral-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Etapa 1 - Dados profissionais',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F3F3D), // neutral-800
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF), // green-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Valor: R\$ 89,90',
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF007A3B), // green-900
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Card Dados de registro
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F5), // neutral-050
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE6F8EF), // green-100
                            border: Border.all(
                              color: Colors.white,
                              width: 1.111,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF00994B),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: const Color(0xFF33CC80), // green-500
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                                width: 1.25,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Título "Dados de registro"
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dados de registro',
                        style: AppTextStyles.arimo(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3F3F3D), // neutral-800
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo CPF
                    _buildTextField(
                      controller: _cpfController,
                      label: 'CPF',
                      hint: 'Digite seu CPF',
                    ),
                    const SizedBox(height: 8),
                    // Campo CRM + UF
                    _buildTextField(
                      controller: _crmController,
                      label: 'CRM + UF',
                      hint: 'Ex: 123456/SP',
                    ),
                    const SizedBox(height: 8),
                    // Campo Especialidade médica
                    _buildTextField(
                      controller: _specialtyController,
                      label: 'Especialidade médica',
                      hint: 'Digite sua especialidade',
                    ),
                    const SizedBox(height: 8),
                    // Campo Tempo de atuação (dropdown)
                    _buildDropdownField(
                      label: 'Tempo de atuação',
                      hint: 'Selecione o tempo de atuação',
                      value: _selectedYearsOfExperience,
                      items: const [
                        'Menos de 1 ano',
                        '1 a 5 anos',
                        '5 a 10 anos',
                        '10 a 20 anos',
                        'Mais de 20 anos',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYearsOfExperience = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Card Endereço profissional
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F5), // neutral-050
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título "Endereço profissional"
                    Text(
                      'Endereço profissional',
                      style: AppTextStyles.arimo(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3F3F3D), // neutral-800
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtítulo
                    Text(
                      'Endereço profissional',
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9A9A97), // neutral-500
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Logradouro e Número
                    Row(
                      children: [
                        Expanded(
                          flex: 216,
                          child: _buildTextField(
                            controller: _streetController,
                            label: 'Logradouro',
                            hint: 'Ex: Rua rego freitas',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 86,
                          child: _buildTextField(
                            controller: _numberController,
                            label: 'Número',
                            hint: 'Ex: 452',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // CEP e Estado
                    Row(
                      children: [
                        Expanded(
                          flex: 216,
                          child: _buildTextField(
                            controller: _cepController,
                            label: 'CEP',
                            hint: 'Ex: 01240-001',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 86,
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'Estado',
                            hint: 'Ex: SP',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Cidade
                    _buildTextField(
                      controller: _cityController,
                      label: 'Cidade',
                      hint: 'Ex: São Paulo',
                    ),
                    const SizedBox(height: 8),
                    // Bairro
                    _buildTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro',
                      hint: 'Ex: Vila Madalena',
                    ),
                    const SizedBox(height: 8),
                    // Complemento
                    _buildTextField(
                      controller: _complementController,
                      label: 'Complemento',
                      hint: 'Ex: Apto 2006',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Botão Próximo
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/professional-validation/step2-documents');
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
                    'Próximo',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3D), // neutral-800
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 14,
              color: const Color(0xFF7C7C79), // neutral-600
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D3), // neutral-300
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D3), // neutral-300
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: AppTheme.canfyGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTextStyles.arimo(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3D), // neutral-800
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFD6D6D3), // neutral-300
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.arimo(
                fontSize: 14,
                color: const Color(0xFF7C7C79), // neutral-600
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF7C7C79),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}


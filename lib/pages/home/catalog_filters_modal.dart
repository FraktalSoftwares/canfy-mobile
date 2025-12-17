import 'package:flutter/material.dart';

class CatalogFiltersModal extends StatefulWidget {
  const CatalogFiltersModal({super.key});

  @override
  State<CatalogFiltersModal> createState() => _CatalogFiltersModalState();
}

class _CatalogFiltersModalState extends State<CatalogFiltersModal> {
  final Set<String> _selectedConcentrations = {};
  final Set<String> _selectedIndications = {};
  final Set<String> _selectedForms = {};
  final Set<String> _selectedCannabinoids = {};

  final List<String> _concentrations = [
    '5mg/ml',
    '10mg/ml',
    '15mg/ml',
    '20mg/ml',
    '25mg/ml',
    '30mg/ml',
  ];

  final List<String> _indications = [
    'Ansiedade',
    'Insônia',
    'Epilepsia',
    'TDAM',
    'Autismo',
  ];

  final List<String> _forms = [
    'Óleo',
    'Cápsula',
    'Spray',
    'Creme',
  ];

  final List<String> _cannabinoids = [
    'CBD',
    'THC',
    'CBN',
    'CBG',
  ];

  Widget _buildFilterTag(String label, Set<String> selectedSet, String value) {
    final isSelected = selectedSet.contains(value);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSet.remove(value);
          } else {
            selectedSet.add(value);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00994B) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00994B)
                : const Color(0xFF7C7C79),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : const Color(0xFF3F3F3D),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Concentração
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Concentração',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _concentrations
                    .map((concentration) => _buildFilterTag(
                          'Concentração',
                          _selectedConcentrations,
                          concentration,
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Indicações clínicas
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Indicações clínicas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _indications
                    .map((indication) => _buildFilterTag(
                          'Indicação',
                          _selectedIndications,
                          indication,
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Forma de uso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Forma de uso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _forms
                    .map((form) => _buildFilterTag(
                          'Forma',
                          _selectedForms,
                          form,
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Canabinoides
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Canabinoides',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cannabinoids
                    .map((cannabinoid) => _buildFilterTag(
                          'Canabinoide',
                          _selectedCannabinoids,
                          cannabinoid,
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Botões
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Aplicar filtros
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00994B),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Aplicar filtros',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedConcentrations.clear();
                      _selectedIndications.clear();
                      _selectedForms.clear();
                      _selectedCannabinoids.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: const BorderSide(color: Color(0xFF00994B)),
                  ),
                  child: const Text(
                    'Limpar filtros',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00994B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}






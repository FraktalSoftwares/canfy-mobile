import 'package:flutter/material.dart';

class CatalogFiltersModal extends StatefulWidget {
  const CatalogFiltersModal({super.key});

  @override
  State<CatalogFiltersModal> createState() => _CatalogFiltersModalState();
}

class _CatalogFiltersModalState extends State<CatalogFiltersModal> {
  final Set<String> _selectedConcentrations = {};
  final Set<String> _selectedIndications = {};
  final Set<String> _selectedUsageForms = {};
  final Set<String> _selectedCannabinoids = {};

  final List<String> _concentrations = ['10mg', '20mg', '30mg', '40mg', '50mg', '60mg'];
  final List<String> _indications = ['Ansiedade', 'Dor', 'Insônia', 'Epilepsia', 'Náusea'];
  final List<String> _usageForms = ['Óleo', 'Cápsula', 'Flor', 'Creme'];
  final List<String> _cannabinoids = ['CBD', 'THC', 'CBG', 'CBN'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF212121)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Concentração',
                    _concentrations,
                    _selectedConcentrations,
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    'Indicações clínicas',
                    _indications,
                    _selectedIndications,
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    'Forma de uso',
                    _usageForms,
                    _selectedUsageForms,
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    'Canabinoides',
                    _cannabinoids,
                    _selectedCannabinoids,
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9067F1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Aplicar filtros',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedConcentrations.clear();
                        _selectedIndications.clear();
                        _selectedUsageForms.clear();
                        _selectedCannabinoids.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9067F1),
                      side: const BorderSide(color: Color(0xFF9067F1)),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Limpar filtros',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    Set<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selected.remove(option);
                  } else {
                    selected.add(option);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF9067F1) 
                      : const Color(0xFFF1EDFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF9067F1) 
                        : const Color(0xFFE7E7F1),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected 
                        ? Colors.white 
                        : const Color(0xFF212121),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}






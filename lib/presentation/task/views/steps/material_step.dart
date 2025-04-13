import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class MaterialStep extends StatelessWidget {
  final List<Map<String, dynamic>> selectedMaterial;
  final Function() onAddMaterial;
  final Function(Map<String, dynamic>) onRemoveMaterial;
  final Function(Map<String, dynamic>, String, String) onUpdateMaterial;

  const MaterialStep({
    super.key,
    required this.selectedMaterial,
    required this.onAddMaterial,
    required this.onRemoveMaterial,
    required this.onUpdateMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ElevatedButton(
        onPressed: onAddMaterial,
        child: const Text('Tambah Material'),
      ),
        const SizedBox(height: 20),
        ...selectedMaterial.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['material'].nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onRemoveMaterial(item),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Jumlah ${item['material'].materialDetails?.materialUnit.name ?? "Unit"}',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(28)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(28)),
                              borderSide: BorderSide(color: Color(0xFFBF4D00), width: 0.5),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(28)),
                              borderSide: BorderSide(color: Color(0xFFBF4D00), width: 1),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: item['quantity'].toString(),
                          onChanged: (value) => onUpdateMaterial(item, 'quantity', value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga per ${item['material'].materialDetails?.materialUnit.name ?? "Unit"}: '
                    'Rp ${FormatHelpers.formatCurrency(item['material'].materialDetails?.pricePerUnit ?? 0)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ).toList(),
      ],
    );
  }
}
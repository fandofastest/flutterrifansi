import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class SecurityStep extends StatelessWidget {
  final List<Map<String, dynamic>> selectedSecurity;
  final Function() onAddSecurity;
  final Function(Map<String, dynamic>) onRemoveSecurity;
  final Function(Map<String, dynamic>, String, String) onUpdateSecurity;

  const SecurityStep({
    super.key,
    required this.selectedSecurity,
    required this.onAddSecurity,
    required this.onRemoveSecurity,
    required this.onUpdateSecurity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onAddSecurity,

          child: const Text('Tambah Security'),
        ),
        const SizedBox(height: 20),
        ...selectedSecurity
            .map(
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
                              item['security'].nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onRemoveSecurity(item),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Orang',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(28),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(28),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBF4D00),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(28),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBF4D00),
                                    width: 1,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: item['quantity'].toString(),
                              onChanged:
                                  (value) =>
                                      onUpdateSecurity(item, 'quantity', value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daily Cost: Rp ${FormatHelpers.formatCurrency(item['security'].securityDetails?.dailyCost ?? 0)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class ManpowerStep extends StatelessWidget {
  final List<Map<String, dynamic>> selectedManpower;
  final VoidCallback onAddManpower;
  final Function(Map<String, dynamic>) onRemoveManpower;
  final Function(Map<String, dynamic>, String, String) onUpdateManpower;

  const ManpowerStep({
    super.key,
    required this.selectedManpower,
    required this.onAddManpower,
    required this.onRemoveManpower,
    required this.onUpdateManpower,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: onAddManpower,
        child: const Text('Tambah Manpower'),
      ),
      const SizedBox(height: 20),
      ...selectedManpower.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['manpower'].nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemoveManpower(item),
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
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: item['quantity'].toString(),
                      onChanged: (value) => onUpdateManpower(item, 'quantity', value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Jam',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: item['hours'].toString(),
                      onChanged: (value) => onUpdateManpower(item, 'hours', value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cost per Hour: Rp ${FormatHelpers.formatCurrency(item['manpower'].costPerHour)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      )).toList(),
    ],
  );
}
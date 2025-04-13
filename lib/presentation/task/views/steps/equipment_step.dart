import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class EquipmentStep extends StatelessWidget {
  final List<Map<String, dynamic>> selectedEquipment;
  final VoidCallback onAddEquipment;
  final Function(Map<String, dynamic>) onRemoveEquipment;
  final Function(Map<String, dynamic>, String, String) onUpdateEquipment;

  const EquipmentStep({
    super.key,
    required this.selectedEquipment,
    required this.onAddEquipment,
    required this.onRemoveEquipment,
    required this.onUpdateEquipment,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: onAddEquipment,
        child: const Text('Tambah Equipment'),
      ),
      const SizedBox(height: 20),
      ...selectedEquipment.map((item) => Card(
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
                      item['equipment'].nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemoveEquipment(item),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Unit',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: item['quantity'].toString(),
                      onChanged: (value) => onUpdateEquipment(item, 'quantity', value),
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
                      onChanged: (value) => onUpdateEquipment(item, 'hours', value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cost per Hour: Rp ${FormatHelpers.formatCurrency(item['equipment'].costPerHour)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      )).toList(),
    ],
  );
}
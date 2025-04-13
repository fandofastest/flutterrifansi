import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class ResourcesStep extends StatelessWidget {
  final List<Map<String, dynamic>> selectedEquipment;
  final Function(Map<String, dynamic>, String, String) onUpdateEquipment;
  final double currentSolarPrice;

  const ResourcesStep({
    Key? key,
    required this.selectedEquipment,
    required this.onUpdateEquipment,
    this.currentSolarPrice = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment Resources',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...selectedEquipment.map((item) {
          // Calculate total fuel cost
          double fuelUsage = (item['fuelUsage'] ?? 0).toDouble();
          double totalFuelCost = fuelUsage * currentSolarPrice;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['equipment'].nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fuel Usage (Liters)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: item['fuelUsage']?.toString() ?? '0',
                    onChanged: (value) => onUpdateEquipment(item, 'fuelUsage', value),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Fuel Price:'),
                            Text(
                              'Rp ${FormatHelpers.formatCurrency(currentSolarPrice)}/L',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Fuel Cost:'),
                            Text(
                              'Rp ${FormatHelpers.formatCurrency(totalFuelCost)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBF4D00),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
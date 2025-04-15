import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/models/spk_details.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';

class StepContentWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final List<Map<String, dynamic>> selectedItems;
  final SpkDetails spkDetails;
  final Function(String itemId, String value) onQuantityChanged;

  const StepContentWidget({
    Key? key,
    required this.category,
    required this.selectedItems,
    required this.spkDetails,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(category['items'] ?? []);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input for ${category['name']}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            final selectedItem = selectedItems.firstWhere(
              (sel) => sel['item']['_id'] == item['_id'],
              orElse: () => {'item': item, 'quantity': 0},
            );
            
            final quantity = selectedItem['quantity'] ?? 0;
            final dailyTarget = (item['targetQty'] / spkDetails.projectDuration).ceil();
            final totalPrice = quantity * (item['rate'] ?? 0);

            // Create a stateful builder to manage the text field state locally
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['description'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Target Qty: ${item['targetQty']}'),
                    const SizedBox(height: 8),
                    Text('Daily Target: $dailyTarget'),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) {
                        // Use a local controller that doesn't get recreated on each build
                        final controller = TextEditingController(text: quantity.toString());
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                        
                        return TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Unit',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            onQuantityChanged(item['_id'], value);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harga: Rp ${FormatHelpers.formatCurrency(item['rate'] ?? 0)}',
                    ),
                    Text(
                      'Total Harga: Rp ${FormatHelpers.formatCurrency(totalPrice)}',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

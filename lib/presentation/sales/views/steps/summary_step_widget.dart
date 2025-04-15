import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/models/spk_details.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';
import 'package:marquee/marquee.dart';

class SummaryStepWidget extends StatelessWidget {
  final SpkDetails spkDetails;
  final List<Map<String, dynamic>> selectedItems;

  const SummaryStepWidget({
    Key? key,
    required this.spkDetails,
    required this.selectedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalSpentToday = selectedItems.fold(0, (sum, item) {
      return sum + ((item['quantity'] ?? 0) * (item['item']['rate'] ?? 0));
    });
    double totalAmount = spkDetails.totalAmount ?? 0;
    double projectDuration = spkDetails.projectDuration.toDouble();

    // Persentase (sekadar contoh, silakan modifikasi)
    final percentageOfWorkDoneToday = (totalAmount > 0 && projectDuration > 0)
        ? (totalSpentToday / (totalAmount / projectDuration)) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...selectedItems.map((item) {
            double itemTotalPriceToday = (item['quantity'] ?? 0) * (item['item']['rate'] ?? 0);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Marquee(
                        text: 'Item: ${item['item']['description']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 20.0,
                        velocity: 30.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unit Price: Rp ${FormatHelpers.formatCurrency(item['item']['rate'] ?? 0)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Qty Today: ${item['quantity'] ?? 0}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Price Today: Rp ${FormatHelpers.formatCurrency(itemTotalPriceToday)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price Today: Rp ${FormatHelpers.formatCurrency(totalSpentToday)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Percentage Today: ${percentageOfWorkDoneToday.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/utils/format_helpers.dart';

class SpkStep extends StatelessWidget {
  final Map<String, dynamic>? selectedSpkDetails;
  final String? selectedSpk;
  final VoidCallback onSelectSpk;

  const SpkStep({
    super.key,
    this.selectedSpkDetails,
    this.selectedSpk,
    required this.onSelectSpk,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: onSelectSpk,
        child: const Text('Pilih SPK'),
      ),
      const SizedBox(height: 20),
      if (selectedSpkDetails != null) ...[
        Text(
          'SPK No: ${selectedSpkDetails!['spkNo']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Title: ${selectedSpkDetails!['spkTitle']}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Start Date: ${selectedSpkDetails!['projectStartDate'] != null 
              ? FormatHelpers.formatDate(selectedSpkDetails!['projectStartDate'])
              : 'Not set'}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'End Date: ${selectedSpkDetails!['projectEndDate'] != null 
              ? FormatHelpers.formatDate(selectedSpkDetails!['projectEndDate'])
              : 'Not set'}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Location: ${selectedSpkDetails!['location']?['name'] ?? 'Not set'}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Amount: Rp ${FormatHelpers.formatCurrency(selectedSpkDetails!['totalAmount'])}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ] else
        Text(
          selectedSpk ?? 'Belum memilih SPK',
          style: const TextStyle(fontSize: 16),
        ),
    ],
  );
}
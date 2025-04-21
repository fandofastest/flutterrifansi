import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';

class SpkDetailDialog extends StatelessWidget {
  final Map<String, dynamic> spk;
  final double progressPercent;
  final String locationName; // Add location name
  final int projectDuration; // Add project duration
  final int progressCount; // Add progress count

  const SpkDetailDialog({
    Key? key,
    required this.spk,
    required this.progressPercent,
    required this.locationName, // Make required
    required this.projectDuration, // Make required
    required this.progressCount, // Make required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        spk['spkTitle'] ?? 'SPK Detail',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('SPK Number', spk['spkNo'] ?? 'N/A'),
            _buildDetailItem('Status', spk['status'] ?? 'N/A',
                color: spk['status'] == 'active' ? Colors.green : Colors.red),
            _buildDetailItem('Location', locationName), // Display location
            _buildDetailItem('Start Date', FormatHelpers.formatDate(spk['projectStartDate']) ?? 'N/A'),
            _buildDetailItem('End Date', FormatHelpers.formatDate(spk['projectEndDate']) ?? 'N/A'),
            _buildDetailItem('Duration', '$projectDuration days'), // Display duration
            _buildDetailItem('Total Amount', FormatHelpers.formatCurrency(spk['totalAmount']) ?? 'N/A'),

            const SizedBox(height: 16),
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailItem('Entries', '$progressCount'), // Display progress count
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progressPercent / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFBF4D00)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFBF4D00), // Use your theme color
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Adjust width as needed
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';

class TaskListItem extends StatelessWidget {
  final Map<String, dynamic> spk;
  
  const TaskListItem({
    Key? key,
    required this.spk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spk['spkTitle'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis, // Ensure title fits in one line
              ),
              maxLines: 1, // Limit title to one line
            ),
            const SizedBox(height: 8),
            Text(
              'SPK Number: ${spk['spkNo'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Status: ${spk['status'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: spk['status'] == 'active' ? Colors.green : Colors.red,
              ),
            ),
            Text(
              'Start Date: ${FormatHelpers.formatDate(spk['projectStartDate']) ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'End Date: ${FormatHelpers.formatDate(spk['projectEndDate']) ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward_ios, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
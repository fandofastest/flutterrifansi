import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';
import 'package:flutterrifansi/presentation/home/widgets/spk_detail_dialog.dart'; // Import the dialog
import 'package:get/get.dart'; // Import Get
import 'package:flutterrifansi/core/services/api_service.dart'; // Import ApiService

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
      child: InkWell(
        onTap: () => _showSpkDetailDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row( // Use Row for image + details layout
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
            children: [
              // Placeholder for Image - Replace with actual image widget later
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Placeholder background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.construction, // Placeholder icon
                  size: 40,
                  color: const Color(0xFFBF4D00), // Theme color
                ),
              ),
              // Expanded Column for text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spk['spkTitle'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2, // Allow title to wrap slightly
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(Icons.confirmation_number_outlined, 'SPK No:', spk['spkNo'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      spk['status'] == 'active' ? Icons.check_circle_outline : Icons.cancel_outlined,
                      'Status:',
                      spk['status'] ?? 'N/A',
                      valueColor: spk['status'] == 'active' ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(height: 4),
                    _buildDetailRow(Icons.calendar_today_outlined, 'Start:', FormatHelpers.formatDate(spk['projectStartDate']) ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildDetailRow(Icons.event_available_outlined, 'End:', FormatHelpers.formatDate(spk['projectEndDate']) ?? 'N/A'),
                  ],
                ),
              ),
              // Arrow icon at the end
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 4.0), // Adjust padding
                child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Method to fetch progress and show the dialog (remains the same)
  void _showSpkDetailDialog(BuildContext context) async {
    final spkId = spk['id'] ?? spk['_id'];
    if (spkId == null) {
      Get.snackbar('Error', 'SPK ID not found');
      return;
    }

    double progressPercent = 0.0; // Default progress
    int progressCount = 0; // Initialize progress count
    String locationName = spk['location']?['name'] ?? 'N/A'; // Extract location name
    int projectDuration = spk['projectDuration'] ?? 0; // Extract project duration

    try {
      // Show loading indicator while fetching
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing while loading
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
  final ApiService api = Get.find<ApiService>();

      final progressList = await api.getSpkProgressBySpkId(spkId);
      // Use mounted check before popping context if TaskListItem could be disposed
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading indicator

      progressCount = progressList.length; // Get the number of progress entries

      // Calculate progress percentage
      double totalAmount = (spk['totalAmount'] ?? 0).toDouble();
      double progressAmount = 0;
      for (var progress in progressList) {
        if (progress['progressItems'] != null) {
          for (var item in progress['progressItems']) {
            progressAmount += (item['workQty']?['amount'] ?? 0).toDouble();
          }
        }
      }
      progressPercent = totalAmount > 0 ? (progressAmount / totalAmount) * 100 : 0;

      // Show the actual detail dialog
      // Use mounted check before showing dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => SpkDetailDialog(
          spk: spk,
          progressPercent: progressPercent,
          locationName: locationName, // Pass location
          projectDuration: projectDuration, // Pass duration
          progressCount: progressCount, // Pass progress count
        ),
      );
    } catch (e) {
       // Use mounted check before popping context
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading indicator on error
      Get.snackbar('Error', 'Failed to load SPK progress: ${e.toString()}');
    }
  }
}
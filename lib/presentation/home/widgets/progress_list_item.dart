import 'package:flutter/material.dart';
import 'package:flutterrifansi/presentation/home/widgets/progress_detail_dialog.dart';

class ProgressListItem extends StatelessWidget {
  final Map<String, dynamic> progress;

  const ProgressListItem({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final spk = progress['spk'] ?? {};
    
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ProgressDetailDialog(progress: progress),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spk['spkNo']?.toString() ?? 'No SPK Number',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  spk['spkTitle']?.toString() ?? 'No Title',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Progress Date: ${progress['progressDate']?.toString().substring(0, 10) ?? 'N/A'}',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mandor: ${progress['mandor']?['name'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
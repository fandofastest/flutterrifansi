import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/constants/api_constants.dart';
import 'package:intl/intl.dart';

class ProgressDetailDialog extends StatelessWidget {
  final Map<String, dynamic> progress;

  const ProgressDetailDialog({super.key, required this.progress});

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spk = progress['spk'] ?? {};
    final mandor = progress['mandor'] ?? {};
    final progressItems = progress['progressItems'] as List<dynamic>? ?? [];
    final costUsed = progress['costUsed'] as List<dynamic>? ?? [];
    final timeDetails = progress['timeDetails'] ?? {};
    final images = progress['images'] ?? {};
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFBF4D00),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'SPK Information',
                        [
                          _buildDetailRow('SPK Number', spk['spkNo']?.toString() ?? 'N/A'),
                          _buildDetailRow('Title', spk['spkTitle']?.toString() ?? 'N/A'),
                          _buildDetailRow('Status', spk['status']?.toString() ?? 'N/A'),
                          _buildDetailRow('Location', spk['location']?.toString() ?? 'N/A'),
                          _buildDetailRow('Project Start', _formatDateTime(spk['projectStartDate']?.toString())),
                          _buildDetailRow('Project End', _formatDateTime(spk['projectEndDate']?.toString())),
                          _buildDetailRow('Duration', '${spk['projectDuration']} Days'),
                          _buildDetailRow('Total Amount', 'IDR ${NumberFormat('#,###').format(spk['totalAmount'] ?? 0)}'),
                        ],
                      ),
                      _buildSection(
                        'Progress Information',
                        [
                          _buildDetailRow('Start Time', _formatDateTime(timeDetails['startTime']?.toString())),
                          _buildDetailRow('End Time', _formatDateTime(timeDetails['endTime']?.toString())),
                          _buildDetailRow('DCU Time', _formatDateTime(timeDetails['dcuTime']?.toString())),
                        ],
                      ),
                      _buildSection(
                        'Progress Images',
                        [
                          if (images['startImage'] != null) _buildImageRow('Start Image', images['startImage']),
                          if (images['endImage'] != null) _buildImageRow('End Image', images['endImage']),
                          if (images['dcuImage'] != null) _buildImageRow('DCU Image', images['dcuImage']),
                        ],
                      ),
                      _buildSection(
                        'Mandor Information',
                        [
                          _buildDetailRow('Name', mandor['name']?.toString() ?? 'N/A'),
                          _buildDetailRow('Email', mandor['email']?.toString() ?? 'N/A'),
                          _buildDetailRow('Role', mandor['role']?.toString() ?? 'N/A'),
                        ],
                      ),
                      if (progressItems.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Progress Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: progressItems.length,
                          itemBuilder: (context, index) {
                            final item = progressItems[index];
                            final workQty = item['workQty'] ?? {};
                            final quantity = workQty['quantity'] ?? {};
                            final snapshot = item['spkItemSnapshot'] ?? {};
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot['description']?.toString() ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quantity: NR: ${quantity['nr']}, R: ${quantity['r']}',
                                      style: const TextStyle(color: Color(0xFF718096)),
                                    ),
                                    Text(
                                      'Amount: IDR ${NumberFormat('#,###').format(workQty['amount'] ?? 0)}',
                                      style: const TextStyle(color: Color(0xFF718096)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (costUsed.isNotEmpty) _buildCostUsedSection(costUsed),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Total Progress Items', 
                                'IDR ${NumberFormat('#,###').format(progress['totalProgressItem'] ?? 0)}'
                              ),
                              _buildDetailRow(
                                'Total Cost Used', 
                                'IDR ${NumberFormat('#,###').format(progress['totalCostUsed'] ?? 0)}'
                              ),
                              _buildDetailRow(
                                'Daily Target', 
                                'IDR ${NumberFormat('#,###').format((spk['totalAmount'] ?? 0) / (spk['projectDuration'] ?? 1))}'
                              ),
                              _buildDetailRow(
                                'Progress Percentage', 
                                '${NumberFormat('#,##0.00').format(((progress['totalProgressItem'] ?? 0) / ((spk['totalAmount'] ?? 0) / (spk['projectDuration'] ?? 1))) * 100)}%'
                              ),
                              const Divider(),
                              _buildDetailRow(
                                'Grand Total (Progress - Cost)', 
                                'IDR ${NumberFormat('#,###').format((progress['totalProgressItem'] ?? 0) - (progress['totalCostUsed'] ?? 0))}'
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (progress['totalProgressItem'] ?? 0) > (progress['totalCostUsed'] ?? 0) ? 'Profit' : 'Loss',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (progress['totalProgressItem'] ?? 0) > (progress['totalCostUsed'] ?? 0) 
                                    ? Colors.green 
                                    : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBF4D00),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageRow(String label, String imagePath) {
    final fullImageUrl = '${ApiConstants.mainurl}$imagePath';
    print('Full Image URL: $fullImageUrl');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostUsedSection(List<dynamic> costUsed) {
    return _buildSection(
      'Cost Details',
      costUsed.map((cost) {
        final details = cost['details'] ?? {};
        final itemCostDetails = cost['itemCostDetails'] ?? {};
        final category = itemCostDetails['category']?.toString().toLowerCase() ?? '';
        final totalCost = cost['totalCost'] ?? 0;

        final manpower = details['manpower'] ?? {};
        final equipment = details['equipment'] ?? {};
        final material = details['material'] ?? {};
        final security = details['security'] ?? {};
        final other = details['other'] ?? {};

        List<Widget> costDetails = [];

        // Manpower details
        if ((manpower['jumlahOrang'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Manpower Count', '${manpower['jumlahOrang']} people'));
        }
        if ((manpower['jamKerja'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Working Hours', '${manpower['jamKerja']} hours'));
        }
        if ((manpower['costPerHour'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Cost per Hour', 'IDR ${NumberFormat('#,###').format(manpower['costPerHour'])}'));
        }

        // Equipment details
        if ((equipment['jumlah'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Equipment Count', '${equipment['jumlah']}'));
        }
        if ((equipment['jamKerja'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Equipment Hours', '${equipment['jamKerja']} hours'));
        }
        if ((equipment['jumlahSolar'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Fuel Usage', '${equipment['jumlahSolar']} liters'));
        }
        if ((equipment['fuelUsage'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Fuel Usage per Hour', '${equipment['fuelUsage']} liters'));
        }
        if ((equipment['fuelPrice'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Fuel Price', 'IDR ${NumberFormat('#,###').format(equipment['fuelPrice'])}'));
        }
        if ((equipment['costPerHour'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Cost per Hour', 'IDR ${NumberFormat('#,###').format(equipment['costPerHour'])}'));
        }

        // Material details
        if ((material['jumlahUnit'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Material Units', '${material['jumlahUnit']}'));
        }
        if ((material['pricePerUnit'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Price per Unit', 'IDR ${NumberFormat('#,###').format(material['pricePerUnit'])}'));
        }

        // Security details
        if ((security['jumlahOrang'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Security Personnel', '${security['jumlahOrang']} people'));
        }
        if ((security['dailyCost'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Daily Cost', 'IDR ${NumberFormat('#,###').format(security['dailyCost'])}'));
        }

        // Other costs
        if ((other['nominal'] ?? 0) > 0) {
          costDetails.add(_buildDetailRow('Other Costs', 'IDR ${NumberFormat('#,###').format(other['nominal'])}'));
        }

        // Total cost
        if (totalCost > 0) {
          costDetails.add(const Divider(height: 24));
          costDetails.add(_buildDetailRow('Total Cost', 'IDR ${NumberFormat('#,###').format(totalCost)}'));
        }

        return costDetails.isEmpty ? const SizedBox() : Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: costDetails,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
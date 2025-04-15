import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/constants/api_constants.dart';
import 'package:flutterrifansi/core/models/spk_details.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';
import 'package:flutterrifansi/presentation/shared/widgets/network_image_with_fallback.dart';
import 'package:flutterrifansi/presentation/shared/widgets/photo_viewer_dialog.dart';
import 'package:intl/intl.dart';

class SubmitDialog extends StatelessWidget {
  final SpkDetails spkDetails;
  final List<Map<String, dynamic>> selectedItems;
  final Map<String, dynamic>? taskFormData;
  final Function(Map<String, dynamic>) onSubmit;

  const SubmitDialog({
    Key? key,
    required this.spkDetails,
    required this.selectedItems,
    this.taskFormData,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate totals for summary
    double totalSpentToday = selectedItems.fold(0, (sum, item) {
      return sum + ((item['quantity'] ?? 0) * (item['item']['rate'] ?? 0));
    });
    
    // Calculate costs from task form data
    List<Map<String, dynamic>> costItems = [];
    double totalCost = 0;
    
    // Extract time and photo data
    String? dcuImagePath, startImagePath, endImagePath;
    DateTime? dcuTime, startTime, endTime;
    
    if (taskFormData != null) {
      if (taskFormData!['images'] != null) {
        dcuImagePath = taskFormData!['images']['dcuImage'];
        startImagePath = taskFormData!['images']['startImage'];
        endImagePath = taskFormData!['images']['endImage'];
      }
      
      if (taskFormData!['timeDetails'] != null) {
        dcuTime = taskFormData!['timeDetails']['dcuTime'] != null 
            ? DateTime.parse(taskFormData!['timeDetails']['dcuTime']) 
            : null;
        startTime = taskFormData!['timeDetails']['startTime'] != null 
            ? DateTime.parse(taskFormData!['timeDetails']['startTime']) 
            : null;
        endTime = taskFormData!['timeDetails']['endTime'] != null 
            ? DateTime.parse(taskFormData!['timeDetails']['endTime']) 
            : null;
      }
      
      if (taskFormData!['costUsed'] != null) {
        final List<dynamic> costUsed = taskFormData!['costUsed'];
        
        for (var cost in costUsed) {
          final Map<String, dynamic> details = cost['details'] ?? {};
          final Map<String, dynamic>? itemCostDetails = cost['itemCostDetails'];
          String type = '';
          String description = '';
          double amount = 0;
          Map<String, dynamic> displayDetails = {};
          
          if (details.containsKey('manpower')) {
            final manpower = details['manpower'];
            amount = (manpower['jumlahOrang'] ?? 0) * (manpower['jamKerja'] ?? 0) * (manpower['costPerHour'] ?? 0);
            type = 'Manpower';
            description = itemCostDetails?['nama'] ?? 'Unknown Manpower';
            displayDetails = {
              'Jumlah Orang': manpower['jumlahOrang'] ?? 0,
              'Jam Kerja': manpower['jamKerja'] ?? 0,
              'Cost/Hour': FormatHelpers.formatCurrency(manpower['costPerHour'] ?? 0),
            };
          } else if (details.containsKey('equipment')) {
            final equipment = details['equipment'];
            amount = (equipment['jumlahUnit'] ?? 0) * (equipment['jamKerja'] ?? 0) * (equipment['costPerHour'] ?? 0);
            if (equipment['fuelUsage'] != null && equipment['fuelPrice'] != null) {
              amount += (equipment['fuelUsage'] ?? 0) * (equipment['fuelPrice'] ?? 0);
            }
            type = 'Equipment';
            description = itemCostDetails?['nama'] ?? 'Unknown Equipment';
            displayDetails = {
              'Jumlah Unit': equipment['jumlahUnit'] ?? 0,
              'Jam Kerja': equipment['jamKerja'] ?? 0,
              'Cost/Hour': FormatHelpers.formatCurrency(equipment['costPerHour'] ?? 0),
              'Fuel Usage': equipment['fuelUsage'] ?? 0,
              'Fuel Price': FormatHelpers.formatCurrency(equipment['fuelPrice'] ?? 0),
            };
          } else if (details.containsKey('material')) {
            final material = details['material'];
            amount = (material['jumlahUnit'] ?? 0) * (material['pricePerUnit'] ?? 0);
            type = 'Material';
            description = itemCostDetails?['nama'] ?? 'Unknown Material';
            displayDetails = {
              'Jumlah Unit': material['jumlahUnit'] ?? 0,
              'Price/Unit': FormatHelpers.formatCurrency(material['pricePerUnit'] ?? 0),
            };
          } else if (details.containsKey('security')) {
            final security = details['security'];
            amount = (security['jumlahOrang'] ?? 0) * (security['dailyCost'] ?? 0);
            type = 'Security';
            description = itemCostDetails?['nama'] ?? 'Unknown Security';
            displayDetails = {
              'Jumlah Orang': security['jumlahOrang'] ?? 0,
              'Daily Cost': FormatHelpers.formatCurrency(security['dailyCost'] ?? 0),
            };
          }
          
          totalCost += amount;
          costItems.add({
            'type': type,
            'description': description,
            'amount': amount,
            'details': displayDetails,
          });
        }
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: min(MediaQuery.of(context).size.width * 0.9, 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SPK Info
                    Text('SPK: ${spkDetails.spkNo}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // Time and Photos Section
                    if (dcuTime != null || startTime != null || endTime != null) ...[
                      const Text(
                        'Time & Photos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      // DCU Time and Photo
                      if (dcuTime != null && dcuImagePath != null && dcuImagePath!.isNotEmpty) ...[
                        _buildTimeAndPhotoSummary(context, 'Jam DCU', dcuTime!, dcuImagePath!),
                        const SizedBox(height: 8),
                      ],
                      
                      // Start Time and Photo
                      if (startTime != null && startImagePath != null && startImagePath!.isNotEmpty) ...[
                        _buildTimeAndPhotoSummary(context, 'Jam Mulai Kerja', startTime!, startImagePath!),
                        const SizedBox(height: 8),
                      ],
                      
                      // End Time and Photo
                      if (endTime != null && endImagePath != null && endImagePath!.isNotEmpty) ...[
                        _buildTimeAndPhotoSummary(context, 'Jam Selesai', endTime!, endImagePath!),
                        const SizedBox(height: 8),
                      ],
                      
                      const SizedBox(height: 8),
                    ],
                    
                    // Selected Items Summary
                    const Text(
                      'Sales Items',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...selectedItems.map((item) {
                      double itemTotalPrice = (item['quantity'] ?? 0) * (item['item']['rate'] ?? 0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['item']['description'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('Quantity: ${item['quantity'] ?? 0}'),
                            Text('Rate: Rp ${FormatHelpers.formatCurrency(item['item']['rate'] ?? 0)}'),
                            Text('Total: Rp ${FormatHelpers.formatCurrency(itemTotalPrice)}'),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    // Cost Items Summary (if available)
                    if (costItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Cost Used',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...costItems.map((cost) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getCostTypeColor(cost['type'])[0],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cost['type'],
                                      style: TextStyle(
                                        color: _getCostTypeColor(cost['type'])[1],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      cost['description'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              
                              // Display detailed cost information
                              ...cost['details'].entries.map<Widget>((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${entry.key}: ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Total: Rp ${FormatHelpers.formatCurrency(cost['amount'])}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    
                    // Grand Total
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Revenue Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                        'Rp ${FormatHelpers.formatCurrency(totalSpentToday)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    
                    if (costItems.isNotEmpty)
                      ListTile(
                        title: const Text('Cost Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          'Rp ${FormatHelpers.formatCurrency(totalCost)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      
                    if (costItems.isNotEmpty)
                      ListTile(
                        title: const Text('Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          'Rp ${FormatHelpers.formatCurrency(totalSpentToday - totalCost)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: (totalSpentToday - totalCost) >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    
                    // Project Progress
                    const SizedBox(height: 16),
                    Text(
                      'Daily Target',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (spkDetails.totalAmount) > 0 
                          ? totalSpentToday / (spkDetails.totalAmount/spkDetails.projectDuration) 
                          : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBF4D00)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${((spkDetails.totalAmount) > 0 
                          ? (totalSpentToday / (spkDetails.totalAmount/spkDetails.projectDuration)) * 100 
                          : 0).toStringAsFixed(2)}%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final formattedData = {
                      'spk': spkDetails.id,
                      'selectedItems': selectedItems,
                      'taskFormData': taskFormData,
                    };
                    onSubmit(formattedData);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF4D00),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build time and photo summary
  Widget _buildTimeAndPhotoSummary(BuildContext context, String title, DateTime time, String imagePath) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(time)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            
            // Display image with full width and proper height
            GestureDetector(
              onTap: () {
                if (imagePath.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => PhotoViewerDialog(
                      imagePath: imagePath,
                      title: title,
                    ),
                  );
                }
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageWithFallback(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        timeoutDuration: const Duration(seconds: 5),
                      ),
                      // Add a zoom icon overlay in the corner if image is available
                      if (imagePath.isNotEmpty)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 20,
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
  
  List<Color> _getCostTypeColor(String type) {
    switch (type) {
      case 'Manpower':
        return [Colors.blue[100]!, Colors.blue[800]!];
      case 'Equipment':
        return [Colors.orange[100]!, Colors.orange[800]!];
      case 'Material':
        return [Colors.green[100]!, Colors.green[800]!];
      case 'Security':
        return [Colors.purple[100]!, Colors.purple[800]!];
      default:
        return [Colors.grey[100]!, Colors.grey[800]!];
    }
  }
}
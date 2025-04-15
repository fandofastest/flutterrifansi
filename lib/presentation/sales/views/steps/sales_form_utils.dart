import 'package:flutter/material.dart';

class SalesFormUtils {
  static Map<String, dynamic> buildSalesProgressJson({
    required String mandorId,
    required String spkId,
    required List<Map<String, dynamic>> selectedItems,
    Map<String, dynamic>? taskFormData,
  }) {
    final progressItems = selectedItems.map((item) => {
      'spkItemSnapshot': {
        'item': item['item']['_id'],
        'description': item['item']['description'],
      },
      'workQty': {
        'quantity': {
          'nr': item['quantity'] ?? 0,
          'r': 0,
        },
        'amount': (item['quantity'] ?? 0) * (item['item']['rate'] ?? 0),
      },
      'unitRate': {
        'nonRemoteAreas': item['item']['rate'] ?? 0,
        'remoteAreas': item['item']['rate'] ?? 0,
      },
    }).toList();

    // Extract costs from task form data if available
    List<Map<String, dynamic>> costUsed = [];
    if (taskFormData != null && taskFormData['costUsed'] != null) {
      costUsed = List<Map<String, dynamic>>.from(taskFormData['costUsed']);
    }

    // Get time details and images from task form data
    Map<String, dynamic> timeDetails = taskFormData?['timeDetails'] ?? {
      'startTime': DateTime.now().toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'dcuTime': DateTime.now().toIso8601String(),
    };

    Map<String, dynamic> images = taskFormData?['images'] ?? {
      'startImage': '',
      'endImage': '',
      'dcuImage': '',
    };

    return {
      'mandor': mandorId,
      'spk': spkId,
      'progressItems': progressItems,
      'progressDate': DateTime.now().toIso8601String(),
      'timeDetails': timeDetails,
      'images': images,
      'costUsed': costUsed,
    };
  }
}

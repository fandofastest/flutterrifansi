
import 'dart:async';

import 'package:flutterrifansi/core/constants/api_constants.dart';
import 'package:flutterrifansi/core/models/item_cost.dart';
import 'package:flutterrifansi/core/models/sales_item.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetConnect {
  final GetStorage _storage = GetStorage();
  
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 60); // Increased to 60 seconds
    httpClient.addRequestModifier<dynamic>((request) {
      print('Sending request to: ${request.url}');
      return request;
    });
    super.onInit();
  }

  // Get token from storage
  Future<String> getToken() async {
    final token = _storage.read('token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  // Login method (preserving existing functionality)
  Future<Response> login(String username, String password) async {
    return await post(
      ApiConstants.login,
      {
        'username': username,
        'password': password,
      },
    );
  }

  // Get SPKs method (preserving existing functionality)
  Future<List<Map<String, dynamic>>> getSpks() async {
    final response = await get(
      ApiConstants.spk,
    );
    if (response.statusCode == HttpStatus.ok) {
      return List<Map<String, dynamic>>.from(response.body);
    }
    throw Exception('Failed to load SPK data');
  }

  // New method to get item costs by category
  Future<List<ItemCost>> getItemCostsByCategory(String category) async {
    final response = await get(
      '${ApiConstants.itemCostsByCategory}/$category',
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.body;
      return data.map((json) => ItemCost.fromJson(json)).toList();
    }
    
    throw Exception('Failed to load item costs: ${response.statusText}');
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await get(
      ApiConstants.categories,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    
    if (response.statusCode == HttpStatus.ok) {
      return List<Map<String, dynamic>>.from(response.body);
    }
    throw Exception('Failed to load categories: ${response.statusText}');
  }
  Future<List<SalesItem>> getItemsByCategory(String categoryId) async {
    final response = await get(
      '${ApiConstants.itemsByCategory}/$categoryId',
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> data = response.body;
      return data.map((json) => SalesItem.fromJson(json)).toList();
    }
    
    throw Exception('Failed to load items: ${response.statusText}');
  }
  
  // Update the method to get SPK details
  Future<Map<String, dynamic>> getSpkDetails(String spkId) async {
    final response = await get(
      '${ApiConstants.spk}/$spkId',
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return Map<String, dynamic>.from(response.body);
    }
    
    throw Exception('Failed to load SPK details: ${response.statusText}');
  }

  Future<Map<String, dynamic>> postSpkProgress(Map<String, dynamic> data) async {
    final response = await post(
      ApiConstants.spkProgress,
      data,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

   return response.body;
    
  }

  Future<Map<String, dynamic>> getCurrentSolarPrice() async {
    final response = await get(
      ApiConstants.solarPrice,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final price = response.body['data']['price'];
      return {
        'price': price is int ? price.toDouble() : double.tryParse(price.toString()) ?? 0.0
      };
    }
    
    throw Exception('Failed to get current solar price: ${response.statusText}');
  }

  Future<List<Map<String, dynamic>>> getSpkProgress() async {
      final response = await get(
        ApiConstants.spkProgress,
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
        },
      );
  
      if (response.statusCode == HttpStatus.ok) {
        return List<Map<String, dynamic>>.from(response.body);
      }
      throw Exception('Failed to load SPK Progress: ${response.statusText}');
    }

  Future<List<Map<String, dynamic>>> getSpkProgressBySpkId(String spkId) async {
    final response = await get(
      '${ApiConstants.spkProgress}/spk/$spkId',
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      return List<Map<String, dynamic>>.from(response.body);
    }
    throw Exception('Failed to load SPK Progress by SPK ID: ${response.statusText}');
  }
}
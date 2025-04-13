import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find();
  final GetStorage _storage = GetStorage();

  final RxBool isLoading = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  Future<void> login(String username, String password) async {
    try {
      print('Login started for user: $username');
      isLoading.value = true;
      
      final response = await _apiService.login(username, password);
      print('API Response received. Status: ${response.statusCode}');
      
      if (response.statusCode == HttpStatus.ok) {
        print('Login successful');
        final responseBody = response.body;
        print('Response body: $responseBody');
        
        if (responseBody is Map<String, dynamic>) {
          // Add null check for user data
          if (responseBody['user'] != null) {
            user.value = UserModel.fromJson(responseBody['user']);
            _storage.write('token', responseBody['token']);
            Get.offAllNamed('/home');
          } else {
            throw Exception('User data is null');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorMessage = response.body is Map ? 
          response.body['message'] ?? 'Login failed' : 'Login failed';
        print('Login failed: $errorMessage');
        Get.snackbar('Error', errorMessage.toString());
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      print('Login process completed');
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.remove('token');
    user.value = null;
    Get.offAllNamed('/login');
  }
}
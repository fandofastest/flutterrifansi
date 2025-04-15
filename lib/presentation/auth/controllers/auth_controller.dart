import 'dart:convert';
import 'dart:io';

import 'package:flutterrifansi/core/services/biometric_service.dart';
import 'package:flutterrifansi/presentation/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final BiometricService _biometricService = BiometricService();
  
  Future<void> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        Get.snackbar('Error', 'Biometric authentication not available');
        return;
      }

      final isAuthenticated = await _biometricService.authenticate();
      if (isAuthenticated) {
        // Load user data and token from storage
        final userData = _storage.read('user_data');
        final token = _storage.read('token');
        
        if (userData != null && token != null) {
          user.value = UserModel.fromJson(json.decode(userData));
          // Navigate to home if authentication is successful
          Get.offAllNamed('/home');
        } else {
          Get.snackbar('Error', 'User data not found');
        }
      } else {
        Get.snackbar('Error', 'Biometric authentication failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Authentication error');
    }
  }
  
  late final ApiService _apiService;
  final GetStorage _storage = GetStorage();

  final RxBool isLoading = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize ApiService here instead of using Get.find()
    _apiService = Get.put(ApiService());
    Get.put(HomeController());
    // Load user data if available
    _loadUserData();
  }

  // Add method to load user data from storage
  void _loadUserData() {
    try {
      final userData = _storage.read('user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        user.value = UserModel.fromJson(userMap);
        print('User data loaded from storage: ${user.value?.name}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
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
            // Store user data in storage
            _storage.write('user_data', json.encode(responseBody['user']));
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
        print('Response body: ${response.body}');
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
    _storage.remove('user_data');
    user.value = null;
    Get.offAllNamed('/login');
  }
}
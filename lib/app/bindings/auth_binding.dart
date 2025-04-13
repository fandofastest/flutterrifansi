import 'package:flutterrifansi/presentation/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => AuthController());
  }
}
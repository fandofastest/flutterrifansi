import 'package:flutterrifansi/core/services/api_service.dart';
import 'package:flutterrifansi/presentation/auth/controllers/auth_controller.dart';
import 'package:flutterrifansi/presentation/task/views/input_task_view.dart';
import 'package:flutterrifansi/presentation/sales/views/input_sales_view.dart';  // Add this import
import 'package:get/get.dart';
import '../presentation/auth/views/login_view.dart';
import '../presentation/home/views/home_view.dart';
import '../app/bindings/auth_binding.dart'; // Add this import
import '../presentation/splash/views/splash_view.dart';

class AppPages {
  static const INITIAL = '/splash';
  
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: '/input-task',
      page: () =>  InputTaskView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: '/input-sales',
      page: () => InputSalesView(), // Remove 'const' to allow arguments
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
  ];
}
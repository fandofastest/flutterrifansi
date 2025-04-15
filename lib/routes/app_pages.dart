import 'package:flutterrifansi/core/services/api_service.dart';
import 'package:flutterrifansi/presentation/auth/controllers/auth_controller.dart';
import 'package:flutterrifansi/presentation/task/views/input_task_view.dart';
import 'package:flutterrifansi/presentation/sales/views/input_sales_view.dart';
import 'package:get/get.dart';
import '../presentation/auth/views/login_view.dart';
import '../presentation/home/views/home_view.dart';
import '../app/bindings/auth_binding.dart';
import '../presentation/splash/views/splash_view.dart';

class AppPages {
  static const INITIAL = '/splash';
  
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        // Initialize AuthController at splash screen
        Get.put(AuthController(), permanent: true);
      }),
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeView(),
      // No need to initialize AuthController again
    ),
    GetPage(
      name: '/input-task',
      page: () => InputTaskView(),
      // No need to initialize AuthController again
    ),
    GetPage(
      name: '/input-sales',
      page: () => InputSalesView(),
      // No need to initialize AuthController again
    ),
  ];
}
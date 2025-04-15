import 'package:flutter/material.dart';
import 'package:flutterrifansi/presentation/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/task_list_item.dart';
import '../widgets/progress_list_item.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key}) {
    Get.put(HomeController());
  }

  // Helper method to format role string
  String _formatRole(String role) {
    // Convert snake_case or camelCase to Title Case with spaces
    String formatted = role.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    
    // Replace underscores with spaces
    formatted = formatted.replaceAll('_', ' ');
    
    // Capitalize each word
    formatted = formatted.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
    
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFBF4D00),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person_2_outlined, color: Color(0xFFBF4D00)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() {
                          // Get user data reactively
                          final user = authController.user.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome ${user?.name ?? 'User'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.role != null 
                                    ? _formatRole(user!.role) 
                                    : 'Loading...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (homeController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: homeController.spkList.length,
                    itemBuilder: (context, index) => TaskListItem(
                      spk: homeController.spkList[index],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  if (homeController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: homeController.progressList.length,
                    itemBuilder: (context, index) => ProgressListItem(
                      progress: homeController.progressList[index],
                    ),
                  );
                }),
              ],
            ),
          ),
              ],
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/input-task'),
        backgroundColor: const Color(0xFFBF4D00),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
   
    );
  }
}
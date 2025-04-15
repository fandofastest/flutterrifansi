import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final RxList<Map<String, dynamic>> progressList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> spkList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSpkProgress();
    fetchSpks(); // Add this lin
  }

  Future<void> loadSpkProgress() async {
    try {
      isLoading.value = true;
      final progress = await _apiService.getSpkProgress();
      progressList.value = progress;
    } catch (e) {
      print('Error loading SPK progress: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchSpks() async {
    try {
      isLoading(true);
      final response = await _apiService.getSpks();
      spkList.value = response;
     
    } catch (e) {
      print('Error fetching SPKs: $e');
    } finally {
      isLoading(false);
    }
  }
}
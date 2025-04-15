import 'dart:async';

import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:flutterrifansi/core/constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:convert';

class PhotoLocationStep extends StatelessWidget {
  final DateTime dcuTime;
  final DateTime startTime;
  final DateTime endTime;
  final String? dcuImagePath;
  final String? startImagePath;
  final String? endImagePath;
  final Function(DateTime) onDcuTimeChanged;
  final Function(DateTime) onStartTimeChanged;
  final Function(DateTime) onEndTimeChanged;
  final Function(String) onDcuImageChanged;
  final Function(String) onStartImageChanged;
  final Function(String) onEndImageChanged;

  const PhotoLocationStep({
    Key? key,
    required this.dcuTime,
    required this.startTime,
    required this.endTime,
    this.dcuImagePath,
    this.startImagePath,
    this.endImagePath,
    required this.onDcuTimeChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onDcuImageChanged,
    required this.onStartImageChanged,
    required this.onEndImageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
  
            
            // DCU Time and Photo
            _buildTimeAndPhotoSection(
              context,
              'Jam DCU',
              dcuTime,
              dcuImagePath,
              onDcuTimeChanged,
              onDcuImageChanged,
            ),
            const SizedBox(height: 24),
            
            // Start Time and Photo
            _buildTimeAndPhotoSection(
              context,
              'Jam Mulai Kerja',
              startTime,
              startImagePath,
              onStartTimeChanged,
              onStartImageChanged,
            ),
            const SizedBox(height: 24),
            
            // End Time and Photo
            _buildTimeAndPhotoSection(
              context,
              'Jam Selesai',
              endTime,
              endImagePath,
              onEndTimeChanged,
              onEndImageChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAndPhotoSection(
    BuildContext context,
    String title,
    DateTime time,
    String? imagePath,
    Function(DateTime) onTimeChanged,
    Function(String) onImageChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Date and Time Picker
        InkWell(
          onTap: () => _selectDateTime(context, time, onTimeChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(time),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Photo Picker
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(onImageChanged),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF4D00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Display selected image
        if (imagePath != null && imagePath.isNotEmpty)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath.startsWith('/uploads') || imagePath.startsWith('http')
                ? Image.network(
                    imagePath.startsWith('/uploads') 
                      ? ApiConstants.mainurl+'${imagePath}'
                      : imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateChanged,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      
      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateChanged(newDateTime);
      }
    }
  }

  Future<void> _pickImage(Function(String) onImageChanged) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Log file details for debugging
        print('Selected image path: ${image.path}');
        print('File exists: ${File(image.path).existsSync()}');
        print('File size: ${await File(image.path).length()} bytes');
        
        // Try a different approach with http package
        var uri = Uri.parse(ApiConstants.uploadEndpoint);
        
        // Use dio for better multipart handling
        final dio = dios.Dio();
        
        // Create FormData
        final formData = dios.FormData.fromMap({
          'image': await dios.MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        });
        
        print('Uploading with Dio to: $uri');
        
        // Make the request with Dio
        final dioResponse = await dio.post(
          uri.toString(),
          data: formData,
          options: dios.Options(
            headers: {
              'Accept': 'application/json',
            },
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
        
        // Log response for debugging
        print('Dio Response status: ${dioResponse.statusCode}');
        print('Dio Response data: ${dioResponse.data}');
        
        // Close loading dialog
        Get.back();
        
        // Check if upload was successful
        if (dioResponse.statusCode == 200) {
          final responseData = dioResponse.data;
          if (responseData != null && 
              responseData['success'] == true && 
              responseData['imageUrl'] != null) {
            // Extract imageUrl from response
            final String imageUrl = responseData['imageUrl'];
            print('Image uploaded successfully. URL: $imageUrl');
            
            // Pass the imageUrl to the callback
            onImageChanged(imageUrl);
            Get.snackbar('Success', 'Gambar berhasil diupload');
          } else {
            print('Upload failed: Response data format incorrect');
            Get.snackbar('Error', 'Format respons tidak valid');
          }
        } else {
          print('Upload failed: Status code ${dioResponse.statusCode}');
          Get.snackbar('Error', 'Gagal mengupload gambar: ${dioResponse.statusCode}');
        }
      } else {
        print('No image selected');
        Get.back(); // Close dialog if no image selected
      }
    } catch (e, stackTrace) {
      print('Exception during upload: $e');
      print('Stack trace: $stackTrace');
      Get.back(); // Close dialog on error
      
      // More specific error messages based on exception type
      if (e is TimeoutException) {
        Get.snackbar('Error', 'Koneksi timeout. Periksa jaringan Anda.');
      } else if (e is SocketException) {
        Get.snackbar('Error', 'Tidak dapat terhubung ke server. Periksa jaringan Anda.');
      } else if (e is FormatException) {
        Get.snackbar('Error', 'Format respons tidak valid.');
      } else if (e is dios.DioException) {
        if (e.type == dios.DioExceptionType.connectionTimeout || 
            e.type == dios.DioExceptionType.sendTimeout || 
            e.type == dios.DioExceptionType.receiveTimeout) {
          Get.snackbar('Error', 'Koneksi timeout. Periksa jaringan Anda.');
        } else if (e.type == dios.DioExceptionType.connectionError) {
          Get.snackbar('Error', 'Tidak dapat terhubung ke server. Periksa jaringan Anda.');
        } else {
          Get.snackbar('Error', 'Gagal mengupload: ${e.message}');
        }
      } else {
        Get.snackbar('Error', 'Error: $e');
      }
    }
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutterrifansi/core/utils/format_helpers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:marquee/marquee.dart';
import '../../../core/services/api_service.dart';
import 'package:flutterrifansi/core/models/sales_item.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterrifansi/core/models/spk_details.dart'; // Import the SpkDetails model
import 'dart:math'; // Import dart:math for the ceil method

class InputSalesView extends StatefulWidget {
  const InputSalesView({super.key});

  @override
  State<InputSalesView> createState() => _InputSalesViewState();
}

class _InputSalesViewState extends State<InputSalesView> {
  late String spkId;
  late ApiService _apiService;
  int activeStep = 0;
  bool isLoading = true;
  SpkDetails? _spkDetails; // Use SpkDetails model
  List<Map<String, dynamic>> _selectedItems = [];
  final _storage = GetStorage();

  // Add a variable to store task data
  Map<String, dynamic>? _taskFormData;

  @override
  void initState() {
    super.initState();
    _apiService = Get.find<ApiService>();
    spkId = Get.arguments['spkId'];
    _loadTaskFormData(); // Load task data first
    _initializeData();
  }

  // Add this method to load task form data
  void _loadTaskFormData() {
    try {
      final taskData = _storage.read('task_form_data');
      if (taskData != null) {
        setState(() {
          _taskFormData = taskData;
        });
      }
    } catch (e) {
      print('Error loading task data: $e');
    }
  }

  Future<void> _initializeData() async {
    try {
      EasyLoading.show(status: 'Loading...');
      final response = await _apiService.getSpkDetails(spkId);
      setState(() {
        _spkDetails = SpkDetails.fromJson(response); // Parse response into SpkDetails model
        _categories = _extractCategoriesFromSpk(_spkDetails!.items);
        print(_categories[0]); // Cetak kategori untuk debugging
        isLoading = false;
      });
    } catch (e) {
      // print('Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Extract categories from SPK items
  List<Map<String, dynamic>> _extractCategoriesFromSpk(List<SpkItem> items) {
    final Map<String, Map<String, dynamic>> categoryMap = {};

    for (var item in items) {
      final category = item.item.category;
      if (category != null && !categoryMap.containsKey(category.id)) {
        categoryMap[category.id] = {
          '_id': category.id,
          'name': category.name,
          'items': [],
        };
      }
      if (category != null) {
        categoryMap[category.id]!['items'].add({
          '_id': item.item.id,
          'description': item.item.description,
          'rate': item.unitRate.remoteAreas, // Ensure rate is extracted
          'targetQty': item.estQty.quantity.r, // Extract target quantity
        });
      }
    }

    return categoryMap.values.toList();
  }

  List<Map<String, dynamic>> _categories = []; // Add this line

  // Helper method to get categories from SPK details
  List<Map<String, dynamic>> get categories {
    return _categories; // Return the extracted categories
  }
  List<SalesItem> _itemList = [];
  bool _isLoadingItems = false;




  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Center(child: Text('No categories available'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedItems.isEmpty) {
        _loadSavedFormData();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFBF4D00),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Input Sales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: CupertinoStepper(
                physics: const NeverScrollableScrollPhysics(),
                onStepCancel: () {
                  if (activeStep > 0) {
                    setState(() => activeStep--);
                  } else {
                    Get.back();
                  }
                },
                onStepContinue: () {
                  if (activeStep < categories.length) {
                    setState(() {
                      activeStep++;
                      _saveFormData(); // Save data when moving to the next step
                    });
                  }
                },
                controlsBuilder: (context, details) => const SizedBox(),
                type: StepperType.vertical,
                currentStep: activeStep.clamp(0, categories.length), // Adjust for summary step
                onStepTapped: (index) {
                  if (index >= 0 && index <= categories.length) {
                    setState(() => activeStep = index);
                    // Show dialog when the last step (summary) is tapped
                    if (index == categories.length) {
                      _showSubmitDialog();
                    }
                  }
                },
                steps: List.generate(
                  categories.length + 1, // Add one for summary step
                  (index) => Step(
                    content: index < categories.length
                        ? _buildStepContent(index)
                        : _buildSummaryStep(), // Add summary step
                    title: index < categories.length
                        ? Text(
                            '${categories[index]['name'][0].toUpperCase()}${categories[index]['name'].substring(1).toLowerCase()}',
                          )
                        : const Text('Summary'), // Title for summary step
                    subtitle: const Text('Input Sales'),
                    isActive: index == activeStep,
                    state: index < activeStep ? StepState.complete : StepState.indexed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (activeStep < categories.length) {
            setState(() {
              activeStep++;
              _saveFormData(); // Save data when moving to the next step
            });
          } else {
            // Show dialog when reaching the last step via FAB
            _showSubmitDialog();
          }
        },
        backgroundColor: const Color(0xFFBF4D00),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }

  // Add summary step method
Widget _buildSummaryStep() {
    double totalAmount = _spkDetails?.totalAmount ?? 0;
    double totalSpentToday = _selectedItems.fold(0, (sum, item) {
      return sum + ((item['quantity'] ?? 0) * (item['item']['rate'] ?? 0));
    });

    // Calculate total target quantity for all items
    double totalTargetQty = _selectedItems.fold(0, (sum, item) {
      return sum + (item['item']['targetQty'] ?? 0);
    });

    // Calculate percentage of today's work compared to the overall target
    double percentageOfWorkDoneToday = (totalSpentToday / (totalAmount/_spkDetails!.projectDuration)) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ..._selectedItems.map((item) {
            double itemTotalPriceToday = (item['quantity'] ?? 0) * (item['item']['rate'] ?? 0);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Marquee(
                        text: 'Item: ${item['item']['description']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 20.0,
                        velocity: 30.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unit Price: Rp ${FormatHelpers.formatCurrency(item['item']['rate'] ?? 0)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Qty Today: ${item['quantity'] ?? 0}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Price Today: Rp ${FormatHelpers.formatCurrency(itemTotalPriceToday)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price Today: Rp ${FormatHelpers.formatCurrency(totalSpentToday)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Percentage Today: ${percentageOfWorkDoneToday.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Modify _saveFormData to ensure SpkDetails is converted to JSON
  Future<void> _saveFormData() async {
    try {
      final formData = {
        'spkId': spkId,
        'spkDetails': _spkDetails?.toJson(), // Convert SpkDetails to JSON
        'salesItems': _selectedItems.map((item) => {
          'itemId': item['item']['_id'],
          'description': item['item']['description'],
          'quantity': item['quantity'],
          'rate': item['item']['rate'],
        }).toList(),
      };

      await _storage.write('sales_form_data_${spkId}', formData);
      print('Data saved successfully'); // Debugging log
    } catch (e) {
      print('Error saving data: $e'); // Error handling
    }
  }

  // Add this method to fetch items by category
  // Add this map to cache loaded items by category
  final Map<String, List<SalesItem>> _cachedItems = {};
  
  // Modify _fetchItemsByCategory to use cache
  Future<void> _fetchItemsByCategory(String categoryId) async {
    if (_cachedItems.containsKey(categoryId)) return;
    
    setState(() => _isLoadingItems = true);
    try {
      final items = await _apiService.getItemsByCategory(categoryId);
      _cachedItems[categoryId] = items;
      setState(() => _itemList = items);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load items');
    } finally {
      setState(() => _isLoadingItems = false);
    }
  }

  // Modify _buildStepContent to not use FutureBuilder
  // Add a debounce duration
  final Duration _debounceDuration = Duration(milliseconds: 300);
  Timer? _debounce;

  Widget _buildStepContent(int stepIndex) {
    final category = categories[stepIndex];
    final items = List<Map<String, dynamic>>.from(category['items'] ?? []);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input for ${category['name']}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            final selectedItem = _selectedItems.firstWhere(
              (selected) => selected['item']['_id'] == item['_id'],
              orElse: () => {'item': item, 'quantity': 0},
            );

            // Calculate daily target and round up
            final dailyTarget = (item['targetQty'] / _spkDetails!.projectDuration).ceil();

            // Calculate total price for the item
            final totalPrice = selectedItem['quantity'] * item['rate'];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['description'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target Qty: ${item['targetQty']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Target: $dailyTarget', // Display rounded daily target
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Unit',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: selectedItem['quantity'].toString(),
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(_debounceDuration, () {
                          setState(() {
                            final index = _selectedItems.indexWhere(
                              (selected) => selected['item']['_id'] == item['_id']
                            );
                            if (index >= 0) {
                              _selectedItems[index]['quantity'] = int.tryParse(value) ?? 0;
                            } else {
                              _selectedItems.add({
                                'item': item,
                                'quantity': int.tryParse(value) ?? 0,
                              });
                            }
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harga: Rp ${FormatHelpers.formatCurrency(item['rate'] ?? 0)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Harga: Rp ${FormatHelpers.formatCurrency(totalPrice)}', // Display total price
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _loadSavedFormData() {
    final savedData = _storage.read('sales_form_data_${spkId}');
    if (savedData != null && _spkDetails != null) {
      setState(() {
        _selectedItems = List<Map<String, dynamic>>.from(
          savedData['salesItems'].map((item) {
            final savedItem = categories
                .expand((cat) => cat['items'])
                .firstWhere(
                  (i) => i['_id'] == item['itemId'],
                  orElse: () => null,
                );
            if (savedItem != null) {
              return {
                'item': savedItem,
                'quantity': item['quantity'],
                'rate': item['rate'], // Ensure rate is included
              };
            }
            return null;
          }).where((item) => item != null),
        );
      });
    }
  }

  // Add this method to show item selection dialog
  void _showItemSelectionDialog() {
    if (_isLoadingItems) {
      Get.snackbar('Info', 'Loading items...');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _itemList.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_itemList[index].description),
              subtitle: Text(
                'Harga: Rp ${FormatHelpers.formatCurrency(_itemList[index].rate)}',
              ),
              onTap: () {
                setState(() {
                  _selectedItems.add({
                    'item': _itemList[index],
                    'quantity': 1,
                  });
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog() {
    final formattedData = _formatDataForBackend();
    final totalProgress = _calculateTotalProgress();
    final totalTaskCost = _calculateTotalTaskCost();
    final profitLoss = totalProgress - totalTaskCost;
    final isProfitable = profitLoss >= 0;
    final totalAmount = _spkDetails?.totalAmount ?? 0;
    final progressPercentage = totalAmount > 0 ? (totalProgress / (totalAmount/_spkDetails!.projectDuration) * 100).toDouble() : 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Progress'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressHeader(),
              if (_taskFormData != null) ...[
                _buildTaskSummary(),
                _buildTotalCost(totalTaskCost),
              ],
              _buildProgressItems(),
              _buildFinancialSummary(totalProgress, totalTaskCost, profitLoss, isProfitable),
              _buildProgressBar(progressPercentage, isProfitable),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitProgress(formattedData);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF4D00),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('SPK ID: $spkId'),
        const SizedBox(height: 8),
        Text('Progress Date: ${DateTime.now().toString().substring(0, 10)}'),
      ],
    );
  }

  Widget _buildTaskSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const Text('Task Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildCostSection('Manpower', _taskFormData!['costUsed']['details']['manpower']),
        _buildCostSection('Equipment', _taskFormData!['costUsed']['details']['equipment']),
        _buildCostSection('Material', _taskFormData!['costUsed']['details']['material']),
        _buildCostSection('Security', _taskFormData!['costUsed']['details']['security']),
      ],
    );
  }

  Widget _buildCostSection(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ...items.map((item) => _buildCostItem(title, item)).toList(),
      ],
    );
  }

  Widget _buildCostItem(String type, Map<String, dynamic> item) {
      final details = item['details'];
      List<Widget> costDetails = [];
  
      switch (type) {
        case 'Manpower':
          final jumlahOrang = details['jumlahOrang'] ?? 0;
          final jamKerja = details['jamKerja'] ?? 0;
          final costPerHour = details['costPerHour'] ?? 0;
          final total = jumlahOrang * jamKerja * costPerHour;
          
          costDetails = [
            Text('$jumlahOrang orang × $jamKerja jam × Rp ${FormatHelpers.formatCurrency(costPerHour)}/jam'),
            Text('Total: Rp ${FormatHelpers.formatCurrency(total)}', 
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ];
          break;
  
        case 'Equipment':
          final jumlahUnit = details['jumlahUnit'] ?? 0;
          final jamKerja = details['jamKerja'] ?? 0;
          final costPerHour = details['costPerHour'] ?? 0;
          final fuelUsage = details['fuelUsage'] ?? 0;
          final fuelPrice = details['fuelPrice'] ?? 0;
          
          final rentalCost = jumlahUnit * jamKerja * costPerHour;
          final fuelCost = fuelUsage * fuelPrice;
          final total = rentalCost + fuelCost;
          
          costDetails = [
            Text('Sewa: $jumlahUnit unit × $jamKerja jam × Rp ${FormatHelpers.formatCurrency(costPerHour)}/jam'),
            Text('BBM: $fuelUsage liter × Rp ${FormatHelpers.formatCurrency(fuelPrice)}/liter'),
            Text('Total: Rp ${FormatHelpers.formatCurrency(total)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ];
          break;
  
        case 'Material':
          final jumlahUnit = details['jumlahUnit'] ?? 0;
          final pricePerUnit = details['pricePerUnit'] ?? 0;
          final total = jumlahUnit * pricePerUnit;
          
          costDetails = [
            Text('$jumlahUnit unit × Rp ${FormatHelpers.formatCurrency(pricePerUnit)}/unit'),
            Text('Total: Rp ${FormatHelpers.formatCurrency(total)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ];
          break;
  
        case 'Security':
          final jumlahOrang = details['jumlahOrang'] ?? 0;
          final dailyCost = details['dailyCost'] ?? 0;
          final total = jumlahOrang * dailyCost;
          
          costDetails = [
            Text('$jumlahOrang orang × Rp ${FormatHelpers.formatCurrency(dailyCost)}/hari'),
            Text('Total: Rp ${FormatHelpers.formatCurrency(total)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ];
          break;
      }
  
      return Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: costDetails,
        ),
      );
    }

  Widget _buildTotalCost(double totalTaskCost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Total Task Cost: Rp ${FormatHelpers.formatCurrency(totalTaskCost)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildProgressItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Progress Items:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._selectedItems.map((item) {
          final quantity = item['quantity'] ?? 0;
          final rate = item['item']['rate'] ?? 0;
          final totalPrice = quantity * rate;
          final targetQty = item['item']['targetQty'] ?? 0;
          final dailyTarget = (targetQty / _spkDetails!.projectDuration).ceil();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item']['description'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Target Total: $targetQty unit'),
                  Text('Target Harian: $dailyTarget unit'),
                  const Divider(),
                  Text('Progress Hari Ini:'),
                  Text('$quantity unit × Rp ${FormatHelpers.formatCurrency(rate)}/unit'),
                  const SizedBox(height: 4),
                  Text(
                    'Total: Rp ${FormatHelpers.formatCurrency(totalPrice)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBF4D00),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFinancialSummary(double totalProgress, double totalTaskCost, double profitLoss, bool isProfitable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(thickness: 2),
        const SizedBox(height: 12),
        const Text('Financial Summary:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFinancialRow('Total Progress Revenue:', totalProgress),
        _buildFinancialRow('Total Task Cost:', totalTaskCost),
        const Divider(),
        _buildProfitLossRow(profitLoss, isProfitable),
        _buildProfitabilityBadge(isProfitable),
      ],
    );
  }

  Widget _buildFinancialRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Rp ${FormatHelpers.formatCurrency(amount)}'),
        ],
      ),
    );
  }

  Widget _buildProfitLossRow(double profitLoss, bool isProfitable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Profit/Loss:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          'Rp ${FormatHelpers.formatCurrency(profitLoss)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isProfitable ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildProfitabilityBadge(bool isProfitable) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isProfitable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isProfitable ? Colors.green : Colors.red),
        ),
        child: Text(
          isProfitable ? 'PROFITABLE' : 'LOSS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isProfitable ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progressPercentage, bool isProfitable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Project Progress: ${progressPercentage.toStringAsFixed(2)}%'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            isProfitable ? Colors.green : const Color(0xFFBF4D00),
          ),
          minHeight: 10,
        ),
      ],
    );
  }

  double _calculateTotalTaskCost() {
    double totalTaskCost = 0;
    if (_taskFormData != null && _taskFormData!['costUsed'] != null) {
      final details = _taskFormData!['costUsed']['details'];
      
      // Calculate manpower cost
      totalTaskCost += _calculateManpowerCost(details['manpower']);
      
      // Calculate equipment cost
      totalTaskCost += _calculateEquipmentCost(details['equipment']);
      
      // Calculate material cost
      totalTaskCost += _calculateMaterialCost(details['material']);
      
      // Calculate security cost
      totalTaskCost += _calculateSecurityCost(details['security']);
    }
    return totalTaskCost;
  }

  double _calculateManpowerCost(List<dynamic>? items) {
    if (items == null) return 0;
    return items.fold(0.0, (sum, item) {
      final details = item['details'];
      final jumlahOrang = details['jumlahOrang'] ?? 0;
      final jamKerja = details['jamKerja'] ?? 0;
      final costPerHour = details['costPerHour'] ?? 0;
      return sum + (jumlahOrang * jamKerja * costPerHour);
    });
  }

  double _calculateEquipmentCost(List<dynamic>? items) {
    if (items == null) return 0;
    return items.fold(0.0, (sum, item) {
      final details = item['details'];
      final jumlahUnit = details['jumlahUnit'] ?? 0;
      final jamKerja = details['jamKerja'] ?? 0;
      final costPerHour = details['costPerHour'] ?? 0;
      final fuelUsage = details['fuelUsage'] ?? 0;
      final fuelPrice = details['fuelPrice'] ?? 0;
      
      final rentalCost = jumlahUnit * jamKerja * costPerHour;
      final fuelCost = fuelUsage * fuelPrice;
      return sum + rentalCost + fuelCost;
    });
  }

  double _calculateMaterialCost(List<dynamic>? items) {
    if (items == null) return 0;
    return items.fold(0.0, (sum, item) {
      final details = item['details'];
      final jumlahUnit = details['jumlahUnit'] ?? 0;
      final pricePerUnit = details['pricePerUnit'] ?? 0;
      return sum + (jumlahUnit * pricePerUnit);
    });
  }

  double _calculateSecurityCost(List<dynamic>? items) {
    if (items == null) return 0;
    return items.fold(0.0, (sum, item) {
      final details = item['details'];
      final jumlahOrang = details['jumlahOrang'] ?? 0;
      final dailyCost = details['dailyCost'] ?? 0;
      return sum + (jumlahOrang * dailyCost);
    });
  }

  // Add this method to format data according to backend schema
  Map<String, dynamic> _formatDataForBackend() {
    // Create progress items from selected items
    final progressItems = _selectedItems.map((item) {
      return {
        'spkItemSnapshot': {
          'item': {
            '_id': item['item']['_id'],
            'description': item['item']['description'],
          },
          'unitRate': {
            'remoteAreas': item['item']['rate'],
          },
          'estQty': {
            'quantity': {
              'r': item['item']['targetQty'],
            },
          },
        },
        'workQty': {
          'quantity': {
            'r': item['quantity'],
          },
          'amount': item['quantity'] * item['item']['rate'],
        },
        'unitRate': {
          'remoteAreas': item['item']['rate'],
        },
      };
    }).toList();

    // Calculate total progress
    final totalProgressItem = _calculateTotalProgress();

    return {
      'spk': spkId,
      'progressItems': progressItems,
      'progressDate': DateTime.now().toIso8601String(),
      'timeDetails': {
        'startTime': DateTime.now().toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
      },
      'totalProgressItem': totalProgressItem,
      'grandTotal': totalProgressItem,
    };
  }

  // Add this method to calculate total progress
  double _calculateTotalProgress() {
    return _selectedItems.fold(0.0, (sum, item) {
      return sum + ((item['quantity'] ?? 0) * (item['item']['rate'] ?? 0));
    });
  }

  // Add this method to submit progress to backend
  Future<void> _submitProgress(Map<String, dynamic> data) async {
    try {
      EasyLoading.show(status: 'Submitting...');
      // await _apiService.submitSalesProgress(data);
      Get.snackbar('Success', 'Progress submitted successfully');
      Get.back(); // Return to previous screen after successful submission
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit progress: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }
}

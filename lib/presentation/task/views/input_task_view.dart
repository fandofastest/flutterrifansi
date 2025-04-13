import 'package:flutter/material.dart';
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterrifansi/core/models/item_cost.dart';
import 'package:flutterrifansi/presentation/task/views/steps/security_step.dart';
import '../../../core/services/api_service.dart';
import 'package:get/get.dart';
import '../../../core/utils/format_helpers.dart';
import 'steps/spk_step.dart';
import 'steps/equipment_step.dart';
import 'package:get_storage/get_storage.dart';
import 'steps/resources_step.dart';
import 'steps/material_step.dart';
import 'steps/summary_step.dart';

class InputTaskView extends StatefulWidget {
  InputTaskView({super.key});

  @override
  State<InputTaskView> createState() => _InputTaskViewState();
}

// At the top of _InputTaskViewState class, add all state variables
class _InputTaskViewState extends State<InputTaskView> {
  double _currentSolarPrice = 0.0;

  late ApiService _apiService;
  int activeStep = 0;
  bool _isLoading = true; // Add this line

  List<Map<String, dynamic>> _spkList = [];
  bool _isLoadingSpk = false;
  Map<String, dynamic>? _selectedSpkDetails;
  String? _selectedSpk;
  List<ItemCost> _manpowerList = [];
  List<Map<String, dynamic>> _selectedManpower = [];
  bool _isLoadingManpower = false;
  List<ItemCost> _equipmentList = [];
  List<Map<String, dynamic>> _selectedEquipment = [];
  bool _isLoadingEquipment = false;
  final _storage = GetStorage();
  List<ItemCost> _materialList = [];
  List<Map<String, dynamic>> _selectedMaterial = [];
  bool _isLoadingMaterial = false;
  List<ItemCost> _securityList = [];
  List<Map<String, dynamic>> _selectedSecurity = [];
  bool _isLoadingSecurity = false;
  // Update initState
  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: 'loading...');

    _apiService = Get.put(ApiService());
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true); // Add this line
    try {
      await Future.wait([
        _fetchSpkData(),
        _fetchManpowerData(),
        _fetchEquipmentData(),
        _fetchMaterialData(),
        _fetchSecurityData(),
        _fetchCurrentSolarPrice(),
      ]);
      _loadSavedFormData();
    } finally {
      EasyLoading.dismiss();

      setState(() => _isLoading = false); // Add this line
    }
  }

  Future<void> _fetchSecurityData() async {
    setState(() => _isLoadingSecurity = true);
    try {
      final security = await _apiService.getItemCostsByCategory('security');
      setState(() => _securityList = security);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoadingSecurity = false);
    }
  }

  // Add new fetch method
  Future<void> _fetchMaterialData() async {
    setState(() => _isLoadingMaterial = true);
    try {
      final material = await _apiService.getItemCostsByCategory('material');
      setState(() => _materialList = material);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoadingMaterial = false);
    }
  }

  // Update _buildStep5
  Widget _buildStep5() => MaterialStep(
    selectedMaterial: _selectedMaterial,
    onAddMaterial: _showMaterialSelectionDialog,
    onRemoveMaterial: (item) {
      setState(() => _selectedMaterial.remove(item));
      _saveFormData();
    },
    onUpdateMaterial: (item, field, value) {
      setState(() {
        item[field] = int.tryParse(value) ?? 0;
      });
      _saveFormData();
    },
  );

  // Add material selection dialog
  void _showMaterialSelectionDialog() {
    if (_isLoadingMaterial) {
      Get.snackbar('Info', 'Loading material data...');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Material'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _materialList.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(_materialList[index].nama),
                      subtitle: Text(
                        'Cost/Unit: Rp ${FormatHelpers.formatCurrency(_materialList[index].costPerHour)}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMaterial.add({
                            'material': _materialList[index],
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

  // Update _saveFormData to include material
  void _saveFormData() {
    final formData = {
      'spk': _selectedSpkDetails?['_id'],
      'spkDetails': _selectedSpkDetails,
      'costUsed': {
        'details': {
          'manpower': _selectedManpower.map((item) => {
            'itemCost': item['manpower'].id,
            'details': {
              'jumlahOrang': item['quantity'],
              'jamKerja': item['hours'],
              'costPerHour': item['manpower'].costPerHour,
            },
          }).toList(),
          'equipment': _selectedEquipment.map((item) => {
            'itemCost': item['equipment'].id,
            'details': {
              'jumlahUnit': item['quantity'],
              'jamKerja': item['hours'],
              'costPerHour': item['equipment'].costPerHour,
              'fuelUsage': item['fuelUsage'] ?? 0,
              'fuelPrice': _currentSolarPrice,
            },
          }).toList(),
          'material': _selectedMaterial.map((item) => {
            'itemCost': item['material'].id,
            'details': {
              'jumlahUnit': item['quantity'],
              'pricePerUnit': item['material'].materialDetails?.pricePerUnit ?? 0,
            },
          }).toList(),
          'security': _selectedSecurity.map((item) => {
            'itemCost': item['security'].id,
            'details': {
              'jumlahOrang': item['quantity'],
              'dailyCost': item['security'].securityDetails?.dailyCost ?? 0,
            },
          }).toList(),
        },
      },
    };

    _storage.write('task_form_data', formData);
  }

  void _loadSavedFormData() {
    final savedData = _storage.read('task_form_data');
    if (savedData != null) {
      // Load SPK details if exists
      if (savedData['spkDetails'] != null) {
        setState(() {
          _selectedSpkDetails = savedData['spkDetails'];
          _selectedSpk = savedData['spkDetails']['spkNo'];
        });
      }

      if (savedData['costUsed']?['details']?['manpower'] != null &&
          _manpowerList.isNotEmpty) {
        setState(() {
          _selectedManpower = List<Map<String, dynamic>>.from(
            savedData['costUsed']['details']['manpower'].map((item) {
              final manpower = _manpowerList.firstWhere(
                (m) => m.id == item['itemCost'],
                orElse:
                    () => ItemCost(
                      id: '',
                      nama: '',
                      costPerMonth: 0,
                      costPerHour: 0,
                      kategori: 'manpower',
                    ),
              );
              return {
                'manpower': manpower,
                'quantity': item['details']['jumlahOrang'],
                'hours': item['details']['jamKerja'],
              };
            }),
          );
        });
      }

      if (savedData['costUsed']?['details']?['equipment'] != null) {
        setState(() {
          _selectedEquipment = List<Map<String, dynamic>>.from(
            savedData['costUsed']['details']['equipment'].map(
              (item) => {
                'equipment': _equipmentList.firstWhere(
                  (e) => e.id == item['itemCost'],
                  orElse:
                      () => ItemCost(
                        id: '',
                        nama: '',
                        costPerMonth: 0,
                        costPerHour: 0,
                        kategori: 'equipment',
                      ),
                ),
                'quantity': item['details']['jumlahUnit'],
                'hours': item['details']['jamKerja'],
                'fuelUsage': item['details']['fuelUsage'] ?? 0, // Add this line
              },
            ),
          );
        });
      }

      // Load SPK data if exists
      if (savedData['spk'] != null) {
        final savedSpk = _spkList.firstWhere(
          (spk) => spk['_id'] == savedData['spk'],
          orElse: () => <String, dynamic>{}, // Return empty map instead of null
        );
        if (savedSpk != null) {
          setState(() {
            _selectedSpk = savedSpk['spkNo'];
            _selectedSpkDetails = savedSpk;
          });
        }
      }

      // Load material data
      if (savedData['costUsed']?['details']?['material'] != null &&
          _materialList.isNotEmpty) {
        setState(() {
          _selectedMaterial = List<Map<String, dynamic>>.from(
            savedData['costUsed']['details']['material'].map((item) {
              final material = _materialList.firstWhere(
                (m) => m.id == item['itemCost'],
                orElse:
                    () => ItemCost(
                      id: '',
                      nama: '',
                      costPerMonth: 0,
                      costPerHour: 0,
                      kategori: 'material',
                    ),
              );
              return {
                'material': material,
                'quantity': item['details']['jumlahUnit'],
              };
            }),
          );
        });
      }

      // Load security data
      if (savedData['costUsed']?['details']?['security'] != null &&
          _securityList.isNotEmpty) {
        setState(() {
          _selectedSecurity = List<Map<String, dynamic>>.from(
            savedData['costUsed']['details']['security'].map((item) {
              final security = _securityList.firstWhere(
                (s) => s.id == item['itemCost'],
                orElse:
                    () => ItemCost(
                      id: '',
                      nama: '',
                      costPerMonth: 0,
                      costPerHour: 0,
                      kategori: 'security',
                    ),
              );
              return {
                'security': security,
                'quantity': item['details']['jumlahOrang'],
              };
            }),
          );
        });
      }
    }
  }

  // Add manpower fetch method
  Future<void> _fetchManpowerData() async {
    setState(() => _isLoadingManpower = true);
    try {
      final manpower = await _apiService.getItemCostsByCategory('manpower');
      setState(() => _manpowerList = manpower);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoadingManpower = false);
    }
  }

  // Add import at the top

  // Update _buildStep4
  Widget _buildStep4() => ResourcesStep(
    selectedEquipment: _selectedEquipment,
    onUpdateEquipment: (item, field, value) {
      setState(() {
        item[field] = double.tryParse(value) ?? 0;
      });
      _saveFormData();
    },
    currentSolarPrice: _currentSolarPrice,  // Add this line
  );

  // Add this method with other fetch methods
  Future<void> _fetchEquipmentData() async {
    setState(() => _isLoadingEquipment = true);
    try {
      final equipment = await _apiService.getItemCostsByCategory('equipment');
      setState(() => _equipmentList = equipment);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoadingEquipment = false);
    }
  }

  // Update _buildStep2
  Widget _buildStep2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () => _showManpowerSelectionDialog(),
        child: const Text('Tambah Manpower'),
      ),
      const SizedBox(height: 20),
      ..._selectedManpower
          .map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['manpower'].nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedManpower.remove(item);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Orang',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: item['quantity'].toString(),
                            onChanged: (value) {
                              setState(() {
                                item['quantity'] = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Jam',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: item['hours'].toString(),
                            onChanged: (value) {
                              setState(() {
                                item['hours'] = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cost per Hour: Rp ${FormatHelpers.formatCurrency(item['manpower'].costPerHour)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    ],
  );

  // Add manpower selection dialog
  void _showManpowerSelectionDialog() {
    if (_isLoadingManpower) {
      Get.snackbar('Info', 'Loading manpower data...');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Manpower'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _manpowerList.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(_manpowerList[index].nama),
                      subtitle: Text(
                        'Cost/Hour: Rp ${FormatHelpers.formatCurrency(_manpowerList[index].costPerHour)}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedManpower.add({
                            'manpower': _manpowerList[index],
                            'quantity': 1,
                            'hours': 8,
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

  final List<String> stepSubTitles = [
    'Pilih SPK',
    'Man Power',
    'Equipment',
    'Resources',
    'Material',
    'Security',
    'Summary',
    'Next',
  ];
  final List<String> stepTitles = [
    'Input Cost',
    'Input Cost',
    'Input Cost',
    'Input Cost',
    'Input Cost',
    'Input Cost',
    'Input Cost',
    'Next',
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Input Cost Task',
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
                  if (activeStep < stepTitles.length - 1) {
                    _saveFormData();
                    setState(() => activeStep++);
                  } else {
                    Get.toNamed(
                      '/input-sales',
                      arguments: {'spkId': _selectedSpkDetails?['_id']},
                    );
                  }
                },
                controlsBuilder: (context, details) {
                  return const SizedBox();
                },
                type: StepperType.vertical,
                currentStep: activeStep,
                onStepTapped: (index) {
                  if (index >= 0 && index < stepTitles.length) {
                    setState(() => activeStep = index);
                  }
                },
                steps: List.generate(
                  stepTitles.length,
                  (index) => Step(
                    content: _buildStepContent(),
                    title: Text(stepSubTitles[index]),
                    subtitle: Text(stepTitles[index]),
                    isActive: index == activeStep,
                    state:
                        index < activeStep
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (activeStep < stepTitles.length - 1) {
            _saveFormData();
            setState(() => activeStep++);
          } else {
            Get.toNamed(
              '/input-sales',
              arguments: {'spkId': _selectedSpkDetails?['_id']},
            );
          }
        },
        backgroundColor: const Color(0xFFBF4D00),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (activeStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      case 5:
        return _buildStep6();
      case 6:
        return _buildStep7();
      case 7:
        return _buildStep8();
      default:
        return Container();
    }
  }

  // Replace the _buildStep1 method with this:
  Widget _buildStep1() => SpkStep(
    selectedSpkDetails: _selectedSpkDetails,
    selectedSpk: _selectedSpk,
    onSelectSpk: _showSpkSelectionDialog,
  );
  Widget _buildStep3() => EquipmentStep(
    selectedEquipment: _selectedEquipment,
    onAddEquipment: _showEquipmentSelectionDialog,
    onRemoveEquipment: (item) {
      setState(() => _selectedEquipment.remove(item));
    },
    onUpdateEquipment: (item, field, value) {
      setState(() {
        item[field] = double.tryParse(value) ?? 0;
      });
    },
  );

  void _showEquipmentSelectionDialog() {
    if (_isLoadingEquipment) {
      Get.snackbar('Info', 'Loading equipment data...');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Equipment'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _equipmentList.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(_equipmentList[index].nama),
                      subtitle: Text(
                        'Cost/Hour: Rp ${FormatHelpers.formatCurrency(_equipmentList[index].costPerHour)}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedEquipment.add({
                            'equipment': _equipmentList[index],
                            'quantity': 1,
                            'hours': 8,
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

  Widget _buildStep6() => SecurityStep(
    selectedSecurity: _selectedSecurity,
    onAddSecurity: _showSecuritySelectionDialog,
    onRemoveSecurity: (item) {
      setState(() => _selectedSecurity.remove(item));
      _saveFormData();
    },
    onUpdateSecurity: (item, field, value) {
      setState(() {
        item[field] = int.tryParse(value) ?? 0;
      });
      _saveFormData();
    },
  );
  Widget _buildStep7() => SummaryStep(
    selectedSpkDetails: _selectedSpkDetails,
    selectedManpower: _selectedManpower,
    selectedEquipment: _selectedEquipment,
    selectedMaterial: _selectedMaterial,
    selectedSecurity: _selectedSecurity,
    currentSolarPrice: _currentSolarPrice,
  );
  Widget _buildStep8() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [const Text('Click next to input sales')],
    ),
  );

  Future<void> _fetchSpkData() async {
    setState(() => _isLoadingSpk = true);
    try {
      final spks = await _apiService.getSpks();
      setState(() => _spkList = spks);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoadingSpk = false);
    }
  }

  void _showSpkSelectionDialog() async {
    if (_isLoadingSpk) {
      Get.snackbar('Info', 'Loading SPK data...');
      return;
    }

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih SPK'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _spkList.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(_spkList[index]['spkNo']),
                      onTap: () => Navigator.pop(context, _spkList[index]),
                    ),
              ),
            ),
          ),
    );

    if (selected != null) {
      setState(() {
        _selectedSpk = selected['spkNo'];
        _selectedSpkDetails = selected;
      });
    }
  }

  void _showSecuritySelectionDialog() {
    if (_isLoadingSecurity) {
      Get.snackbar('Info', 'Loading security data...');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pilih Security'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _securityList.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(_securityList[index].nama),
                      subtitle: Text(
                        'Daily Cost: Rp ${FormatHelpers.formatCurrency(_securityList[index].securityDetails?.dailyCost ?? 0)}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSecurity.add({
                            'security': _securityList[index],
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

  // Update _saveFormData to include security
  Future<void> _fetchCurrentSolarPrice() async {
    try {
      final solarPrice = await _apiService.getCurrentSolarPrice();
      print('Current solar price: $solarPrice');
      setState(() {
        _currentSolarPrice = solarPrice['price'];
      });
    } catch (e) {
      print('Error fetching solar price: $e');
      // Set default price if API fails
      _currentSolarPrice = 6500;
    }
  }
}

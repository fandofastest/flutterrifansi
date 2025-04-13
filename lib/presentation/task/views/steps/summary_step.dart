import 'package:flutter/material.dart';
import '../../../../core/models/item_cost.dart';
import '../../../../core/utils/format_helpers.dart';

class SummaryStep extends StatelessWidget {
  final Map<String, dynamic>? selectedSpkDetails;
  final List<Map<String, dynamic>> selectedManpower;
  final List<Map<String, dynamic>> selectedEquipment;
  final List<Map<String, dynamic>> selectedMaterial;
  final List<Map<String, dynamic>> selectedSecurity;
  final double currentSolarPrice;

  const SummaryStep({
    Key? key,
    this.selectedSpkDetails,
    required this.selectedManpower,
    required this.selectedEquipment,
    required this.selectedMaterial,
    required this.selectedSecurity,
    required this.currentSolarPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalManpowerCost = selectedManpower.fold(0, (sum, item) =>
        sum + (item['manpower'].costPerHour * item['quantity'] * item['hours']));

    double totalEquipmentCost = selectedEquipment.fold(0, (sum, item) {
      double equipmentRentalCost = item['equipment'].costPerHour * item['quantity'] * item['hours'];
      double fuelCost = (item['fuelUsage'] ?? 0) * currentSolarPrice;
      return sum + equipmentRentalCost + fuelCost;
    });

    double totalMaterialCost = selectedMaterial.fold(0, (sum, item) =>
        sum + (item['material'].materialDetails?.pricePerUnit ?? 0) * item['quantity']);

    double totalSecurityCost = selectedSecurity.fold(0, (sum, item) =>
        sum + (item['security'].securityDetails?.dailyCost ?? 0) * item['quantity']);

    double grandTotal = totalManpowerCost + totalEquipmentCost + totalMaterialCost + totalSecurityCost;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SPK: ${selectedSpkDetails?['spkNo'] ?? '-'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          _buildCostSection('Manpower Cost', selectedManpower, (item) =>
              '${item['manpower'].nama} (${item['quantity']} orang × ${item['hours']} jam × Rp ${FormatHelpers.formatCurrency(item['manpower'].costPerHour)})',
              totalManpowerCost),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Equipment Cost', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...selectedEquipment.map((item) {
                double rentalCost = item['equipment'].costPerHour * item['quantity'] * item['hours'];
                double fuelUsage = item['fuelUsage'] ?? 0;
                double fuelCost = fuelUsage * currentSolarPrice;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['equipment'].nama} (${item['quantity']} unit × ${item['hours']} jam × Rp ${FormatHelpers.formatCurrency(item['equipment'].costPerHour)})'),
                      Text('  Fuel: ${fuelUsage.toStringAsFixed(1)} L × Rp ${FormatHelpers.formatCurrency(currentSolarPrice)} = Rp ${FormatHelpers.formatCurrency(fuelCost)}'),
                      Text('  Total: Rp ${FormatHelpers.formatCurrency(rentalCost + fuelCost)}'),
                    ],
                  ),
                );
              }).toList(),
              ListTile(
                title: const Text('Subtotal'),
                trailing: Text('Rp ${FormatHelpers.formatCurrency(totalEquipmentCost)}'),
              ),
              const Divider(),
            ],
          ),

          _buildCostSection('Material Cost', selectedMaterial, (item) =>
              '${item['material'].nama} (${item['quantity']} ${item['material'].materialDetails?.materialUnit.name ?? "unit"} × Rp ${FormatHelpers.formatCurrency(item['material'].materialDetails?.pricePerUnit ?? 0)})',
              totalMaterialCost),

          _buildCostSection('Security Cost', selectedSecurity, (item) =>
              '${item['security'].nama} (${item['quantity']} orang × Rp ${FormatHelpers.formatCurrency(item['security'].securityDetails?.dailyCost ?? 0)})',
              totalSecurityCost),

          const Divider(thickness: 2),
          ListTile(
            title: const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              'Rp ${FormatHelpers.formatCurrency(grandTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection(String title, List<Map<String, dynamic>> items, 
      String Function(Map<String, dynamic>) detailBuilder, double totalCost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(detailBuilder(item)),
        )),
        ListTile(
          title: const Text('Subtotal'),
          trailing: Text('Rp ${FormatHelpers.formatCurrency(totalCost)}'),
        ),
        const Divider(),
      ],
    );
  }
}
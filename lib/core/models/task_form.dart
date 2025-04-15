import 'package:flutterrifansi/core/models/spk_details.dart';

class TaskForm {
  final String spk;
  final SpkDetails? spkDetails;
  final CostUsedDetails costUsed;

  TaskForm({
    required this.spk,
    this.spkDetails,
    required this.costUsed,
  });

  factory TaskForm.fromJson(Map<String, dynamic> json) {
    return TaskForm(
      spk: json['spk'] ?? '',
      spkDetails: json['spkDetails'] != null 
          ? SpkDetails.fromJson(json['spkDetails']) 
          : null,
      costUsed: CostUsedDetails.fromJson(json['costUsed']['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spk': spk,
      'spkDetails': spkDetails?.toJson(),
      'costUsed': {
        'details': costUsed.toJson(),
      },
    };
  }
}

class CostUsedDetails {
  final List<ManpowerCost> manpower;
  final List<EquipmentCost> equipment;
  final List<MaterialCost> material;
  final List<SecurityCost> security;

  CostUsedDetails({
    required this.manpower,
    required this.equipment,
    required this.material,
    required this.security,
  });

  factory CostUsedDetails.fromJson(Map<String, dynamic> json) {
    return CostUsedDetails(
      manpower: (json['manpower'] as List?)
          ?.map((e) => ManpowerCost.fromJson(e))
          .toList() ?? [],
      equipment: (json['equipment'] as List?)
          ?.map((e) => EquipmentCost.fromJson(e))
          .toList() ?? [],
      material: (json['material'] as List?)
          ?.map((e) => MaterialCost.fromJson(e))
          .toList() ?? [],
      security: (json['security'] as List?)
          ?.map((e) => SecurityCost.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manpower': manpower.map((e) => e.toJson()).toList(),
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'material': material.map((e) => e.toJson()).toList(),
      'security': security.map((e) => e.toJson()).toList(),
    };
  }
}

class ManpowerCost {
  final String itemCost;
  final ManpowerDetails details;

  ManpowerCost({
    required this.itemCost,
    required this.details,
  });

  factory ManpowerCost.fromJson(Map<String, dynamic> json) {
    return ManpowerCost(
      itemCost: json['itemCost'] ?? '',
      details: ManpowerDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCost': itemCost,
      'details': details.toJson(),
    };
  }
}

class ManpowerDetails {
  final int jumlahOrang;
  final int jamKerja;
  final double costPerHour;

  ManpowerDetails({
    required this.jumlahOrang,
    required this.jamKerja,
    required this.costPerHour,
  });

  factory ManpowerDetails.fromJson(Map<String, dynamic> json) {
    return ManpowerDetails(
      jumlahOrang: json['jumlahOrang'] ?? 0,
      jamKerja: json['jamKerja'] ?? 0,
      costPerHour: (json['costPerHour'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jumlahOrang': jumlahOrang,
      'jamKerja': jamKerja,
      'costPerHour': costPerHour,
    };
  }
}

class EquipmentCost {
  final String itemCost;
  final EquipmentDetails details;

  EquipmentCost({
    required this.itemCost,
    required this.details,
  });

  factory EquipmentCost.fromJson(Map<String, dynamic> json) {
    return EquipmentCost(
      itemCost: json['itemCost'] ?? '',
      details: EquipmentDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCost': itemCost,
      'details': details.toJson(),
    };
  }
}

class EquipmentDetails {
  final int jumlahUnit;
  final int jamKerja;
  final double costPerHour;
  final double fuelUsage;
  final double fuelPrice;

  EquipmentDetails({
    required this.jumlahUnit,
    required this.jamKerja,
    required this.costPerHour,
    required this.fuelUsage,
    required this.fuelPrice,
  });

  factory EquipmentDetails.fromJson(Map<String, dynamic> json) {
    return EquipmentDetails(
      jumlahUnit: json['jumlahUnit'] ?? 0,
      jamKerja: json['jamKerja'] ?? 0,
      costPerHour: (json['costPerHour'] ?? 0).toDouble(),
      fuelUsage: (json['fuelUsage'] ?? 0).toDouble(),
      fuelPrice: (json['fuelPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jumlahUnit': jumlahUnit,
      'jamKerja': jamKerja,
      'costPerHour': costPerHour,
      'fuelUsage': fuelUsage,
      'fuelPrice': fuelPrice,
    };
  }
}

class MaterialCost {
  final String itemCost;
  final MaterialDetails details;

  MaterialCost({
    required this.itemCost,
    required this.details,
  });

  factory MaterialCost.fromJson(Map<String, dynamic> json) {
    return MaterialCost(
      itemCost: json['itemCost'] ?? '',
      details: MaterialDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCost': itemCost,
      'details': details.toJson(),
    };
  }
}

class MaterialDetails {
  final int jumlahUnit;
  final double pricePerUnit;

  MaterialDetails({
    required this.jumlahUnit,
    required this.pricePerUnit,
  });

  factory MaterialDetails.fromJson(Map<String, dynamic> json) {
    return MaterialDetails(
      jumlahUnit: json['jumlahUnit'] ?? 0,
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jumlahUnit': jumlahUnit,
      'pricePerUnit': pricePerUnit,
    };
  }
}

class SecurityCost {
  final String itemCost;
  final SecurityDetails details;

  SecurityCost({
    required this.itemCost,
    required this.details,
  });

  factory SecurityCost.fromJson(Map<String, dynamic> json) {
    return SecurityCost(
      itemCost: json['itemCost'] ?? '',
      details: SecurityDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCost': itemCost,
      'details': details.toJson(),
    };
  }
}

class SecurityDetails {
  final int jumlahOrang;
  final double dailyCost;

  SecurityDetails({
    required this.jumlahOrang,
    required this.dailyCost,
  });

  factory SecurityDetails.fromJson(Map<String, dynamic> json) {
    return SecurityDetails(
      jumlahOrang: json['jumlahOrang'] ?? 0,
      dailyCost: (json['dailyCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jumlahOrang': jumlahOrang,
      'dailyCost': dailyCost,
    };
  }
}
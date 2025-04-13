class ItemCost {
  final String id;
  final String nama;
  final double costPerMonth;
  final double costPerHour;
  final String kategori;
  final ManpowerDetails? manpowerDetails;
  final MaterialDetails? materialDetails;
  final SecurityDetails? securityDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemCost({
    required this.id,
    required this.nama,
    required this.costPerMonth,
    required this.costPerHour,
    required this.kategori,
    this.manpowerDetails,
    this.materialDetails,
    this.securityDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemCost.fromJson(Map<String, dynamic> json) {
    return ItemCost(
      id: json['_id'],
      nama: json['nama'],
      costPerMonth: json['costPerMonth'].toDouble(),
      costPerHour: json['costPerHour'].toDouble(),
      kategori: json['kategori'],
      manpowerDetails: json['details'] != null && json['details']['manpowerDetails'] != null
          ? ManpowerDetails.fromJson(json['details']['manpowerDetails'])
          : null,
      materialDetails: json['details'] != null && json['details']['materialDetails'] != null
          ? MaterialDetails.fromJson(json['details']['materialDetails'])
          : null,
      securityDetails: json['details'] != null && json['details']['securityDetails'] != null
          ? SecurityDetails.fromJson(json['details']['securityDetails'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'costPerMonth': costPerMonth,
      'costPerHour': costPerHour,
      'kategori': kategori,
      'details': {
        'manpowerDetails': manpowerDetails?.toJson(),
        'materialDetails': materialDetails?.toJson(),
        'securityDetails': securityDetails?.toJson(),
      },
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

// Add SecurityDetails class
class SecurityDetails {
  final double dailyCost;

  SecurityDetails({
    required this.dailyCost,
  });

  factory SecurityDetails.fromJson(Map<String, dynamic> json) {
    return SecurityDetails(
      dailyCost: json['dailyCost'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCost': dailyCost,
    };
  }
}

// Add new MaterialDetails class
class MaterialDetails {
  final MaterialUnit materialUnit;
  final double pricePerUnit;

  MaterialDetails({
    required this.materialUnit,
    required this.pricePerUnit,
  });

  factory MaterialDetails.fromJson(Map<String, dynamic> json) {
    return MaterialDetails(
      materialUnit: MaterialUnit.fromJson(json['materialUnit']),
      pricePerUnit: json['pricePerUnit'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialUnit': materialUnit.toJson(),
      'pricePerUnit': pricePerUnit,
    };
  }
}

class MaterialUnit {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialUnit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialUnit.fromJson(Map<String, dynamic> json) {
    return MaterialUnit(
      id: json['_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ManpowerDetails {
  final List<Overtime> overtime;

  ManpowerDetails({
    required this.overtime,
  });

  factory ManpowerDetails.fromJson(Map<String, dynamic> json) {
    return ManpowerDetails(
      overtime: json['overtime'] != null
          ? List<Overtime>.from(json['overtime'].map((x) => Overtime.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overtime': overtime.map((x) => x.toJson()).toList(),
    };
  }
}

class Overtime {
  final String id;
  final double rate;
  final String description;

  Overtime({
    required this.id,
    required this.rate,
    required this.description,
  });

  factory Overtime.fromJson(Map<String, dynamic> json) {
    return Overtime(
      id: json['_id'],
      rate: json['rate'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rate': rate,
      'description': description,
    };
  }
}
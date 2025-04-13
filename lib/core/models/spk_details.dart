class SpkDetails {
  final String id;
  final String spkNo;
  final String spkTitle;
  final DateTime projectStartDate;
  final DateTime projectEndDate;
  final List<SpkItem> items;
  final String status;
  final double totalAmount;
  final String location;
  final double solarPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int projectDuration;

  SpkDetails({
    required this.id,
    required this.spkNo,
    required this.spkTitle,
    required this.projectStartDate,
    required this.projectEndDate,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.location,
    required this.solarPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.projectDuration,
  });

  factory SpkDetails.fromJson(Map<String, dynamic> json) {
    return SpkDetails(
      id: json['_id'],
      spkNo: json['spkNo'],
      spkTitle: json['spkTitle'],
      projectStartDate: DateTime.parse(json['projectStartDate']),
      projectEndDate: DateTime.parse(json['projectEndDate']),
      items: (json['items'] as List)
          .map((item) => SpkItem.fromJson(item))
          .toList(),
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
      location: json['location'],
      solarPrice: json['solarPrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      projectDuration: json['projectDuration'],
    );
  }

  // Implement the toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spkNo': spkNo,
      'spkTitle': spkTitle,
      'projectStartDate': projectStartDate.toIso8601String(),
      'projectEndDate': projectEndDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'location': location,
      'solarPrice': solarPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'projectDuration': projectDuration,
    };
  }
}

class SpkItem {
  final EstQty estQty;
  final UnitRate unitRate;
  final Item item;
  final String rateCode;

  SpkItem({
    required this.estQty,
    required this.unitRate,
    required this.item,
    required this.rateCode,
  });

  factory SpkItem.fromJson(Map<String, dynamic> json) {
    return SpkItem(
      estQty: EstQty.fromJson(json['estQty']),
      unitRate: UnitRate.fromJson(json['unitRate']),
      item: Item.fromJson(json['item']),
      rateCode: json['rateCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estQty': estQty.toJson(),
      'unitRate': unitRate.toJson(),
      'item': item.toJson(),
      'rateCode': rateCode,
    };
  }
}

class EstQty {
  final Quantity quantity;
  final double amount;

  EstQty({
    required this.quantity,
    required this.amount,
  });

  factory EstQty.fromJson(Map<String, dynamic> json) {
    return EstQty(
      quantity: Quantity.fromJson(json['quantity']),
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity.toJson(),
      'amount': amount,
    };
  }
}

class Quantity {
  final int nr;
  final int r;

  Quantity({
    required this.nr,
    required this.r,
  });

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      nr: json['nr'],
      r: json['r'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nr': nr,
      'r': r,
    };
  }
}

class UnitRate {
  final double nonRemoteAreas;
  final double remoteAreas;

  UnitRate({
    required this.nonRemoteAreas,
    required this.remoteAreas,
  });

  factory UnitRate.fromJson(Map<String, dynamic> json) {
    return UnitRate(
      nonRemoteAreas: json['nonRemoteAreas'].toDouble(),
      remoteAreas: json['remoteAreas'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonRemoteAreas': nonRemoteAreas,
      'remoteAreas': remoteAreas,
    };
  }
}

class Item {
  final String id;
  final String itemCode;
  final String description;
  final String unitMeasurement;
  final Category category;
  final SubCategory subCategory;
  final List<Rate> rates;

  Item({
    required this.id,
    required this.itemCode,
    required this.description,
    required this.unitMeasurement,
    required this.category,
    required this.subCategory,
    required this.rates,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      itemCode: json['itemCode'],
      description: json['description'],
      unitMeasurement: json['unitMeasurement'],
      category: Category.fromJson(json['category']),
      subCategory: SubCategory.fromJson(json['subCategory']),
      rates: (json['rates'] as List)
          .map((rate) => Rate.fromJson(rate))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemCode': itemCode,
      'description': description,
      'unitMeasurement': unitMeasurement,
      'category': category.toJson(),
      'subCategory': subCategory.toJson(),
      'rates': rates.map((rate) => rate.toJson()).toList(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class SubCategory {
  final String id;
  final String name;
  final String category;

  SubCategory({
    required this.id,
    required this.name,
    required this.category,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }
}

class Rate {
  final String rateCode;
  final double nonRemoteAreas;
  final double remoteAreas;
  final bool isActive;

  Rate({
    required this.rateCode,
    required this.nonRemoteAreas,
    required this.remoteAreas,
    required this.isActive,
  });

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      rateCode: json['rateCode'],
      nonRemoteAreas: json['nonRemoteAreas'].toDouble(),
      remoteAreas: json['remoteAreas'].toDouble(),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rateCode': rateCode,
      'nonRemoteAreas': nonRemoteAreas,
      'remoteAreas': remoteAreas,
      'isActive': isActive,
    };
  }
}
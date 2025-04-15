class SalesProgress {
  final String spk;
  final List<ProgressItem>? progressItems;  // Made optional
  final DateTime progressDate;
  final TimeDetails timeDetails;
  final Images images;
  final List<CostUsed>? costUsed;  // Made optional

  SalesProgress({
    required this.spk,
    this.progressItems,  // Optional parameter
    required this.progressDate,
    required this.timeDetails,
    required this.images,
    this.costUsed,  // Optional parameter
  });

  factory SalesProgress.fromJson(Map<String, dynamic> json) {
    String progressDateStr;
    if (json['progressDate'] is String) {
      progressDateStr = json['progressDate'];
    } else if (json['progressDate'] is Map) {
      progressDateStr = json['progressDate']['date'] ?? '';
    } else {
      progressDateStr = '';
    }

    return SalesProgress(
      spk: json['spk'] ?? '',
      progressItems: (json['progressItems'] as List?)
          ?.map((e) => ProgressItem.fromJson(e))
          .toList(),  // Removed default empty list
      progressDate: progressDateStr.isNotEmpty
          ? DateTime.parse(progressDateStr)
          : DateTime.now(),
      timeDetails: TimeDetails.fromJson(json['timeDetails']),
      images: Images.fromJson(json['images']),
      costUsed: (json['costUsed'] as List?)
          ?.map((e) => CostUsed.fromJson(e))
          .toList(),  // Removed default empty list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spk': spk,
      'progressItems': progressItems?.map((e) => e.toJson()).toList(),
      'progressDate': progressDate.toIso8601String(),
      'timeDetails': timeDetails.toJson(),
      'images': images.toJson(),
      'costUsed': costUsed?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgressItem {
  final SpkItemSnapshot spkItemSnapshot;
  final WorkQty workQty;
  final UnitRate unitRate;

  ProgressItem({
    required this.spkItemSnapshot,
    required this.workQty,
    required this.unitRate,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    print('Parsing ProgressItem: $json');
    return ProgressItem(
      spkItemSnapshot: SpkItemSnapshot.fromJson(json['spkItemSnapshot']),
      workQty: WorkQty.fromJson(json['workQty']),
      unitRate: UnitRate.fromJson(json['unitRate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spkItemSnapshot': spkItemSnapshot.toJson(),
      'workQty': workQty.toJson(),
      'unitRate': unitRate.toJson(),
    };
  }
}

class SpkItemSnapshot {
  final String item;
  final String description;

  SpkItemSnapshot({
    required this.item,
    required this.description,
  });

  factory SpkItemSnapshot.fromJson(Map<String, dynamic> json) {
    return SpkItemSnapshot(
      item: json['item'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'description': description,
    };
  }
}

class WorkQty {
  final Quantity quantity;
  final double amount;

  WorkQty({
    required this.quantity,
    required this.amount,
  });

  factory WorkQty.fromJson(Map<String, dynamic> json) {
    return WorkQty(
      quantity: Quantity.fromJson(json['quantity']),
      amount: (json['amount'] ?? 0).toDouble(),
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
      nr: json['nr'] ?? 0,
      r: json['r'] ?? 0,
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
      nonRemoteAreas: (json['nonRemoteAreas'] ?? 0).toDouble(),
      remoteAreas: (json['remoteAreas'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonRemoteAreas': nonRemoteAreas,
      'remoteAreas': remoteAreas,
    };
  }
}

class TimeDetails {
  final DateTime startTime;
  final DateTime endTime;
  final DateTime dcuTime;

  TimeDetails({
    required this.startTime,
    required this.endTime,
    required this.dcuTime,
  });

  factory TimeDetails.fromJson(Map<String, dynamic> json) {
    return TimeDetails(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      dcuTime: DateTime.parse(json['dcuTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'dcuTime': dcuTime.toIso8601String(),
    };
  }
}

class Images {
  final String startImage;
  final String endImage;
  final String dcuImage;

  Images({
    required this.startImage,
    required this.endImage,
    required this.dcuImage,
  });

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      startImage: json['startImage'] ?? '',
      endImage: json['endImage'] ?? '',
      dcuImage: json['dcuImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startImage': startImage,
      'endImage': endImage,
      'dcuImage': dcuImage,
    };
  }
}

class CostUsed {
  final String itemCost;
  final Map<String, dynamic> details;
  final Map<String, dynamic>? itemCostDetails;

  CostUsed({
    required this.itemCost,
    required this.details,
    this.itemCostDetails,
  });

  factory CostUsed.fromJson(Map<String, dynamic> json) {
    return CostUsed(
      itemCost: json['itemCost'],
      details: json['details'],
      itemCostDetails: json['itemCostDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCost': itemCost,
      'details': details,
      'itemCostDetails': itemCostDetails,
    };
  }
}
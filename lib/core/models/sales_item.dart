class SalesItem {
  final String id;
  final String itemCode;
  final String description;
  final String unitMeasurement;
  final String categoryId;
  final String categoryName;
  final String subCategoryName;
  final int rate;

  SalesItem({
    required this.id,
    required this.itemCode,
    required this.description,
    required this.unitMeasurement,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryName,
    required this.rate,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    final activeRate = (json['rates'] as List?)?.firstWhere(
      (rate) => rate['isActive'] == true,
      orElse: () => {'nonRemoteAreas': 0, 'remoteAreas': 0},
    );

    return SalesItem(
      id: json['_id']?.toString() ?? '',
      itemCode: json['itemCode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitMeasurement: json['unitMeasurement']?.toString() ?? '',
      categoryId: json['category']?['_id']?.toString() ?? '',
      categoryName: json['category']?['name']?.toString() ?? '',
      subCategoryName: json['subCategory']?['name']?.toString() ?? '',
      rate: activeRate?['nonRemoteAreas'] ?? 0,
    );
  }
}
class SolarPrice {
  final String id;
  final double price;
  final DateTime effectiveDate;

  SolarPrice({
    required this.id,
    required this.price,
    required this.effectiveDate,
  });

  factory SolarPrice.fromJson(Map<String, dynamic> json) {
    return SolarPrice(
      id: json['_id'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      effectiveDate: DateTime.tryParse(json['effectiveDate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'price': price,
      'effectiveDate': effectiveDate.toIso8601String(),
    };
  }
}
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.consultantId,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.description,
    this.image,
  });

  final int id;
  final int consultantId;
  final String name;
  final int durationMinutes;
  final num price;
  final String? description;
  final String? image;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      consultantId: json['consultantId'] as int,
      name: json['name'] as String,
      durationMinutes: json['durationMinutes'] as int,
      price: num.tryParse(json['price'].toString()) ?? 0,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }
}

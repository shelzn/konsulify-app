class ConsultantModel {
  const ConsultantModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experienceYears,
    this.title,
    this.categoryName,
    this.photo,
    this.description,
  });

  final int id;
  final String name;
  final String specialization;
  final int experienceYears;
  final String? title;
  final String? categoryName;
  final String? photo;
  final String? description;

  factory ConsultantModel.fromJson(Map<String, dynamic> json) {
    return ConsultantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      title: json['title'] as String?,
      categoryName: json['categoryName'] as String?,
      specialization: json['specialization'] as String,
      experienceYears: json['experienceYears'] as int,
      photo: json['photo'] as String?,
      description: json['description'] as String?,
    );
  }
}

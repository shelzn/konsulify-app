class BookingModel {
  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.consultantName,
    required this.serviceName,
    required this.status,
    required this.price,
    this.consultationDate,
    this.startTime,
    this.endTime,
  });

  final int id;
  final String bookingCode;
  final String consultantName;
  final String serviceName;
  final String status;
  final num price;
  final String? consultationDate;
  final String? startTime;
  final String? endTime;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      bookingCode: json['bookingCode'] as String,
      consultantName: json['consultantName']?.toString() ?? 'Konsultan',
      serviceName: json['serviceName']?.toString() ?? 'Layanan Konsultasi',
      status: json['status'] as String,
      price: num.tryParse(json['price'].toString()) ?? 0,
      consultationDate: json['consultationDate']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
    );
  }
}

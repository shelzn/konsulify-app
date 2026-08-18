class ScheduleModel {
  const ScheduleModel({
    required this.id,
    required this.consultantId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  final int id;
  final int consultantId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      consultantId: json['consultantId'] as int,
      date: json['date'].toString(),
      startTime: json['startTime'].toString(),
      endTime: json['endTime'].toString(),
      status: json['status'] as String,
    );
  }
}

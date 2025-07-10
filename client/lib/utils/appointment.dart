class Appointment {
  final String clientName;
  final DateTime startTime;
  final DateTime endTime;
  final String service;
  final String stylist;

  Appointment({
    required this.clientName,
    required this.startTime,
    required this.endTime,
    required this.service,
    required this.stylist,
  });
}
class BookingSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  BookingSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });
}

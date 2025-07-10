import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/business.dart';
import '../../../utils/appointment.dart';
import '../../../utils/booking_slot.dart';

class ProviderBookingsPage extends StatefulWidget {
  final Business business;

  const ProviderBookingsPage({super.key, required this.business});

  @override
  State<ProviderBookingsPage> createState() => _ProviderBookingsPage();
}
class _ProviderBookingsPage extends State<ProviderBookingsPage> {
  DateTime _selectedDate = DateTime.now();
  final List<Appointment> _appointments = [];

  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late List<String> _workingDays;

  late int startHour;
  late int endHour;
  

  List<Appointment> get _appointmentsForDay {
    return _appointments.where((a) =>
    a.startTime.year == _selectedDate.year &&
        a.startTime.month == _selectedDate.month &&
        a.startTime.day == _selectedDate.day
    ).toList();
  }

  List<BookingSlot> _bookingSlots = [];

  List<BookingSlot> get _slotsForSelectedDay {
    return _bookingSlots.where((slot) =>
    slot.startTime.year == _selectedDate.year &&
        slot.startTime.month == _selectedDate.month &&
        slot.startTime.day == _selectedDate.day
    ).toList();
  }

  void _showAddSlotDialog(DateTime startTime) {
    final TextEditingController serviceController = TextEditingController();
    final TextEditingController stylistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Booking Slot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Time: ${TimeOfDay.fromDateTime(startTime).format(context)}"),
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(labelText: "Service"),
            ),
            TextField(
              controller: stylistController,
              decoration: const InputDecoration(labelText: "Stylist"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _bookingSlots.add(BookingSlot(
                  startTime: startTime,
                  endTime: startTime.add(Duration(hours: 1)),
                  // Store extra data if needed
                ));
              });
              Navigator.pop(context);
            },
            child: const Text("Save Slot"),
          ),
        ],
      ),
    );
  }

  int parseTimeTo24Hour(String time12h) {
    final timeParts = time12h.split(' '); // ["8:00", "AM"]
    if (timeParts.length != 2) return 9; // fallback default

    final hm = timeParts[0].split(':'); // ["8", "00"]
    if (hm.length != 2) return 9;

    int hour = int.tryParse(hm[0]) ?? 9;
    final int minute = int.tryParse(hm[1]) ?? 0;

    final meridiem = timeParts[1].toUpperCase();

    if (meridiem == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridiem == 'AM' && hour == 12) {
      hour = 0;
    }

    return hour;
  }

  @override
  void initState() {
    super.initState();

    // Example: load workingDays from business (you may already do this elsewhere)
    _workingDays = widget.business.workingDays;


    startHour = parseTimeTo24Hour(widget.business.startTime);
    endHour = parseTimeTo24Hour(widget.business.endTime);

    print('Parsed startHour: $startHour, endHour: $endHour');

    // Try to set today's date if it's allowed, otherwise fallback
    final todayIndex = DateTime.now().weekday - 1;
    final todayName = _weekdays[todayIndex];

    if (_workingDays.contains(todayName)) {
      _selectedDate = DateTime.now();
    } else {
      // Fallback to the first allowed day
      for (int i = 0; i < 7; i++) {
        final candidateDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - i));
        final candidateName = _weekdays[i];
        if (_workingDays.contains(candidateName)) {
          _selectedDate = candidateDate;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotCount = (endHour - startHour) > 0 ? (endHour - startHour) : 0;
    print('startTime string: ${widget.business.startTime}');
    print('endTime string: ${widget.business.endTime}');

    print('Received startTime: ${widget.business.startTime}');
    print('Received endTime: ${widget.business.endTime}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "booking schedule",
          // style: TextStyle(
          //   fontWeight: FontWeight.bold,
          // ),
        ),
      ),
      body: Column(
        children: [
          // Day selector
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                DateTime day = DateTime.now().subtract(
                  Duration(days: DateTime.now().weekday - 1 - index),
                );

                bool isWorkingDay = widget.business.workingDays.contains(
                  _weekdays[index],
                );

                final weekdayName = _weekdays[index];
                final isSelected = _selectedDate.day == day.day;

                return GestureDetector(
                  onTap: isWorkingDay
                      ? () => setState(() => _selectedDate = day)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedDate.day == day.day
                          ? Colors.deepPurple
                          : isWorkingDay ? Colors.grey[200]
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        weekdayName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isWorkingDay
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // Time slots
          Expanded(
            child: ListView.builder(
              itemCount: slotCount,
              itemBuilder: (context, index) {
                final time = TimeOfDay(hour: startHour + index, minute: 0);
                final startDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  time.hour,
                  time.minute,
                );

                final appointment = _appointmentsForDay.firstWhere(
                      (a) => a.startTime.hour == startDateTime.hour,
                  orElse: () => Appointment(
                    clientName: '',
                    startTime: startDateTime,
                    endTime: startDateTime.add(Duration(hours: 1)),
                    service: '',
                    stylist: '',
                  ),
                );

                final isBooked = appointment.clientName.isNotEmpty;

                BookingSlot? slot;
                try {
                  slot = _slotsForSelectedDay.firstWhere(
                        (s) => s.startTime.hour == startDateTime.hour,
                  );
                } catch (e) {
                  slot = null;
                }

                return ListTile(
                  title: Text('${time.format(context)}'),
                  subtitle: slot != null
                      ? const Text('Slot Available')
                      : const Text('Tap to create slot'),
                  trailing: IconButton(
                    icon: Icon(
                      slot != null ? Icons.edit : Icons.add,
                      color: slot != null ? Colors.blue : Colors.green,
                    ),
                    onPressed: () {
                      if (slot != null) {
                        // Edit slot (optional)
                      } else {
                        _showAddSlotDialog(startDateTime); // Create new slot
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
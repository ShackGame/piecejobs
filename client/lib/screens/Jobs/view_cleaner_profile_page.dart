import 'dart:io';

import 'package:flutter/material.dart';

class CleanerProfileViewPage extends StatelessWidget {
  final Map<String, dynamic> cleaner;

  const CleanerProfileViewPage({super.key, required this.cleaner});

  void _showBookingDialog(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(selectedDate == null
                          ? 'Select Date'
                          : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      title: Text(selectedTime == null
                          ? 'Select Time'
                          : selectedTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter location',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (selectedDate != null &&
                    selectedTime != null &&
                    locationController.text.isNotEmpty) {
                  final bookingDetails =
                      '📅 ${selectedDate!.toLocal().toString().split(' ')[0]}\n🕒 ${selectedTime!.format(context)}\n📍 ${locationController.text}';

                  // Simulate sending booking message
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Booking request sent:\n$bookingDetails'),
                  ));

                  // TODO: Push this to chat/inbox system
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please complete all fields'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleaner Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: cleaner['image'] != null
                  ? FileImage(File(cleaner['image']))
                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(height: 20),
          _info('Name', '${cleaner['name']} ${cleaner['surname']}'),
          _info('Gender', cleaner['gender']),
          _info('Age', cleaner['dob']), // Or calculate age if needed
          _info('Province', cleaner['province']),
          _info('City/Town', cleaner['city']),
          _info('Area common name', cleaner['common_name']),
          _info('About', cleaner['about']),
          _info('Tools', (cleaner['tools'] as List<String>).join(', ')),
          _info('Skills', (cleaner['skills'] as Set<String>).join(', ')),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showBookingDialog(context),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Book Now'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.teal,
            ),
          )
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

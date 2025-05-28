import 'package:client/screens/Jobs/view_cleaner_profile_page.dart';
import 'package:flutter/material.dart';

class CleanersPage extends StatelessWidget {
  const CleanersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cleaners = [
      {
        'name': 'Lebo Mokoena',
        'age': 28,
        'gender': 'Female',
        'about': 'Experienced domestic cleaner with 5+ years in residential homes.',
        'rating': 4.8,
        'lastGig': '2 days ago',
      },
      {
        'name': 'Thabo Nkosi',
        'age': 32,
        'gender': 'Male',
        'about': 'Hardworking and reliable, available for weekend work.',
        'rating': 4.5,
        'lastGig': '1 week ago',
      },
      {
        'name': 'Thabo Nkosi',
        'age': 32,
        'gender': 'Male',
        'about': 'Hardworking and reliable, available for weekend work.',
        'rating': 4.5,
        'lastGig': '1 week ago',
      },
      {
        'name': 'Thabo Nkosi',
        'age': 32,
        'gender': 'Male',
        'about': 'Hardworking and reliable, available for weekend work.',
        'rating': 4.5,
        'lastGig': '1 week ago',
      },
      {
        'name': 'Thabo Nkosi',
        'age': 32,
        'gender': 'Male',
        'about': 'Hardworking and reliable, available for weekend work.',
        'rating': 4.5,
        'lastGig': '1 week ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cleaners')),
      body: ListView.builder(
        itemCount: cleaners.length,
        itemBuilder: (context, index) {
          final cleaner = cleaners[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                cleaner['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${cleaner['age']} • ${cleaner['gender']}'),
                  Text('⭐ ${cleaner['rating']} • Last gig: ${cleaner['lastGig']}'),
                  Text(
                    cleaner['about'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CleanerProfileViewPage(
                        cleaner: {
                          'name': 'John',
                          'surname': 'Doe',
                          'gender': 'Male',
                          'dob': '1990-01-01',
                          'cell': '0812345678',
                          'province': 'Gauteng',
                          'city': 'Johannesburg',
                          'common_name' : 'Central Park',
                          'about': 'Experienced cleaner with over 5 years of service.',
                          'tools': ['Vacuum', 'Mop', 'Bucket'],
                          'skills': {'Cleaning', 'Tiling'},
                          'image': null, // or local image path if exists
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Expand'),
              ),
            ),
          );
        },
      ),
    );
  }
}

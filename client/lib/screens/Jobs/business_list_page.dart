import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/business.dart';

class BusinessListPage extends StatefulWidget {
  final Map<String, dynamic>? business;
  const BusinessListPage({super.key, this.business});

  @override
  _BusinessListPageState createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage> {
  late Future<List<Business>> _futureBusinesses;
  Uint8List? _existingProfileImage;
  late Business b;

  @override
  void initState() {
    super.initState();

    // Fetch all businesses for list or refresh
    _futureBusinesses = fetchAllBusinesses();

    // Parse the business passed into this widget (null-safe)
    if (widget.business != null) {
      b = Business.fromJson(widget.business!);
      _existingProfileImage = b.profileImageBytes;
    } else {
      // Optional: Handle the null case with a fallback or error
      debugPrint("widget.business is null");
    }
  }


  Future<List<Business>> fetchAllBusinesses() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/businesses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Business.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load businesses');
    }
  }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 16);
        }
      }),
    );
  }

  void _showBusinessDetailsDialog(BuildContext context, Business b) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFE8DDF9),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom + 24, // add bottom space
          top: 16,
          left: 16,
          right: 16,),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ---------- Product Images Carousel ----------
              SizedBox(
                height: 180,
                child: b.products.isNotEmpty
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: b.products.length,
                  itemBuilder: (context, index) {
                    final image = b.products[index]; // image is BusinessProductImage
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(image.imageData),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
                    : const Center(child: Text('No product images')),
              ),
              const SizedBox(height: 10),
              // ---------- Business Info ----------
              Text(
                b.businessName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 4),
                  Text('${b.suburb}, ${b.city}'),
                ],
              ),
              const SizedBox(height: 10),
              Text('Description: ${b.description}'),
              const SizedBox(height: 10),
              Text('Working Days: ${b.workingDays.join(', ')}'),
              const SizedBox(height: 10),
              Text('Services: ${b.services.join(', ')}'),
              const SizedBox(height: 10),
              Text('Category: ${b.category}'),
              const SizedBox(height: 10),
              Text('Hours: ${b.startTime} - ${b.endTime}'),
              const SizedBox(height: 10),
              Text('Rates: R${b.minRate} - R${b.maxRate}'),
              const SizedBox(height: 10),
              Text('Rating: ${b.rating == 0.0 ? 'Not yet rated' : b.rating.toString()}'),

              const SizedBox(height: 20),

              // ---------- Actions ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Book'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Providers')),
      body: FutureBuilder<List<Business>>(
        future: _futureBusinesses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No businesses found'));
          }

          final businesses = snapshot.data!;
          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final b = businesses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFF6F0FF), // soft pastel purple
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text & Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.businessName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.deepPurpleAccent),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${b.suburb}, ${b.city}',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurpleAccent),
                                    const SizedBox(width: 4),
                                    Text(
                                      b.workingDays.join(', '),
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Profile Image
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: b.profileImageBytes != null
                                  ? Image.memory(
                                b.profileImageBytes!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 24, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating
                      Row(
                        children: [
                          _buildStars(b.rating),
                          const SizedBox(width: 8),
                          Text(
                            b.rating == 0.0 ? 'Not yet rated' : 'Rating: ${b.rating}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Pricing
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 16, color: Colors.deepPurpleAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Price range: R${b.minRate.toStringAsFixed(0)} - R${b.maxRate.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Expand Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurpleAccent,
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => _showBusinessDetailsDialog(context, b),
                          child: const Text('Expand'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data'; // ✅ Use this instead of internal patch
import 'business_product_image.dart';


class Business {
  final int id;
  final String businessName;
  final String description;
  final String province;
  final String category;
  final String city;
  final String suburb;          // Add this
  final String businessPhone;   // Add this
  final List<String> services;
  final List<String> workingDays;
  final String startTime;
  final String endTime;
  final double minRate;         // Add this
  final double maxRate;         // Add this
  final String profileImageUrl;
  final double rating;
  final List<BusinessProductImage> products;
  final Uint8List? profileImageBytes;


  Business({
    required this.products,
    required this.id,
    required this.province,
    required this.businessName,
    required this.description,
    required this.category,
    required this.city,
    required this.suburb,
    required this.businessPhone,
    required this.services,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.minRate,
    required this.maxRate,
    required this.profileImageUrl,
    required this.rating,
    this.profileImageBytes,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? 0,
      businessName: json['businessName'] ?? '',
      description: json['description'] ?? '',
      province: json['province'] ?? '',
      category: json['category'] ?? '',
      city: json['city'] ?? '',
      suburb: json['suburb'] ?? '',
      businessPhone: json['businessPhone'] ?? '',
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      workingDays: (json['workingDays'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      minRate: (json['minRate'] as num?)?.toDouble() ?? 0.0,
      maxRate: (json['maxRate'] as num?)?.toDouble() ?? 0.0,
      profileImageUrl: json['profileImageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => BusinessProductImage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      profileImageBytes: json['profilePicData'] != null
          ? base64Decode(json['profilePicData'])
          : null,
    );
  }
}

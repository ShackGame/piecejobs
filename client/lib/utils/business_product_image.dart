class BusinessProductImage {
  final int id;
  final String imageData;

  BusinessProductImage({required this.id, required this.imageData});

  factory BusinessProductImage.fromJson(Map<String, dynamic> json) {
    return BusinessProductImage(
      id: json['id'] ?? -1,
      imageData: json['imageData'] ?? '',
    );
  }
}

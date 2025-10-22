class Address {
  final int id;
  final int userId;
  final String address;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    required this.userId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor สำหรับแปลง JSON ที่ได้จาก Node.js
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      address: json['address'],
      // แปลง num (int/double) ให้เป็น double
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
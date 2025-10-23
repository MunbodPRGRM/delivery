class DeliveryInfo {
  final int id;
  final int status;
  final String? itemDescription;
  final String? senderName; // จะมีค่า เมื่อเราเป็น "ผู้รับ"
  final String? receiverName; // จะมีค่า เมื่อเราเป็น "ผู้ส่ง"

  DeliveryInfo({
    required this.id,
    required this.status,
    this.itemDescription,
    this.senderName,
    this.receiverName,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      id: json['id'],
      status: json['status'],
      itemDescription: json['item_description'],
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
    );
  }

  // Helper เพื่อแปลง status (ตัวเลข) เป็นข้อความ
  String getStatusText() {
    switch (status) {
      case 1: return 'รอไรเดอร์มารับ';
      case 2: return 'ไรเดอร์รับงานแล้ว';
      case 3: return 'กำลังเดินทางไปส่ง';
      case 4: return 'ส่งสำเร็จ';
      default: return 'ไม่ทราบสถานะ';
    }
  }
}
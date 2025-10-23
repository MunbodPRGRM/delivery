class DeliveryJob {
  final int id;
  final String? photoStatus1;
  final String destinationAddress;
  final String senderName;
  final String? itemDescription;

  DeliveryJob({
    required this.id,
    this.photoStatus1,
    required this.destinationAddress,
    required this.senderName,
    this.itemDescription,
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) {
    return DeliveryJob(
      id: json['id'],
      photoStatus1: json['photo_status1'],
      destinationAddress: json['destination_address'],
      senderName: json['sender_name'],
      itemDescription: json['item_description'],
    );
  }
}
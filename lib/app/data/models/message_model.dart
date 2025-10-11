
class MessageModel {
  final int id;
  final String message;
  final String sender;
  final String createdAt;
  final int orderId;

  MessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.createdAt,
    required this.orderId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: int.parse(json['id'].toString()),
      message: json['message'],
      sender: json['admin_id'] == null ? 'user' : 'admin',
      createdAt: json['created_at'],
      orderId: int.parse(json['order_id'].toString()),
    );
  }
}

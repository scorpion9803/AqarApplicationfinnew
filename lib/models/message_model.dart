/// يمثل موديل الرسالة داخل المحادثة
class MessageModel {
  final int id;
  final int conversation;
  final int sender;
  final String senderUsername;
  final String? senderAvatar;
  final String messageText;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.conversation,
    required this.sender,
    required this.senderUsername,
    this.senderAvatar,
    required this.messageText,
    required this.createdAt,
    required this.isRead,
  });

  /// إنشاء كائن الرسالة من JSON مع التأكد من سلامة أنواع البيانات
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversation: json['conversation'] as int,
      sender: json['sender'] as int,
      senderUsername: (json['sender_username'] ?? 'User') as String,
      senderAvatar: json['sender_avatar'] as String?,
      messageText: (json['message_text'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: (json['is_read'] as bool? ?? false),
    );
  }

  /// تحويل الكائن إلى Map (مفيد عند الحفظ المحلي أو إرسال بيانات)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversation,
      'sender': sender,
      'sender_username': senderUsername,
      'sender_avatar': senderAvatar,
      'message_text': messageText,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
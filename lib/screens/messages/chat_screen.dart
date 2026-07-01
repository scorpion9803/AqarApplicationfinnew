import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الموديلات والخدمات
import '../../../models/message_model.dart';
import '../../../models/conversation_model.dart';
import '../../../services/messaging_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final OtherUser otherUser; // OtherUser معرف داخل ملف conversation_model

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // جلب الرسائل من السيرفر
  Future<void> _fetchMessages() async {
    try {
      final data = await _messagingService.fetchConversationDetail(widget.conversationId);
      if (mounted) {
        setState(() {
          // جلب قائمة الرسائل من حقل 'messages' في الـ JSON
          _messages = (data['messages'] as List)
              .map((m) => MessageModel.fromJson(m))
              .toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // إرسال رسالة جديدة
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      final newMessage = await _messagingService.sendMessage(widget.conversationId, text);
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إرسال الرسالة')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUser.avatar != null ? NetworkImage(widget.otherUser.avatar!) : null,
              child: widget.otherUser.avatar == null ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUser.username, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.sender == currentUserId;
                return _buildMessageBubble(msg, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.goldAccent : AppTheme.fieldBg,
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomLeft: isMe ? const Radius.circular(0) : const Radius.circular(15),
            bottomRight: isMe ? const Radius.circular(15) : const Radius.circular(0),
          ),
        ),
        child: Text(
          msg.messageText,
          style: TextStyle(
            color: isMe ? AppTheme.secondaryDark : AppTheme.textLight,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppTheme.fieldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppTheme.goldAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.secondaryDark),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
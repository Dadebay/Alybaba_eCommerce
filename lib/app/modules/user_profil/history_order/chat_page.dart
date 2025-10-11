import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabelli_ecommerce/app/constants/custom_app_bar.dart';
import 'package:nabelli_ecommerce/app/data/models/message_model.dart';
import 'package:nabelli_ecommerce/app/data/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final int orderId;
  const ChatPage({required this.orderId, Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<MessageModel> _messagesList = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialFetch();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initialFetch() async {
    try {
      final messages = await ChatService().getMessages(widget.orderId);
      if (mounted) {
        setState(() {
          _messagesList = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print(e);
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final messages = await ChatService().getMessages(widget.orderId);
      if (mounted) {
        setState(() {
          _messagesList = messages;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await ChatService().sendMessage(widget.orderId, _messageController.text);
        _messageController.clear();
        _fetchMessages(); // Refresh messages immediately after sending
      } catch (e) {
        print(e); // Added for debugging
        Get.snackbar('errorTitle'.tr, 'failed_to_send_message'.tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backArrow: true,
        actionIcon: false,
        name: 'chat'.tr,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messagesList.isEmpty
                    ? Center(child: Text('no_messages_yet'.tr))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: _messagesList.length,
                        itemBuilder: (context, index) {
                          final message = _messagesList[index];
                          final bool isMe = message.sender == 'user';
                          return ChatBubble(
                            message: message.message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'type_a_message'.tr,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    required this.message,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[300],
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16.0, color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

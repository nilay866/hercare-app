import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! I\'m your HerCare health advisor. How can I help you today? 💊', 'isUser': false, 'time': 'Now'},
  ];
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true, 'time': _timeNow()});
      _isSending = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final token = context.read<AuthProvider>().token!;
      final resp = await ApiService.sendChat(message: text, token: token);
      if (mounted) {
        setState(() => _messages.add({'text': resp['reply'], 'isUser': false, 'time': _timeNow()}));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _messages.add({'text': 'Sorry, I couldn\'t process that. Please try again.', 'isUser': false, 'time': _timeNow()}));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '${h == 0 ? 12 : h}:${now.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.medical_services, color: Color(0xFFE91E8C), size: 18)),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Health Advisor', style: TextStyle(fontSize: 16)),
            Text('Online', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ]),
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              final isUser = msg['isUser'] as bool;
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFE91E8C) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(msg['text'], style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(msg['time'], style: TextStyle(fontSize: 10, color: isUser ? Colors.white60 : Colors.grey.shade400)),
                  ]),
                ),
              );
            },
          ),
        ),

        // Typing indicator
        if (_isSending)
          const Padding(padding: EdgeInsets.only(left: 20, bottom: 8), child: Align(alignment: Alignment.centerLeft, child: Text('Advisor is typing...', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)))),

        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Type your message...', filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            )),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFE91E8C), borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _isSending ? null : _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.send, color: Colors.white, size: 20)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

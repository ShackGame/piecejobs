import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProviderMessagesPage extends StatefulWidget {
  const ProviderMessagesPage({super.key});

  @override
  State<ProviderMessagesPage> createState() => _ProviderMessagesPage();
}
class _ProviderMessagesPage extends State<ProviderMessagesPage> {
  final List<Map<String, dynamic>> chatThreads = [
    {
      'providerName': 'Jane Doe',
      'job': 'Cleaner',
      'avatar': Icons.cleaning_services,
      'messages': [
        {'fromUser': false, 'text': 'Hi! I am available on your date.', 'time': '09:00 AM'},
        {'fromUser': true, 'text': 'Great! Please confirm.', 'time': '09:02 AM'},
        {'fromUser': false, 'text': 'Booking confirmed, see you then!', 'time': '09:05 AM'},
      ],
    },
    {
      'providerName': 'Tom Smith',
      'job': 'Plumber',
      'avatar': Icons.plumbing,
      'messages': [
        {'fromUser': true, 'text': 'Can you come tomorrow morning?', 'time': 'Yesterday 08:15 PM'},
        {'fromUser': false, 'text': 'Yes, I will be there by 9 AM.', 'time': 'Yesterday 08:20 PM'},
      ],
    },
    {
      'providerName': 'Lerato Mokoena',
      'job': 'Gardener',
      'avatar': Icons.grass,
      'messages': [
        {'fromUser': false, 'text': 'I accepted the booking.', 'time': 'May 25 04:00 PM'},
      ],
    },
  ];

  void _openChat(Map<String, dynamic> thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(thread: thread),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messaging")),
      body: ListView.builder(
        itemCount: chatThreads.length,
        itemBuilder: (context, index) {
          final thread = chatThreads[index];
          final lastMessage = thread['messages'].last;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(thread['avatar'], color: Colors.teal),
            ),
            title: Text('${thread['providerName']} – ${thread['job']}'),
            subtitle: Text(lastMessage['text']),
            trailing: Text(lastMessage['time']),
            onTap: () => _openChat(thread),
          );
        },
      ),
    );
  }
}
class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> thread;
  const ChatScreen({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final messages = thread['messages'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${thread['providerName']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isUser = msg['fromUser'] as bool;
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isUser ? Colors.teal.shade300 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['text'],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg['time'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
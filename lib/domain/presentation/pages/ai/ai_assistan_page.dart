import 'package:flutter/material.dart';
import 'package:mytodo_app/data/repositories/ai_asistant_service.dart';
import 'package:mytodo_app/data/repositories/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String text;
  final bool isUser;
  Message(this.text, this.isUser);
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? username;
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? userName = await LocalStorageService.getUserName();
      print('Loaded username from SharedPreferences: $userName'); // Debug log

    if (userName != null) {
      setState(() {
        this.username=userName;
      });
    }
    setState(() {
      username = userName ?? "Kullanıcı"; // Eğer kayıtlı değilse varsayılan olarak "Kullanıcı" kullan
      _messages.add(Message(
          "Merhaba $username! Ben senin AI asistanınım. Bugün sana nasıl yardımcı olabilirim?",
          false));
    });
  
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text, true));
      _controller.clear();
    });

    // Mesaj gönderildikten sonra en alta scroll
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    // AI Yanıtını Al
    _getAIResponse(text);
  }

  Future<void> _getAIResponse(String userMessage) async {
    setState(() {
      _messages.add(Message("...", false)); // Kullanıcı beklediğini görebilir
    });

    String aiResponse = await AiAssistantService.getAIResponse(userMessage);

    setState(() {
      _messages.removeLast(); // "Yapay Zeka yazıyor..." mesajını kaldır
      _messages.add(Message(aiResponse, false)); // Gerçek yanıtı ekle
    });

    // Yanıt alındıktan sonra en alta scroll
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Asistan"),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 8,
                      left: message.isUser ? 50 : 0,
                      right: message.isUser ? 0 : 50,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_controller.text),
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

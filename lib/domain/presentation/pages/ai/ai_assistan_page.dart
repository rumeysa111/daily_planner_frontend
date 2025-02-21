import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/data/repositories/ai_asistant_service.dart';
import 'package:mytodo_app/data/repositories/local_storage_service.dart';
import 'package:mytodo_app/domain/presentation/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  String? username;
  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();

    _loadUserName();
  }

  // konuşma tanıma başlat
 Future<void> _initializeSpeech() async {
  try {
       // Önce izinleri kontrol et
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("Mikrofon izni reddedildi");
        return;
      }
    print("Speech initialization starting...");
    bool available = await _speech.initialize(
      onError: (error) => print("Speech Error: $error"),
      onStatus: (status) => print("Speech Status: $status"),
    );
    print("Speech initialization result: $available");
    if (!available) {
      print("Ses tanıma kullanılamıyor");
    }
  } catch (e) {
    print("Speech initialization error: $e");
  }
}
  //metinden texte çevirme başlat
  Future<void> _initializeTts()async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  // sesli yanıt Ver(),
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }
  // Sesle yazma
 void _listen() async {
  try {
    if (!_isListening) {
      print("Starting listening...");
      if (!_speech.isAvailable) {
        await _initializeSpeech();
      }
      
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          print("Speech result: ${result.recognizedWords}");
          setState(() {
            _controller.text = result.recognizedWords;
            if (result.finalResult) {
              _sendMessage(_controller.text);
              _isListening = false;
            }
          });
        },
        localeId: "tr_TR",
        listenFor: Duration(seconds: 60),
        pauseFor: Duration(seconds: 5),
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      print("Stopped listening");
    }
  } catch (e) {
    print("Listen error: $e");
    setState(() => _isListening = false);
  }
}

  Future<void> _loadUserName() async {
    //String? userName = await LocalStorageService.getUserName();
    //print('Loaded username from SharedPreferences: $userName'); // Debug log

    setState(() {
      _messages.add(Message(
          "Merhaba! Ben senin AI asistanınım. Bugün sana nasıl yardımcı olabilirim?",
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
      _messages.add(Message("Yazıyor...", false)); // Kullanıcı beklediğini görebilir
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
  final theme = Theme.of(context);
  return Scaffold(
    appBar: CustomAppBar(
  title: "AI Asistan",
  showLeading: false,
 
),
    body: Column(
      children: [
        Expanded(
          child: Container(
            color: AppColors.background,
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
                  child: GestureDetector(
                    onTap: () {
                      if (!message.isUser) {
                        _speak(message.text);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 8,
                        left: message.isUser ? 50 : 0,
                        right: message.isUser ? 0 : 50,
                      ),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, -1),
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Mesajınızı yazın...",
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
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
              IconButton(
                onPressed: _listen,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.error : AppColors.icon,
                  size: 28,
                ),
              ),
              FloatingActionButton(
                onPressed: () => _sendMessage(_controller.text),
                child: Icon(Icons.send),
                backgroundColor: AppColors.primary,
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
        _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/data/repositories/ai_asistant_service.dart';
import 'package:mytodo_app/data/repositories/local_storage_service.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/todo_viewmodel.dart';
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

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? username;
  @override
  void initState() {
    super.initState();

    _setupAssistant();
  }

  Future<void> _setupAssistant() async {
    setState(() => _isLoading = true);
    try {
      await _initializeSpeech();
      await _initializeTts();
      await AiAssistantService.initialize();
      await _loadUserName();
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Setup error: $e');
      _showErrorDialog('Uygulama başlatılamadı: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _analyzeUserTasks() {
    final todos = ref.read(todoProvider);

    final completedTasks = todos.where((task) => task.isCompleted).toList();
    final pendingTasks = todos.where((task) => !task.isCompleted).toList();

    //kategori bazlı Analiz(),
    final categoryAnalysis = <String, int>{};
    for (var task in completedTasks) {
      categoryAnalysis[task.categoryId] =
          (categoryAnalysis[task.categoryId] ?? 0) + 1;
    }
    String? mostCompletedCategory;
    int maxCount = 0;
    categoryAnalysis.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCompletedCategory = category;
      }
    });

    return {
      'totalCompleted': completedTasks.length,
      'totalPending': pendingTasks.length,
      'mostCompletedCategory': mostCompletedCategory,
      'completionRate': todos.isEmpty
          ? 0
          : (completedTasks.length / todos.length * 100).round(),
      'categoryAnalysis': categoryAnalysis,
    };
  }

  String _generatePersonalizedContext() {
    final analysis = _analyzeUserTasks();
    final categories = ref.read(categoryProvider);
    String mostCompletedCategoryName = "belirsiz";
    if (analysis['mostCompletedCategory'] != null) {
      final category = categories.firstWhere(
        (cat) => cat.id == analysis['mostCompletedCategory'],
        orElse: () => categories.first,
      );
      mostCompletedCategoryName = category.name;
    }
    return """
    Kullanıcı profili:
    - Toplam tamamlanan görev sayısı: ${analysis['totalCompleted']}
    - Bekleyen görev sayısı: ${analysis['totalPending']}
    - Tamamlanma oranı: ${analysis['completionRate']}%
    - En çok tamamlanan kategori: $mostCompletedCategoryName
    """;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  // konuşma tanıma başlat
  Future<void> _initializeSpeech() async {
    try {
      // Önce izinleri kontrol et
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (kDebugMode) {
          print("Mikrofon izni reddedildi");
        }
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
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // sesli yanıt Ver(),
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<bool> _handleMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      // İzin henüz istenmemiş, kullanıcıdan iste
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      // Kullanıcı izni kalıcı olarak reddetmiş, ayarlara yönlendir
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mikrofon İzni Gerekli'),
          content: const Text(
              'Sesli komut özelliğini kullanmak için mikrofon iznine ihtiyaç var. Lütfen ayarlardan mikrofon iznini verin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Ayarlara Git'),
            ),
          ],
        ),
      );
      return false;
    }

    return status.isGranted;
  }

  // Sesle yazma
  void _listen() async {
    try {
      // Mikrofon iznini kontrol et
      bool hasPermission = await _handleMicrophonePermission();
      if (!hasPermission) {
        return;
      }

      if (!_isListening) {
        if (!_speech.isAvailable) {
          await _initializeSpeech();
        }

        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              if (result.finalResult) {
                _sendMessage(_controller.text);
                _isListening = false;
              }
            });
          },
          localeId: "tr-TR",
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        setState(() => _isListening = false);
        await _speech.stop();
      }
    } catch (e) {
      print("Listen error: $e");
      setState(() => _isListening = false);
      _showErrorDialog('Ses tanıma başlatılamadı: $e');
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
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (!_isInitialized) {
      _showErrorDialog('AI servisi henüz hazır değil');
      return;
    }

    setState(() {
      _messages.add(Message(trimmedText, true));
      _controller.clear();
    });

    _getAIResponse(trimmedText);
  }

Future<void> _getAIResponse(String userMessage) async {
  int maxAttempts = 3;
  int currentAttempt = 0;
  Duration backoffDuration = const Duration(seconds: 2);

  while (currentAttempt < maxAttempts) {
    if (!_isInitialized) {
      _showErrorDialog('AI servisi henüz hazır değil');
      return;
    }

    final typingMessageIndex = _messages.length;
    setState(() {
      _isLoading = true;
      _messages.add(Message("Yazıyor...", false));
    });

    try {
      final context = _generatePersonalizedContext();
      final enhancedMessage = """
      $context
      Kullanıcı mesajı: $userMessage
      Lütfen yukarıdaki kullanıcı profilini göz önünde bulundurarak ve kişiselleştirilmiş öneriler sunarak yanıt ver.
      """;
      
      final aiResponse = await AiAssistantService.getAIResponse(enhancedMessage);
      setState(() {
        _messages.removeAt(typingMessageIndex);
        _messages.add(Message(aiResponse, false));
        _isLoading = false;
      });
      
      await _scrollToBottom();
      return; // Başarılı yanıt aldıysak döngüden çık
      
    } catch (e) {
      currentAttempt++;
      
      setState(() {
        _messages.removeAt(typingMessageIndex);
        if (currentAttempt == maxAttempts) {
          _messages.add(Message(
            "Üzgünüm, şu anda servis yoğun. Lütfen birkaç dakika sonra tekrar deneyin.",
            false));
        } else {
          _messages.add(Message("Yeniden deneniyor...", false));
        }
        _isLoading = false;
      });

      print('AI Response Error (Attempt $currentAttempt): $e');
      
      if (currentAttempt < maxAttempts) {
        // Exponential backoff: Her denemede bekleme süresini artır
        await Future.delayed(backoffDuration);
        backoffDuration *= 2;
      }
    }
  }
}

// Scroll helper method
  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(
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
                padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
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
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
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
                  child: const Icon(Icons.send),
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

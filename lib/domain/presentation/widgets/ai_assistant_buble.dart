import 'package:flutter/material.dart';

import '../pages/ai/ai_assistan_page.dart';

class AiAssistantBuble extends StatelessWidget {
  const AiAssistantBuble({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("🤖 AI Assistant'a tıklandı");
        // AI Asistanı sayfasına yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AiAssistantPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
            child: Icon(
          Icons.chat,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

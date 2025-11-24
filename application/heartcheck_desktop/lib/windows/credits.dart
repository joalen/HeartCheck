import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  Future<String> loadCredits() async {
    return await rootBundle.loadString('assets/credits.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      appBar: AppBar(title: const Text('Credits')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credits',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),

                child: FutureBuilder<String>(
                  future: loadCredits(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Markdown(
                      data: snapshot.data!,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            fontSize: 18, color: Color(0xFF444444)),
                        h1: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFF444444),
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF444444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

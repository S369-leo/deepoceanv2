import 'package:flutter/material.dart';

class SafetyTipsPage extends StatelessWidget {
  const SafetyTipsPage({super.key});
  static const String routeName = '/info/safety';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> tips = <String>[
      'Meet in public, well-lit places and tell a trusted friend where you will be.',
      'Keep personal details like your home address and workplace private until you feel comfortable.',
      'Use in-app messaging until you trust the person enough to share other contact information.',
      'Trust your instincts: if something feels off, pause the conversation or end the date.',
      'Report suspicious behavior so our team can investigate and protect the community.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Tips')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: tips.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay safe while you connect',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dating should feel exciting and secure. Keep these best practices in mind every time you meet someone new.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            if (index == tips.length + 1) {
              return const SizedBox.shrink();
            }
            final String tip = tips[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

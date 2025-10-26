import 'package:flutter/material.dart';

class SignInChoicePage extends StatelessWidget {
  const SignInChoicePage({
    super.key,
    required this.onGoogle,
    required this.onEmail,
  });

  final VoidCallback onGoogle;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x001677E5),
                    Color(0xB31677E5),
                    Color(0xFF0A3E8C),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Make the first move',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose how you want to continue your journey.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Google button (reuse existing callback if found)
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0A3E8C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Email button (reuse existing callback if found)
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0A3E8C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.mail_outline),
                          label: const Text(
                            'Sign in with Email',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

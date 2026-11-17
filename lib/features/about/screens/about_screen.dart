
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _background = Color(0xFF08050D);
  static const Color _surface = Color(0xFF1A1022);
  static const Color _purple = Color(0xFF9B35D5);
  static const Color _gold = Color(0xFFFFC857);
  static const Color _secondaryText = Color(0xFFB9AFC1);

  static const String _github =
      'https://github.com/MozamilRamadan';

  void _copyGithub(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _github));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GitHub link copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _gold, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text(
          'About Melora',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF35104D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: _gold,
                size: 65,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'MELORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Music Player',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 15,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _purple.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'Version 1.0.0+1',
                style: TextStyle(
                  color: _gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 36),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF40204F),
                ),
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Developer',
                    value: 'MozamilRamadan',
                  ),

                  const Divider(color: Color(0xFF40204F)),

                  _infoRow(
                    icon: Icons.music_note_rounded,
                    title: 'Application',
                    value: 'Melora Music Player',
                  ),

                  const Divider(color: Color(0xFF40204F)),

                  _infoRow(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    value: '1.0.0+1',
                  ),

                  const Divider(color: Color(0xFF40204F)),

                  InkWell(
                    onTap: () => _copyGithub(context),
                    borderRadius: BorderRadius.circular(12),
                    child: _infoRow(
                      icon: Icons.code_rounded,
                      title: 'GitHub',
                      value: 'MozamilRamadan',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Designed for music lovers.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(color: Color(0xFF40204F)),

            const SizedBox(height: 16),

            const Text(
              '© 2026 MozamilRamadan',
              style: TextStyle(
                color: _gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'All rights reserved.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

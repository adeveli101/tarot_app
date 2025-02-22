import 'package:flutter/material.dart';
import 'package:tarot_fal/generated/l10n.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const SettingsScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.tarotFortune), // "Settings" yerine "Tarot Reading" kullanıldı, ayarlar başlığı eklenebilir
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language / Dil', // Lokalize edilebilir
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => onLocaleChange(const Locale('en')),
              ),
            ),
            ListTile(
              title: const Text(
                'Türkçe',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => onLocaleChange(const Locale('tr')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
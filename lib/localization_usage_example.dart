// Example: How to use localization in your app

import 'package:flutter/material.dart';
import 'package:raheel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:raheel/providers/language_provider.dart';

class ExampleLocalizationUsage extends StatelessWidget {
  const ExampleLocalizationUsage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization strings
    final loc = AppLocalizations.of(context);
    
    // Access language provider
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle), // Uses "Raheel" or "رحيل"
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.welcome), // Uses "Welcome" or "أهلا وسهلا"
            const SizedBox(height: 20),
            Text('Current Language: ${languageProvider.languageCode}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Toggle between English and Arabic
                languageProvider.toggleLanguage();
              },
              child: Text(languageProvider.languageCode == 'en'
                  ? loc.arabic  // Switch to Arabic
                  : loc.english), // Switch to English
            ),
            const SizedBox(height: 20),
            Text(loc.bookTrip), // Uses "Book a Trip" or "حجز رحلة"
          ],
        ),
      ),
    );
  }
}

// Usage pattern:
// 1. Get localization: final loc = AppLocalizations.of(context)!;
// 2. Access string: loc.welcomeMessage (or any key from your .arb files)
// 3. To change language: context.read<LanguageProvider>().setLanguage('ar');

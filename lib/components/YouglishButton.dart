import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/repositories/WordEntryRepository.dart';
import '../models/tranlsatorsAndDictionaries/aiEnrichment.dart';

class YouglishButton extends StatelessWidget {
  final WordEntry entry;

  YouglishButton({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text("Youglish", style: Theme.of(context).textTheme.bodyLarge),
        onPressed: () => _launchUrl(youglishLink(entry)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}

Future<void> _launchUrl(Uri url) async {
  await launchUrl(url, mode: LaunchMode.inAppBrowserView);
}

const YOUGLISH_BASE_URL = 'https://youglish.com';

Uri youglishLink(WordEntry entry) {
  final language = findLanguage(entry.locale);
  return Uri.parse(
      "$YOUGLISH_BASE_URL/pronounce/${entry.word}/${language.name.toLowerCase()}");
}

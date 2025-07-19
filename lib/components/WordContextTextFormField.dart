import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/tranlsatorsAndDictionaries/input.dart';
import '../models/tranlsatorsAndDictionaries/reverso.dart';


class WordContextTextFormField extends StatelessWidget {
  final Function(String) onChanged;
  final WordContextInput entry;
  final TextEditingController controller;

  WordContextTextFormField({
    Key? key,
    required this.onChanged,
    required this.entry,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
          filled: true,
          hintText: localization.editEnterContextHint,
          labelText: localization.editEnterContextLabel,
          suffixIcon: IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              final wordContexts = await reversoWordContexts(entry.word);
              wordContexts.shuffle();
              controller.text = wordContexts[0];
              onChanged(wordContexts[0]);
            },
          ),
      ),
      onChanged: onChanged,
    );
  }
}

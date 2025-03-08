import 'package:flutter/material.dart';
import '../models/tranlsatorsAndDictionaries/reverso.dart';
import '../models/tranlsatorsAndDictionaries/translatorsAndDictionaries.dart';


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
    return TextFormField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
          filled: true,
          hintText: 'Enter a context...',
          labelText: 'Context',
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

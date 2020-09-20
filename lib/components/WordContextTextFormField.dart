import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_trainer/models/tranlsatorsAndDictionaries/reverso.dart';

abstract class WordContextInput {
  String word;
  String context;

  WordContextInput(this.word, this.context);
}

class WordContextTextFormField extends StatelessWidget {
  final Function(String) onChanged;
  final WordContextInput entry;
  final TextEditingController controller = TextEditingController();

  WordContextTextFormField({
    Key key,
    @required this.onChanged,
    @required this.entry,
  }) : super(key: key) {
    controller.text = entry.context;
  }

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
          )),
      onChanged: onChanged,
    );
  }
}

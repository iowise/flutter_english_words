import 'package:flutter/material.dart';
import '../components/TranslationTextInput.dart';

class WordEntryForm extends StatefulWidget {

  final WordEntryInput entry;

  WordEntryForm({Key key, this.entry}) : super(key: key);

  @override
  _WordEntryFormState createState() => _WordEntryFormState();
}

class _WordEntryFormState extends State<WordEntryForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: Align(
          alignment: Alignment.topCenter,
          child: Card(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter a word...',
                        labelText: 'Word',
                      ),
                      onChanged: (value) {
                        setState(() {
                          widget.entry.word = value;
                        });
                      },
                    ),
                    TranslationTextInput(
                      word: widget.entry.word,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter a translation...',
                        labelText: 'Translation',
                      ),
                      onChanged: (value) {
                        widget.entry.translation = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
 }


class WordEntryInput {
  String word;
  String translation;

  WordEntryInput(this.word, this.translation);
}

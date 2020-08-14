import 'package:flutter/material.dart';

class TrainPage extends StatefulWidget {
  @override
  _TrainPageState createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final _formKey = GlobalKey<FormState>();

  String word = '';
  String translation = '';

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
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter a word...',
                        labelText: 'Word',
                      ),
                      onChanged: (value) {
                        setState(() {
                          word = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter a translation...',
                        labelText: 'Translation',
                      ),
                      onChanged: (value) {
                        translation = value;
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
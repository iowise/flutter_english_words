import 'package:flutter/material.dart';

import '../models/tranlsatorsAndDictionaries/aiEnrichment.dart';

class LanguageBottomSheet extends StatelessWidget {
  final Language value;
  final void Function(Language) onChange;

  const LanguageBottomSheet(
      {Key? key, required this.value, required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optionButtons = List<Widget>.from(Language.values.map((language) {
      final isSelected = language == value;
      return ElevatedButton(
        child: Text(language.name + (isSelected ? ' (selected)' : '')),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: isSelected ? null : () {
          onChange(language);
          Navigator.of(context).pop();
        },
      );
    }));

    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: optionButtons,
        ),
      ),
    );
  }
}

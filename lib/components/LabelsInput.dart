import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class Label {
  final String text;
  final bool existing;

  Label(this.text, [this.existing = true]);

  Label.create(this.text, [this.existing = false]);
}

class LabelsInput extends StatefulWidget {
  final List<Label> initialValue;
  final List<Label> allLabels;
  final ValueChanged<List<String>> onChange;

  LabelsInput(
      {Key key,
      @required this.initialValue,
      @required this.onChange,
      @required this.allLabels})
      : super(key: key);

  factory LabelsInput.fromStrings(
      {Key key,
      @required List<String> initialValue,
      @required onChange,
      @required List<String> allLabels}) {
    final _allLabels = allLabels.map((e) => Label(e)).toList();
    final _initialValue = initialValue.map(((e) => Label(e))).toList();
    return LabelsInput(
        key: key,
        initialValue: _initialValue,
        allLabels: _allLabels,
        onChange: onChange);
  }

  @override
  _LabelsInputState createState() => _LabelsInputState();
}

class _LabelsInputState extends State<LabelsInput> {
  GlobalKey<ChipsInputState> _chipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ChipsInput<Label>(
      key: _chipKey,
      initialValue: widget.initialValue,
      decoration: InputDecoration(
        labelText: "Labels",
        filled: true,
      ),
      findSuggestions: findSuggestions,
      onChanged: (data) {
        setState(() {
          widget.onChange(data.map((e) => e.text).toList());
        });
      },
      chipBuilder: (context, state, label) {
        return InputChip(
          key: ObjectKey(label),
          label: Text(label.text),
          onDeleted: () => state.deleteChip(label),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, label) {
        return ListTile(
          key: ObjectKey(label),
          title: Text(label.text),
          leading: !label.existing ? Icon(Icons.add) : null,
          onTap: () => state.selectSuggestion(label),
        );
      },
    );
  }

  List<Label> findSuggestions(String query) {
    final exactLabel = widget.allLabels
        .firstWhere((element) => element.text == query, orElse: () => null);
    if (query.length == 0) {
      return widget.allLabels;
    }
    var lowercaseQuery = query.toLowerCase();
    final filtered = widget.allLabels
        .where((label) => label.text.toLowerCase().contains(lowercaseQuery))
        .toList(growable: false);
    return exactLabel == null
        ? [Label.create(query.trim()), ...filtered]
        : filtered;
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

@immutable
class Label extends Equatable {
  final String text;
  final bool existing;

  Label(this.text, [this.existing = true]);

  Label.create(this.text, [this.existing = false]);

  @override
  List<Object?> get props => [text];
}

class LabelsInput extends StatefulWidget {
  final List<Label> initialValue;
  final List<Label> allLabels;
  final ValueChanged<List<String>> onChange;

  LabelsInput({
    Key? key,
    required this.initialValue,
    required this.onChange,
    required this.allLabels,
  }) : super(key: key);

  factory LabelsInput.fromStrings({
    Key? key,
    required List<String> initialValue,
    required onChange,
    required List<String> allLabels,
  }) {
    final _allLabels = allLabels.map((e) => Label(e)).toList();
    final _initialValue = initialValue.map(((e) => Label(e))).toList();
    return LabelsInput(
      key: key,
      initialValue: _initialValue,
      allLabels: _allLabels,
      onChange: onChange,
    );
  }

  @override
  _LabelsInputState createState() => _LabelsInputState();
}

class _LabelsInputState extends State<LabelsInput> {
  TextEditingController _typeAheadController = TextEditingController(text: '');
  List<Label> selected = [];

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypeAheadFormField<Label>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Labels',
              )
            ),
            suggestionsCallback: findSuggestions,
            autoFlipDirection: true,
            itemBuilder: (context, label) {
              return ListTile(
                leading: !label.existing ? Icon(Icons.add) : null,
                title: Text(label.text),
              );
            },
            onSuggestionSelected: (suggestion) {
              addLabel(suggestion);
            },
          ),
          _LabelChips(selected: selected, onDelete: this.onDelete),
        ],
      ),
    );
  }

  List<Label> get notSelected => widget.allLabels
      .where((element) => !selected.contains(element))
      .toList(growable: false);

  List<Label> findSuggestions(String query) {
    final newLabel = isNewLabel(query);
    if (query.length == 0) {
      return notSelected;
    }
    var lowercaseQuery = query.toLowerCase();
    final filtered = notSelected
        .where((label) => label.text.toLowerCase().contains(lowercaseQuery))
        .toList(growable: false);
    return newLabel ? [Label.create(query.trim()), ...filtered] : filtered;
  }

  bool isNewLabel(String query) {
    try {
      [...notSelected, ...selected].firstWhere((e) => e.text == query);
      return false;
    } catch (IterableElementError) {
      return true;
    }
  }

  void onDelete(Label label) {
    onChange(selected.where((e) => e != label).toList(growable: false));
  }

  void addLabel(Label suggestion) {
    onChange([...selected, suggestion]);
  }

  void onChange(List<Label> labels) {
    setState(() {
      selected = labels;
      widget.onChange(selected.map((e) => e.text).toList());
      _typeAheadController.text = '';
    });
  }
}

class _LabelChips extends StatelessWidget {
  final List<Label> selected;

  final void Function(Label) onDelete;

  _LabelChips({required this.selected, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List<Widget>.from(
        selected.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(e.text),
              onDeleted: () => this.onDelete(e),
            ),
          ),
        ),
      ),
    );
  }
}

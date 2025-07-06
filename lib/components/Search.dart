import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_trainer/l10n/app_localizations.dart';

import '../models/blocs/WordEntryCubit.dart';
import '../models/repositories/WordEntryRepository.dart';
import './WordList.dart';

class SearchButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, _) => IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate:
            CustomSearchDelegate(context.read<WordEntryCubit>()),
          );
        },
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final WordEntryCubit bloc;

  CustomSearchDelegate(this.bloc);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        query = '';
      },
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      close(context, null);
    },
  );

  @override
  Widget buildResults(BuildContext context) {
    final filtered = filterWords(bloc.state.allWords);
    if (filtered.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.nothingIsFound));
    }
    return WordList(words: filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  List<WordEntry> filterWords(List<WordEntry> data) => data
      .where((element) => element.word.contains(query) ||
      element.translation.contains(query) ||
      element.definition.contains(query))
      .toList();
}

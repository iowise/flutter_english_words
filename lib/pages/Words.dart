import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../models/SharedWords.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/repositories/WordEntryRepository.dart';
import '../models/blocs/WordEntryCubit.dart';
import '../components/ReviewButton.dart';
import '../components/WordList.dart';
import './WordDetails.dart';

@immutable
class WordsArguments {
  final String? label;

  WordsArguments({this.label});
}

class WordsPage extends StatefulWidget {
  @override
  _WordsPageState createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  WordEntryRepository repository = GetIt.I.get<WordEntryRepository>();
  TrainService? trainRepository;

  @override
  void initState() {
    super.initState();
    GetIt.I.isReady<TrainService>().then((value) {
      setState(() {
        trainRepository = GetIt.I.get<TrainService>();
      });
      GetIt.I.getAsync<SharedWordsService>().then((value) => value.init());
    });
  }

  String? get label {
    final Object? argObj = ModalRoute.of(context)?.settings.arguments;
    final WordsArguments? arg = argObj as WordsArguments;
    return arg?.label;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldWrapper = (w) => BlocProvider.value(
          value: GetIt.I.get<WordEntryCubit>(),
          child: w,
        );

    return scaffoldWrapper(
      Scaffold(
          appBar: AppBar(
            title: buildTitle(),
            actions: <Widget>[
              BlocBuilder<WordEntryCubit, WordEntryListState>(
                  builder: (context, _) {
                return IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    if (repository == null) return;
                    _showSortingAndFilter(
                        context.read<WordEntryCubit>(), context);
                  },
                );
              }),
              BlocBuilder<WordEntryCubit, WordEntryListState>(
                  builder: (context, _) {
                return IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (repository == null) return;
                    showSearch(
                      context: context,
                      delegate:
                          CustomSearchDelegate(context.read<WordEntryCubit>()),
                    );
                  },
                );
              })
            ],
          ),
          body: Center(
            child: _buildList(),
          ),
          floatingActionButton: BlocBuilder<WordEntryCubit, WordEntryListState>(
              builder: (context, state) {
            return FloatingActionButton(
              tooltip: 'Add a word',
              child: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/word/create',
                  arguments: WordDetailsArguments(label: state.selectedLabel)),
            );
          })),
    );
  }

  Widget buildTitle() {
    if (repository == null) return Text("Words");

    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, state) {
        return Text(state.selectedLabel ?? 'Inbox');
      },
    );
  }

  Widget _buildList() {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, state) {
        if (!state.isConfigured || trainRepository == null) {
          return CircularProgressIndicator();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildReviewButton(),
            Expanded(child: WordList(words: state.selectedWords)),
          ],
        );
      },
    );
  }

  Widget _buildReviewButton() {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (_, state) {
        final wordsToReview =
            trainRepository!.getToReviewToday(state.wordsToReview);
        return ReviewButton(wordsToReview: wordsToReview);
      },
    );
  }

  void _showSortingAndFilter(WordEntryCubit bloc, BuildContext context) {
    final selectedStyle = Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(color: Theme.of(context).accentColor);
    final selectedOrNull =
        (value, option) => (value == option ? selectedStyle : null);
    final makeOption = ({text, option, current}) => SimpleDialogOption(
          child: Text(text, style: selectedOrNull(current, option)),
          onPressed: () {
            Navigator.pop(context);
            if (option.runtimeType == Filtering) {
              bloc.setFiltering(option);
            } else {
              bloc.setSorting(option);
            }
          },
        );
    final state = bloc.state;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Sorting and Filtering'),
            children: <Widget>[
              makeOption(
                text: 'Sort by word',
                option: Sorting.byWord,
                current: state.sorting,
              ),
              makeOption(
                text: 'Sort by date',
                option: Sorting.byDate,
                current: state.sorting,
              ),
              makeOption(
                text: 'Show not trained',
                option: Filtering.unTrained,
                current: state.filtering,
              ),
              makeOption(
                text: 'Show all',
                option: Filtering.all,
                current: state.filtering,
              ),
            ],
          );
        });
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final WordEntryCubit bloc;

  CustomSearchDelegate(this.bloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filtered = filterWords(bloc.state.allWords);
    if (filtered.isEmpty) {
      return Center(child: Text('Nothing is found'));
    }
    return WordList(words: filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  List<WordEntry> filterWords(List<WordEntry> data) => data
      .where((element) =>
          element.word.contains(query) ||
          element.translation.contains(query) ||
          element.definition.contains(query))
      .toList();
}

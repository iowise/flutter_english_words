import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:word_trainer/l10n/app_localizations.dart';
import '../components/Search.dart';
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
                builder: (context, _) => IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    _showSortingAndFilter(
                        context.read<WordEntryCubit>(), context);
                  },
                ),
              ),
              SearchButton(),
            ],
          ),
          body: Center(child: _buildList()),
          floatingActionButton: BlocBuilder<WordEntryCubit, WordEntryListState>(
            builder: (context, state) => FloatingActionButton(
              tooltip: 'Add a word',
              child: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/word/create',
                  arguments: WordDetailsArguments(label: state.selectedLabel)),
            ),
          )),
    );
  }

  Widget buildTitle() {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, state) => Text(state.selectedLabel ?? 'Inbox'),
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
        .bodyMedium!
        .copyWith(color: Theme.of(context).colorScheme.secondary);
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
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Text(localization.sortingSelectSortingAndFiltering),
        children: <Widget>[
          makeOption(
            text: localization.sortingSortWord,
            option: Sorting.byWord,
            current: state.sorting,
          ),
          makeOption(
            text: localization.sortingSortDate,
            option: Sorting.byDate,
            current: state.sorting,
          ),
          makeOption(
            text: localization.sortingShowNotTrained,
            option: Filtering.unTrained,
            current: state.filtering,
          ),
          makeOption(
            text: localization.sortingShowAll,
            option: Filtering.all,
            current: state.filtering,
          ),
        ],
      ),
    );
  }
}

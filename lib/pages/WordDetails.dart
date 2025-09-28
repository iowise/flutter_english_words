import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../components/LanguageBottomSheet.dart';
import '../models/blocs/LabelCubit.dart';
import '../models/blocs/TrainLogCubit.dart';
import '../models/blocs/WordEntryCubit.dart';
import '../models/repositories/TrainLogRepository.dart';
import '../models/repositories/WordEntryRepository.dart';
import '../components/WordEntryForm.dart';
import '../models/tranlsatorsAndDictionaries/aiEnrichment.dart';
import '../models/tranlsatorsAndDictionaries/input.dart';

@immutable
class WordDetailsArguments {
  final WordEntry? entry;
  final String? word;
  final String? label;

  WordDetailsArguments({this.entry, this.word, this.label});
}

class WordDetails extends StatelessWidget {
  WordDetails({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final Object? argObj = ModalRoute.of(context)?.settings.arguments;
    final WordDetailsArguments? arg = argObj as WordDetailsArguments?;
    final entryInput = arg?.entry == null
        ? WordEntryInput.empty(defaultLabel: arg?.label)
        : WordEntryInput.fromWordEntry(arg!.entry!);
    if (arg?.word != null) {
      entryInput.word = arg!.word!;
    }
    return WordCreateOrEdit(title: title, entryInput: entryInput);
  }
}

class WordCreateOrEdit extends StatefulWidget {
  WordCreateOrEdit({super.key, required this.title, required this.entryInput});

  final String title;
  final WordEntryInput entryInput;

  @override
  _WordCreateOrEditState createState() => _WordCreateOrEditState();
}

class _WordCreateOrEditState extends State<WordCreateOrEdit> {
  late WordEntryInput entryInput;

  @override
  void initState() {
    entryInput = widget.entryInput;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.I.get<WordEntryCubit>()),
        BlocProvider.value(value: GetIt.I.get<TrainLogCubit>()),
        BlocProvider.value(value: GetIt.I.get<LabelEntryCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: entryInput.arg == null
              ? <Widget>[
                  BlocBuilder<LabelEntryCubit, LabelMapState>(
                    builder: (context, state) => IconButton(
                      icon: Text(getLocalLanguage(state).icon),
                      onPressed: () => showLanguageBottomSheet(context),
                    ),
                  ),
                ]
              : <Widget>[
                  BlocBuilder<WordEntryCubit, WordEntryListState>(
                    builder: (context, _) => IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _onDelete(context),
                    ),
                  ),
                ],
        ),
        body: buildBody(),
        floatingActionButton: BlocBuilder<WordEntryCubit, WordEntryListState>(
          builder: (context, _) => FloatingActionButton(
            tooltip: 'Save',
            child: Icon(Icons.save),
            onPressed: () => _onSave(context),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (entryInput.arg == null) {
      return BlocBuilder<WordEntryCubit, WordEntryListState>(
        builder: (_, state) => ListView(
          children: <Widget>[
            WordEntryForm(
              entry: entryInput,
              allLabels: state.labelsStatistics.labels,
            ),
          ],
        ),
      );
    }
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (_, state) => BlocBuilder<TrainLogCubit, TrainLogState>(
        builder: (_, trainLogState) {
          List details = [];
          if (entryInput.arg?.dueToLearnAfter != null) {
            final logs = (entryInput.arg?.id == null)
                ? List<TrainLog>.empty(growable: false)
                : trainLogState.getLogs(entryInput.arg!.id!);
            details = [
              buildWordDetails(context),
              ...buildTrainLogs(logs),
            ];
          }
          final allLabels = state.labelsStatistics.labels;

          return ListView(
            children: <Widget>[
              WordEntryForm(entry: entryInput, allLabels: allLabels),
              ...details,
            ],
          );
        },
      ),
    );
  }

  Widget buildWordDetails(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final nextTrainDate = formatter.format(entryInput.arg!.dueToLearnAfter!);
    return ListTile(
      title: Text(
        AppLocalizations.of(context)!.trainingNextTrainingOnDate(nextTrainDate),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  List<Widget> buildTrainLogs(List<TrainLog> logs) {
    final DateFormat formatterWithTime = DateFormat('yyyy-MM-dd H:m');
    return logs.map((e) {
      return ListTile(
        title: Text(
          "${formatterWithTime.format(e.trainedAt)} ${e.score}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }).toList();
  }

  _onSave(BuildContext context) async {
    await context.read<WordEntryCubit>().save(entryInput.toEntry());
    Navigator.pop(context);
  }

  _onDelete(BuildContext context) async {
    if (entryInput.arg == null) return;

    final wordId = entryInput.arg!.id!;
    await GetIt.I.get<TrainLogCubit>().deleteLogsForWord(wordId);
    await context.read<WordEntryCubit>().delete(entryInput.arg!);
    Navigator.pop(context);
  }

  showLanguageBottomSheet(BuildContext parentContext) {
    final labelCubit = GetIt.I.get<LabelEntryCubit>();
    showModalBottomSheet<void>(
      context: parentContext,
      builder: (context) => LanguageBottomSheet(
        onChange: (_language) {
          final singleLabel = entryInput.labels.singleOrNull;
          if (singleLabel != null) {
            labelCubit.save([singleLabel], _language.locale);
          }
        },
        value: getLocalLanguage(labelCubit.state),
      ),
    );
  }

  Language getLocalLanguage(LabelMapState labelMap) {
    final singleLabel = entryInput.labels.singleOrNull;
    final localeLabel = singleLabel != null ? [singleLabel] : <String>[];
    return findLanguage(labelMap.guessLocale(localeLabel) ?? DEFAULT_LOCALE);
  }
}

class LogsAndLabels {
  final List<TrainLog> logs;
  final List<String> labels;

  const LogsAndLabels(this.logs, this.labels);
}

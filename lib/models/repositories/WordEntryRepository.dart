import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

const WORDS_TABLE = '_word_entry';
const DEFAULT_LOCALE = 'en-US';

const _columnId = '_id';
const _columnWord = 'word';
const _columnTranslation = 'translation';
const _columnContext = 'context';
const _columnSynonyms = 'synonyms';
const _columnAntonyms = 'antonyms';
const _columnDefinition = 'definition';
const _columnLocale = '_locale';
const _columnCreatedAt = '_created_at';
const _columnTrainedAt = '_trained_at';
const columnDueToLearnAfter = '_due_to_learn_after';
const _columnLabels = '_labels';

class WordEntry extends Equatable {
  String? id;

  late String word;
  late String locale;
  late String translation;
  late String definition;
  late String context;
  late String synonyms;
  late String antonyms;

  late DateTime createdAt;
  DateTime? trainedAt;
  DateTime? dueToLearnAfter;

  late List<String> labels;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnWord: word,
      _columnTranslation: translation,
      _columnContext: context,
      _columnDefinition: definition,
      _columnSynonyms: synonyms,
      _columnAntonyms: antonyms,
      _columnLocale: locale,
      _columnCreatedAt: createdAt.toIso8601String(),
      _columnLabels: labels,
    };
    if (id != null) {
      map[_columnId] = id;
    }
    if (trainedAt != null) {
      map[_columnTrainedAt] = trainedAt!.toIso8601String();
    }
    if (dueToLearnAfter != null) {
      map[columnDueToLearnAfter] = dueToLearnAfter!.toIso8601String();
    }
    return map;
  }

  WordEntry.create({
    required this.word,
    required this.translation,
    required this.definition,
    required this.context,
    required this.synonyms,
    required this.antonyms,
    required this.labels,
    required this.locale,
  }) {
    createdAt = DateTime.now();
  }

  WordEntry.copy(
    WordEntry other, {
    required final String word,
    required final String translation,
    required final String definition,
    required final String context,
    required final String synonyms,
    required final String antonyms,
    required final String locale,
    required final List<String> labels,
  }) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.dueToLearnAfter = other.dueToLearnAfter;

    this.locale = locale;
    this.word = word;
    this.translation = translation;
    this.definition = definition;
    this.context = context;
    this.synonyms = synonyms;
    this.antonyms = antonyms;
    this.labels = labels;
  }

  WordEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    word = map[_columnWord];
    translation = map[_columnTranslation];
    definition = map[_columnDefinition] ?? '';
    context = map[_columnContext] ?? '';
    synonyms = map[_columnSynonyms] ?? '';
    antonyms = map[_columnAntonyms] ?? '';
    createdAt = DateTime.parse(map[_columnCreatedAt]);
    labels = map[_columnLabels] != null
        ? new List<String>.from(map[_columnLabels], growable: false)
        : [];
    locale = map[_columnLocale] ?? DEFAULT_LOCALE;

    trainedAt = map[_columnTrainedAt] != null
        ? DateTime.parse(map[_columnTrainedAt])
        : null;
    dueToLearnAfter = map[columnDueToLearnAfter] != null
        ? DateTime.parse(map[columnDueToLearnAfter])
        : null;
  }

  factory WordEntry.fromDocument(DocumentSnapshot snapshot) {
    final entry = WordEntry.fromMap(snapshot.data() as Map<String, dynamic>);
    entry.id = snapshot.reference.id;
    return entry;
  }

  bool hasLabel(String? label) =>
      label == null ? labels.isEmpty : labels.contains(label);

  bool isForLearn(DateTime now) =>
      dueToLearnAfter == null || dueToLearnAfter!.isBefore(now);

  @override
  List<Object?> get props => [
        id,
        word,
        translation,
        definition,
        context,
        synonyms,
        antonyms,
        createdAt,
        trainedAt,
        dueToLearnAfter,
        labels,
        locale,
      ];
}

class WordEntryRepository {
  CollectionReference? _words;

  CollectionReference? get words {
    if (FirebaseAuth.instance.currentUser == null) return null;

    _words ??= FirebaseFirestore.instance
        .collection('words')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('list');
    return _words;
  }

  get isReady => FirebaseAuth.instance.currentUser == null;

  Future<WordEntry> insert(WordEntry entry) async {
    if (words == null) return Future.error("User not loaded");

    final reference = await words!.add(entry.toMap());
    entry.id = reference.id;
    return entry;
  }

  Future<WordEntry?> getWordEntry(String id) async {
    if (words == null) return Future.error("User not loaded");

    final snapshot = await words!.doc(id).get();
    return snapshot.exists ? WordEntry.fromDocument(snapshot) : null;
  }

  Future<List<WordEntry>> getAllWordEntries(bool fromCache) async {
    if (words == null) return Future.error("User not loaded");

    final snapshot = await words!
        .get(fromCache ? const GetOptions(source: Source.cache) : null);
    return [for (final doc in snapshot.docs) WordEntry.fromDocument(doc)];
  }

  Future<List<WordEntry>> getWordEntries({final String? label}) async {
    final entries = await getAllWordEntries(true);
    final filtered =
        entries.where((word) => word.hasLabel(label)).toList(growable: false);
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future delete(String id) async {
    if (words == null) return;
    await words!.doc(id).delete();
  }

  Future update(WordEntry entry) async {
    if (words == null) return;
    await words!.doc(entry.id).update(entry.toMap());
  }

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }

  Future<WordEntry?> findCopy(String word) async {
    if (words == null) return Future.error("User not loaded");

    final snapshot = await words!.where(_columnWord, isEqualTo: word).get();

    return snapshot.docs.isNotEmpty
        ? WordEntry.fromDocument(snapshot.docs[0])
        : null;
  }
}

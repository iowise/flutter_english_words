import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String WORDS_TABLE = '_word_entry';

const String _columnId = '_id';
const String _columnWord = 'word';
const String _columnTranslation = 'translation';
const String _columnContext = 'context';
const String _columnSynonyms = 'synonyms';
const String _columnAntonyms = 'antonyms';
const String _columnDefinition = 'definition';
const String _columnCreatedAt = '_created_at';
const String _columnTrainedAt = '_trained_at';
const String columnDueToLearnAfter = '_due_to_learn_after';
const String _columnLabels = '_labels';

class WordEntry extends Equatable {
  String? id;

  late String word;
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
    required final List<String> labels,
  }) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.dueToLearnAfter = other.dueToLearnAfter;

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

  bool isForLearn(DateTime now) => dueToLearnAfter == null || dueToLearnAfter!.isBefore(now);

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
      ];
}

class WordEntryRepository {
  CollectionReference? _words;

  get words {
    if (FirebaseAuth.instance.currentUser == null) return null;

    _words ??= FirebaseFirestore.instance
        .collection('words')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('list');
    return _words;
  }

  get isReady => words != null;

  Future<WordEntry> insert(WordEntry entry) async {
    final reference = await words.add(entry.toMap());
    entry.id = reference.id;
    return entry;
  }

  Future<WordEntry?> getWordEntry(String id) async {
    final snapshot = await words.doc(id).get();
    return snapshot.exists ? WordEntry.fromDocument(snapshot) : null;
  }

  Future<List<WordEntry>> getAllWordEntries() async {
    final snapshot = await words.get();
    return [for (final doc in snapshot.docs) WordEntry.fromDocument(doc)];
  }

  Future<List<WordEntry>> getWordEntries({final String? label}) async {
    final entries = await getAllWordEntries();
    final filtered =
        entries.where((word) => word.hasLabel(label)).toList(growable: false);
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Stream<WordEntry> query({
    required bool Function(WordEntry word) where,
  }) async* {
    final snapshot = await words.get();
    for (final doc in snapshot.docs) {
      final word = WordEntry.fromDocument(doc);
      if (where(word)) {
        yield word;
      }
    }
  }

  Future delete(String id) async {
    await words.doc(id).delete();
  }

  Future update(WordEntry entry) async {
    await words.doc(entry.id).update(entry.toMap());
  }

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }

  Future<WordEntry?> findCopy(String word) async {
    final snapshot = await words.where(_columnWord, isEqualTo: word).get();

    return snapshot.docs.isNotEmpty
        ? WordEntry.fromDocument(snapshot.docs[0])
        : null;
  }
}

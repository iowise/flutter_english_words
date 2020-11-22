import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

final String WORDS_TABLE = '_word_entry';

final String _columnId = '_id';
final String _columnWord = 'word';
final String _columnTranslation = 'translation';
final String _columnContext = 'context';
final String _columnSynonyms = 'synonyms';
final String _columnAntonyms = 'antonyms';
final String _columnDefinition = 'definition';
final String _columnCreatedAt = '_created_at';
final String _columnTrainedAt = '_trained_at';
final String columnDueToLearnAfter = '_due_to_learn_after';
final String _columnLabels = '_labels';

class WordEntry {
  String id;

  String word;
  String translation;
  String definition;
  String context;
  String synonyms;
  String antonyms;

  DateTime createdAt;
  DateTime trainedAt;
  DateTime dueToLearnAfter;

  List<String> labels;

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
      map[_columnTrainedAt] = trainedAt.toIso8601String();
    }
    if (dueToLearnAfter != null) {
      map[columnDueToLearnAfter] = dueToLearnAfter.toIso8601String();
    }
    return map;
  }

  WordEntry.create({
    @required this.word,
    @required this.translation,
    @required this.definition,
    @required this.context,
    @required this.synonyms,
    @required this.antonyms,
    @required this.labels,
  }) {
    createdAt = DateTime.now();
  }

  WordEntry.copy(
    WordEntry other, {
    @required final String word,
    @required final String translation,
    @required final String definition,
    @required final String context,
    @required final String synonyms,
    @required final String antonyms,
    @required final List<String> labels,
  }) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.dueToLearnAfter = other.dueToLearnAfter;

    this.word = word != null ? word : other.word;
    this.translation = translation != null ? translation : other.translation;
    this.definition = definition != null ? definition : other.definition;
    this.context = context != null ? context : other.context;
    this.synonyms = synonyms != null ? synonyms : other.synonyms;
    this.antonyms = antonyms != null ? antonyms : other.antonyms;
    this.labels = labels != null ? labels : other.labels;
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
        ? new List<String>.from(map[_columnLabels])
        : [];

    trainedAt = map[_columnTrainedAt] != null
        ? DateTime.parse(map[_columnTrainedAt])
        : null;
    dueToLearnAfter = map[columnDueToLearnAfter] != null
        ? DateTime.parse(map[columnDueToLearnAfter])
        : null;
  }

  factory WordEntry.fromDocument(DocumentSnapshot snapshot) {
    final entry = WordEntry.fromMap(snapshot.data());
    entry.id = snapshot.reference.id;
    return entry;
  }

  bool hasLabel(String label) =>  label == null || labels.contains(label);
}

class WordEntryRepository extends ChangeNotifier {
  CollectionReference words;
  final editedWord = ValueNotifier<WordEntry>(null);
  final deletedWordId = ValueNotifier<String>(null);

  WordEntryRepository() {
    words = FirebaseFirestore.instance
        .collection('words')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('list');
  }

  Future<WordEntry> insert(WordEntry entry) async {
    final reference = await words.add(entry.toMap());
    entry.id = reference.id;
    notifyListeners();
    return entry;
  }

  Future<WordEntry> getWordEntry(String id) async {
    final snapshot = await words.doc(id).get();
    return snapshot.exists ? WordEntry.fromDocument(snapshot) : null;
  }

  Future<List<WordEntry>> getWordEntries({final String label}) async {
    final snapshot = await words.get();
    final entries = [
      for (final doc in snapshot.docs) WordEntry.fromDocument(doc)
    ];
    final filtered = entries.where((word) => word.hasLabel(label)).toList(growable: false);
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<List<String>> getAllLabels() async {
    final words = await getWordEntries();
    final labels = words.expand((e) => e.labels).toSet().toList();
    labels.sort((a, b) => a.compareTo(b));
    return labels;
  }

  Stream<WordEntry> query({
    bool Function(WordEntry word) where,
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
    deletedWordId.value = id;
    notifyListeners();
  }

  Future update(WordEntry entry) async {
    await words.doc(entry.id).update(entry.toMap());
    editedWord.value = entry;
    notifyListeners();
  }

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }

  Future<WordEntry> findCopy(String word) async {
    final snapshot = await words.where(_columnWord, isEqualTo: word).get();

    return snapshot.docs.isNotEmpty
        ? WordEntry.fromDocument(snapshot.docs[0])
        : null;
  }
}

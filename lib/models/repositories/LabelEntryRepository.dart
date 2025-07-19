import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_trainer/components/LabelsInput.dart';

const WORDS_TABLE = '_word_entry';
const DEFAULT_LOCALE = 'en-US';

const _columnId = '_id';
const _columnName = '_name';
const _columnLocale = '_locale';

class LabelEntry extends Equatable {
  String? id;

  late String name;
  late String locale;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnName: name,
      _columnLocale: locale,
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  LabelEntry.create({
    required this.name,
    required this.locale,
  }) {}

  LabelEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    name = map[_columnName];
    locale = map[_columnLocale] ?? DEFAULT_LOCALE;
  }

  factory LabelEntry.fromDocument(DocumentSnapshot snapshot) {
    final entry = LabelEntry.fromMap(snapshot.data() as Map<String, dynamic>);
    entry.id = snapshot.reference.id;
    return entry;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        locale,
      ];
}

class LabelEntryRepository {
  CollectionReference? _labels;

  CollectionReference? get labels {
    if (FirebaseAuth.instance.currentUser == null) return null;

    _labels ??= FirebaseFirestore.instance
        .collection('labels')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('list');
    return _labels;
  }

  get isReady => FirebaseAuth.instance.currentUser == null;

  Future<LabelEntry> insert(LabelEntry entry) async {
    if (labels == null) return Future.error("User not loaded");

    final reference = await labels!.add(entry.toMap());
    entry.id = reference.id;
    return entry;
  }

  Future<LabelEntry> update(LabelEntry entry) async {
    if (labels == null) return Future.error("User not loaded");
    await labels!.doc(entry.id).update(entry.toMap());
    return entry;
  }

  Future<LabelEntry?> getLabelEntry(String id) async {
    if (labels == null) return Future.error("User not loaded");

    final snapshot = await labels!.doc(id).get();
    return snapshot.exists ? LabelEntry.fromDocument(snapshot) : null;
  }

  Future<List<LabelEntry>> getAllLabelEntries(bool fromCache) async {
    if (labels == null) return Future.error("User not loaded");

    final snapshot = await labels!
        .get(fromCache ? const GetOptions(source: Source.cache) : null);
    return [for (final doc in snapshot.docs) LabelEntry.fromDocument(doc)];
  }

  Future<String?> findLocale({
    required String name,
  }) async {
    if (labels == null) return null;

    final snapshot = await labels!.get();
    for (final doc in snapshot.docs) {
      final entry = LabelEntry.fromDocument(doc);
      if (entry.name == name) {
        return entry.locale;
      }
    }
    return null;
  }

  Future<List<LabelEntry>> createLocales(List<String> newLabels, String locale) async {
    if (labels == null) return [];

    final snapshot = await labels!.get();
    final existingLocales = [
      for (final doc in snapshot.docs) LabelEntry.fromDocument(doc)
    ];
    final newLabelSet = newLabels.toSet();
    final entriesToUpdate = <LabelEntry>[];
    final matchedLabels = <LabelEntry>[];
    for (final e in existingLocales) {
      if (newLabelSet.contains(e.name)) {
        if (e.locale != locale) {
          e.locale = locale;
          entriesToUpdate.add(e);
        }
        matchedLabels.add(e);
      }
      newLabelSet.remove(e.name);
    }
    final newLabelEntries = newLabelSet.map(
            (label) => LabelEntry.create(name: label, locale: locale));
    final creationFutures = newLabelEntries.map((entry) => insert(entry));
    final updateFutures = entriesToUpdate.map((entry) => update(entry));
    await Future.wait(creationFutures.followedBy(
        updateFutures));
    return List.from(newLabelEntries.followedBy(matchedLabels));
  }
}

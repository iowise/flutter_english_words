import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:word_trainer/models/TrainLogRepository.dart';
import 'package:word_trainer/models/WordEntryRepository.dart';

class FakeWordEntryRepository extends Mock
    implements WordEntryRepository {}

class FakeTrainLogRepository extends Mock implements TrainLogRepository {
}

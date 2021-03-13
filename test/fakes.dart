import 'package:mockito/mockito.dart';
import 'package:word_trainer/models/repositories/TrainLogRepository.dart';
import 'package:word_trainer/models/repositories/WordEntryRepository.dart';

class FakeWordEntryRepository extends Mock
    implements WordEntryRepository {
  get isReady => false;
}

class FakeTrainLogRepository extends Mock implements TrainLogRepository {
}

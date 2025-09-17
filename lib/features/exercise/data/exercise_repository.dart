import 'package:fitness_app/data/exercises_dummy_data.dart';
import 'package:fitness_app/models/exercise.dart';
import 'package:fitness_app/utility/in_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseRepository {
  final _exercises = InMemoryStore<List<Exercise>>(List.from(kExercises));

  List<Exercise> getExercicesList() {
    return _exercises.value;
  }

  Future<List<Exercise>> fetchExercisesList() async {
    return Future.value(_exercises.value);
  }

  Future<List<Exercise>> fetchExerciseByCategory(Category category) async {
    final exercises = await fetchExercisesList();
    return exercises
        .where((exercise) => exercise.category == category)
        .toList();
  }

  Stream<List<Exercise>> watchProductLists() {
    return _exercises.stream;
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final exercisesListStreamProvider = StreamProvider<List<Exercise>>((ref) {
  final exerciseRepository = ref.watch(exerciseRepositoryProvider);
  return exerciseRepository.watchProductLists();
});

final exerciseBycategoryProvider =
    FutureProvider.family<List<Exercise>, Category>((ref, category) {
      final exerciseRepository = ref.watch(exerciseRepositoryProvider);
      return exerciseRepository.fetchExerciseByCategory(category);
    });

import '../environment.dart';
import '../environment_variable.dart';

abstract class EnvironmentRepository {
  Future<List<Environment>> getProjectEnvironments(int projectId);

  Future<Environment> createProjectEnvironment({
    required int projectId,
    required String name,
  });

  Future<List<EnvironmentVariable>> getVariables(int environmentId);

  Future<void> updateVariables({
    required int environmentId,
    required List<Map<String, dynamic>> added,
    required List<Map<String, dynamic>> updated,
    required List<int> removed,
  });
}

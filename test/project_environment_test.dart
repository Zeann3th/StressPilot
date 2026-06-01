import 'package:flutter_test/flutter_test.dart';
import 'package:stress_pilot/features/environments/domain/environment.dart';
import 'package:stress_pilot/features/projects/domain/models/project.dart';

void main() {
  test('Project reads activeEnvironmentId and keeps environmentId alias', () {
    final project = Project.fromJson({
      'id': 1,
      'name': 'Demo',
      'description': 'Demo project',
      'environmentId': 10,
      'activeEnvironmentId': 11,
      'createdAt': '2026-06-02T00:00:00',
      'updatedAt': '2026-06-02T00:00:00',
    });

    expect(project.environmentId, 11);
    expect(project.activeEnvironmentId, 11);
    expect(project.toJson()['activeEnvironmentId'], 11);
  });

  test('Environment reads backend environment payload', () {
    final environment = Environment.fromJson({
      'id': 7,
      'projectId': 1,
      'name': 'Staging',
      'createdAt': '2026-06-02T00:00:00',
      'updatedAt': '2026-06-02T00:00:00',
    });

    expect(environment.id, 7);
    expect(environment.projectId, 1);
    expect(environment.name, 'Staging');
  });
}

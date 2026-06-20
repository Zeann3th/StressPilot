### Task 1: Relocate Projects & Flows State to Shared

**Files:**
- Create:
  - `lib/features/shared/domain/models/project.dart`
  - `lib/features/shared/domain/repositories/project_repository.dart`
  - `lib/features/shared/data/repositories/project_repository_impl.dart`
  - `lib/features/shared/presentation/provider/project_provider.dart`
  - `lib/features/shared/domain/models/flow.dart`
  - `lib/features/shared/domain/repositories/flow_repository.dart`
  - `lib/features/shared/data/repositories/flow_repository_impl.dart`
  - `lib/features/shared/presentation/provider/flow_provider.dart`
- Modify:
  - `lib/core/di/locator.dart`
- Delete:
  - `lib/features/projects/domain/models/project.dart`
  - `lib/features/projects/domain/repositories/project_repository.dart`
  - `lib/features/projects/data/repositories/project_repository_impl.dart`
  - `lib/features/projects/presentation/provider/project_provider.dart`
  - `lib/features/projects/domain/models/flow.dart`
  - `lib/features/projects/domain/repositories/flow_repository.dart`
  - `lib/features/projects/data/repositories/flow_repository_impl.dart`
  - `lib/features/projects/presentation/provider/flow_provider.dart`

**Interfaces:**
- Consumes: None
- Produces: `Flow`, `Project`, `FlowRepository`, `ProjectRepository`, `FlowProvider`, `ProjectProvider` located in `shared`.

- [ ] **Step 1: Create directories in shared**
  Run: `New-Item -ItemType Directory -Force -Path lib/features/shared/domain/models, lib/features/shared/domain/repositories, lib/features/shared/data/repositories, lib/features/shared/presentation/provider`
- [ ] **Step 2: Move project files to shared**
  Run:
  ```powershell
  Move-Item -Path lib/features/projects/domain/models/project.dart -Destination lib/features/shared/domain/models/project.dart
  Move-Item -Path lib/features/projects/domain/repositories/project_repository.dart -Destination lib/features/shared/domain/repositories/project_repository.dart
  Move-Item -Path lib/features/projects/data/repositories/project_repository_impl.dart -Destination lib/features/shared/data/repositories/project_repository_impl.dart
  Move-Item -Path lib/features/projects/presentation/provider/project_provider.dart -Destination lib/features/shared/presentation/provider/project_provider.dart
  ```
- [ ] **Step 3: Move flow files to shared**
  Run:
  ```powershell
  Move-Item -Path lib/features/projects/domain/models/flow.dart -Destination lib/features/shared/domain/models/flow.dart
  Move-Item -Path lib/features/projects/domain/repositories/flow_repository.dart -Destination lib/features/shared/domain/repositories/flow_repository.dart
  Move-Item -Path lib/features/projects/data/repositories/flow_repository_impl.dart -Destination lib/features/shared/data/repositories/flow_repository_impl.dart
  Move-Item -Path lib/features/projects/presentation/provider/flow_provider.dart -Destination lib/features/shared/presentation/provider/flow_provider.dart
  ```
- [ ] **Step 4: Update internal package imports inside moved files**
  Inside `lib/features/shared/data/repositories/project_repository_impl.dart`, update the import paths to:
  `import 'package:stress_pilot/features/shared/domain/models/project.dart';`
  `import 'package:stress_pilot/features/shared/domain/repositories/project_repository.dart';`

  Inside `lib/features/shared/presentation/provider/project_provider.dart`, update the import paths to:
  `import 'package:stress_pilot/features/shared/domain/models/project.dart';`
  `import 'package:stress_pilot/features/shared/domain/repositories/project_repository.dart';`

  Inside `lib/features/shared/data/repositories/flow_repository_impl.dart`, update the import paths to:
  `import 'package:stress_pilot/features/shared/domain/models/flow.dart';`
  `import 'package:stress_pilot/features/shared/domain/repositories/flow_repository.dart';`

  Inside `lib/features/shared/presentation/provider/flow_provider.dart`, update the import paths to:
  `import 'package:stress_pilot/features/shared/domain/models/flow.dart';`
  `import 'package:stress_pilot/features/shared/domain/repositories/flow_repository.dart';`
  `import 'package:stress_pilot/features/shared/data/repositories/flow_repository_impl.dart';`
- [ ] **Step 5: Update DI locator.dart imports**
  Modify `lib/core/di/locator.dart` to use new import paths for:
  `FlowRepository`, `FlowRepositoryImpl`, `ProjectRepository`, `ProjectRepositoryImpl`, `FlowProvider`, `ProjectProvider`.
- [ ] **Step 6: Commit**
  Run:
  ```bash
  git add lib/features/shared lib/features/projects lib/core/di/locator.dart
  git commit -m "refactor: relocate projects and flows state to shared"
  ```

# Feature Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the package structure of `stresspilot_super_app` to decouple presentation features (`projects`, `results`, `workspace`) by moving shared data, models, and providers to `shared`, making features flat and dependent only on `shared`.

**Architecture:** Relocate models, repositories, and providers for Projects, Flows, Endpoints, and Runs into `lib/features/shared/`. Move specific presentation dialogs/widgets to their corresponding consuming features (`workspace`, `results`). Update DI registrations and imports.

**Tech Stack:** Dart, Flutter, Provider, GetIt.

## Global Constraints
- Target architecture must have no cross-feature imports between `projects`, `results`, and `workspace`.
- Features must only depend on `shared` and `core`.
- The application must compile and pass all tests.

---

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

---

### Task 2: Relocate Endpoints State to Shared

**Files:**
- Create:
  - `lib/features/shared/domain/models/endpoint.dart`
  - `lib/features/shared/domain/repositories/endpoint_repository.dart`
  - `lib/features/shared/data/repositories/endpoint_repository_impl.dart`
  - `lib/features/shared/presentation/provider/endpoint_provider.dart`
- Delete:
  - `lib/features/endpoints/domain/models/endpoint.dart`
  - `lib/features/endpoints/domain/repositories/endpoint_repository.dart`
  - `lib/features/endpoints/data/repositories/endpoint_repository_impl.dart`
  - `lib/features/endpoints/presentation/provider/endpoint_provider.dart`

**Interfaces:**
- Consumes: None
- Produces: `Endpoint`, `EndpointRepository`, `EndpointProvider` in `shared`.

- [ ] **Step 1: Move files to shared**
  Run:
  ```powershell
  Move-Item -Path lib/features/endpoints/domain/models/endpoint.dart -Destination lib/features/shared/domain/models/endpoint.dart
  Move-Item -Path lib/features/endpoints/domain/repositories/endpoint_repository.dart -Destination lib/features/shared/domain/repositories/endpoint_repository.dart
  Move-Item -Path lib/features/endpoints/data/repositories/endpoint_repository_impl.dart -Destination lib/features/shared/data/repositories/endpoint_repository_impl.dart
  Move-Item -Path lib/features/endpoints/presentation/provider/endpoint_provider.dart -Destination lib/features/shared/presentation/provider/endpoint_provider.dart
  ```
- [ ] **Step 2: Update internal imports in moved endpoint files**
  Inside `lib/features/shared/data/repositories/endpoint_repository_impl.dart`:
  Update imports for `endpoint.dart` and `endpoint_repository.dart`.
  Inside `lib/features/shared/presentation/provider/endpoint_provider.dart`:
  Update imports for `endpoint.dart`, `endpoint_repository.dart`, `endpoint_repository_impl.dart`.
- [ ] **Step 3: Update DI locator.dart imports**
  Modify `lib/core/di/locator.dart` to use new import paths for:
  `EndpointProvider`.
- [ ] **Step 4: Commit**
  Run:
  ```bash
  git add lib/features/shared lib/features/endpoints lib/core/di/locator.dart
  git commit -m "refactor: relocate endpoints state to shared"
  ```

---

### Task 3: Relocate Runs State to Shared

**Files:**
- Create:
  - `lib/features/shared/domain/models/run.dart`
  - `lib/features/shared/domain/repositories/run_repository.dart`
  - `lib/features/shared/data/repositories/run_repository_impl.dart`
  - `lib/features/shared/presentation/provider/run_provider.dart`
- Delete:
  - `lib/features/results/domain/models/run.dart`
  - `lib/features/results/domain/repositories/run_repository.dart`
  - `lib/features/results/data/repositories/run_repository_impl.dart`
  - `lib/features/results/presentation/provider/run_provider.dart`

**Interfaces:**
- Consumes: None
- Produces: `Run`, `RunRepository`, `RunProvider` in `shared`.

- [ ] **Step 1: Move files to shared**
  Run:
  ```powershell
  Move-Item -Path lib/features/results/domain/models/run.dart -Destination lib/features/shared/domain/models/run.dart
  Move-Item -Path lib/features/results/domain/repositories/run_repository.dart -Destination lib/features/shared/domain/repositories/run_repository.dart
  Move-Item -Path lib/features/results/data/repositories/run_repository_impl.dart -Destination lib/features/shared/data/repositories/run_repository_impl.dart
  Move-Item -Path lib/features/results/presentation/provider/run_provider.dart -Destination lib/features/shared/presentation/provider/run_provider.dart
  ```
- [ ] **Step 2: Update internal imports in moved run files**
  Inside `lib/features/shared/data/repositories/run_repository_impl.dart`:
  Update imports for `run.dart` and `run_repository.dart`.
  Inside `lib/features/shared/presentation/provider/run_provider.dart`:
  Update imports for `run.dart`, `run_repository.dart`, `run_repository_impl.dart`.
- [ ] **Step 3: Update DI locator.dart imports**
  Modify `lib/core/di/locator.dart` to use new import paths for:
  `RunRepository`, `RunRepositoryImpl`, `RunProvider`.
- [ ] **Step 4: Commit**
  Run:
  ```bash
  git add lib/features/shared lib/features/results lib/core/di/locator.dart
  git commit -m "refactor: relocate runs state to shared"
  ```

---

### Task 4: Relocate Presentation Widgets

**Files:**
- Create:
  - `lib/features/results/presentation/widgets/runs_list_widget.dart`
  - `lib/features/shared/presentation/widgets/run_flow_dialog.dart`
  - `lib/features/workspace/presentation/widgets/node_configuration_dialog.dart`
  - `lib/features/workspace/presentation/widgets/subflow_configuration_dialog.dart`
  - `lib/features/shared/presentation/widgets/flow_dialog.dart`
  - `lib/features/shared/presentation/widgets/endpoint_type_badge.dart`
  - `lib/features/shared/presentation/widgets/json_viewer.dart`
  - `lib/features/shared/presentation/widgets/key_value_editor.dart`
  - `lib/features/shared/presentation/widgets/endpoints/editor/...`
- Delete:
  - `lib/features/projects/presentation/widgets/runs_list_widget.dart`
  - `lib/features/projects/presentation/widgets/run_flow_dialog.dart`
  - `lib/features/projects/presentation/widgets/node_configuration_dialog.dart`
  - `lib/features/projects/presentation/widgets/subflow_configuration_dialog.dart`
  - `lib/features/projects/presentation/widgets/flow_dialog.dart`
  - `lib/features/endpoints/presentation/widgets/endpoint_type_badge.dart`
  - `lib/features/endpoints/presentation/widgets/json_viewer.dart`
  - `lib/features/endpoints/presentation/widgets/key_value_editor.dart`
  - `lib/features/endpoints/presentation/widgets/editor/...`

- [ ] **Step 1: Move widget files to new locations**
  Run:
  ```powershell
  New-Item -ItemType Directory -Force -Path lib/features/shared/presentation/widgets/endpoints
  Move-Item -Path lib/features/projects/presentation/widgets/runs_list_widget.dart -Destination lib/features/results/presentation/widgets/runs_list_widget.dart
  Move-Item -Path lib/features/projects/presentation/widgets/run_flow_dialog.dart -Destination lib/features/shared/presentation/widgets/run_flow_dialog.dart
  Move-Item -Path lib/features/projects/presentation/widgets/node_configuration_dialog.dart -Destination lib/features/workspace/presentation/widgets/node_configuration_dialog.dart
  Move-Item -Path lib/features/projects/presentation/widgets/subflow_configuration_dialog.dart -Destination lib/features/workspace/presentation/widgets/subflow_configuration_dialog.dart
  Move-Item -Path lib/features/projects/presentation/widgets/flow_dialog.dart -Destination lib/features/shared/presentation/widgets/flow_dialog.dart
  Move-Item -Path lib/features/endpoints/presentation/widgets/endpoint_type_badge.dart -Destination lib/features/shared/presentation/widgets/endpoint_type_badge.dart
  Move-Item -Path lib/features/endpoints/presentation/widgets/json_viewer.dart -Destination lib/features/shared/presentation/widgets/json_viewer.dart
  Move-Item -Path lib/features/endpoints/presentation/widgets/key_value_editor.dart -Destination lib/features/shared/presentation/widgets/key_value_editor.dart
  Move-Item -Path lib/features/endpoints/presentation/widgets/editor -Destination lib/features/shared/presentation/widgets/endpoints/editor
  ```
- [ ] **Step 2: Clean up the endpoints folder**
  Remove the empty `lib/features/endpoints` directory since all its files have been relocated.
  Run: `Remove-Item -Recurse -Force lib/features/endpoints`
- [ ] **Step 3: Refactor FlowDialog to accept projectId dynamically**
  Modify `lib/features/shared/presentation/widgets/flow_dialog.dart`:
  Remove import of `package:stress_pilot/features/projects/presentation/provider/project_provider.dart`.
  Update `showCreateDialog` signature to accept `required int projectId`.
- [ ] **Step 4: Update imports and callbacks in caller files**
  Update callers in `lib/features/workspace/presentation/widgets/workspace_flow_tabs.dart` and `workspace_sidebar.dart` to pass `projectId` to `FlowDialog.showCreateDialog`.
- [ ] **Step 5: Commit**
  Run:
  ```bash
  git add lib/features
  git commit -m "refactor: relocate UI components and clean up cross-imports"
  ```

---

### Task 5: Project-wide Import Cleanup and Verification

**Files:**
- Modify: All dart files containing invalid imports of the relocated modules.

- [ ] **Step 1: Execute import-path replacement script**
  Run a PowerShell script to globally replace the old import paths with the new ones.
  Old Paths:
  - `package:stress_pilot/features/projects/domain/models/flow.dart` -> `package:stress_pilot/features/shared/domain/models/flow.dart`
  - `package:stress_pilot/features/projects/domain/repositories/flow_repository.dart` -> `package:stress_pilot/features/shared/domain/repositories/flow_repository.dart`
  - `package:stress_pilot/features/projects/data/repositories/flow_repository_impl.dart` -> `package:stress_pilot/features/shared/data/repositories/flow_repository_impl.dart`
  - `package:stress_pilot/features/projects/presentation/provider/flow_provider.dart` -> `package:stress_pilot/features/shared/presentation/provider/flow_provider.dart`
  - `package:stress_pilot/features/projects/domain/models/project.dart` -> `package:stress_pilot/features/shared/domain/models/project.dart`
  - `package:stress_pilot/features/projects/domain/repositories/project_repository.dart` -> `package:stress_pilot/features/shared/domain/repositories/project_repository.dart`
  - `package:stress_pilot/features/projects/data/repositories/project_repository_impl.dart` -> `package:stress_pilot/features/shared/data/repositories/project_repository_impl.dart`
  - `package:stress_pilot/features/projects/presentation/provider/project_provider.dart` -> `package:stress_pilot/features/shared/presentation/provider/project_provider.dart`
  - `package:stress_pilot/features/endpoints/domain/models/endpoint.dart` -> `package:stress_pilot/features/shared/domain/models/endpoint.dart`
  - `package:stress_pilot/features/endpoints/presentation/provider/endpoint_provider.dart` -> `package:stress_pilot/features/shared/presentation/provider/endpoint_provider.dart`
  - `package:stress_pilot/features/results/domain/models/run.dart` -> `package:stress_pilot/features/shared/domain/models/run.dart`
  - `package:stress_pilot/features/results/presentation/provider/run_provider.dart` -> `package:stress_pilot/features/shared/presentation/provider/run_provider.dart`
  - `package:stress_pilot/features/results/domain/repositories/run_repository.dart` -> `package:stress_pilot/features/shared/domain/repositories/run_repository.dart`
  - `package:stress_pilot/features/projects/presentation/widgets/runs_list_widget.dart` -> `package:stress_pilot/features/results/presentation/widgets/runs_list_widget.dart`
  - `package:stress_pilot/features/projects/presentation/widgets/run_flow_dialog.dart` -> `package:stress_pilot/features/shared/presentation/widgets/run_flow_dialog.dart`
  - `package:stress_pilot/features/projects/presentation/widgets/node_configuration_dialog.dart` -> `package:stress_pilot/features/workspace/presentation/widgets/node_configuration_dialog.dart`
  - `package:stress_pilot/features/projects/presentation/widgets/subflow_configuration_dialog.dart` -> `package:stress_pilot/features/workspace/presentation/widgets/subflow_configuration_dialog.dart`
  - `package:stress_pilot/features/projects/presentation/widgets/flow_dialog.dart` -> `package:stress_pilot/features/shared/presentation/widgets/flow_dialog.dart`
  - `package:stress_pilot/features/endpoints/presentation/widgets/endpoint_type_badge.dart` -> `package:stress_pilot/features/shared/presentation/widgets/endpoint_type_badge.dart`
  - `package:stress_pilot/features/endpoints/presentation/widgets/json_viewer.dart` -> `package:stress_pilot/features/shared/presentation/widgets/json_viewer.dart`
  - `package:stress_pilot/features/endpoints/presentation/widgets/key_value_editor.dart` -> `package:stress_pilot/features/shared/presentation/widgets/key_value_editor.dart`
  - `package:stress_pilot/features/endpoints/presentation/widgets/editor/` -> `package:stress_pilot/features/shared/presentation/widgets/endpoints/editor/`
- [ ] **Step 2: Run flutter analyze to verify compile and code standards**
  Run: `flutter analyze`
  Expected: No analysis errors.
- [ ] **Step 3: Run all unit tests**
  Run: `flutter test`
  Expected: All tests pass.
- [ ] **Step 4: Commit**
  Run:
  ```bash
  git add lib test
  git commit -m "refactor: project-wide import updates and verification passing"
  ```

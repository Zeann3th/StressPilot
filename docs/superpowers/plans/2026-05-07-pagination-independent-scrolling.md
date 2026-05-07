# Pagination and Independent Scrolling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement infinite scroll pagination for Projects, Flows, and Endpoints, and ensure each list has its own independent scroll bar in the sidebars.

**Architecture:** 
- Update `ProjectProvider` and `FlowProvider` to maintain pagination state (current page, has more, loading more).
- Refactor `WorkspaceSidebar` and `ProjectsSidebar` to use `ListView.builder` with `ScrollController` and `Scrollbar` for each section.
- Implement scroll listeners in the presentation layer to trigger "load more" actions when the user reaches the bottom of a list.

**Tech Stack:** Flutter, Provider, Lucide Icons (already in use).

---

### Task 1: Update ProjectProvider for Pagination

**Files:**
- Modify: `lib/features/projects/presentation/provider/project_provider.dart`

- [ ] **Step 1: Add pagination state variables**
Add `_currentPage`, `_pageSize`, `_hasMore`, and `_isLoadingMore` to `ProjectProvider`.

- [ ] **Step 2: Update `loadProjects` method**
Modify `loadProjects` to reset pagination state and fetch the first page.

- [ ] **Step 3: Implement `loadMoreProjects` method**
Add a method to fetch the next page of projects and append to the `_projects` list.

- [ ] **Step 4: Update getters**
Expose `isLoadingMore` and `hasMore`.

---

### Task 2: Update FlowProvider for Pagination

**Files:**
- Modify: `lib/features/projects/presentation/provider/flow_provider.dart`

- [ ] **Step 1: Add pagination state variables**
Add `_currentPage`, `_pageSize`, `_hasMore`, and `_isLoadingMore` to `FlowProvider`.

- [ ] **Step 2: Update `loadFlows` method**
Modify `loadFlows` to reset pagination state and fetch the first page.

- [ ] **Step 3: Implement `loadMoreFlows` method**
Add a method to fetch the next page of flows for a given project.

- [ ] **Step 4: Update getters**
Expose `isLoadingMore` and `hasMore`.

---

### Task 3: Refactor ProjectsSidebar for Independent Scrolling and Pagination

**Files:**
- Modify: `lib/features/projects/presentation/widgets/projects_sidebar.dart`

- [ ] **Step 1: Convert `_ProjectsList` to StatefulWidget**
Need a `ScrollController` to detect scroll position.

- [ ] **Step 2: Implement ScrollListener**
Trigger `provider.loadMoreProjects()` when approaching the bottom.

- [ ] **Step 3: Add Scrollbar**
Wrap the `ListView.builder` with a `Scrollbar` (ensure it's always visible or follows theme).

- [ ] **Step 4: Add Loading Indicator at bottom**
Add a small spinner at the end of the list if `isLoadingMore` is true.

---

### Task 4: Refactor WorkspaceSidebar for Independent Scrolling

**Files:**
- Modify: `lib/features/workspace/presentation/widgets/workspace_sidebar.dart`

- [ ] **Step 1: Remove parent ListView**
Change the root `ListView` in `WorkspaceSidebar` to a `Column`.

- [ ] **Step 2: Update `_SidebarSection` and lists to use Expanded**
Ensure each section can grow and have its own scroll area. Use `Expanded` for the expanded section.

- [ ] **Step 3: Refactor `_EndpointList` for Pagination**
- Add `ScrollController` and `Scrollbar`.
- Convert `Column` of rows to `ListView.builder`.
- Implement `_onScroll` to trigger `endpointProvider.loadMoreEndpoints()`.
- Add `isLoadingMore` indicator.

- [ ] **Step 4: Refactor `_FlowList` for Pagination**
- Add `ScrollController` and `Scrollbar`.
- Convert `Column` of rows to `ListView.builder`.
- Implement `_onScroll` to trigger `flowProvider.loadMoreFlows()`.
- Add `isLoadingMore` indicator.

---

### Task 5: Final Layout Polish and Verification

**Files:**
- Modify: `lib/features/workspace/presentation/widgets/workspace_sidebar.dart`
- Modify: `lib/features/projects/presentation/widgets/projects_sidebar.dart`

- [ ] **Step 1: Ensure Scrollbars are visible**
Desktop users expect visible scrollbars. Use `Scrollbar(thumbVisibility: true, ...)` if appropriate.

- [ ] **Step 2: Verify independent scrolling**
Confirm that scrolling Endpoints does not scroll Flows, and vice-versa.

- [ ] **Step 3: Verify pagination works**
Test by scrolling to the bottom of each list (might need many items or small page size for testing).

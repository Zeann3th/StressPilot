# StressPilot MCP Service Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the backend service discovery and action methods through MCP, excluding the full request-log analysis dump, then package the backend jar into the Flutter app asset.

**Architecture:** Keep the existing Spring AI annotation-based MCP components and add only thin wrappers around existing service methods. Prefer JSON-friendly methods; do not add MCP tools that require servlet response streaming or raw multipart transport.

**Tech Stack:** Java, Spring Boot, Spring AI MCP annotations, Maven, Flutter asset jar.

---

### Task 1: MCP Tool Coverage

**Files:**
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/ProjectMcpTools.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/EndpointMcpTools.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/FlowMcpTools.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/RunMcpTools.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/ConfigMcpTools.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/main/java/dev/zeann3th/stresspilot/ui/mcp/FunctionMcpTools.java`

- [ ] Remove the `getRunAnalysisDump` MCP method because it returns every request/response log.
- [ ] Add project environment discovery and switching tools.
- [ ] Preserve project-filtered discovery on `listEndpoints(projectId, name)` and `listFlows(projectId, name)`.
- [ ] Add endpoint update.
- [ ] Add flow update and dry-run step.
- [ ] Add config value lookup by one key and multiple keys.
- [ ] Add all-functions list for runtime-visible script functions.

### Task 2: MCP Tests

**Files:**
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/test/java/dev/zeann3th/stresspilot/ui/mcp/McpStreamableIntegrationTest.java`
- Modify: `D:/Workspace/Projects/StressPilot/stresspilot/src/test/java/dev/zeann3th/stresspilot/ui/mcp/RunMcpToolsTest.java`

- [ ] Update tool discovery assertions to require list/read tools and new service methods.
- [ ] Replace the run dump unit test with a reflection assertion that `getRunAnalysisDump` is not MCP-exposed.

### Task 3: Verify and Package

- [ ] Run `.\mvnw.cmd -Dtest=McpStreamableIntegrationTest,RunMcpToolsTest test`.
- [ ] Run `.\mvnw.cmd clean package`.
- [ ] Copy the packaged jar from `target` to `D:/Workspace/Projects/StressPilot/stresspilot_super_app/assets/core/app.jar`.

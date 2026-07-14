# Simulator Edge Light Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the separate simulator light strip with reusable animated edge lighting integrated into the dashboard summary and knowledge title cards.

**Architecture:** Create an `EdgeLightPanel` container that owns only the ArkUI animation and renders caller-provided content through a Builder parameter. Keep `HdsVisualComponent` as an optional background layer, while the ArkUI edge lights are always visible on the emulator.

**Tech Stack:** HarmonyOS API 26, ArkTS, ArkUI, `@kit.UIDesignKit`, Hvigor, Hypium.

---

### Task 1: Create reusable edge-light container

**Files:**
- Create: `entry/src/main/ets/common/components/EdgeLightPanel.ets`
- Remove use of: `entry/src/main/ets/common/components/HdsAccent.ets`

- [ ] Implement a `@BuilderParam content` container with a clipped rounded `Stack`.
- [ ] Add two independently animated 4vp edge segments using blue `#246BFD` and green `#12B76A`.
- [ ] Start animation in `aboutToAppear` and keep HDS behind the visible ArkUI layer.
- [ ] Run `assembleHap`; expect `BUILD SUCCESSFUL`.

### Task 2: Integrate dashboard card

**Files:**
- Modify: `entry/src/main/ets/features/dashboard/DashboardPage.ets`

- [ ] Delete the standalone `HdsAccent({ heightValue: 72 })` row.
- [ ] Wrap the greeting/statistics `SectionBlock` content in `EdgeLightPanel` without changing callbacks or dashboard data.
- [ ] Verify no extra empty space remains above the greeting card.

### Task 3: Integrate knowledge title card

**Files:**
- Modify: `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`

- [ ] Delete the standalone `HdsAccent({ heightValue: 56 })` row.
- [ ] Wrap the existing title/update-time block in `EdgeLightPanel`.
- [ ] Preserve title typography, tags and scroll layout.

### Task 4: Verify on simulator

- [ ] Build the main HAP and ohosTest HAP.
- [ ] Run the four existing Hypium tests; expect four passes and zero failures.
- [ ] Install the main HAP to Pura 90 Pro.
- [ ] Capture the dashboard and knowledge detail screens and confirm blue/green edge motion without text overlap.

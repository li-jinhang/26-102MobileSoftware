# HarmonyOS A Capabilities Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute this plan task-by-task with verification after each task.

**Goal:** Add a real desktop service card, album-based OCR flow, persistent reading typography controls, and HDS visual effects with graceful fallback to the existing A experience line.

**Architecture:** Keep `Index` as the owner of app state. Add focused services for preferences synchronization and OCR, a result page for OCR, a form extension for the desktop card, and a small visual-effect component that never becomes a hard dependency for page startup. Preserve the existing member A/B directory boundaries.

**Tech Stack:** HarmonyOS API 26, ArkTS, ArkUI, `@kit.FormKit`, `@kit.MediaLibraryKit`, `@kit.CoreVisionKit`, `@kit.UIDesignKit`, Preferences, Hvigor, Hypium.

---

### Task 1: Add persistent dashboard and typography state services

**Files:**
- Create: `entry/src/main/ets/common/services/ExperienceStateService.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`

- [ ] Add typed `ReadingWeight` (`standard | semiBold`) and dashboard summary fields to the service.
- [ ] Implement `loadReadingSettings`, `saveReadingSettings`, `saveDashboardSummary`, and `loadDashboardSummary` with Preferences; catch failures and return defaults.
- [ ] Load settings during `Index.aboutToAppear`, save changes when font controls change, and pass both scale and weight to `KnowledgeDetailPage`.
- [ ] Add a second compact font-control row to the existing detail panel and calculate `FontWeight` without changing the existing three size values.
- [ ] Rebuild and verify existing login/dashboard/detail flows compile before continuing.

### Task 2: Add the service-widget extension and card UI

**Files:**
- Create: `entry/src/main/ets/knowledgedashboardform/KnowledgeDashboardForm.ets`
- Create: `entry/src/main/ets/knowledgedashboardform/pages/KnowledgeDashboardFormCard.ets`
- Create: `entry/src/main/resources/base/profile/form_config.json`
- Modify: `entry/src/main/module.json5`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/common/services/ExperienceStateService.ets`

- [ ] Register a `type: "form"` extension with `ohos.extension.form` metadata and a 2x2/2x4 form configuration.
- [ ] Implement `onAddForm` and `onUpdateForm` using `formBindingData` and a JSON summary payload.
- [ ] Render pending count, unread count, recent knowledge title, and a click action using `postCardAction`.
- [ ] Persist a summary after login, notification read changes, favorite/recent changes, and workflow summary refreshes; use defaults when no app session has written data.
- [ ] Build and install; verify the card is registered and can be added from the device desktop service-card picker.

### Task 3: Add album-based OCR service and result page

**Files:**
- Create: `entry/src/main/ets/common/services/OcrService.ets`
- Create: `entry/src/main/ets/features/knowledge/OcrResultPage.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] Add a single-image album picker using `photoAccessHelper.PhotoViewPicker` from `@kit.MediaLibraryKit`; do not add camera permissions.
- [ ] Decode the selected URI into a `PixelMap`, call `textRecognition.recognizeText` from `@kit.CoreVisionKit`, merge text blocks, and extract up to five non-empty keywords.
- [ ] Match extracted keywords against existing article titles, tags, categories, and content; return a typed result with `success`, `text`, `keywords`, `relatedArticleIds`, `previewUri`, and `fallbackReason`.
- [ ] Add a knowledge-page “图片识别” command and route to the result page with loading, success, empty, cancel, and fallback states.
- [ ] Verify selecting an image shows text and related knowledge; verify cancellation returns to the knowledge list and unsupported OCR shows a demo result without crashing.

### Task 4: Add optional HDS visual effect with static fallback

**Files:**
- Create: `entry/src/main/ets/common/components/HdsAccent.ets`
- Modify: `entry/src/main/ets/features/dashboard/DashboardPage.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`

- [ ] Wrap `HdsVisualComponent` behind a small component that catches construction/render failures and exposes the same fixed-height layout in fallback mode.
- [ ] Use a restrained non-gradient static background and border/highlight fallback consistent with the current blue/green palette.
- [ ] Place the component only in the dashboard summary and knowledge detail title area; do not cover controls or text.
- [ ] Verify both supported and unsupported device paths by checking the rendered page and logs.

### Task 5: Regression tests and device verification

**Files:**
- Modify: `entry/src/ohosTest/ets/test/Ability.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets` only if shared test registration requires it.

- [ ] Add pure service tests for dashboard default/fallback state, font settings round-trip behavior, keyword extraction, and article matching.
- [ ] Run the existing Hypium suite and a clean HarmonyOS build.
- [ ] Install the resulting HAP to the selected Pura 90 Pro target.
- [ ] Record manual acceptance steps for card registration, OCR album selection, font persistence, and HDS fallback.

### Task 6: Review and handoff

- [ ] Inspect `git diff` for changes outside member A boundaries.
- [ ] Report any inability to commit caused by the workspace `.git` read-only restriction.
- [ ] Provide the user the exact test sequence and list any features requiring a real supported device.

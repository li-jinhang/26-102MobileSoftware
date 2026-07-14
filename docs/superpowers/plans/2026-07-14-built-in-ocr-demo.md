# Built-in OCR Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an app-bundled Chinese receipt image that can demonstrate the existing OCR and knowledge matching flow without importing media into the emulator.

**Architecture:** Keep photo picking and bundled-resource recognition as separate entry functions, then share one `PixelMap` recognition function. The knowledge page exposes two callbacks and the index page owns navigation and loading feedback.

**Tech Stack:** HarmonyOS ArkTS, ArkUI, ResourceManager, ImageKit, CoreVisionKit, Hypium

---

### Task 1: Shared OCR pipeline

**Files:**
- Modify: `entry/src/main/ets/common/services/OcrService.ets`
- Test: `entry/src/ohosTest/ets/test/Ability.test.ets`

- [x] Add a small test proving the bundled demo text produces reimbursement keywords and matches article `k2`.
- [x] Extract `PixelMap` recognition into a shared helper.
- [x] Add `recognizeBundledDemoImage(context, articles)` that reads media resource `ocr_demo_receipt`, decodes it, and calls the shared helper.
- [x] Preserve the existing explicit fallback result for unsupported OCR, decode failure, and empty text.

### Task 2: Bundled receipt asset

**Files:**
- Create: `entry/src/main/resources/base/media/ocr_demo_receipt.png`

- [x] Generate a high-contrast Chinese receipt image containing reimbursement, invoice, amount, date, and reason fields.
- [x] Verify the file exists and has non-zero dimensions.

### Task 3: Two OCR entry points

**Files:**
- Modify: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [x] Replace the single OCR callback with `onSelectOcrImage` and `onUseOcrDemo`.
- [x] Render “从相册选择” as the primary option and “使用内置演示图片” as the secondary option.
- [x] Add separate index handlers that both store `OcrResult` and navigate to `ocrResult`.
- [x] Show an explanatory toast when the bundled demo starts or cannot access host context.

### Task 4: Verification

**Files:**
- Verify: `entry/src/main/ets/common/services/OcrService.ets`
- Verify: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Verify: `entry/src/main/ets/pages/Index.ets`

- [x] Run `hvigorw --mode module -p product=default assembleHap` and expect `BUILD SUCCESSFUL`.
- [x] Run `hvigorw --mode module -p module=entry@ohosTest assembleHap` and expect `BUILD SUCCESSFUL`.
- [ ] On the emulator, open 知识库, tap 使用内置演示图片, and confirm the OCR result page appears with text, keywords, and related knowledge.

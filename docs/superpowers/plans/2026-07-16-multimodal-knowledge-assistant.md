# Multimodal Knowledge Assistant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move text and album-image knowledge search into the workbench assistant, use the configured multimodal LLM for both inputs, and offer manual or AI-prefilled workflow forms without automatic submission.

**Architecture:** The NestJS backend owns the LLM prompt, knowledge grounding, strict JSON normalization, and history persistence through a new authenticated `/assistant/analyze` endpoint. The HarmonyOS app owns image selection/encoding, renders one assistant result model, and maps only validated non-empty draft fields into the existing workflow composer.

**Tech Stack:** HarmonyOS ArkTS/ArkUI, ImageKit, MediaLibraryKit, NestJS 11, Prisma 6, OpenAI-compatible chat completions API, Hypium, TypeScript smoke tests

---

### Task 1: Backend LLM client and strict assistant result parser

**Files:**
- Create: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/src/common/llm-client.ts`
- Create: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/src/common/assistant-result.ts`
- Create: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/scripts/assistant-parser-smoke.ts`
- Modify: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/package.json`
- Modify: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/src/modules/ocr.module.ts`

- [ ] **Step 1: Add the parser smoke test**

Create `scripts/assistant-parser-smoke.ts` with assertions covering a valid leave draft, an invalid workflow ID, unknown knowledge IDs, a negative amount, and malformed JSON:

```ts
import assert from 'node:assert/strict';
import { parseAssistantModelContent } from '../src/common/assistant-result';

const valid = parseAssistantModelContent(
  JSON.stringify({
    answer: '请查看请假制度。',
    recognizedText: '',
    intent: 'leave',
    relatedKnowledgeIds: ['k1', 'missing'],
    recommendedWorkflowId: 'wf1',
    confidence: 0.92,
    formDraft: {
      title: '病假申请', extra: '病假', date: '2026-07-17 14:00-18:00',
      amount: '', reason: '身体不适', attachment: ''
    },
    missingFields: []
  }),
  new Set(['k1']),
  new Set(['wf1', 'wf2', 'wf3', 'wf4'])
);
assert.equal(valid.recommendedWorkflowId, 'wf1');
assert.deepEqual(valid.relatedKnowledgeIds, ['k1']);

const invalid = parseAssistantModelContent(
  '{"answer":"x","intent":"reimbursement","recommendedWorkflowId":"wf999","formDraft":{"amount":"-10"}}',
  new Set(['k1']),
  new Set(['wf1', 'wf2', 'wf3', 'wf4'])
);
assert.equal(invalid.recommendedWorkflowId, '');
assert.equal(invalid.formDraft.amount, '');
assert.throws(() => parseAssistantModelContent('not-json', new Set(), new Set()));
console.log('assistant parser smoke passed');
```

- [ ] **Step 2: Run the smoke test and verify it fails**

Run:

```powershell
cd C:\Users\13241\Desktop\26-103MobileSoftwareBackend
npx ts-node scripts/assistant-parser-smoke.ts
```

Expected: compilation fails because `src/common/assistant-result.ts` does not exist.

- [ ] **Step 3: Implement strict assistant result types and normalization**

Create `src/common/assistant-result.ts` with these exported contracts and behavior:

```ts
export type AssistantIntent =
  | 'knowledge_query' | 'leave' | 'reimbursement' | 'purchase' | 'permission' | 'unknown';

export interface AssistantFormDraft {
  title: string;
  extra: string;
  date: string;
  amount: string;
  reason: string;
  attachment: string;
}

export interface AssistantAnalysisResult {
  answer: string;
  recognizedText: string;
  intent: AssistantIntent;
  relatedKnowledgeIds: string[];
  recommendedWorkflowId: string;
  confidence: number;
  formDraft: AssistantFormDraft;
  missingFields: string[];
}

export function parseAssistantModelContent(
  content: string,
  allowedKnowledgeIds: Set<string>,
  allowedWorkflowIds: Set<string>
): AssistantAnalysisResult;
```

The implementation must extract raw or fenced JSON, clamp confidence to `0..1`, filter IDs against the supplied sets, accept only the six intent values, turn a negative or non-numeric amount into an empty string, limit text fields to 4000 characters, and throw `Error('模型未返回合法 JSON')` when no candidate parses.

- [ ] **Step 4: Extract the OpenAI-compatible request into one client**

Create `src/common/llm-client.ts`:

```ts
import { AppException } from './app-exception';
import { HttpStatus } from '@nestjs/common';

export interface LlmMessage { role: 'system' | 'user'; content: unknown; }

export async function requestLlmJson(messages: LlmMessage[]): Promise<string> {
  const baseUrl = (process.env.LLM_BASE_URL ?? '').replace(/\/$/, '');
  const apiKey = process.env.LLM_API_KEY ?? '';
  const model = process.env.LLM_MODEL ?? '';
  if (!baseUrl || !apiKey || !model) {
    throw new AppException(1007, '大模型服务尚未配置', HttpStatus.SERVICE_UNAVAILABLE);
  }
  const response = await fetch(`${baseUrl}/chat/completions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
    body: JSON.stringify({ model, temperature: 0, response_format: { type: 'json_object' }, messages })
  });
  if (!response.ok) {
    throw new AppException(1007, `大模型请求失败: HTTP ${response.status}`, HttpStatus.BAD_GATEWAY);
  }
  const payload = await response.json() as {
    choices?: Array<{ message?: { content?: string | Array<{ text?: string }> } }>;
  };
  const content = payload.choices?.[0]?.message?.content;
  return typeof content === 'string'
    ? content
    : Array.isArray(content) ? content.map((item) => item.text ?? '').join('') : '';
}
```

Refactor `ocr.module.ts` to call `requestLlmJson()` while preserving `/ocr/recognize` request and response behavior.

- [ ] **Step 5: Add and run the backend checks**

Add to `package.json`:

```json
"test:assistant": "ts-node scripts/assistant-parser-smoke.ts"
```

Run:

```powershell
npm run test:assistant
npm run build
```

Expected: `assistant parser smoke passed` and TypeScript exits with code `0`.

### Task 2: Authenticated multimodal assistant endpoint

**Files:**
- Modify: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/src/modules/assistant.module.ts`
- Modify: `C:/Users/13241/Desktop/26-103MobileSoftwareBackend/scripts/assistant-parser-smoke.ts`

- [ ] **Step 1: Define the request DTO and endpoint contract**

Replace the question-only DTO with:

```ts
class AnalyzeAssistantDto {
  @IsOptional() @IsString() text = '';
  @IsOptional() @IsString() imageBase64 = '';
  @IsOptional() @IsIn(['', 'image/jpeg', 'image/png']) imageMimeType = '';
}
```

Reject requests where both trimmed text and image are empty. Reject base64 bodies longer than `8_000_000` characters. Keep `/assistant/ask` temporarily as a text-only compatibility wrapper and add authenticated `POST /assistant/analyze`.

- [ ] **Step 2: Build grounded context from Prisma**

In `AssistantService.analyze`, query published `KnowledgeArticle` rows and all `WorkflowTemplate` rows. Build compact plain objects containing only IDs, names/titles, summaries/descriptions, tags, related IDs, risk hints, and the article content required to answer the question. Parse JSON columns with `parseJsonArray`.

- [ ] **Step 3: Call the model once for text or image**

Use one system prompt that requires the exact `AssistantAnalysisResult` keys, the six intent values, and only IDs found in the supplied context. The user message must contain plain text for text-only requests and this content array for image requests:

```ts
[
  { type: 'text', text: text || '读取图片并回答与公司知识或流程相关的问题。' },
  { type: 'image_url', image_url: { url: `data:${imageMimeType};base64,${imageBase64}` } }
]
```

Parse the response through `parseAssistantModelContent`. If no valid workflow remains after validation, clear the form draft and missing fields.

- [ ] **Step 4: Persist a controlled history row**

Store the original text, or `图片查询：${recognizedText.slice(0, 120)}` when text is empty. Continue storing answer, validated knowledge IDs, validated workflow ID, and formatted time in the existing `AssistantHistory` table. Do not store image base64.

- [ ] **Step 5: Run backend verification**

Run:

```powershell
npm run test:assistant
npm run build
```

With the backend running, authenticate and exercise both requests. Expected: envelope `code: 0`, strict result fields, and no Markdown outside JSON.

### Task 3: Frontend assistant transport and album encoding

**Files:**
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/domain/contracts/AppRepositories.ets`
- Modify: `entry/src/main/ets/http/adapters/HttpRepositories.ets`
- Modify: `entry/src/main/ets/app/usecases/AssistantUseCases.ets`
- Modify: `entry/src/main/ets/common/services/ApiClient.ets`
- Create: `entry/src/main/ets/common/services/AssistantMediaService.ets`

- [ ] **Step 1: Add shared frontend models**

Extend `AppModels.ets` with matching `AssistantIntent`, `AssistantFormDraft`, and `AssistantReply` fields from Task 1. Add:

```ts
export interface AssistantAnalyzeInput {
  text: string;
  imageBase64: string;
  imageMimeType: string;
}

export interface AssistantSelectedImage {
  previewUri: string;
  imageBase64: string;
  imageMimeType: string;
}
```

- [ ] **Step 2: Change the repository contract and HTTP adapter**

Replace `AssistantRepository.ask(question)` with:

```ts
analyze(input: AssistantAnalyzeInput): Promise<AssistantReply>;
```

Post the JSON body to `/assistant/analyze`. Extend `apiPost` with an optional read-timeout argument and use `60_000` milliseconds only for assistant analysis; preserve the default `15_000` milliseconds for other requests.

- [ ] **Step 3: Add album selection and JPEG encoding**

Implement `selectAssistantImage(): Promise<AssistantSelectedImage | null>` in `AssistantMediaService.ets` using `PhotoViewPicker`, `fileIo.openSync`, `ImageKit.createImageSource`, `createPixelMap`, `image.createImagePacker().packing(... quality: 80)`, and `Base64Helper`. Return `null` only when the picker is cancelled, and always close the opened file in `finally`.

- [ ] **Step 4: Update the use case**

Change `askAssistantUseCase` to accept `AssistantAnalyzeInput`. Reject only when both trimmed text and image are empty. Call `repositories.assistantRepository.analyze(input)`. For image-only history, use the recognized-text prefix or `图片查询`; preserve the existing newest-first history behavior.

- [ ] **Step 5: Compile the main HAP to expose type errors**

Run:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default assembleHap
```

Expected: `BUILD SUCCESSFUL`.

### Task 4: Unified assistant UI and knowledge-page relocation

**Files:**
- Modify: `entry/src/main/ets/features/assistant/AssistantPage.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Remove only search controls from KnowledgePage**

Delete `searchKeyword`, the search input, album button, bundled-demo button, and OCR callbacks. Keep `selectedCategoryId`, category chips, `getResults()` filtered by category, knowledge cards, favorite state, and empty-state recovery.

- [ ] **Step 2: Add assistant input state and callbacks**

Add selected image, loading state, `onSelectImage`, `onClearImage`, `onAnalyze`, `onOpenWorkflowWithoutDraft`, and `onOpenWorkflowWithDraft` props/callbacks. Use a stable input section containing a multiline text area, album icon/button, image preview, clear-image action, and one send button disabled while loading or when both inputs are empty.

- [ ] **Step 3: Render the structured result**

When a result exists, render recognized text only for image input, the answer, related knowledge cards, missing-field text, and a workflow action area only when `recommendedWorkflowId` matches a loaded template. Use two clearly separate buttons: `打开表单` and `智能预填`.

- [ ] **Step 4: Orchestrate image selection and analysis in Index**

Add `assistantSelectedImage` and `assistantLoading` state. `handleAssistantImageSelect` calls `selectAssistantImage`; `handleAssistantAnalyze` calls the updated use case with text plus optional base64 and clears the image only after a successful response. Logout clears image, reply, and loading state.

- [ ] **Step 5: Remove the old OCR navigation entry points**

Remove OCR callbacks passed to `KnowledgePage` and remove the now-unreachable `ocrResult` navigation branch and handlers from `Index`. Keep `OcrService.ets`, `/ocr/recognize`, and their regression tests because the API remains a supported backend capability.

- [ ] **Step 6: Build the HAP**

Run the main HAP build command from Task 3. Expected: `BUILD SUCCESSFUL`.

### Task 5: Safe workflow draft prefill

**Files:**
- Modify: `entry/src/main/ets/app/usecases/WorkflowFormStateUseCases.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/ohosTest/ets/test/Ability.test.ets`

- [ ] **Step 1: Add failing draft-mapping tests**

Add Hypium tests that call `buildStartWorkflowStateUseCase('wf2', draft)` and assert supplied title, amount, and reason override defaults while empty date and attachment fields do not invent values. Add a second test confirming `buildOpenWorkflowComposerStateUseCase('wf2')` retains the current default behavior.

- [ ] **Step 2: Implement non-empty draft mapping**

Change the start function signature to:

```ts
export function buildStartWorkflowStateUseCase(
  templateId: string,
  draft?: AssistantFormDraft
): WorkflowFormState
```

Build the existing template defaults first, then overwrite each form field only when the corresponding trimmed draft value is non-empty. Do not change `approvalComment`, active tab, risk logic, submit logic, or security confirmation logic.

- [ ] **Step 3: Wire the two assistant actions**

In `Index`, map `打开表单` to `openWorkflowComposer(templateId)` and `智能预填` to `startWorkflow(templateId, draft)`. Both actions only open the existing composer; neither calls `handleCreateWorkflow`.

- [ ] **Step 4: Compile the test HAP**

Run:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap
```

Expected: `BUILD SUCCESSFUL`.

### Task 6: End-to-end verification and deployment handoff

**Files:**
- Verify both repositories and simulator behavior

- [ ] **Step 1: Run all automated checks**

Backend:

```powershell
cd C:\Users\13241\Desktop\26-103MobileSoftwareBackend
npm run test:assistant
npm run build
```

Frontend: build main and ohosTest HAPs. Expected: all four commands exit `0`.

- [ ] **Step 2: Verify backend deployment configuration**

Confirm the server `.env` still defines `LLM_BASE_URL`, `LLM_API_KEY`, and `LLM_MODEL`. Deploy with the project's existing `npm ci`, Prisma generation/migration/seed, build, and start process. Never commit `.env` or print the API key.

- [ ] **Step 3: Run simulator acceptance**

Verify these cases:

1. Knowledge tab shows category browsing but no search or image buttons.
2. Text `报销打车费需要什么材料` returns an LLM answer and related reimbursement knowledge.
3. Text `我明天下午身体不舒服，要请病假去医院` recommends leave; `打开表单` does not apply model fields; `智能预填` fills known fields.
4. Album receipt image returns recognized text and recommends reimbursement.
5. Missing information remains editable and does not auto-submit.
6. Invalid or unavailable LLM response shows a controlled error and does not navigate.
7. Existing manual workflow submission, approval, OCR backend endpoint, login, attendance, mail, and knowledge detail remain functional.

- [ ] **Step 4: Review Git scope before any commit**

Frontend changes must contain only the confirmed assistant/knowledge/workflow work plus this spec and plan. Backend changes must contain only the shared LLM client, assistant endpoint, OCR client refactor, parser smoke test, and package script. Do not stage `.env`, build output, `node_modules`, HAP files, or unrelated user changes.

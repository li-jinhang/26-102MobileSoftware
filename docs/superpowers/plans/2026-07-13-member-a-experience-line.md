# Member A Experience Line Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete member A dashboard, knowledge, assistant, messages, profile, and HarmonyOS reading experience without changing member B's workflow state machine.

**Architecture:** Keep `Index.ets` as the application shell and A/B integration point. Move A-owned UI into focused feature components and move filter, assistant, and notification behavior into pure services covered by Hypium unit tests. Connect A to B only through template IDs, todo counts, and callbacks.

**Tech Stack:** HarmonyOS API 26, ArkTS, ArkUI, Hypium, Hvigor, DevEco Studio.

---

## File Map

- Modify `entry/src/main/ets/models/AppModels.ets`: add A-owned navigation, reading, feedback, correction, and notification target types.
- Modify `entry/src/main/ets/mock/MockData.ets`: add target metadata and expose mock data compatible with the new services.
- Create `entry/src/main/ets/common/services/KnowledgeService.ets`: published filtering, combined search, correction validation, and workflow-related lookup.
- Create `entry/src/main/ets/common/services/AssistantService.ets`: deterministic assistant matching with empty-input handling.
- Create `entry/src/main/ets/common/services/MessageService.ets`: role filtering, unread filtering, and immutable read-state updates.
- Create `entry/src/main/ets/common/components/SectionBlock.ets`: shared unframed section container.
- Create `entry/src/main/ets/common/components/KnowledgeCard.ets`: reusable knowledge result card.
- Create `entry/src/main/ets/common/components/EmptyState.ets`: stable empty-state component.
- Create `entry/src/main/ets/features/dashboard/DashboardPage.ets`: A-owned workbench content.
- Create `entry/src/main/ets/features/knowledge/KnowledgePage.ets`: category and keyword search surface.
- Create `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`: reading, favorite, useful feedback, correction, and related workflow surface.
- Create `entry/src/main/ets/features/assistant/AssistantPage.ets`: simulated Agent/Skill experience and history.
- Create `entry/src/main/ets/features/messages/MessagesPage.ets`: all/unread filter, mark-read, and target navigation.
- Create `entry/src/main/ets/features/profile/ProfilePage.ets`: profile, permissions, favorites, messages, and reading preference.
- Modify `entry/src/main/ets/pages/Index.ets`: remove A-owned builders, mount new feature components, and preserve B-owned workflow builders and actions.
- Modify `entry/src/test/LocalUnit.test.ets`: replace template assertion with service behavior tests.

## Task 1: Extend Shared Models and Mock Data

**Files:**
- Modify: `entry/src/main/ets/models/AppModels.ets`
- Modify: `entry/src/main/ets/mock/MockData.ets`

- [ ] **Step 1: Add A-owned shared types**

Append these definitions to `AppModels.ets` and extend `NotificationItem` with `targetType` and `targetId`:

```ts
export type AppSubPage = 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
export type ReadingFontScale = 'small' | 'standard' | 'large';
export type NotificationTargetType = 'knowledge' | 'workflow' | 'none';

export interface KnowledgeCorrection {
  id: string;
  articleId: string;
  userId: string;
  content: string;
  createTime: string;
}

export interface NotificationItem {
  id: string;
  title: string;
  content: string;
  time: string;
  read: boolean;
  targetRoles: UserRole[];
  targetType: NotificationTargetType;
  targetId: string;
}
```

- [ ] **Step 2: Add message target metadata to every mock notification**

Use these mappings in `MockData.ets`:

```ts
// n1: approval todo
targetType: 'workflow',
targetId: 'i1'

// n2: workflow progress
targetType: 'workflow',
targetId: 'i2'

// n3: knowledge update
targetType: 'knowledge',
targetId: 'k4'

// n4: informational admin reminder
targetType: 'none',
targetId: ''
```

Update `cloneNotification` to copy both fields.

- [ ] **Step 3: Build to catch model mismatches**

Run:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --mode module -p product=default -p module=entry@default -p buildMode=debug --no-daemon
```

Expected: build reaches ArkTS compilation. Any missing `targetType` or `targetId` field is fixed before continuing.

- [ ] **Step 4: Commit the model contract**

```powershell
git add entry/src/main/ets/models/AppModels.ets entry/src/main/ets/mock/MockData.ets
git commit -m "feat: extend member A data contracts"
```

## Task 2: Build Pure A-owned Services Test-first

**Files:**
- Create: `entry/src/main/ets/common/services/KnowledgeService.ets`
- Create: `entry/src/main/ets/common/services/AssistantService.ets`
- Create: `entry/src/main/ets/common/services/MessageService.ets`
- Modify: `entry/src/test/LocalUnit.test.ets`

- [ ] **Step 1: Replace the template test with failing knowledge tests**

Add imports and assertions:

```ts
import { describe, it, expect } from '@ohos/hypium';
import { KnowledgeArticle, NotificationItem } from '../main/ets/models/AppModels';
import {
  filterPublishedArticles,
  searchKnowledge,
  validateCorrection
} from '../main/ets/common/services/KnowledgeService';
import { buildAssistantReply } from '../main/ets/common/services/AssistantService';
import {
  filterNotifications,
  markNotificationRead
} from '../main/ets/common/services/MessageService';

export default function localUnitTest() {
  describe('memberAServiceTest', () => {
    const published: KnowledgeArticle = {
      id: 'k1', title: '差旅报销制度', summary: '发票规范', content: '正文',
      categoryId: 'c2', categoryName: '财务报销', tags: ['报销'],
      updateTime: '2026-07-13', version: 'v1.0', status: 'published',
      attachments: [], relatedWorkflowIds: ['wf2']
    };
    const removed: KnowledgeArticle = {
      id: 'k2', title: '旧制度', summary: '旧内容', content: '正文',
      categoryId: 'c2', categoryName: '财务报销', tags: ['废止'],
      updateTime: '2026-07-01', version: 'v0.9', status: 'removed',
      attachments: [], relatedWorkflowIds: []
    };

    it('filters non-published knowledge', 0, () => {
      expect(filterPublishedArticles([published, removed]).length).assertEqual(1);
    });

    it('combines category and keyword search', 0, () => {
      expect(searchKnowledge([published, removed], 'c2', ' 发票 ').length).assertEqual(1);
      expect(searchKnowledge([published, removed], 'c1', '发票').length).assertEqual(0);
    });

    it('validates correction text', 0, () => {
      expect(validateCorrection('   ')).assertEqual('');
      expect(validateCorrection(' 日期已经过期 ')).assertEqual('日期已经过期');
    });

    it('rejects empty assistant input', 0, () => {
      expect(buildAssistantReply('   ')).assertNull();
      expect(buildAssistantReply('打车费怎么报销')?.recommendedWorkflowId).assertEqual('wf2');
    });

    it('filters unread messages and marks one read immutably', 0, () => {
      const message: NotificationItem = {
        id: 'n1', title: '更新', content: '内容', time: '现在', read: false,
        targetRoles: ['employee'], targetType: 'knowledge', targetId: 'k1'
      };
      expect(filterNotifications([message], true).length).assertEqual(1);
      expect(markNotificationRead([message], 'n1')[0].read).assertTrue();
      expect(message.read).assertFalse();
    });
  });
}
```

- [ ] **Step 2: Verify the tests cannot compile before services exist**

Open `entry/src/test/LocalUnit.test.ets` in DevEco Studio and run `memberAServiceTest`.

Expected: imports fail because the three service files do not exist.

- [ ] **Step 3: Implement `KnowledgeService.ets`**

```ts
import { KnowledgeArticle } from '../../models/AppModels';

export function filterPublishedArticles(articles: KnowledgeArticle[]): KnowledgeArticle[] {
  return articles.filter((item: KnowledgeArticle) => item.status === 'published');
}

export function searchKnowledge(
  articles: KnowledgeArticle[],
  categoryId: string,
  keyword: string
): KnowledgeArticle[] {
  const normalized: string = keyword.trim().toLowerCase();
  return filterPublishedArticles(articles).filter((item: KnowledgeArticle) => {
    const categoryMatched: boolean = categoryId === 'all' || item.categoryId === categoryId;
    const text: string = `${item.title} ${item.summary} ${item.categoryName} ${item.tags.join(' ')}`.toLowerCase();
    return categoryMatched && (normalized.length === 0 || text.includes(normalized));
  });
}

export function validateCorrection(content: string): string {
  return content.trim();
}

export function findArticle(articles: KnowledgeArticle[], articleId: string): KnowledgeArticle | null {
  const item: KnowledgeArticle | undefined = articles.find((article: KnowledgeArticle) => article.id === articleId);
  return item === undefined ? null : item;
}

export function getKnowledgeByWorkflowType(
  articles: KnowledgeArticle[],
  workflowId: string
): KnowledgeArticle[] {
  return filterPublishedArticles(articles).filter((item: KnowledgeArticle) => item.relatedWorkflowIds.includes(workflowId));
}
```

- [ ] **Step 4: Implement `AssistantService.ets`**

Move the existing keyword cases from `MockData.ets` into `buildAssistantReply` and return `null` for trimmed empty input:

```ts
import { AssistantReply } from '../../models/AppModels';

export function buildAssistantReply(question: string): AssistantReply | null {
  const keyword: string = question.trim();
  if (keyword.length === 0) {
    return null;
  }
  if (keyword.includes('报销') || keyword.includes('打车') || keyword.includes('发票')) {
    return {
      answer: '根据《差旅报销制度》，报销需上传发票、行程截图和事由说明。你可以直接发起“报销申请”。',
      relatedKnowledgeIds: ['k2'],
      recommendedWorkflowId: 'wf2'
    };
  }
  if (keyword.includes('请假') || keyword.includes('病假') || keyword.includes('年假')) {
    return {
      answer: '请假前建议先查看《请假制度说明》，确认请假类型和材料要求，然后发起“请假申请”。',
      relatedKnowledgeIds: ['k1'],
      recommendedWorkflowId: 'wf1'
    };
  }
  if (keyword.includes('权限') || keyword.includes('账号') || keyword.includes('系统')) {
    return {
      answer: '系统权限开通需要说明业务场景、系统名称和期限范围，建议先阅读《系统权限申请规范》并发起“权限申请”。',
      relatedKnowledgeIds: ['k4'],
      recommendedWorkflowId: 'wf4'
    };
  }
  if (keyword.includes('采购') || keyword.includes('预算') || keyword.includes('合同')) {
    return {
      answer: '采购流程需补充用途、预算和期望到货时间，可参考《采购申请规范》后发起“采购申请”。',
      relatedKnowledgeIds: ['k3'],
      recommendedWorkflowId: 'wf3'
    };
  }
  return {
    answer: '暂未找到完全匹配的制度，下面是可能相关的知识。',
    relatedKnowledgeIds: ['k1', 'k2'],
    recommendedWorkflowId: ''
  };
}
```

- [ ] **Step 5: Implement `MessageService.ets`**

```ts
import { NotificationItem, UserRole } from '../../models/AppModels';

export function getRoleNotifications(items: NotificationItem[], role: UserRole): NotificationItem[] {
  return items.filter((item: NotificationItem) => item.targetRoles.includes(role));
}

export function filterNotifications(items: NotificationItem[], unreadOnly: boolean): NotificationItem[] {
  return unreadOnly ? items.filter((item: NotificationItem) => !item.read) : items;
}

export function markNotificationRead(items: NotificationItem[], notificationId: string): NotificationItem[] {
  return items.map((item: NotificationItem) => ({
    id: item.id,
    title: item.title,
    content: item.content,
    time: item.time,
    read: item.id === notificationId ? true : item.read,
    targetRoles: item.targetRoles.slice(),
    targetType: item.targetType,
    targetId: item.targetId
  }));
}
```

- [ ] **Step 6: Run service tests and build**

Run `memberAServiceTest` from DevEco Studio.

Expected: five tests pass.

Then run the Hvigor `assembleHap` command from Task 1.

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 7: Commit services and tests**

```powershell
git add entry/src/main/ets/common/services entry/src/test/LocalUnit.test.ets entry/src/main/ets/mock/MockData.ets
git commit -m "test: cover member A service behavior"
```

## Task 3: Create Shared ArkUI Components

**Files:**
- Create: `entry/src/main/ets/common/components/SectionBlock.ets`
- Create: `entry/src/main/ets/common/components/KnowledgeCard.ets`
- Create: `entry/src/main/ets/common/components/EmptyState.ets`

- [ ] **Step 1: Extract `SectionBlock` from `Index.ets`**

Create an exported component with `title`, `subtitle`, and `@BuilderParam content`. Preserve the existing 16 px padding and replace the 22 px radius with an 8 px radius to keep operational surfaces restrained.

```ts
@Component
export struct SectionBlock {
  title: string = '';
  subtitle: string = '';
  @BuilderParam content: () => void = this.defaultBuilder;

  @Builder
  private defaultBuilder() {}

  build() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1F2A44').width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle).fontSize(12).fontColor('#667085').lineHeight(18).width('100%')
        }
      }.alignItems(HorizontalAlign.Start)
      this.content()
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
```

- [ ] **Step 2: Create `KnowledgeCard`**

The component receives a `KnowledgeArticle`, favorite state, and open callback. It renders title, summary, category, tags, update time, and a compact favorite indicator with fixed minimum height.

```ts
import { KnowledgeArticle } from '../../models/AppModels';

@Component
export struct KnowledgeCard {
  article: KnowledgeArticle;
  favorite: boolean = false;
  onOpen: (articleId: string) => void = () => {};

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.article.title).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1F2A44').layoutWeight(1)
        Text(this.favorite ? '已收藏' : this.article.categoryName)
          .fontSize(11).fontColor(this.favorite ? '#B54708' : '#175CD3')
      }
      Text(this.article.summary).fontSize(12).fontColor('#667085').lineHeight(18).maxLines(2).width('100%')
      Text(`${this.article.tags.join(' / ')} · ${this.article.updateTime}`)
        .fontSize(11).fontColor('#98A2B3').width('100%')
    }
    .width('100%').constraintSize({ minHeight: 104 }).padding(14)
    .backgroundColor('#F8FAFC').borderRadius(8)
    .onClick(() => this.onOpen(this.article.id))
  }
}
```

- [ ] **Step 3: Create `EmptyState`**

```ts
@Component
export struct EmptyState {
  title: string = '暂无内容';
  description: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {};

  build() {
    Column({ space: 8 }) {
      Text('○').fontSize(30).fontColor('#98A2B3')
      Text(this.title).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#344054')
      if (this.description.length > 0) {
        Text(this.description).fontSize(12).fontColor('#667085').textAlign(TextAlign.Center)
      }
      if (this.actionLabel.length > 0) {
        Button(this.actionLabel).height(36).fontSize(12).borderRadius(8)
          .onClick(() => this.onAction())
      }
    }.width('100%').padding({ top: 24, bottom: 24 })
  }
}
```

- [ ] **Step 4: Build and commit shared components**

Run the Task 1 Hvigor build command. Expected: `BUILD SUCCESSFUL`.

```powershell
git add entry/src/main/ets/common/components
git commit -m "feat: add shared member A components"
```

## Task 4: Implement Knowledge Search and Detail

**Files:**
- Create: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Create: `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`

- [ ] **Step 1: Build `KnowledgePage` state and filtering**

The page receives categories, articles, favorites, and `onOpenArticle`. It owns `selectedCategoryId` and `searchKeyword`, calls `searchKnowledge`, and renders `EmptyState` when the result is empty.

Required component contract:

```ts
@Component
export struct KnowledgePage {
  categories: KnowledgeCategory[];
  articles: KnowledgeArticle[];
  favoriteKnowledgeIds: string[];
  onOpenArticle: (articleId: string) => void = () => {};
  @State selectedCategoryId: string = 'all';
  @State searchKeyword: string = '';
}
```

The clear action must assign both `selectedCategoryId = 'all'` and `searchKeyword = ''`.

- [ ] **Step 2: Build `KnowledgeDetailPage` interaction contract**

Use this component contract:

```ts
@Component
export struct KnowledgeDetailPage {
  article: KnowledgeArticle;
  favorite: boolean = false;
  useful: boolean = false;
  fontScale: ReadingFontScale = 'standard';
  workflowNames: string = '';
  onBack: () => void = () => {};
  onToggleFavorite: (articleId: string) => void = () => {};
  onMarkUseful: (articleId: string) => void = () => {};
  onSubmitCorrection: (articleId: string, content: string) => boolean = () => false;
  onFontScaleChange: (scale: ReadingFontScale) => void = () => {};
  onStartWorkflow: (templateId: string) => void = () => {};
  @State correctionText: string = '';
}
```

Map font scale to body size with `small = 14`, `standard = 16`, and `large = 19`. Render the related workflow button only when `article.relatedWorkflowIds.length > 0`. On successful correction submission, clear `correctionText`.

- [ ] **Step 3: Add empty and error feedback**

Use the API 26 UI context instead of the deprecated global prompt API:

```ts
private showMessage(message: string): void {
  try {
    this.getUIContext().getPromptAction().showToast({ message: message });
  } catch (error) {
    console.error(`KnowledgeDetailPage toast failed: ${error}`);
  }
}
```

Call it for empty correction text and successful submission. Do not substitute `wf1` when an article has no related workflow.

- [ ] **Step 4: Build and commit knowledge pages**

Run the Task 1 Hvigor build command. Expected: `BUILD SUCCESSFUL`.

```powershell
git add entry/src/main/ets/features/knowledge
git commit -m "feat: add knowledge search and reading experience"
```

## Task 5: Implement Dashboard, Assistant, Messages, and Profile

**Files:**
- Create: `entry/src/main/ets/features/dashboard/DashboardPage.ets`
- Create: `entry/src/main/ets/features/assistant/AssistantPage.ets`
- Create: `entry/src/main/ets/features/messages/MessagesPage.ets`
- Create: `entry/src/main/ets/features/profile/ProfilePage.ets`

- [ ] **Step 1: Create `DashboardPage`**

Use props for current user, published knowledge, recent knowledge, favorite knowledge, visible notifications, workflow templates, and todo count. Expose callbacks for article, assistant, messages, and workflow navigation.

The layout must include fixed-size statistic cards, a four-item workflow grid, assistant entry, recent knowledge, favorites, and the latest three messages.

- [ ] **Step 2: Create `AssistantPage`**

Use this state contract:

```ts
@Component
export struct AssistantPage {
  articles: KnowledgeArticle[];
  templates: WorkflowTemplate[];
  @Link history: AssistantHistory[];
  onBack: () => void = () => {};
  onOpenArticle: (articleId: string) => void = () => {};
  onStartWorkflow: (templateId: string) => void = () => {};
  @State question: string = '';
  @State reply: AssistantReply | null = null;
}
```

On submit, call `buildAssistantReply`. If it returns `null`, show a toast and do not mutate history. Otherwise prepend one complete `AssistantHistory` item, show related knowledge cards, and show the workflow button only when the recommended ID exists in `templates`.

- [ ] **Step 3: Create `MessagesPage`**

Use an `@State unreadOnly` toggle and callbacks `onMarkRead`, `onOpenKnowledge`, and `onOpenWorkflow`. Opening a message marks it read first. A missing target invokes a toast instead of a fallback route.

- [ ] **Step 4: Create `ProfilePage`**

Render user name, department, role, permissions, favorite knowledge, unread count, reading font segmented control, message entry, and logout. Expose `onOpenArticle`, `onOpenMessages`, `onFontScaleChange`, and `onLogout` callbacks.

- [ ] **Step 5: Build and commit A feature pages**

Run the Task 1 Hvigor build command. Expected: `BUILD SUCCESSFUL`.

```powershell
git add entry/src/main/ets/features/dashboard entry/src/main/ets/features/assistant entry/src/main/ets/features/messages entry/src/main/ets/features/profile
git commit -m "feat: add member A dashboard and utility pages"
```

## Task 6: Integrate A Pages in `Index.ets` Without Rewriting B

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Add imports and A-owned state**

Import all new pages and services. Add:

```ts
@State activeSubPage: AppSubPage = 'none';
@State usefulKnowledgeIds: string[] = [];
@State corrections: KnowledgeCorrection[] = [];
@State readingFontScale: ReadingFontScale = 'standard';
```

- [ ] **Step 2: Replace A builders with feature components**

Mount `DashboardPage`, `KnowledgePage`, and `ProfilePage` for tabs 0, 1, and 3. Leave `WorkflowTab`, `WorkflowCard`, `startWorkflow`, and `handleWorkflowDecision` functionally unchanged.

When `activeSubPage` is not `none`, render the matching `KnowledgeDetailPage`, `AssistantPage`, or `MessagesPage` instead of the selected tab.

- [ ] **Step 3: Implement A state handlers**

Implement exact behavior:

```ts
private markKnowledgeUseful(articleId: string): void {
  if (!this.usefulKnowledgeIds.includes(articleId)) {
    this.usefulKnowledgeIds = [articleId, ...this.usefulKnowledgeIds];
  }
}

private submitCorrection(articleId: string, content: string): boolean {
  const normalized: string = validateCorrection(content);
  if (normalized.length === 0 || this.currentUser === null) {
    return false;
  }
  const correction: KnowledgeCorrection = {
    id: `correction-${Date.now()}`,
    articleId: articleId,
    userId: this.currentUser.id,
    content: normalized,
    createTime: '刚刚'
  };
  this.corrections = [correction, ...this.corrections];
  return true;
}
```

Use `markNotificationRead` for message state. Use `findArticle` before opening a knowledge target. For a workflow message target, clear the A subpage, set `activeTab = 2`, and show a non-blocking “已进入流程页面” message through `this.getUIContext().getPromptAction()`. This calls B's existing surface without altering workflow state.

- [ ] **Step 4: Reset user-scoped state on login and logout**

After login, initialize favorites from the cloned user and clear subpage, useful feedback, corrections, assistant history, and temporary inputs. Logout clears `currentUser`, `activeSubPage`, and all A-owned transient state.

- [ ] **Step 5: Delete duplicated A-only builders and helpers**

Remove the old `SectionBlock`, `WorkbenchTab`, `KnowledgeTab`, `ProfileTab`, `ArticlePreview`, assistant handler, and duplicated A filtering helpers only after the new components compile. Preserve B-owned workflow helpers and shared login logic.

- [ ] **Step 6: Build and perform regression checks**

Run the Task 1 Hvigor build command.

Expected: `BUILD SUCCESSFUL`, with no unresolved imports or ArkTS state decorator errors.

Verify `WorkflowTab`, workflow creation, and approval functions remain present using:

```powershell
rg -n "WorkflowTab|startWorkflow|handleWorkflowDecision|WorkflowCard" entry/src/main/ets/pages/Index.ets
```

Expected: all four identifiers remain.

- [ ] **Step 7: Commit integration**

```powershell
git add entry/src/main/ets/pages/Index.ets
git commit -m "refactor: integrate member A feature boundary"
```

## Task 7: DevEco Studio Runtime Verification and Final Audit

**Files:**
- Modify only files required to fix observed build or runtime defects.

- [ ] **Step 1: Run a clean debug build**

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' clean --mode module -p product=default -p module=entry@default -p buildMode=debug --no-daemon
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --mode module -p product=default -p module=entry@default -p buildMode=debug --no-daemon
```

Expected: `BUILD SUCCESSFUL` and a debug HAP under `entry/build/default/outputs/default/`.

- [ ] **Step 2: Open and run the project in DevEco Studio**

Use DevEco Studio to sync the project, select an available emulator or connected device, and run the `entry` module.

If a Huawei account, signing confirmation, emulator download, device unlock, or USB authorization prompt appears, pause and tell the user the exact one-time action required.

- [ ] **Step 3: Execute the A acceptance path**

Verify:

1. `employee01 / 123456` opens the dashboard.
2. Search `发票` and open 《差旅报销制度》.
3. Change reading size, favorite the article, mark useful, and submit `日期或额度需要更新`.
4. Ask `报销打车费需要什么材料` and open the related knowledge.
5. Return to the assistant and trigger the recommended reimbursement workflow.
6. Open messages, show unread only, and mark a message read.
7. Open “我的” and confirm favorite and unread counts.
8. Log out, log in as `manager01`, and verify the workflow tab still opens.

- [ ] **Step 4: Audit implementation against the specification**

Check every item in `docs/superpowers/specs/2026-07-13-member-a-experience-line-design.md`. Record any unsupported system feature as an environment dependency, not as completed functionality.

- [ ] **Step 5: Commit runtime fixes and final documentation state**

```powershell
git add entry docs/superpowers
git commit -m "fix: complete member A runtime verification"
```

Expected: clean worktree and all member A acceptance items verified, except any explicitly reported account, signing, emulator, or device action that only the user can authorize.

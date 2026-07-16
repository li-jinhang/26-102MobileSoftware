import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import {
  createOcrFallback,
  extractOcrKeywords,
  matchOcrArticles,
  OCR_DEMO_TEXT
} from '../../../main/ets/common/services/OcrService';
import { getMockArticles } from '../../../main/ets/mock/MockData';
import {
  buildOpenWorkflowComposerStateUseCase,
  buildStartWorkflowStateUseCase,
  WorkflowFormState
} from '../../../main/ets/app/usecases/WorkflowFormStateUseCases';
import { AssistantFormDraft } from '../../../main/ets/models/AppModels';

export default function abilityTest() {
  describe('ActsAbilityTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('assertContain', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
      let a = 'abc';
      let b = 'b';
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    })

    it('extractOcrKeywords', 0, () => {
      const keywords: string[] = extractOcrKeywords('差旅报销需要发票和行程截图');
      expect(keywords.includes('报销')).assertTrue();
      expect(keywords.includes('发票')).assertTrue();
    })

    it('matchOcrArticles', 0, () => {
      const articleIds: string[] = matchOcrArticles('差旅报销需要发票', getMockArticles());
      expect(articleIds.includes('k2')).assertTrue();
    })

    it('createOcrFallback', 0, () => {
      const fallback = createOcrFallback(getMockArticles(), 'unsupported');
      expect(fallback.success).assertFalse();
      expect(fallback.text.length > 0).assertTrue();
      expect(fallback.fallbackReason).assertEqual('unsupported');
    })

    it('matchBundledOcrDemo', 0, () => {
      const keywords: string[] = extractOcrKeywords(OCR_DEMO_TEXT);
      const articleIds: string[] = matchOcrArticles(OCR_DEMO_TEXT, getMockArticles());
      expect(keywords.includes('报销')).assertTrue();
      expect(keywords.includes('发票')).assertTrue();
      expect(articleIds.includes('k2')).assertTrue();
    })

    it('prefillWorkflowFromAssistantDraft', 0, () => {
      const draft: AssistantFormDraft = {
        title: '华南差旅报销',
        extra: '差旅',
        date: '',
        amount: '3680',
        reason: '客户现场交通费用',
        attachment: ''
      };
      const state: WorkflowFormState = buildStartWorkflowStateUseCase('wf2', draft);
      expect(state.workflowTitleInput).assertEqual('华南差旅报销');
      expect(state.workflowAmountInput).assertEqual('3680');
      expect(state.workflowReasonInput).assertEqual('客户现场交通费用');
      expect(state.workflowDateInput).assertEqual('');
      expect(state.workflowAttachmentInput).assertEqual('');
    })

    it('openWorkflowKeepsCurrentDefaults', 0, () => {
      const state: WorkflowFormState = buildOpenWorkflowComposerStateUseCase('wf2');
      expect(state.workflowExtraInput.length > 0).assertTrue();
      expect(state.workflowAmountInput.length > 0).assertTrue();
    })
  })
}

export interface WorkflowFormState {
  selectedTemplateId: string;
  activeTab: number;
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
  workflowTitleInput: string;
  workflowExtraInput: string;
  workflowDateInput: string;
  workflowAmountInput: string;
  workflowReasonInput: string;
  workflowAttachmentInput: string;
  approvalComment: string;
}

function buildWorkflowFormDefaults(templateId: string): WorkflowFormState {
  const baseState: WorkflowFormState = {
    selectedTemplateId: templateId,
    activeTab: 2,
    activeSubPage: 'none',
    detailReturnSubPage: 'none',
    workflowTitleInput: '',
    workflowExtraInput: '',
    workflowDateInput: '',
    workflowAmountInput: '',
    workflowReasonInput: '',
    workflowAttachmentInput: '',
    approvalComment: '材料齐全，建议通过。'
  };

  if (templateId === 'wf1') {
    baseState.workflowExtraInput = '年假';
    baseState.workflowDateInput = '2026-07-18 09:00-18:00';
    return baseState;
  }

  if (templateId === 'wf2') {
    baseState.workflowExtraInput = '差旅';
    baseState.workflowAmountInput = '3680';
    return baseState;
  }

  if (templateId === 'wf3') {
    baseState.workflowExtraInput = '会议平板 2 台';
    baseState.workflowAmountInput = '12800';
    baseState.workflowDateInput = '2026-07-20';
    return baseState;
  }

  baseState.workflowExtraInput = '项目看板';
  baseState.workflowDateInput = '2026-07 至 2026-12';
  return baseState;
}

export function buildOpenWorkflowComposerStateUseCase(templateId: string): WorkflowFormState {
  return buildWorkflowFormDefaults(templateId);
}

export function buildStartWorkflowStateUseCase(templateId: string): WorkflowFormState {
  return buildWorkflowFormDefaults(templateId);
}

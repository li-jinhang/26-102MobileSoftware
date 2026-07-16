import { AssistantFormDraft } from '../../models/AppModels';

export interface WorkflowFormState {
  selectedTemplateId: string;
  activeTab: number;
  activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' | 'attendance' | 'mail' | 'mailDetail' | 'mailComposer';
  detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' | 'attendance' | 'mail' | 'mailDetail' | 'mailComposer';
  workflowTitleInput: string;
  workflowExtraInput: string;
  workflowDateInput: string;
  workflowEndDateInput: string;
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
    workflowEndDateInput: '',
    workflowAmountInput: '',
    workflowReasonInput: '',
    workflowAttachmentInput: '',
    approvalComment: ''
  };
  return baseState;
}

export interface WorkflowDateRange {
  start: string;
  end: string;
}

export function splitWorkflowDateRange(value: string): WorkflowDateRange {
  const normalized: string = value.trim();
  const empty: WorkflowDateRange = { start: '', end: '' };
  if (normalized.length === 0) {
    return empty;
  }
  const explicitParts: string[] = normalized.split(' 至 ');
  if (explicitParts.length === 2) {
    return { start: explicitParts[0].trim(), end: explicitParts[1].trim() };
  }
  const sameDay = normalized.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})$/);
  if (sameDay !== null) {
    return {
      start: `${sameDay[1]} ${sameDay[2]}`,
      end: `${sameDay[1]} ${sameDay[3]}`
    };
  }
  const fullRange = normalized.match(
    /^(\d{4}-\d{2}-\d{2}\s+\d{1,2}:\d{2})\s*-\s*(\d{4}-\d{2}-\d{2}\s+\d{1,2}:\d{2})$/
  );
  if (fullRange !== null) {
    return { start: fullRange[1], end: fullRange[2] };
  }
  return { start: normalized, end: '' };
}

export function buildOpenWorkflowComposerStateUseCase(templateId: string): WorkflowFormState {
  return buildWorkflowFormDefaults(templateId);
}

export function buildStartWorkflowStateUseCase(
  templateId: string,
  draft?: AssistantFormDraft
): WorkflowFormState {
  const state: WorkflowFormState = buildWorkflowFormDefaults(templateId);
  if (draft === undefined) {
    return state;
  }
  state.workflowTitleInput = draft.title.trim();
  state.workflowExtraInput = draft.extra.trim();
  if (templateId === 'wf1') {
    const range: WorkflowDateRange = splitWorkflowDateRange(draft.date);
    state.workflowDateInput = range.start;
    state.workflowEndDateInput = range.end;
  } else {
    state.workflowDateInput = draft.date.trim();
  }
  state.workflowAmountInput = draft.amount.trim();
  state.workflowReasonInput = draft.reason.trim();
  state.workflowAttachmentInput = draft.attachment.trim();
  return state;
}

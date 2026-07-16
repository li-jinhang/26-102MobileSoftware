import { AssistantIntent, AssistantReply } from '../../models/AppModels';

function emptyReply(
  answer: string,
  relatedKnowledgeIds: string[],
  recommendedWorkflowId: string,
  intent: AssistantIntent
): AssistantReply {
  return {
    answer,
    recognizedText: '',
    intent,
    relatedKnowledgeIds,
    recommendedWorkflowId,
    confidence: 0.5,
    formDraft: { title: '', extra: '', date: '', amount: '', reason: '', attachment: '' },
    missingFields: [],
    action: { type: 'none', label: '', mailDraft: null }
  };
}

export function buildAssistantReply(question: string): AssistantReply | null {
  const keyword: string = question.trim();
  if (keyword.length === 0) {
    return null;
  }

  if (keyword.includes('报销') || keyword.includes('打车') || keyword.includes('发票')) {
    return emptyReply('根据《差旅报销制度》，报销需上传发票、行程截图和事由说明。你可以直接发起“报销申请”。', ['k2'], 'wf2', 'reimbursement');
  }

  if (keyword.includes('请假') || keyword.includes('病假') || keyword.includes('年假')) {
    return emptyReply('请假前建议先查看《请假制度说明》，确认请假类型和材料要求，然后发起“请假申请”。', ['k1'], 'wf1', 'leave');
  }

  if (keyword.includes('权限') || keyword.includes('账号') || keyword.includes('系统')) {
    return emptyReply('系统权限开通需要说明业务场景、系统名称和期限范围，建议先阅读《系统权限申请规范》并发起“权限申请”。', ['k4'], 'wf4', 'permission');
  }

  if (keyword.includes('采购') || keyword.includes('预算') || keyword.includes('合同')) {
    return emptyReply('采购流程需补充用途、预算和期望到货时间，可参考《采购申请规范》后发起“采购申请”。', ['k3'], 'wf3', 'purchase');
  }

  return emptyReply('暂未找到完全匹配的制度，下面是可能相关的知识。', ['k1', 'k2'], '', 'unknown');
}

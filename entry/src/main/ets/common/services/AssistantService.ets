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

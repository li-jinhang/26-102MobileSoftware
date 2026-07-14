import { AuditLog, NotificationItem, User, WorkflowInstance, WorkflowTemplate } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface WorkflowCreateInput {
  template: WorkflowTemplate;
  user: User;
  workflowInstances: WorkflowInstance[];
  notifications: NotificationItem[];
  titleInput: string;
  extraInput: string;
  dateInput: string;
  amountInput: string;
  reasonInput: string;
  attachmentInput: string;
}

export interface WorkflowCreateResult {
  success: boolean;
  errorMessage: string;
  workflowInstances: WorkflowInstance[];
  notifications: NotificationItem[];
  instance: WorkflowInstance | null;
}

export interface WorkflowDecisionResult {
  workflowInstances: WorkflowInstance[];
  notifications: NotificationItem[];
  message: string;
}

export interface WorkflowSecurityConfirmResult {
  workflowInstances: WorkflowInstance[];
  notifications: NotificationItem[];
  auditLogs: AuditLog[];
  selectedWorkflowId: string;
  message: string;
}

function parseAmount(value: string): number {
  const amount: number = Number(value.trim());
  return isNaN(amount) ? 0 : amount;
}

function buildWorkflowTitle(templateId: string, user: User, titleInput: string, extraInput: string, dateInput: string): string {
  if (titleInput.trim().length > 0) {
    return titleInput.trim();
  }
  if (templateId === 'wf1') {
    return dateInput.trim();
  }
  if (templateId === 'wf2' || templateId === 'wf3' || templateId === 'wf4') {
    return extraInput.trim();
  }
  return user.name;
}

function validateWorkflowForm(
  templateId: string,
  amount: number,
  extraInput: string,
  dateInput: string,
  reasonInput: string,
  attachmentInput: string
): string {
  if (reasonInput.trim().length === 0) {
    return '请填写申请事由。';
  }
  if (attachmentInput.trim().length === 0) {
    return '请补充附件模拟内容。';
  }
  if (templateId === 'wf1' && (extraInput.trim().length === 0 || dateInput.trim().length === 0)) {
    return '请完整填写请假类型和时间。';
  }
  if ((templateId === 'wf2' || templateId === 'wf3') && (amount <= 0 || extraInput.trim().length === 0)) {
    return '请填写金额和业务类型。';
  }
  if (templateId === 'wf3' && dateInput.trim().length === 0) {
    return '请填写期望到货时间。';
  }
  if (templateId === 'wf4' && (extraInput.trim().length === 0 || dateInput.trim().length === 0)) {
    return '请填写系统名称和申请期限。';
  }
  return '';
}

function mergeWorkflowInstances(myItems: WorkflowInstance[], todoItems: WorkflowInstance[]): WorkflowInstance[] {
  const map = new Map<string, WorkflowInstance>();
  myItems.forEach((item: WorkflowInstance) => {
    map.set(item.id, item);
  });
  todoItems.forEach((item: WorkflowInstance) => {
    map.set(item.id, item);
  });
  return Array.from(map.values()).sort((left: WorkflowInstance, right: WorkflowInstance) => {
    return right.createTime.localeCompare(left.createTime);
  });
}

async function refreshWorkflowInstances(): Promise<WorkflowInstance[]> {
  const myItems: WorkflowInstance[] = await repositories.workflowRepository.getMyInstances();
  const todoItems: WorkflowInstance[] = await repositories.workflowRepository.getTodoInstances();
  return mergeWorkflowInstances(myItems, todoItems);
}

async function refreshNotifications(): Promise<NotificationItem[]> {
  return repositories.notificationRepository.getNotifications();
}

function buildSecurityConfirmAuditLog(user: User, instance: WorkflowInstance): AuditLog {
  return {
    id: `log${Date.now()}`,
    module: '安全治理',
    action: '完成二次确认',
    operatorName: user.name,
    operatorRole: user.role,
    riskLevel: 'high',
    detail: `${user.name} 对“${instance.title}”执行了二次安全确认。`,
    time: '刚刚'
  };
}

export async function createWorkflowUseCase(input: WorkflowCreateInput): Promise<WorkflowCreateResult> {
  const amount: number = parseAmount(input.amountInput);
  const errorMessage: string = validateWorkflowForm(
    input.template.id,
    amount,
    input.extraInput,
    input.dateInput,
    input.reasonInput,
    input.attachmentInput
  );
  if (errorMessage.length > 0) {
    return {
      success: false,
      errorMessage,
      workflowInstances: input.workflowInstances,
      notifications: input.notifications,
      instance: null
    };
  }

  const instance: WorkflowInstance = await repositories.workflowRepository.createInstance({
    templateId: input.template.id,
    title: buildWorkflowTitle(
      input.template.id,
      input.user,
      input.titleInput,
      input.extraInput,
      input.dateInput
    ),
    extraInput: input.extraInput.trim(),
    dateInput: input.dateInput.trim(),
    amountInput: amount,
    reasonInput: input.reasonInput.trim(),
    attachmentInput: input.attachmentInput.trim()
  });

  return {
    success: true,
    errorMessage: '',
    workflowInstances: await refreshWorkflowInstances(),
    notifications: await refreshNotifications(),
    instance
  };
}

export async function applyWorkflowDecisionUseCase(
  instanceId: string,
  approvalComment: string,
  isApproved: boolean
): Promise<WorkflowDecisionResult> {
  if (isApproved) {
    await repositories.workflowRepository.approveInstance(instanceId, approvalComment.trim());
  } else {
    await repositories.workflowRepository.rejectInstance(instanceId, approvalComment.trim());
  }

  return {
    workflowInstances: await refreshWorkflowInstances(),
    notifications: await refreshNotifications(),
    message: isApproved ? '已通过当前节点。' : '已驳回该流程。'
  };
}

export async function applyWorkflowSecurityConfirmUseCase(
  auditLogs: AuditLog[],
  instanceId: string,
  currentUser: User,
  approvalComment: string
): Promise<WorkflowSecurityConfirmResult> {
  const instance: WorkflowInstance = await repositories.workflowRepository.securityConfirmInstance(
    instanceId,
    approvalComment.trim()
  );
  const nextAuditLogs: AuditLog[] = [buildSecurityConfirmAuditLog(currentUser, instance), ...auditLogs];

  return {
    workflowInstances: await refreshWorkflowInstances(),
    notifications: await refreshNotifications(),
    auditLogs: nextAuditLogs,
    selectedWorkflowId: instance.id,
    message: '已完成二次确认。'
  };
}

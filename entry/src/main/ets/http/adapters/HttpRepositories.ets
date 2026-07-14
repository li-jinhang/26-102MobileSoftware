import { apiDelete, apiGet, apiPost } from '../../common/services/ApiClient';
import { clearAccessToken, setAccessToken } from '../../app/repositories/BackendSession';
import {
  AssistantReply,
  AuditLog,
  KnowledgeCorrection,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  User,
  WorkflowInstance,
  WorkflowTemplate
} from '../../models/AppModels';
import {
  AssistantRepository,
  AuditRepository,
  AuthLoginResult,
  AuthRepository,
  KnowledgeRepository,
  NotificationRepository,
  WorkflowRepository
} from '../../domain/contracts/AppRepositories';

type BackendWorkflowStatus = 'pending' | 'in_review' | 'pending_security_confirm' | 'approved' | 'rejected';
type BackendApprovalDecision = 'submitted' | 'approved' | 'rejected' | 'security_confirmed';

function mapWorkflowStatus(status: BackendWorkflowStatus): WorkflowInstance['status'] {
  if (status === 'approved') {
    return '已通过';
  }
  if (status === 'rejected') {
    return '已驳回';
  }
  if (status === 'in_review') {
    return '审批中';
  }
  if (status === 'pending_security_confirm') {
    return '待二次确认';
  }
  return '待审批';
}

function mapApprovalDecision(decision: BackendApprovalDecision): 'submitted' | 'approved' | 'rejected' | 'securityConfirmed' {
  if (decision === 'security_confirmed') {
    return 'securityConfirmed';
  }
  return decision;
}

function mapUser(source: {
  id: string;
  name: string;
  account: string;
  department: string;
  role: User['role'];
  roleLabel: string;
  permissions: string[];
  favoriteKnowledgeIds: string[];
  recentKnowledgeIds: string[];
  todoCount: number;
}): User {
  return {
    id: source.id,
    name: source.name,
    account: source.account,
    password: '',
    department: source.department,
    role: source.role,
    roleLabel: source.roleLabel,
    permissions: source.permissions,
    favoriteKnowledgeIds: source.favoriteKnowledgeIds,
    recentKnowledgeIds: source.recentKnowledgeIds,
    todoCount: source.todoCount
  };
}

function mapWorkflowInstance(source: {
  id: string;
  templateId: string;
  title: string;
  applicantId: string;
  applicantName: string;
  status: BackendWorkflowStatus;
  currentNode: string;
  currentApproverRole: User['role'];
  createTime: string;
  latestComment: string;
  relatedKnowledgeIds: string[];
  amount: number;
  formSummary: string;
  formDetail: string[];
  approvalRecords: Array<{
    id: string;
    nodeName: string;
    operatorRole: User['role'];
    operatorName: string;
    decision: BackendApprovalDecision;
    comment: string;
    time: string;
  }>;
  riskLevel: 'normal' | 'high';
  riskReason: string;
  requiresSecurityConfirm: boolean;
  securityConfirmed: boolean;
}): WorkflowInstance {
  return {
    id: source.id,
    templateId: source.templateId,
    title: source.title,
    applicantId: source.applicantId,
    applicantName: source.applicantName,
    status: mapWorkflowStatus(source.status),
    currentNode: source.currentNode,
    currentApproverRole: source.currentApproverRole,
    createTime: source.createTime,
    latestComment: source.latestComment,
    relatedKnowledgeIds: source.relatedKnowledgeIds,
    amount: source.amount,
    formSummary: source.formSummary,
    formDetail: source.formDetail,
    approvalRecords: source.approvalRecords.map((item) => ({
      id: item.id,
      nodeName: item.nodeName,
      operatorRole: item.operatorRole,
      operatorName: item.operatorName,
      decision: mapApprovalDecision(item.decision),
      comment: item.comment,
      time: item.time
    })),
    riskLevel: source.riskLevel,
    riskReason: source.riskReason,
    requiresSecurityConfirm: source.requiresSecurityConfirm,
    securityConfirmed: source.securityConfirmed
  };
}

class HttpAuthRepository implements AuthRepository {
  async login(account: string, password: string): Promise<AuthLoginResult> {
    const data = await apiPost<{
      token: string;
      user: {
        id: string;
        name: string;
        account: string;
        department: string;
        role: User['role'];
        roleLabel: string;
        permissions: string[];
        favoriteKnowledgeIds: string[];
        recentKnowledgeIds: string[];
        todoCount: number;
      };
    }>('/auth/login', {
      account,
      password
    }, false);

    setAccessToken(data.token);
    return {
      token: data.token,
      user: mapUser(data.user)
    };
  }

  async logout(): Promise<void> {
    try {
      await apiPost<null>('/auth/logout', {});
    } finally {
      clearAccessToken();
    }
  }
}

class HttpKnowledgeRepository implements KnowledgeRepository {
  async getCategories(): Promise<KnowledgeCategory[]> {
    const categories = await apiGet<KnowledgeCategory[]>('/knowledge/categories');
    return [
      { id: 'all', name: '全部', description: '查看所有已发布知识' },
      ...categories
    ];
  }

  async getArticles(): Promise<KnowledgeArticle[]> {
    const items = await apiGet<Array<KnowledgeArticle & { favorite: boolean }>>('/knowledge/articles');
    return items.map((item) => ({
      id: item.id,
      title: item.title,
      summary: item.summary,
      content: item.content,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      tags: item.tags,
      updateTime: item.updateTime,
      version: item.version,
      status: item.status,
      attachments: item.attachments,
      relatedWorkflowIds: item.relatedWorkflowIds
    }));
  }

  async favorite(articleId: string): Promise<boolean> {
    await apiPost<{ articleId: string; favorite: boolean }>(`/knowledge/articles/${articleId}/favorite`, {});
    return true;
  }

  async unfavorite(articleId: string): Promise<boolean> {
    await apiDelete<{ articleId: string; favorite: boolean }>(`/knowledge/articles/${articleId}/favorite`);
    return false;
  }

  async createCorrection(articleId: string, content: string): Promise<KnowledgeCorrection> {
    const result = await apiPost<{
      id: string;
      articleId: string;
      content: string;
      createTime: string;
    }>(`/knowledge/articles/${articleId}/corrections`, {
      content
    });
    return {
      id: result.id,
      articleId: result.articleId,
      userId: '',
      content: result.content,
      createTime: result.createTime
    };
  }
}

class HttpWorkflowRepository implements WorkflowRepository {
  async getTemplates(): Promise<WorkflowTemplate[]> {
    return apiGet<WorkflowTemplate[]>('/workflow/templates');
  }

  async getMyInstances(): Promise<WorkflowInstance[]> {
    const items = await apiGet<Array<Parameters<typeof mapWorkflowInstance>[0]>>('/workflow/instances/my');
    return items.map((item) => mapWorkflowInstance(item));
  }

  async getTodoInstances(): Promise<WorkflowInstance[]> {
    const items = await apiGet<Array<Parameters<typeof mapWorkflowInstance>[0]>>('/workflow/instances/todo');
    return items.map((item) => mapWorkflowInstance(item));
  }

  async getInstance(instanceId: string): Promise<WorkflowInstance> {
    const item = await apiGet<Parameters<typeof mapWorkflowInstance>[0]>(`/workflow/instances/${instanceId}`);
    return mapWorkflowInstance(item);
  }

  async createInstance(input: {
    templateId: string;
    title: string;
    extraInput: string;
    dateInput: string;
    amountInput: number;
    reasonInput: string;
    attachmentInput: string;
  }): Promise<WorkflowInstance> {
    const created = await apiPost<{ id: string }>(
      '/workflow/instances',
      input
    );
    return this.getInstance(created.id);
  }

  async approveInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    await apiPost<{ id: string }>(`/workflow/instances/${instanceId}/approve`, {
      comment
    });
    return this.getInstance(instanceId);
  }

  async rejectInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    await apiPost<{ id: string }>(`/workflow/instances/${instanceId}/reject`, {
      comment
    });
    return this.getInstance(instanceId);
  }

  async securityConfirmInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    await apiPost<{ id: string }>(`/workflow/instances/${instanceId}/security-confirm`, {
      comment
    });
    return this.getInstance(instanceId);
  }
}

class HttpNotificationRepository implements NotificationRepository {
  async getNotifications(unreadOnly?: boolean): Promise<NotificationItem[]> {
    return apiGet<NotificationItem[]>('/notifications', unreadOnly === undefined ? undefined : {
      unreadOnly
    });
  }

  async markRead(notificationId: string): Promise<void> {
    await apiPost<{ id: string; read: boolean }>(`/notifications/${notificationId}/read`, {});
  }
}

class HttpAssistantRepository implements AssistantRepository {
  async ask(question: string): Promise<AssistantReply> {
    return apiPost<AssistantReply>('/assistant/ask', {
      question
    });
  }
}

class HttpAuditRepository implements AuditRepository {
  async getAuditLogs(): Promise<AuditLog[]> {
    return [];
  }
}

export const httpAuthRepository: AuthRepository = new HttpAuthRepository();
export const httpKnowledgeRepository: KnowledgeRepository = new HttpKnowledgeRepository();
export const httpWorkflowRepository: WorkflowRepository = new HttpWorkflowRepository();
export const httpNotificationRepository: NotificationRepository = new HttpNotificationRepository();
export const httpAssistantRepository: AssistantRepository = new HttpAssistantRepository();
export const httpAuditRepository: AuditRepository = new HttpAuditRepository();

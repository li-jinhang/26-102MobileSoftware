import { apiDelete, apiGet, apiPost, ApiQueryParam } from '../../common/services/ApiClient';
import { clearAccessToken, setAccessToken } from '../../app/repositories/BackendSession';
import {
  ApprovalRecord,
  ApprovalDecision,
  AssistantReply,
  AuditLog,
  KnowledgeCorrection,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  User,
  UserRole,
  WorkflowInstance,
  WorkflowStatus,
  WorkflowTemplate
} from '../../models/AppModels';
import {
  AssistantRepository,
  AuditRepository,
  AuthLoginResult,
  AuthRepository,
  KnowledgeRepository,
  NotificationRepository,
  WorkflowCreatePayload,
  WorkflowRepository
} from '../../domain/contracts/AppRepositories';

type BackendWorkflowStatus = 'pending' | 'in_review' | 'pending_security_confirm' | 'approved' | 'rejected';
type BackendApprovalDecision = 'submitted' | 'approved' | 'rejected' | 'security_confirmed';

interface BackendUserProfile {
  id: string;
  name: string;
  account: string;
  department: string;
  role: UserRole;
  roleLabel: string;
  permissions: string[];
  favoriteKnowledgeIds: string[];
  recentKnowledgeIds: string[];
  todoCount: number;
}

interface BackendLoginResponseData {
  token: string;
  user: BackendUserProfile;
}

interface BackendKnowledgeArticle extends KnowledgeArticle {
  favorite: boolean;
}

interface BackendCorrectionResponse {
  id: string;
  articleId: string;
  content: string;
  createTime: string;
}

interface BackendIdResponse {
  id: string;
}

interface BackendFavoriteResponse {
  articleId: string;
  favorite: boolean;
}

interface BackendReadResponse {
  id: string;
  read: boolean;
}

interface BackendApprovalRecord {
  id: string;
  nodeName: string;
  operatorRole: UserRole;
  operatorName: string;
  decision: BackendApprovalDecision;
  comment: string;
  time: string;
}

interface BackendWorkflowInstance {
  id: string;
  templateId: string;
  title: string;
  applicantId: string;
  applicantName: string;
  status: BackendWorkflowStatus;
  currentNode: string;
  currentApproverRole: UserRole;
  createTime: string;
  latestComment: string;
  relatedKnowledgeIds: string[];
  amount: number;
  formSummary: string;
  formDetail: string[];
  approvalRecords: BackendApprovalRecord[];
  riskLevel: 'normal' | 'high';
  riskReason: string;
  requiresSecurityConfirm: boolean;
  securityConfirmed: boolean;
}

interface LoginRequestBody {
  account: string;
  password: string;
}

interface CorrectionRequestBody {
  content: string;
}

interface CommentRequestBody {
  comment: string;
}

interface AskAssistantRequestBody {
  question: string;
}

interface EmptyRequestBody {
}

const EMPTY_BODY_JSON: string = '{}';

function mapWorkflowStatus(status: BackendWorkflowStatus): WorkflowStatus {
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

function mapApprovalDecision(decision: BackendApprovalDecision): ApprovalDecision {
  if (decision === 'security_confirmed') {
    return 'securityConfirmed';
  }
  if (decision === 'submitted') {
    return 'submitted';
  }
  if (decision === 'approved') {
    return 'approved';
  }
  return 'rejected';
}

function mapUser(source: BackendUserProfile): User {
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

function mapKnowledgeArticle(source: BackendKnowledgeArticle): KnowledgeArticle {
  return {
    id: source.id,
    title: source.title,
    summary: source.summary,
    content: source.content,
    categoryId: source.categoryId,
    categoryName: source.categoryName,
    tags: source.tags,
    updateTime: source.updateTime,
    version: source.version,
    status: source.status,
    attachments: source.attachments,
    relatedWorkflowIds: source.relatedWorkflowIds
  };
}

function mapApprovalRecord(source: BackendApprovalRecord): ApprovalRecord {
  return {
    id: source.id,
    nodeName: source.nodeName,
    operatorRole: source.operatorRole,
    operatorName: source.operatorName,
    decision: mapApprovalDecision(source.decision),
    comment: source.comment,
    time: source.time
  };
}

function mapWorkflowInstance(source: BackendWorkflowInstance): WorkflowInstance {
  const approvalRecords = source.approvalRecords.map((item: BackendApprovalRecord) => mapApprovalRecord(item));
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
    approvalRecords,
    riskLevel: source.riskLevel,
    riskReason: source.riskReason,
    requiresSecurityConfirm: source.requiresSecurityConfirm,
    securityConfirmed: source.securityConfirmed
  };
}

class HttpAuthRepository implements AuthRepository {
  async login(account: string, password: string): Promise<AuthLoginResult> {
    const requestBody: LoginRequestBody = { account, password };
    const data: BackendLoginResponseData = await apiPost<BackendLoginResponseData>(
      '/auth/login',
      JSON.stringify(requestBody),
      false
    );

    setAccessToken(data.token);
    return {
      token: data.token,
      user: mapUser(data.user)
    };
  }

  async logout(): Promise<void> {
    try {
      const body: EmptyRequestBody = {};
      await apiPost<null>('/auth/logout', JSON.stringify(body));
    } finally {
      clearAccessToken();
    }
  }
}

class HttpKnowledgeRepository implements KnowledgeRepository {
  async getCategories(): Promise<KnowledgeCategory[]> {
    const categories: KnowledgeCategory[] = await apiGet<KnowledgeCategory[]>('/knowledge/categories');
    const allCategory: KnowledgeCategory = { id: 'all', name: '全部', description: '查看所有已发布知识' };
    const result: KnowledgeCategory[] = [allCategory];
    categories.forEach((item: KnowledgeCategory) => {
      result.push(item);
    });
    return result;
  }

  async getArticles(): Promise<KnowledgeArticle[]> {
    const items: BackendKnowledgeArticle[] = await apiGet<BackendKnowledgeArticle[]>('/knowledge/articles');
    return items.map((item: BackendKnowledgeArticle) => mapKnowledgeArticle(item));
  }

  async favorite(articleId: string): Promise<boolean> {
    const body: EmptyRequestBody = {};
    const result: BackendFavoriteResponse = await apiPost<BackendFavoriteResponse>(
      `/knowledge/articles/${articleId}/favorite`,
      JSON.stringify(body)
    );
    return result.favorite;
  }

  async unfavorite(articleId: string): Promise<boolean> {
    const result: BackendFavoriteResponse = await apiDelete<BackendFavoriteResponse>(
      `/knowledge/articles/${articleId}/favorite`
    );
    return result.favorite;
  }

  async createCorrection(articleId: string, content: string): Promise<KnowledgeCorrection> {
    const body: CorrectionRequestBody = { content };
    const result: BackendCorrectionResponse = await apiPost<BackendCorrectionResponse>(
      `/knowledge/articles/${articleId}/corrections`,
      JSON.stringify(body)
    );
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
    const items: BackendWorkflowInstance[] = await apiGet<BackendWorkflowInstance[]>('/workflow/instances/my');
    return items.map((item: BackendWorkflowInstance) => mapWorkflowInstance(item));
  }

  async getTodoInstances(): Promise<WorkflowInstance[]> {
    const items: BackendWorkflowInstance[] = await apiGet<BackendWorkflowInstance[]>('/workflow/instances/todo');
    return items.map((item: BackendWorkflowInstance) => mapWorkflowInstance(item));
  }

  async getInstance(instanceId: string): Promise<WorkflowInstance> {
    const item: BackendWorkflowInstance = await apiGet<BackendWorkflowInstance>(`/workflow/instances/${instanceId}`);
    return mapWorkflowInstance(item);
  }

  async createInstance(input: WorkflowCreatePayload): Promise<WorkflowInstance> {
    const created: BackendIdResponse = await apiPost<BackendIdResponse>(
      '/workflow/instances',
      JSON.stringify(input)
    );
    return this.getInstance(created.id);
  }

  async approveInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    const body: CommentRequestBody = { comment };
    await apiPost<BackendIdResponse>(`/workflow/instances/${instanceId}/approve`, JSON.stringify(body));
    return this.getInstance(instanceId);
  }

  async rejectInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    const body: CommentRequestBody = { comment };
    await apiPost<BackendIdResponse>(`/workflow/instances/${instanceId}/reject`, JSON.stringify(body));
    return this.getInstance(instanceId);
  }

  async securityConfirmInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    const body: CommentRequestBody = { comment };
    await apiPost<BackendIdResponse>(`/workflow/instances/${instanceId}/security-confirm`, JSON.stringify(body));
    return this.getInstance(instanceId);
  }
}

class HttpNotificationRepository implements NotificationRepository {
  async getNotifications(unreadOnly?: boolean): Promise<NotificationItem[]> {
    if (unreadOnly === undefined) {
      return apiGet<NotificationItem[]>('/notifications');
    }
    const queryParams: ApiQueryParam[] = [
      {
        key: 'unreadOnly',
        value: unreadOnly ? 'true' : 'false'
      }
    ];
    return apiGet<NotificationItem[]>('/notifications', queryParams);
  }

  async markRead(notificationId: string): Promise<void> {
    const body: EmptyRequestBody = {};
    await apiPost<BackendReadResponse>(`/notifications/${notificationId}/read`, JSON.stringify(body));
  }
}

class HttpAssistantRepository implements AssistantRepository {
  async ask(question: string): Promise<AssistantReply> {
    const body: AskAssistantRequestBody = { question };
    return apiPost<AssistantReply>('/assistant/ask', JSON.stringify(body));
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

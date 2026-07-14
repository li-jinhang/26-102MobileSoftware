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

export interface AuthLoginResult {
  token: string;
  user: User;
}

export interface WorkflowCreatePayload {
  templateId: string;
  title: string;
  extraInput: string;
  dateInput: string;
  amountInput: number;
  reasonInput: string;
  attachmentInput: string;
}

export interface AuthRepository {
  login(account: string, password: string): Promise<AuthLoginResult>;
  logout(): Promise<void>;
}

export interface KnowledgeRepository {
  getCategories(): Promise<KnowledgeCategory[]>;
  getArticles(): Promise<KnowledgeArticle[]>;
  favorite(articleId: string): Promise<boolean>;
  unfavorite(articleId: string): Promise<boolean>;
  createCorrection(articleId: string, content: string): Promise<KnowledgeCorrection>;
}

export interface WorkflowRepository {
  getTemplates(): Promise<WorkflowTemplate[]>;
  getMyInstances(): Promise<WorkflowInstance[]>;
  getTodoInstances(): Promise<WorkflowInstance[]>;
  getInstance(instanceId: string): Promise<WorkflowInstance>;
  createInstance(input: WorkflowCreatePayload): Promise<WorkflowInstance>;
  approveInstance(instanceId: string, comment: string): Promise<WorkflowInstance>;
  rejectInstance(instanceId: string, comment: string): Promise<WorkflowInstance>;
  securityConfirmInstance(instanceId: string, comment: string): Promise<WorkflowInstance>;
}

export interface NotificationRepository {
  getNotifications(unreadOnly?: boolean): Promise<NotificationItem[]>;
  markRead(notificationId: string): Promise<void>;
}

export interface AssistantRepository {
  ask(question: string): Promise<AssistantReply>;
}

export interface AuditRepository {
  getAuditLogs(): Promise<AuditLog[]>;
}

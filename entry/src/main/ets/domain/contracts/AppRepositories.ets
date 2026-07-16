import {
  AttendanceRecord,
  AttendanceTodaySummary,
  AssistantAnalyzeInput,
  AssistantReply,
  AuditLog,
  KnowledgeCorrection,
  KnowledgeArticle,
  KnowledgeCategory,
  MailMessage,
  NotificationItem,
  DepartmentTreeItem,
  EmployeeDirectoryItem,
  OrganizationProfile,
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

export interface AttendanceSubmitPayload {
  location: string;
  note: string;
}

export interface MailSendPayload {
  receiverIds: string[];
  subject: string;
  content: string;
  relatedWorkflowId: string;
  relatedKnowledgeId: string;
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

export interface AttendanceRepository {
  getTodaySummary(): Promise<AttendanceTodaySummary>;
  getMyRecords(): Promise<AttendanceRecord[]>;
  checkIn(input: AttendanceSubmitPayload): Promise<AttendanceTodaySummary>;
  checkOut(input: AttendanceSubmitPayload): Promise<AttendanceTodaySummary>;
}

export interface MailRepository {
  getInbox(): Promise<MailMessage[]>;
  getSent(): Promise<MailMessage[]>;
  getMail(mailId: string): Promise<MailMessage>;
  sendMail(input: MailSendPayload): Promise<MailMessage>;
  markRead(mailId: string): Promise<void>;
  deleteMail(mailId: string): Promise<void>;
}

export interface OrganizationRepository {
  getMyOrganization(): Promise<OrganizationProfile>;
  getDepartmentTree(): Promise<DepartmentTreeItem[]>;
  searchUsers(scope: 'department' | 'team' | 'all', keyword?: string, departmentId?: string): Promise<EmployeeDirectoryItem[]>;
}

export interface AssistantRepository {
  analyze(input: AssistantAnalyzeInput): Promise<AssistantReply>;
}

export interface AuditRepository {
  getAuditLogs(): Promise<AuditLog[]>;
}

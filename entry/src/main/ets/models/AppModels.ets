export type UserRole = 'employee' | 'approver' | 'knowledgeAdmin' | 'systemAdmin';
export type ApprovalDecision = 'submitted' | 'approved' | 'rejected' | 'securityConfirmed';
export type WorkflowStatus = '待审批' | '审批中' | '待二次确认' | '已通过' | '已驳回';
export type NotificationTargetType = 'workflow' | 'knowledge' | 'attendance' | 'mail' | 'none';
export type ReadingFontScale = 'small' | 'standard' | 'large';
export type ReadingFontWeight = 'standard' | 'semiBold';
export type AttendanceRecordType = 'checkIn' | 'checkOut';
export type AttendanceRecordStatus = 'normal' | 'late' | 'earlyLeave' | 'offsite';
export type MailFolder = 'inbox' | 'sent' | 'draft' | 'trash';
export type MailImportance = 'normal' | 'important' | 'urgent';
export type EmploymentStatus = 'active' | 'inactive';
export type CollaborationKind = 'meeting' | 'task' | 'group' | 'chain';
export type CollaborationState = 'action' | 'waiting' | 'active';

export interface User {
  id: string;
  name: string;
  account: string;
  password: string;
  department: string;
  role: UserRole;
  roleLabel: string;
  permissions: string[];
  favoriteKnowledgeIds: string[];
  recentKnowledgeIds: string[];
  todoCount: number;
  departmentId: string;
  managerId: string;
  jobTitle: string;
  employmentStatus: EmploymentStatus;
}

export interface Department {
  id: string;
  name: string;
  parentId: string;
  leaderId: string;
  sortOrder: number;
  status: EmploymentStatus;
}

export interface EmployeeDirectoryItem {
  id: string;
  name: string;
  account: string;
  departmentId: string;
  departmentName: string;
  jobTitle: string;
  managerId: string;
  managerName: string;
  employmentStatus: EmploymentStatus;
}

export interface OrganizationProfile {
  employee: EmployeeDirectoryItem;
  manager: EmployeeDirectoryItem | null;
  directReports: EmployeeDirectoryItem[];
  departmentMembers: EmployeeDirectoryItem[];
}

export interface CollaborationItem {
  id: string;
  kind: CollaborationKind;
  title: string;
  summary: string;
  ownerName: string;
  ownerDepartment: string;
  timeText: string;
  placeText: string;
  statusText: string;
  state: CollaborationState;
  needsAction: boolean;
  participantIds: string[];
  members: EmployeeDirectoryItem[];
}

export interface CollaborationMessage {
  id: string;
  threadId: string;
  senderName: string;
  senderRoleLabel: string;
  content: string;
  timeText: string;
  direction: 'in' | 'out';
}

export interface CollaborationMessageSendPayload {
  threadId: string;
  receiverIds: string[];
  content: string;
}

export interface CollaborationBoard {
  actionCount: number;
  waitingCount: number;
  meetingCount: number;
  groupCount: number;
  meetingItems: CollaborationItem[];
  taskItems: CollaborationItem[];
  groupItems: CollaborationItem[];
  chainItems: CollaborationItem[];
}

export interface DepartmentTreeItem extends Department {
  leaderName: string;
  children: DepartmentTreeItem[];
}

export interface KnowledgeCategory {
  id: string;
  name: string;
  description: string;
}

export interface KnowledgeArticle {
  id: string;
  title: string;
  summary: string;
  content: string;
  categoryId: string;
  categoryName: string;
  tags: string[];
  updateTime: string;
  version: string;
  status: 'published' | 'deprecated' | 'removed' | 'draft';
  attachments: string[];
  relatedWorkflowIds: string[];
}

export interface WorkflowTemplate {
  id: string;
  name: string;
  description: string;
  approverText: string;
  relatedKnowledgeIds: string[];
  riskLevel: 'normal' | 'high';
  riskHint: string;
  defaultApproverRoles: UserRole[];
}

export interface ApprovalRecord {
  id: string;
  nodeName: string;
  operatorRole: UserRole;
  operatorName: string;
  decision: ApprovalDecision;
  comment: string;
  time: string;
}

export interface WorkflowInstance {
  id: string;
  templateId: string;
  title: string;
  applicantId: string;
  applicantName: string;
  status: WorkflowStatus;
  currentNode: string;
  currentApproverRole: UserRole;
  createTime: string;
  latestComment: string;
  relatedKnowledgeIds: string[];
  amount: number;
  formSummary: string;
  formDetail: string[];
  approvalRecords: ApprovalRecord[];
  riskLevel: 'normal' | 'high';
  riskReason: string;
  requiresSecurityConfirm: boolean;
  securityConfirmed: boolean;
}

export interface NotificationItem {
  id: string;
  title: string;
  content: string;
  time: string;
  read: boolean;
  targetRoles: UserRole[];
  targetType: NotificationTargetType;
  targetId: string;
}

export interface AttendanceRecord {
  id: string;
  userId: string;
  userName: string;
  type: AttendanceRecordType;
  time: string;
  location: string;
  note: string;
  status: AttendanceRecordStatus;
}

export interface AttendanceTodaySummary {
  date: string;
  checkedIn: boolean;
  checkedOut: boolean;
  checkInTime: string;
  checkOutTime: string;
  workDurationText: string;
  statusText: string;
  location: string;
  recentRecords: AttendanceRecord[];
}

export interface MailRecipient {
  userId: string;
  userName: string;
  read: boolean;
  readTime: string;
}

export interface MailMessage {
  id: string;
  subject: string;
  summary: string;
  content: string;
  senderId: string;
  senderName: string;
  recipients: MailRecipient[];
  folder: MailFolder;
  importance: MailImportance;
  createTime: string;
  read: boolean;
  relatedWorkflowId: string;
  relatedKnowledgeId: string;
}

export interface KnowledgeCorrection {
  id: string;
  articleId: string;
  userId: string;
  content: string;
  createTime: string;
}

export type AssistantIntent = 'knowledge_query' | 'leave' | 'reimbursement' |
  'purchase' | 'permission' | 'mail' | 'unknown';
export type AssistantActionType = 'none' | 'mail' | 'workflow' | 'knowledge';

export interface AssistantFormDraft {
  title: string;
  extra: string;
  date: string;
  amount: string;
  reason: string;
  attachment: string;
}

export interface AssistantAnalyzeInput {
  text: string;
  imageBase64: string;
  imageMimeType: string;
}

export interface AssistantSelectedImage {
  previewUri: string;
  imageBase64: string;
  imageMimeType: string;
}

export interface AssistantMailDraft {
  receiverIds: string[];
  receiverNames: string[];
  subject: string;
  content: string;
}

export interface AssistantAction {
  type: AssistantActionType;
  label: string;
  mailDraft: AssistantMailDraft | null;
}

export interface AssistantReply {
  answer: string;
  recognizedText: string;
  intent: AssistantIntent;
  relatedKnowledgeIds: string[];
  recommendedWorkflowId: string;
  confidence: number;
  formDraft: AssistantFormDraft;
  missingFields: string[];
  action: AssistantAction;
}

export interface AssistantHistory {
  id: string;
  question: string;
  answer: string;
  time: string;
}

export interface AuditLog {
  id: string;
  module: string;
  action: string;
  operatorName: string;
  operatorRole: UserRole;
  riskLevel: 'normal' | 'high';
  detail: string;
  time: string;
}

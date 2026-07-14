export type UserRole = 'employee' | 'approver' | 'knowledgeAdmin' | 'systemAdmin';
export type ApprovalDecision = 'submitted' | 'approved' | 'rejected' | 'securityConfirmed';
export type WorkflowStatus = '待审批' | '审批中' | '待二次确认' | '已通过' | '已驳回';
export type NotificationTargetType = 'workflow' | 'knowledge' | 'none';
export type ReadingFontScale = 'small' | 'standard' | 'large';
export type ReadingFontWeight = 'standard' | 'semiBold';

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

export interface KnowledgeCorrection {
  id: string;
  articleId: string;
  userId: string;
  content: string;
  createTime: string;
}

export interface AssistantReply {
  answer: string;
  relatedKnowledgeIds: string[];
  recommendedWorkflowId: string;
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

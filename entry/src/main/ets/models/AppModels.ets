export type UserRole = 'employee' | 'approver' | 'knowledgeAdmin' | 'systemAdmin';
export type AppSubPage = 'none' | 'knowledgeDetail' | 'assistant' | 'messages';
export type ReadingFontScale = 'small' | 'standard' | 'large';
export type NotificationTargetType = 'knowledge' | 'workflow' | 'none';

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
}

export interface WorkflowInstance {
  id: string;
  templateId: string;
  title: string;
  applicantId: string;
  applicantName: string;
  status: '草稿' | '待审批' | '审批中' | '已驳回' | '已通过' | '已归档';
  currentNode: string;
  currentApproverRole: UserRole;
  createTime: string;
  latestComment: string;
  relatedKnowledgeIds: string[];
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

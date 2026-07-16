export type UserRole = 'employee' | 'approver' | 'knowledgeAdmin' | 'systemAdmin';
export type WorkflowStatus = 'pending' | 'in_review' | 'pending_security_confirm' | 'approved' | 'rejected';
export type ApprovalDecision = 'submitted' | 'approved' | 'rejected' | 'security_confirmed';
export type NotificationTargetType = 'workflow' | 'knowledge' | 'attendance' | 'mail' | 'none';
export type AttendanceRecordType = 'checkIn' | 'checkOut';
export type AttendanceRecordStatus = 'normal' | 'late' | 'earlyLeave' | 'offsite';
export type MailFolder = 'inbox' | 'sent' | 'draft' | 'trash';
export type MailImportance = 'normal' | 'important' | 'urgent';
export type EmploymentStatus = 'active' | 'inactive';
export interface DepartmentProfile {
    id: string;
    name: string;
    parentId: string;
    leaderId: string;
    sortOrder: number;
    status: EmploymentStatus;
}
export interface DirectoryItem {
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
    employee: DirectoryItem;
    manager: DirectoryItem | null;
    directReports: DirectoryItem[];
    departmentMembers: DirectoryItem[];
}
export interface DepartmentTreeItem extends DepartmentProfile {
    leaderName: string;
    children: DepartmentTreeItem[];
}
export interface UserProfile {
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
    favorite?: boolean;
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
export interface CollaborationMessage {
    id: string;
    threadId: string;
    senderId: string;
    senderName: string;
    senderRoleLabel: string;
    receiverIds: string[];
    content: string;
    timeText: string;
}
export interface CollaborationMessageView {
    id: string;
    threadId: string;
    senderName: string;
    senderRoleLabel: string;
    content: string;
    timeText: string;
    direction: 'in' | 'out';
}
export declare function getUserByToken(token: string): UserProfile;
export declare function authenticate(account: string, password: string): {
    token: string;
    user: UserProfile;
};
export declare function getMyOrganization(token: string): OrganizationProfile;
export declare function getDepartmentTree(token: string): DepartmentTreeItem[];
export declare function searchOrganizationUsers(token: string, scope: string, departmentId: string, keyword: string, activeOnly: boolean): DirectoryItem[];
export declare function getCategories(): KnowledgeCategory[];
export declare function getArticles(token: string): KnowledgeArticle[];
export declare function favoriteArticle(token: string, articleId: string): {
    articleId: string;
    favorite: boolean;
};
export declare function unfavoriteArticle(token: string, articleId: string): {
    articleId: string;
    favorite: boolean;
};
export declare function createCorrection(token: string, articleId: string, content: string): KnowledgeCorrection;
export declare function getWorkflowTemplates(): WorkflowTemplate[];
export declare function getMyWorkflowInstances(token: string): WorkflowInstance[];
export declare function getTodoWorkflowInstances(token: string): WorkflowInstance[];
export declare function getWorkflowInstanceById(instanceId: string): WorkflowInstance;
export declare function createWorkflow(token: string, payload: {
    templateId: string;
    title: string;
    extraInput: string;
    dateInput: string;
    amountInput: number;
    reasonInput: string;
    attachmentInput: string;
}): {
    id: string;
};
export declare function approveWorkflow(token: string, instanceId: string, comment: string): {
    id: string;
};
export declare function rejectWorkflow(token: string, instanceId: string, comment: string): {
    id: string;
};
export declare function securityConfirmWorkflow(token: string, instanceId: string, comment: string): {
    id: string;
};
export declare function getNotifications(token: string, unreadOnly?: boolean): NotificationItem[];
export declare function markNotificationRead(notificationId: string): {
    id: string;
    read: boolean;
};
export declare function askAssistant(question: string): AssistantReply;
export declare function getAttendanceToday(token: string): AttendanceTodaySummary;
export declare function getAttendanceRecords(token: string): AttendanceRecord[];
export declare function checkIn(token: string, location: string, note: string): AttendanceTodaySummary;
export declare function checkOut(token: string, location: string, note: string): AttendanceTodaySummary;
export declare function getInbox(token: string): MailMessage[];
export declare function getCollaborationMessages(token: string, threadId: string): CollaborationMessageView[];
export declare function sendCollaborationMessage(token: string, threadId: string, payload: {
    receiverIds: string[];
    content: string;
}): CollaborationMessageView;
export declare function getSent(token: string): MailMessage[];
export declare function getMail(token: string, mailId: string): MailMessage;
export declare function sendMail(token: string, payload: {
    receiverIds: string[];
    subject: string;
    content: string;
    relatedWorkflowId: string;
    relatedKnowledgeId: string;
}): {
    id: string;
};
export declare function markMailRead(token: string, mailId: string): {
    id: string;
    read: boolean;
};
export declare function deleteMail(token: string, mailId: string): {
    id: string;
};

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

const users: UserProfile[] = [
  {
    id: 'u1',
    name: '张晓宁',
    account: 'employee01',
    password: '123456',
    department: '产品研发部',
    departmentId: 'd-rd',
    managerId: 'u2',
    jobTitle: '产品经理',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: ['k2', 'k4'],
    recentKnowledgeIds: ['k1', 'k2', 'k3'],
    todoCount: 2
  },
  {
    id: 'u2',
    name: '李清越',
    account: 'manager01',
    password: '123456',
    department: '产品研发部',
    departmentId: 'd-rd',
    managerId: '',
    jobTitle: '研发部负责人',
    employmentStatus: 'active',
    role: 'approver',
    roleLabel: '审批人',
    permissions: ['知识查询', '发起流程', '处理待办', '查看关联制度', '内部邮件'],
    favoriteKnowledgeIds: ['k1'],
    recentKnowledgeIds: ['k2', 'k4'],
    todoCount: 5
  },
  {
    id: 'u3',
    name: '周承安',
    account: 'admin01',
    password: '123456',
    department: '信息化管理部',
    departmentId: 'd-it',
    managerId: '',
    jobTitle: '系统管理员',
    employmentStatus: 'active',
    role: 'systemAdmin',
    roleLabel: '系统管理员',
    permissions: ['知识管理', '用户角色管理', '流程模板管理', '查看操作日志', '安全确认'],
    favoriteKnowledgeIds: ['k3'],
    recentKnowledgeIds: ['k1', 'k5'],
    todoCount: 3
  },
  {
    id: 'u4',
    name: '林知夏',
    account: 'knowledge01',
    password: '123456',
    department: '知识运营组',
    departmentId: 'd-knowledge',
    managerId: '',
    jobTitle: '知识运营专员',
    employmentStatus: 'active',
    role: 'knowledgeAdmin',
    roleLabel: '知识管理员',
    permissions: ['知识管理', '知识分类维护', '知识发布下架', '查看审计摘要'],
    favoriteKnowledgeIds: ['k2', 'k5'],
    recentKnowledgeIds: ['k5', 'k2'],
    todoCount: 1
  },
  {
    id: 'u5',
    name: '王晨曦',
    account: 'frontend01',
    password: '123456',
    department: '前端开发组',
    departmentId: 'd-frontend',
    managerId: 'u2',
    jobTitle: '前端开发工程师',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k5', 'k4'],
    todoCount: 0
  },
  {
    id: 'u6',
    name: '陈思远',
    account: 'backend01',
    password: '123456',
    department: '后端开发组',
    departmentId: 'd-backend',
    managerId: 'u2',
    jobTitle: '后端开发工程师',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k5', 'k4'],
    todoCount: 0
  },
  {
    id: 'u7',
    name: '赵子涵',
    account: 'qa01',
    password: '123456',
    department: '测试与质量组',
    departmentId: 'd-qa',
    managerId: 'u2',
    jobTitle: '测试工程师',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k5', 'k4'],
    todoCount: 0
  },
  {
    id: 'u8',
    name: '孙若琳',
    account: 'itops01',
    password: '123456',
    department: '基础设施组',
    departmentId: 'd-itops',
    managerId: 'u3',
    jobTitle: 'IT 运维工程师',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k4'],
    todoCount: 0
  },
  {
    id: 'u9',
    name: '许景行',
    account: 'security01',
    password: '123456',
    department: '安全合规组',
    departmentId: 'd-security',
    managerId: 'u3',
    jobTitle: '安全合规专员',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k4'],
    todoCount: 0
  },
  {
    id: 'u10',
    name: '刘雅琴',
    account: 'hr01',
    password: '123456',
    department: '人力资源部',
    departmentId: 'd-hr',
    managerId: 'u20',
    jobTitle: '人力资源总监',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k1'],
    todoCount: 0
  },
  {
    id: 'u11',
    name: '郑博文',
    account: 'finance01',
    password: '123456',
    department: '财务部',
    departmentId: 'd-finance',
    managerId: 'u20',
    jobTitle: '财务经理',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u12',
    name: '黄思敏',
    account: 'sales01',
    password: '123456',
    department: '销售中心',
    departmentId: 'd-sales',
    managerId: 'u20',
    jobTitle: '销售总监',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u13',
    name: '马可',
    account: 'cs01',
    password: '123456',
    department: '客户成功中心',
    departmentId: 'd-customer-success',
    managerId: 'u20',
    jobTitle: '客户成功中心负责人',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u14',
    name: '周子墨',
    account: 'cs02',
    password: '123456',
    department: '客户成功组',
    departmentId: 'd-customer-success-group',
    managerId: 'u13',
    jobTitle: '客户成功主管',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u15',
    name: '唐雨桐',
    account: 'procurement01',
    password: '123456',
    department: '采购与行政部',
    departmentId: 'd-procurement-admin',
    managerId: 'u20',
    jobTitle: '采购与行政部负责人',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k3'],
    todoCount: 0
  },
  {
    id: 'u16',
    name: '罗嘉',
    account: 'office01',
    password: '123456',
    department: '行政组',
    departmentId: 'd-office',
    managerId: 'u15',
    jobTitle: '行政主管',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k1'],
    todoCount: 0
  },
  {
    id: 'u17',
    name: '何子怡',
    account: 'sales-east01',
    password: '123456',
    department: '华东销售组',
    departmentId: 'd-sales-east',
    managerId: 'u12',
    jobTitle: '区域销售代表',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u18',
    name: '叶启明',
    account: 'sales-south01',
    password: '123456',
    department: '华南销售组',
    departmentId: 'd-sales-south',
    managerId: 'u12',
    jobTitle: '区域销售代表',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k2'],
    todoCount: 0
  },
  {
    id: 'u19',
    name: '彭晓峰',
    account: 'knowledgeeditor01',
    password: '123456',
    department: '知识运营组',
    departmentId: 'd-knowledge',
    managerId: 'u4',
    jobTitle: '知识编辑',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k5'],
    todoCount: 0
  },
  {
    id: 'u20',
    name: '许昭远',
    account: 'ceo01',
    password: '123456',
    department: '总裁办',
    departmentId: 'd-executive',
    managerId: '',
    jobTitle: '总经理',
    employmentStatus: 'active',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程', '签到签退', '内部邮件'],
    favoriteKnowledgeIds: [],
    recentKnowledgeIds: ['k1', 'k2', 'k3'],
    todoCount: 0
  }
];

const departments: DepartmentProfile[] = [
  {
    id: 'd-rd',
    name: '产品研发部',
    parentId: '',
    leaderId: 'u2',
    sortOrder: 1,
    status: 'active'
  },
  {
    id: 'd-it',
    name: '信息化管理部',
    parentId: '',
    leaderId: 'u3',
    sortOrder: 2,
    status: 'active'
  },
  {
    id: 'd-knowledge',
    name: '知识运营组',
    parentId: '',
    leaderId: 'u4',
    sortOrder: 3,
    status: 'active'
  },
  {
    id: 'd-executive',
    name: '总裁办',
    parentId: '',
    leaderId: 'u20',
    sortOrder: 4,
    status: 'active'
  },
  {
    id: 'd-frontend',
    name: '前端开发组',
    parentId: 'd-rd',
    leaderId: 'u2',
    sortOrder: 11,
    status: 'active'
  },
  {
    id: 'd-backend',
    name: '后端开发组',
    parentId: 'd-rd',
    leaderId: 'u2',
    sortOrder: 12,
    status: 'active'
  },
  {
    id: 'd-qa',
    name: '测试与质量组',
    parentId: 'd-rd',
    leaderId: 'u2',
    sortOrder: 13,
    status: 'active'
  },
  {
    id: 'd-itops',
    name: '基础设施组',
    parentId: 'd-it',
    leaderId: 'u3',
    sortOrder: 21,
    status: 'active'
  },
  {
    id: 'd-security',
    name: '安全合规组',
    parentId: 'd-it',
    leaderId: 'u3',
    sortOrder: 22,
    status: 'active'
  },
  {
    id: 'd-hr',
    name: '人力资源部',
    parentId: '',
    leaderId: 'u10',
    sortOrder: 5,
    status: 'active'
  },
  {
    id: 'd-finance',
    name: '财务部',
    parentId: '',
    leaderId: 'u11',
    sortOrder: 6,
    status: 'active'
  },
  {
    id: 'd-sales',
    name: '销售中心',
    parentId: '',
    leaderId: 'u12',
    sortOrder: 7,
    status: 'active'
  },
  {
    id: 'd-sales-east',
    name: '华东销售组',
    parentId: 'd-sales',
    leaderId: 'u12',
    sortOrder: 71,
    status: 'active'
  },
  {
    id: 'd-sales-south',
    name: '华南销售组',
    parentId: 'd-sales',
    leaderId: 'u12',
    sortOrder: 72,
    status: 'active'
  },
  {
    id: 'd-customer-success',
    name: '客户成功中心',
    parentId: '',
    leaderId: 'u13',
    sortOrder: 8,
    status: 'active'
  },
  {
    id: 'd-customer-success-group',
    name: '客户成功组',
    parentId: 'd-customer-success',
    leaderId: 'u14',
    sortOrder: 81,
    status: 'active'
  },
  {
    id: 'd-procurement-admin',
    name: '采购与行政部',
    parentId: '',
    leaderId: 'u15',
    sortOrder: 9,
    status: 'active'
  },
  {
    id: 'd-office',
    name: '行政组',
    parentId: 'd-procurement-admin',
    leaderId: 'u16',
    sortOrder: 91,
    status: 'active'
  }
];

const categories: KnowledgeCategory[] = [
  { id: 'c1', name: '行政人事', description: '请假、考勤与入职相关制度' },
  { id: 'c2', name: '财务报销', description: '差旅、发票与费用标准' },
  { id: 'c3', name: '采购管理', description: '采购申请与合同审批规范' },
  { id: 'c4', name: 'IT 支持', description: '账号权限与设备申请指南' },
  { id: 'c5', name: '项目资料', description: '项目规范与开发文档' }
];

const articles: KnowledgeArticle[] = [
  {
    id: 'k1',
    title: '请假制度说明',
    summary: '说明年假、事假、病假的申请入口、审批要求与材料规范。',
    content: '员工请假需提前发起申请，病假需补充证明材料。超过 3 天的请假需要部门负责人审批，并同步更新团队排期。',
    categoryId: 'c1',
    categoryName: '行政人事',
    tags: ['请假', '考勤', '制度'],
    updateTime: '2026-07-10',
    version: 'v1.2',
    status: 'published',
    attachments: ['请假流程图.pdf'],
    relatedWorkflowIds: ['wf1']
  },
  {
    id: 'k2',
    title: '差旅报销制度',
    summary: '覆盖差旅发票、住宿、交通与打车报销所需材料及额度标准。',
    content: '报销打车费需上传发票、行程截图和事由说明。单笔超 5000 元的报销申请需要二次安全确认并留痕。',
    categoryId: 'c2',
    categoryName: '财务报销',
    tags: ['报销', '发票', '差旅'],
    updateTime: '2026-07-09',
    version: 'v2.1',
    status: 'published',
    attachments: ['报销材料清单.xlsx'],
    relatedWorkflowIds: ['wf2']
  },
  {
    id: 'k3',
    title: '采购申请规范',
    summary: '描述采购申请、预算填写、供应商比选与合同审批注意事项。',
    content: '采购申请需要明确用途、预算、期望到货时间。涉及固定资产采购时，需要补充资产归属说明与验收负责人。',
    categoryId: 'c3',
    categoryName: '采购管理',
    tags: ['采购', '预算', '合同'],
    updateTime: '2026-07-08',
    version: 'v1.5',
    status: 'published',
    attachments: ['采购模板.docx'],
    relatedWorkflowIds: ['wf3']
  },
  {
    id: 'k4',
    title: '系统权限申请规范',
    summary: '介绍企业系统账号、权限开通、回收与审批节点要求。',
    content: '申请系统权限时需说明业务场景、系统名称、期限范围和直属负责人。敏感系统权限会附加安全确认步骤。',
    categoryId: 'c4',
    categoryName: 'IT 支持',
    tags: ['权限', '账号', 'IT'],
    updateTime: '2026-07-11',
    version: 'v1.1',
    status: 'published',
    attachments: ['权限矩阵表.xlsx'],
    relatedWorkflowIds: ['wf4']
  }
];

const templates: WorkflowTemplate[] = [
  {
    id: 'wf1',
    name: '请假申请',
    description: '填写请假类型、时间与原因，提交给部门负责人审批。',
    approverText: '部门负责人',
    relatedKnowledgeIds: ['k1'],
    riskLevel: 'normal',
    riskHint: '常规人员流程，无需额外安全确认。',
    defaultApproverRoles: ['approver']
  },
  {
    id: 'wf2',
    name: '报销申请',
    description: '填写费用类型、金额、事由并上传材料，支持高金额安全确认。',
    approverText: '部门负责人 / 财务复核',
    relatedKnowledgeIds: ['k2'],
    riskLevel: 'high',
    riskHint: '金额超过 5000 元会触发二次安全确认和审计留痕。',
    defaultApproverRoles: ['approver', 'systemAdmin']
  },
  {
    id: 'wf3',
    name: '采购申请',
    description: '填写采购物品、预算、用途和期望到货时间。',
    approverText: '部门负责人 / 采购复核',
    relatedKnowledgeIds: ['k3'],
    riskLevel: 'high',
    riskHint: '高金额采购需进行风险检测并走二次确认。',
    defaultApproverRoles: ['approver', 'systemAdmin']
  },
  {
    id: 'wf4',
    name: '权限申请',
    description: '申请业务系统账号或访问权限，可预填申请说明。',
    approverText: '部门负责人 / 系统管理员',
    relatedKnowledgeIds: ['k4'],
    riskLevel: 'normal',
    riskHint: '敏感系统账号会由系统管理员完成最终开通确认。',
    defaultApproverRoles: ['approver', 'systemAdmin']
  }
];

let workflowInstances: WorkflowInstance[] = [
  {
    id: 'i1',
    templateId: 'wf2',
    title: '差旅报销 - 华南客户拜访',
    applicantId: 'u1',
    applicantName: '张晓宁',
    status: 'pending',
    currentNode: '等待部门负责人审批',
    currentApproverRole: 'approver',
    createTime: '2026-07-12 09:20',
    latestComment: '已提交，等待审批。',
    relatedKnowledgeIds: ['k2'],
    amount: 3680,
    formSummary: '打车与住宿报销，需补充电子发票和行程截图。',
    formDetail: ['费用类型：差旅', '报销金额：3680 元', '事由：华南客户拜访', '附件：发票+行程截图'],
    approvalRecords: [
      {
        id: 'ar1',
        nodeName: '提交流程',
        operatorRole: 'employee',
        operatorName: '张晓宁',
        decision: 'submitted',
        comment: '已提交差旅报销材料。',
        time: '2026-07-12 09:20'
      }
    ],
    riskLevel: 'normal',
    riskReason: '',
    requiresSecurityConfirm: false,
    securityConfirmed: false
  },
  {
    id: 'i2',
    templateId: 'wf4',
    title: '权限申请 - 项目看板访问',
    applicantId: 'u1',
    applicantName: '张晓宁',
    status: 'in_review',
    currentNode: '等待系统管理员确认',
    currentApproverRole: 'systemAdmin',
    createTime: '2026-07-11 15:30',
    latestComment: '部门负责人已通过，待系统管理员开通。',
    relatedKnowledgeIds: ['k4'],
    amount: 0,
    formSummary: '申请项目看板访问权限，用于跟进版本发布。',
    formDetail: ['系统名称：项目看板', '使用期限：2026-07 至 2026-12', '业务场景：版本发布跟踪', '附件：权限矩阵截图'],
    approvalRecords: [
      {
        id: 'ar2',
        nodeName: '提交流程',
        operatorRole: 'employee',
        operatorName: '张晓宁',
        decision: 'submitted',
        comment: '申请项目看板访问权限。',
        time: '2026-07-11 15:30'
      },
      {
        id: 'ar3',
        nodeName: '部门负责人审批',
        operatorRole: 'approver',
        operatorName: '李清越',
        decision: 'approved',
        comment: '业务场景明确，同意流转至系统管理员。',
        time: '2026-07-11 16:20'
      }
    ],
    riskLevel: 'normal',
    riskReason: '',
    requiresSecurityConfirm: false,
    securityConfirmed: false
  },
  {
    id: 'i3',
    templateId: 'wf3',
    title: '采购申请 - 新会议平板',
    applicantId: 'u2',
    applicantName: '李清越',
    status: 'pending_security_confirm',
    currentNode: '等待数字盾二次确认',
    currentApproverRole: 'systemAdmin',
    createTime: '2026-07-10 10:10',
    latestComment: '金额较高，已触发采购风险确认。',
    relatedKnowledgeIds: ['k3'],
    amount: 12800,
    formSummary: '采购会议平板 2 台，用于客户演示室升级。',
    formDetail: ['采购物品：会议平板', '预算金额：12800 元', '用途：客户演示室升级', '期望到货：2026-07-20'],
    approvalRecords: [
      {
        id: 'ar4',
        nodeName: '提交流程',
        operatorRole: 'approver',
        operatorName: '李清越',
        decision: 'submitted',
        comment: '采购演示设备。',
        time: '2026-07-10 10:10'
      },
      {
        id: 'ar5',
        nodeName: '部门负责人审批',
        operatorRole: 'approver',
        operatorName: '李清越',
        decision: 'approved',
        comment: '预算合理，进入安全确认。',
        time: '2026-07-10 11:00'
      }
    ],
    riskLevel: 'high',
    riskReason: '采购金额超过 10000 元，需进行二次确认。',
    requiresSecurityConfirm: true,
    securityConfirmed: false
  }
];

let notifications: NotificationItem[] = [
  {
    id: 'n1',
    title: '报销申请待处理',
    content: '张晓宁提交了“差旅报销 - 华南客户拜访”，请尽快审批。',
    time: '10 分钟前',
    read: false,
    targetRoles: ['approver'],
    targetType: 'workflow',
    targetId: 'i1'
  },
  {
    id: 'n2',
    title: '权限申请进入下一节点',
    content: '你的权限申请已由部门负责人通过，正在等待系统管理员处理。',
    time: '1 小时前',
    read: false,
    targetRoles: ['employee'],
    targetType: 'workflow',
    targetId: 'i2'
  },
  {
    id: 'n3',
    title: '知识更新提醒',
    content: '《系统权限申请规范》已发布新版本 v1.1。',
    time: '今天',
    read: false,
    targetRoles: ['knowledgeAdmin', 'systemAdmin'],
    targetType: 'knowledge',
    targetId: 'k4'
  },
  {
    id: 'n5',
    title: '今日考勤提醒',
    content: '你今天已签到，离下班还有一段时间，记得在离岗前完成签退。',
    time: '刚刚',
    read: false,
    targetRoles: ['employee'],
    targetType: 'attendance',
    targetId: 'today'
  },
  {
    id: 'n6',
    title: '收到一封内部邮件',
    content: '李清越发来“报销材料已补充，请查收”，可直接进入邮件查看详情。',
    time: '5 分钟前',
    read: false,
    targetRoles: ['employee'],
    targetType: 'mail',
    targetId: 'mail2'
  }
];

let corrections: KnowledgeCorrection[] = [];

let attendanceRecords: AttendanceRecord[] = [
  {
    id: 'at1',
    userId: 'u1',
    userName: '张晓宁',
    type: 'checkIn',
    time: '2026-07-15 08:56',
    location: '深圳南山办公区',
    note: '正常到岗',
    status: 'normal'
  },
  {
    id: 'at2',
    userId: 'u1',
    userName: '张晓宁',
    type: 'checkOut',
    time: '2026-07-14 18:21',
    location: '深圳南山办公区',
    note: '完成日报后签退',
    status: 'normal'
  },
  {
    id: 'at3',
    userId: 'u1',
    userName: '张晓宁',
    type: 'checkIn',
    time: '2026-07-14 09:18',
    location: '深圳南山办公区',
    note: '早会后签到',
    status: 'late'
  }
];

let mails: MailMessage[] = [
  {
    id: 'mail1',
    subject: '请确认下周客户拜访排期',
    summary: '需要负责人确认出差安排，并同步给行政同事预订酒店。',
    content: '李经理你好，我计划下周二到周三前往广州拜访客户，烦请帮忙确认排期是否可行。确认后我会同步行政同事预订酒店，并补充差旅申请材料。',
    senderId: 'u1',
    senderName: '张晓宁',
    recipients: [
      {
        userId: 'u2',
        userName: '李清越',
        read: false,
        readTime: ''
      }
    ],
    folder: 'sent',
    importance: 'important',
    createTime: '2026-07-15 09:30',
    read: true,
    relatedWorkflowId: 'i1',
    relatedKnowledgeId: 'k2'
  },
  {
    id: 'mail2',
    subject: '报销材料已补充，请查收',
    summary: '已补齐发票和行程截图，可直接进入审批。',
    content: '你的差旅报销材料已补充完整，包括电子发票、行程截图和事由说明。请在流程页查看最新附件，如无问题可直接审批。',
    senderId: 'u2',
    senderName: '李清越',
    recipients: [
      {
        userId: 'u1',
        userName: '张晓宁',
        read: false,
        readTime: ''
      }
    ],
    folder: 'inbox',
    importance: 'normal',
    createTime: '2026-07-15 10:12',
    read: false,
    relatedWorkflowId: 'i1',
    relatedKnowledgeId: 'k2'
  },
  {
    id: 'mail3',
    subject: '权限规范已更新',
    summary: '系统权限申请规范已更新到 v1.1，请研发同学查看。',
    content: '知识运营已更新《系统权限申请规范》到 v1.1，新增了敏感系统申请的说明，请相关同学在提交流程前先阅读最新版本。',
    senderId: 'u4',
    senderName: '林知夏',
    recipients: [
      {
        userId: 'u1',
        userName: '张晓宁',
        read: true,
        readTime: '2026-07-15 10:20'
      }
    ],
    folder: 'inbox',
    importance: 'important',
    createTime: '2026-07-15 09:55',
    read: true,
    relatedWorkflowId: '',
    relatedKnowledgeId: 'k4'
  }
];

function cloneStringArray(items: string[]): string[] {
  return items.map((item: string) => item);
}

function cloneRoleArray(items: UserRole[]): UserRole[] {
  return items.map((item: UserRole) => item);
}

function cloneUser(user: UserProfile): UserProfile {
  return {
    id: user.id,
    name: user.name,
    account: user.account,
    password: user.password,
    department: user.department,
    role: user.role,
    roleLabel: user.roleLabel,
    permissions: cloneStringArray(user.permissions),
    favoriteKnowledgeIds: cloneStringArray(user.favoriteKnowledgeIds),
    recentKnowledgeIds: cloneStringArray(user.recentKnowledgeIds),
    todoCount: user.todoCount,
    departmentId: user.departmentId,
    managerId: user.managerId,
    jobTitle: user.jobTitle,
    employmentStatus: user.employmentStatus
  };
}

function getDepartmentById(departmentId: string): DepartmentProfile | undefined {
  return departments.find((item: DepartmentProfile) => item.id === departmentId);
}

function buildDirectoryItem(user: UserProfile): DirectoryItem {
  const manager: UserProfile | undefined = users.find((item: UserProfile) => item.id === user.managerId);
  return {
    id: user.id,
    name: user.name,
    account: user.account,
    departmentId: user.departmentId,
    departmentName: getDepartmentById(user.departmentId)?.name ?? user.department,
    jobTitle: user.jobTitle,
    managerId: user.managerId,
    managerName: manager?.name ?? '',
    employmentStatus: user.employmentStatus
  };
}

function cloneDirectoryItem(item: DirectoryItem): DirectoryItem {
  return {
    id: item.id,
    name: item.name,
    account: item.account,
    departmentId: item.departmentId,
    departmentName: item.departmentName,
    jobTitle: item.jobTitle,
    managerId: item.managerId,
    managerName: item.managerName,
    employmentStatus: item.employmentStatus
  };
}

function getVisibleDirectoryUsers(user: UserProfile, scope: string): UserProfile[] {
  if (user.role === 'systemAdmin' && scope === 'all') {
    return users.filter((item: UserProfile) => item.employmentStatus === 'active');
  }
  return users.filter((item: UserProfile) => {
    return item.employmentStatus === 'active' && item.departmentId === user.departmentId;
  });
}

function cloneArticle(article: KnowledgeArticle): KnowledgeArticle {
  return {
    id: article.id,
    title: article.title,
    summary: article.summary,
    content: article.content,
    categoryId: article.categoryId,
    categoryName: article.categoryName,
    tags: cloneStringArray(article.tags),
    updateTime: article.updateTime,
    version: article.version,
    status: article.status,
    attachments: cloneStringArray(article.attachments),
    relatedWorkflowIds: cloneStringArray(article.relatedWorkflowIds),
    favorite: article.favorite
  };
}

function cloneTemplate(template: WorkflowTemplate): WorkflowTemplate {
  return {
    id: template.id,
    name: template.name,
    description: template.description,
    approverText: template.approverText,
    relatedKnowledgeIds: cloneStringArray(template.relatedKnowledgeIds),
    riskLevel: template.riskLevel,
    riskHint: template.riskHint,
    defaultApproverRoles: cloneRoleArray(template.defaultApproverRoles)
  };
}

function cloneApprovalRecord(record: ApprovalRecord): ApprovalRecord {
  return {
    id: record.id,
    nodeName: record.nodeName,
    operatorRole: record.operatorRole,
    operatorName: record.operatorName,
    decision: record.decision,
    comment: record.comment,
    time: record.time
  };
}

function cloneWorkflow(instance: WorkflowInstance): WorkflowInstance {
  return {
    id: instance.id,
    templateId: instance.templateId,
    title: instance.title,
    applicantId: instance.applicantId,
    applicantName: instance.applicantName,
    status: instance.status,
    currentNode: instance.currentNode,
    currentApproverRole: instance.currentApproverRole,
    createTime: instance.createTime,
    latestComment: instance.latestComment,
    relatedKnowledgeIds: cloneStringArray(instance.relatedKnowledgeIds),
    amount: instance.amount,
    formSummary: instance.formSummary,
    formDetail: cloneStringArray(instance.formDetail),
    approvalRecords: instance.approvalRecords.map((item: ApprovalRecord) => cloneApprovalRecord(item)),
    riskLevel: instance.riskLevel,
    riskReason: instance.riskReason,
    requiresSecurityConfirm: instance.requiresSecurityConfirm,
    securityConfirmed: instance.securityConfirmed
  };
}

function cloneNotification(item: NotificationItem): NotificationItem {
  return {
    id: item.id,
    title: item.title,
    content: item.content,
    time: item.time,
    read: item.read,
    targetRoles: cloneRoleArray(item.targetRoles),
    targetType: item.targetType,
    targetId: item.targetId
  };
}

function cloneAttendanceRecord(item: AttendanceRecord): AttendanceRecord {
  return {
    id: item.id,
    userId: item.userId,
    userName: item.userName,
    type: item.type,
    time: item.time,
    location: item.location,
    note: item.note,
    status: item.status
  };
}

function cloneMailRecipient(item: MailRecipient): MailRecipient {
  return {
    userId: item.userId,
    userName: item.userName,
    read: item.read,
    readTime: item.readTime
  };
}

function cloneMail(item: MailMessage): MailMessage {
  return {
    id: item.id,
    subject: item.subject,
    summary: item.summary,
    content: item.content,
    senderId: item.senderId,
    senderName: item.senderName,
    recipients: item.recipients.map((recipient: MailRecipient) => cloneMailRecipient(recipient)),
    folder: item.folder,
    importance: item.importance,
    createTime: item.createTime,
    read: item.read,
    relatedWorkflowId: item.relatedWorkflowId,
    relatedKnowledgeId: item.relatedKnowledgeId
  };
}

function getTokenAccount(token: string): string {
  if (!token.startsWith('mock-token-')) {
    return '';
  }
  return token.replace('mock-token-', '');
}

export function getUserByToken(token: string): UserProfile {
  const account: string = getTokenAccount(token);
  const user: UserProfile | undefined = users.find((item: UserProfile) => item.account === account);
  if (user === undefined) {
    throw new Error('未登录或 Token 无效');
  }
  return user;
}

export function authenticate(account: string, password: string): { token: string; user: UserProfile } {
  const user: UserProfile | undefined = users.find((item: UserProfile) => item.account === account && item.password === password);
  if (user === undefined) {
    throw new Error('账号或密码错误，请重试。');
  }
  return {
    token: `mock-token-${user.account}`,
    user: cloneUser(user)
  };
}

export function getMyOrganization(token: string): OrganizationProfile {
  const user: UserProfile = getUserByToken(token);
  const manager: UserProfile | undefined = users.find((item: UserProfile) => item.id === user.managerId);
  const directReports: UserProfile[] = users.filter((item: UserProfile) => {
    return item.managerId === user.id && item.employmentStatus === 'active';
  });
  const departmentMembers: UserProfile[] = users.filter((item: UserProfile) => {
    return item.departmentId === user.departmentId && item.employmentStatus === 'active';
  });
  return {
    employee: cloneDirectoryItem(buildDirectoryItem(user)),
    manager: manager === undefined ? null : cloneDirectoryItem(buildDirectoryItem(manager)),
    directReports: directReports.map((item: UserProfile) => cloneDirectoryItem(buildDirectoryItem(item))),
    departmentMembers: departmentMembers.map((item: UserProfile) => cloneDirectoryItem(buildDirectoryItem(item)))
  };
}

export function getDepartmentTree(token: string): DepartmentTreeItem[] {
  const user: UserProfile = getUserByToken(token);
  const visibleDepartments: DepartmentProfile[] = user.role === 'systemAdmin'
    ? departments.filter((item: DepartmentProfile) => item.status === 'active')
    : departments.filter((item: DepartmentProfile) => item.id === user.departmentId);
  const buildTree = (parentId: string): DepartmentTreeItem[] => {
    return visibleDepartments
      .filter((item: DepartmentProfile) => item.parentId === parentId)
      .sort((left: DepartmentProfile, right: DepartmentProfile) => left.sortOrder - right.sortOrder)
      .map((item: DepartmentProfile) => {
        const leader: UserProfile | undefined = users.find((candidate: UserProfile) => candidate.id === item.leaderId);
        return {
          id: item.id,
          name: item.name,
          parentId: item.parentId,
          leaderId: item.leaderId,
          sortOrder: item.sortOrder,
          status: item.status,
          leaderName: leader?.name ?? '',
          children: buildTree(item.id)
        };
      });
  };
  return buildTree('');
}

export function searchOrganizationUsers(
  token: string,
  scope: string,
  departmentId: string,
  keyword: string,
  activeOnly: boolean
): DirectoryItem[] {
  const currentUser: UserProfile = getUserByToken(token);
  const normalizedKeyword: string = keyword.trim().toLowerCase();
  const visibleUsers: UserProfile[] = getVisibleDirectoryUsers(currentUser, scope);
  return visibleUsers
    .filter((item: UserProfile) => departmentId.length === 0 || item.departmentId === departmentId)
    .filter((item: UserProfile) => !activeOnly || item.employmentStatus === 'active')
    .filter((item: UserProfile) => {
      if (normalizedKeyword.length === 0) {
        return true;
      }
      return item.name.toLowerCase().includes(normalizedKeyword) ||
        item.account.toLowerCase().includes(normalizedKeyword) ||
        item.jobTitle.toLowerCase().includes(normalizedKeyword);
    })
    .map((item: UserProfile) => cloneDirectoryItem(buildDirectoryItem(item)));
}

export function getCategories(): KnowledgeCategory[] {
  return categories.map((item: KnowledgeCategory) => ({ id: item.id, name: item.name, description: item.description }));
}

export function getArticles(token: string): KnowledgeArticle[] {
  const user: UserProfile = getUserByToken(token);
  return articles.map((item: KnowledgeArticle) => {
    const article: KnowledgeArticle = cloneArticle(item);
    article.favorite = user.favoriteKnowledgeIds.includes(item.id);
    return article;
  });
}

export function favoriteArticle(token: string, articleId: string): { articleId: string; favorite: boolean } {
  const user: UserProfile = getUserByToken(token);
  if (!user.favoriteKnowledgeIds.includes(articleId)) {
    user.favoriteKnowledgeIds.unshift(articleId);
  }
  return { articleId, favorite: true };
}

export function unfavoriteArticle(token: string, articleId: string): { articleId: string; favorite: boolean } {
  const user: UserProfile = getUserByToken(token);
  user.favoriteKnowledgeIds = user.favoriteKnowledgeIds.filter((item: string) => item !== articleId);
  return { articleId, favorite: false };
}

export function createCorrection(token: string, articleId: string, content: string): KnowledgeCorrection {
  const user: UserProfile = getUserByToken(token);
  const item: KnowledgeCorrection = {
    id: `correction-${Date.now()}`,
    articleId,
    userId: user.id,
    content,
    createTime: '刚刚'
  };
  corrections.unshift(item);
  return { ...item };
}

export function getWorkflowTemplates(): WorkflowTemplate[] {
  return templates.map((item: WorkflowTemplate) => cloneTemplate(item));
}

export function getMyWorkflowInstances(token: string): WorkflowInstance[] {
  const user: UserProfile = getUserByToken(token);
  return workflowInstances
    .filter((item: WorkflowInstance) => item.applicantId === user.id)
    .map((item: WorkflowInstance) => cloneWorkflow(item));
}

export function getTodoWorkflowInstances(token: string): WorkflowInstance[] {
  const user: UserProfile = getUserByToken(token);
  return workflowInstances
    .filter((item: WorkflowInstance) => {
      return item.currentApproverRole === user.role &&
        (item.status === 'pending' || item.status === 'in_review' || item.status === 'pending_security_confirm');
    })
    .map((item: WorkflowInstance) => cloneWorkflow(item));
}

export function getWorkflowInstanceById(instanceId: string): WorkflowInstance {
  const item: WorkflowInstance | undefined = workflowInstances.find((workflow: WorkflowInstance) => workflow.id === instanceId);
  if (item === undefined) {
    throw new Error('流程不存在');
  }
  return cloneWorkflow(item);
}

function findTemplate(templateId: string): WorkflowTemplate {
  const template: WorkflowTemplate | undefined = templates.find((item: WorkflowTemplate) => item.id === templateId);
  if (template === undefined) {
    throw new Error('流程模板不存在');
  }
  return template;
}

function appendNotification(item: NotificationItem): void {
  notifications.unshift(item);
}

export function createWorkflow(token: string, payload: {
  templateId: string;
  title: string;
  extraInput: string;
  dateInput: string;
  amountInput: number;
  reasonInput: string;
  attachmentInput: string;
}): { id: string } {
  const user: UserProfile = getUserByToken(token);
  const template: WorkflowTemplate = findTemplate(payload.templateId);
  const amountValue: number = Number(payload.amountInput ?? 0);
  const requiresSecurityConfirm: boolean =
    (template.id === 'wf2' && amountValue > 5000) ||
    (template.id === 'wf3' && amountValue > 10000);
  const riskReason: string = template.id === 'wf2'
    ? '报销金额超过 5000 元，需进行二次确认。'
    : '采购金额超过 10000 元，需进行二次确认。';

  const instanceId: string = `i${Date.now()}`;
  const workflow: WorkflowInstance = {
    id: instanceId,
    templateId: template.id,
    title: `${template.name} - ${payload.title}`,
    applicantId: user.id,
    applicantName: user.name,
    status: 'pending',
    currentNode: `等待${template.approverText}处理`,
    currentApproverRole: template.defaultApproverRoles[0],
    createTime: '刚刚',
    latestComment: '已提交，等待审批。',
    relatedKnowledgeIds: cloneStringArray(template.relatedKnowledgeIds),
    amount: amountValue,
    formSummary: payload.reasonInput,
    formDetail: [payload.extraInput, payload.dateInput, payload.attachmentInput].filter((item: string) => item.length > 0),
    approvalRecords: [
      {
        id: `ar${Date.now()}`,
        nodeName: '提交流程',
        operatorRole: user.role,
        operatorName: user.name,
        decision: 'submitted',
        comment: '提交了新的流程申请。',
        time: '刚刚'
      }
    ],
    riskLevel: requiresSecurityConfirm ? 'high' : 'normal',
    riskReason: requiresSecurityConfirm ? riskReason : '',
    requiresSecurityConfirm,
    securityConfirmed: false
  };
  workflowInstances.unshift(workflow);
  appendNotification({
    id: `n${Date.now()}`,
    title: `${template.name}待处理`,
    content: `${user.name}提交了“${workflow.title}”，请尽快处理。`,
    time: '刚刚',
    read: false,
    targetRoles: cloneRoleArray(template.defaultApproverRoles),
    targetType: 'workflow',
    targetId: workflow.id
  });
  return { id: workflow.id };
}

export function approveWorkflow(token: string, instanceId: string, comment: string): { id: string } {
  const user: UserProfile = getUserByToken(token);
  const item: WorkflowInstance | undefined = workflowInstances.find((workflow: WorkflowInstance) => workflow.id === instanceId);
  if (item === undefined) {
    throw new Error('流程不存在');
  }

  item.approvalRecords.push({
    id: `ar${Date.now()}`,
    nodeName: item.currentNode,
    operatorRole: user.role,
    operatorName: user.name,
    decision: 'approved',
    comment,
    time: '刚刚'
  });

  if (item.requiresSecurityConfirm) {
    item.status = 'pending_security_confirm';
    item.currentApproverRole = 'systemAdmin';
    item.currentNode = '等待数字盾二次确认';
    item.latestComment = `${user.name} 已通过，进入二次确认。`;
  } else if (item.currentApproverRole === 'approver' && item.templateId === 'wf4') {
    item.status = 'in_review';
    item.currentApproverRole = 'systemAdmin';
    item.currentNode = '等待系统管理员确认';
    item.latestComment = `${user.name} 已通过，流转至系统管理员。`;
  } else {
    item.status = 'approved';
    item.currentNode = '流程结束';
    item.latestComment = `${user.name} 已通过审批。`;
  }
  return { id: item.id };
}

export function rejectWorkflow(token: string, instanceId: string, comment: string): { id: string } {
  const user: UserProfile = getUserByToken(token);
  const item: WorkflowInstance | undefined = workflowInstances.find((workflow: WorkflowInstance) => workflow.id === instanceId);
  if (item === undefined) {
    throw new Error('流程不存在');
  }
  item.status = 'rejected';
  item.currentNode = '流程已驳回';
  item.latestComment = `${user.name}：${comment}`;
  item.approvalRecords.push({
    id: `ar${Date.now()}`,
    nodeName: item.currentNode,
    operatorRole: user.role,
    operatorName: user.name,
    decision: 'rejected',
    comment,
    time: '刚刚'
  });
  return { id: item.id };
}

export function securityConfirmWorkflow(token: string, instanceId: string, comment: string): { id: string } {
  const user: UserProfile = getUserByToken(token);
  const item: WorkflowInstance | undefined = workflowInstances.find((workflow: WorkflowInstance) => workflow.id === instanceId);
  if (item === undefined) {
    throw new Error('流程不存在');
  }
  item.status = 'approved';
  item.currentNode = '流程结束';
  item.securityConfirmed = true;
  item.latestComment = `${user.name} 已完成二次确认。`;
  item.approvalRecords.push({
    id: `ar${Date.now()}`,
    nodeName: '二次确认',
    operatorRole: user.role,
    operatorName: user.name,
    decision: 'security_confirmed',
    comment,
    time: '刚刚'
  });
  return { id: item.id };
}

export function getNotifications(token: string, unreadOnly?: boolean): NotificationItem[] {
  const user: UserProfile = getUserByToken(token);
  return notifications
    .filter((item: NotificationItem) => item.targetRoles.includes(user.role))
    .filter((item: NotificationItem) => (unreadOnly ? !item.read : true))
    .map((item: NotificationItem) => cloneNotification(item));
}

export function markNotificationRead(notificationId: string): { id: string; read: boolean } {
  const item: NotificationItem | undefined = notifications.find((notification: NotificationItem) => notification.id === notificationId);
  if (item === undefined) {
    throw new Error('消息不存在');
  }
  item.read = true;
  return {
    id: item.id,
    read: true
  };
}

export function askAssistant(question: string): AssistantReply {
  const keyword: string = question.trim();
  if (keyword.length === 0) {
    throw new Error('问题不能为空');
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
  return {
    answer: '当前版本先使用规则问答，后续可以接入更完整的大模型服务。',
    relatedKnowledgeIds: ['k1', 'k2'],
    recommendedWorkflowId: 'wf1'
  };
}

function buildTodaySummary(user: UserProfile): AttendanceTodaySummary {
  const userRecords: AttendanceRecord[] = attendanceRecords
    .filter((item: AttendanceRecord) => item.userId === user.id)
    .sort((left: AttendanceRecord, right: AttendanceRecord) => right.time.localeCompare(left.time));
  const todayCheckIn: AttendanceRecord | undefined = userRecords.find((item: AttendanceRecord) => item.time.startsWith('2026-07-15') && item.type === 'checkIn');
  const todayCheckOut: AttendanceRecord | undefined = userRecords.find((item: AttendanceRecord) => item.time.startsWith('2026-07-15') && item.type === 'checkOut');
  return {
    date: '2026-07-15',
    checkedIn: todayCheckIn !== undefined,
    checkedOut: todayCheckOut !== undefined,
    checkInTime: todayCheckIn === undefined ? '' : todayCheckIn.time.slice(11),
    checkOutTime: todayCheckOut === undefined ? '' : todayCheckOut.time.slice(11),
    workDurationText: todayCheckIn === undefined ? '今日尚未开始考勤' : (todayCheckOut === undefined ? '已工作 3 小时 24 分' : '今日工作 8 小时 16 分'),
    statusText: todayCheckIn === undefined ? '今日未签到' : (todayCheckOut === undefined ? '今日正常出勤' : '今日考勤已完成'),
    location: todayCheckIn === undefined ? '深圳南山办公区' : todayCheckIn.location,
    recentRecords: userRecords.map((item: AttendanceRecord) => cloneAttendanceRecord(item))
  };
}

export function getAttendanceToday(token: string): AttendanceTodaySummary {
  const user: UserProfile = getUserByToken(token);
  return buildTodaySummary(user);
}

export function getAttendanceRecords(token: string): AttendanceRecord[] {
  const user: UserProfile = getUserByToken(token);
  return attendanceRecords
    .filter((item: AttendanceRecord) => item.userId === user.id)
    .sort((left: AttendanceRecord, right: AttendanceRecord) => right.time.localeCompare(left.time))
    .map((item: AttendanceRecord) => cloneAttendanceRecord(item));
}

export function checkIn(token: string, location: string, note: string): AttendanceTodaySummary {
  const user: UserProfile = getUserByToken(token);
  attendanceRecords.unshift({
    id: `at${Date.now()}`,
    userId: user.id,
    userName: user.name,
    type: 'checkIn',
    time: '2026-07-15 09:02',
    location,
    note,
    status: 'normal'
  });
  return buildTodaySummary(user);
}

export function checkOut(token: string, location: string, note: string): AttendanceTodaySummary {
  const user: UserProfile = getUserByToken(token);
  attendanceRecords.unshift({
    id: `at${Date.now()}`,
    userId: user.id,
    userName: user.name,
    type: 'checkOut',
    time: '2026-07-15 18:06',
    location,
    note,
    status: 'normal'
  });
  return buildTodaySummary(user);
}

export function getInbox(token: string): MailMessage[] {
  const user: UserProfile = getUserByToken(token);
  return mails
    .filter((item: MailMessage) => item.folder === 'inbox' && item.recipients.some((recipient: MailRecipient) => recipient.userId === user.id))
    .map((item: MailMessage) => cloneMail(item));
}

export function getSent(token: string): MailMessage[] {
  const user: UserProfile = getUserByToken(token);
  return mails
    .filter((item: MailMessage) => item.folder === 'sent' && item.senderId === user.id)
    .map((item: MailMessage) => cloneMail(item));
}

export function getMail(token: string, mailId: string): MailMessage {
  const user: UserProfile = getUserByToken(token);
  const item: MailMessage | undefined = mails.find((mail: MailMessage) => {
    return mail.id === mailId &&
      (mail.senderId === user.id || mail.recipients.some((recipient: MailRecipient) => recipient.userId === user.id));
  });
  if (item === undefined) {
    throw new Error('邮件不存在');
  }
  return cloneMail(item);
}

export function sendMail(token: string, payload: {
  receiverIds: string[];
  subject: string;
  content: string;
  relatedWorkflowId: string;
  relatedKnowledgeId: string;
}): { id: string } {
  const user: UserProfile = getUserByToken(token);
  const recipients: MailRecipient[] = payload.receiverIds.map((receiverId: string, index: number) => {
    const receiver: UserProfile | undefined = users.find((item: UserProfile) => item.id === receiverId);
    if (receiver === undefined) {
      throw new Error(`收件人不存在: ${receiverId}`);
    }
    return {
      userId: receiver.id,
      userName: receiver.name,
      read: false,
      readTime: index === 0 ? '' : ''
    };
  });
  const id: string = `mail${Date.now()}`;
  const mail: MailMessage = {
    id,
    subject: payload.subject,
    summary: payload.content.slice(0, 40),
    content: payload.content,
    senderId: user.id,
    senderName: user.name,
    recipients,
    folder: 'sent',
    importance: 'normal',
    createTime: '刚刚',
    read: true,
    relatedWorkflowId: payload.relatedWorkflowId,
    relatedKnowledgeId: payload.relatedKnowledgeId
  };
  mails.unshift(mail);

  recipients.forEach((recipient: MailRecipient) => {
    mails.unshift({
      id,
      subject: payload.subject,
      summary: payload.content.slice(0, 40),
      content: payload.content,
      senderId: user.id,
      senderName: user.name,
      recipients: recipients.map((item: MailRecipient) => cloneMailRecipient(item)),
      folder: 'inbox',
      importance: 'normal',
      createTime: '刚刚',
      read: false,
      relatedWorkflowId: payload.relatedWorkflowId,
      relatedKnowledgeId: payload.relatedKnowledgeId
    });
    appendNotification({
      id: `n${Date.now()}${recipient.userId}`,
      title: '收到一封内部邮件',
      content: `${user.name} 发来“${payload.subject}”，可进入邮件查看。`,
      time: '刚刚',
      read: false,
      targetRoles: [users.find((item: UserProfile) => item.id === recipient.userId)?.role ?? 'employee'],
      targetType: 'mail',
      targetId: id
    });
  });
  return { id };
}

export function markMailRead(token: string, mailId: string): { id: string; read: boolean } {
  const user: UserProfile = getUserByToken(token);
  mails.forEach((item: MailMessage) => {
    if (item.id === mailId && item.recipients.some((recipient: MailRecipient) => recipient.userId === user.id)) {
      item.read = true;
      item.recipients = item.recipients.map((recipient: MailRecipient) => {
        if (recipient.userId !== user.id) {
          return recipient;
        }
        return {
          userId: recipient.userId,
          userName: recipient.userName,
          read: true,
          readTime: '刚刚'
        };
      });
    }
  });
  return { id: mailId, read: true };
}

export function deleteMail(token: string, mailId: string): { id: string } {
  const user: UserProfile = getUserByToken(token);
  mails = mails.filter((item: MailMessage) => {
    if (item.id !== mailId) {
      return true;
    }
    return !(item.senderId === user.id || item.recipients.some((recipient: MailRecipient) => recipient.userId === user.id));
  });
  return { id: mailId };
}

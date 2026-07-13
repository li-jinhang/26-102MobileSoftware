import {
  ApprovalRecord,
  AssistantReply,
  AuditLog,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  User,
  UserRole,
  WorkflowInstance,
  WorkflowTemplate
} from '../models/AppModels';

const mockUsers: User[] = [
  {
    id: 'u1',
    name: '张晓宁',
    account: 'employee01',
    password: '123456',
    department: '产品研发部',
    role: 'employee',
    roleLabel: '普通员工',
    permissions: ['知识查询', '收藏知识', '发起流程', '查看我的流程'],
    favoriteKnowledgeIds: ['k2', 'k4'],
    recentKnowledgeIds: ['k1', 'k2', 'k3'],
    todoCount: 2
  },
  {
    id: 'u2',
    name: '李清越',
    account: 'manager01',
    password: '123456',
    department: '部门负责人',
    role: 'approver',
    roleLabel: '审批人',
    permissions: ['知识查询', '发起流程', '处理待办', '查看关联制度'],
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
    role: 'knowledgeAdmin',
    roleLabel: '知识管理员',
    permissions: ['知识管理', '知识分类维护', '知识发布下架', '查看审计摘要'],
    favoriteKnowledgeIds: ['k2', 'k5'],
    recentKnowledgeIds: ['k5', 'k2'],
    todoCount: 1
  }
];

const mockCategories: KnowledgeCategory[] = [
  { id: 'all', name: '全部', description: '查看所有已发布知识' },
  { id: 'c1', name: '行政人事', description: '请假、考勤与入职相关制度' },
  { id: 'c2', name: '财务报销', description: '差旅、发票与费用标准' },
  { id: 'c3', name: '采购管理', description: '采购申请与合同审批规范' },
  { id: 'c4', name: 'IT 支持', description: '账号权限与设备申请指南' },
  { id: 'c5', name: '项目资料', description: '项目规范与开发文档' },
  { id: 'c6', name: '培训材料', description: '培训课件与经验沉淀' }
];

const mockArticles: KnowledgeArticle[] = [
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
  },
  {
    id: 'k5',
    title: '项目交付文档模板',
    summary: '整理项目开发、测试、上线交付所需的文档清单与版本要求。',
    content: '项目交付前需要补齐需求文档、测试报告、上线说明和回滚预案。文档应统一归档到项目资料知识库中。',
    categoryId: 'c5',
    categoryName: '项目资料',
    tags: ['项目', '交付', '文档'],
    updateTime: '2026-07-07',
    version: 'v1.0',
    status: 'published',
    attachments: ['交付材料清单.zip'],
    relatedWorkflowIds: []
  }
];

const mockTemplates: WorkflowTemplate[] = [
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

const mockInstances: WorkflowInstance[] = [
  {
    id: 'i1',
    templateId: 'wf2',
    title: '差旅报销 - 华南客户拜访',
    applicantId: 'u1',
    applicantName: '张晓宁',
    status: '待审批',
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
    status: '审批中',
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
    status: '待二次确认',
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

const mockNotifications: NotificationItem[] = [
  {
    id: 'n1',
    title: '报销申请待处理',
    content: '张晓宁提交了“差旅报销 - 华南客户拜访”，请尽快审批。',
    time: '10 分钟前',
    read: false,
    targetRoles: ['approver']
  },
  {
    id: 'n2',
    title: '权限申请进入下一节点',
    content: '你的权限申请已由部门负责人通过，正在等待系统管理员处理。',
    time: '1 小时前',
    read: false,
    targetRoles: ['employee']
  },
  {
    id: 'n3',
    title: '知识更新提醒',
    content: '《系统权限申请规范》已发布新版本 v1.1。',
    time: '今天',
    read: false,
    targetRoles: ['employee', 'approver', 'systemAdmin', 'knowledgeAdmin']
  },
  {
    id: 'n4',
    title: '高风险采购待二次确认',
    content: '“采购申请 - 新会议平板”已触发安全确认，请系统管理员处理。',
    time: '今天',
    read: true,
    targetRoles: ['systemAdmin']
  }
];

const mockAuditLogs: AuditLog[] = [
  {
    id: 'log1',
    module: '流程审批',
    action: '提交报销申请',
    operatorName: '张晓宁',
    operatorRole: 'employee',
    riskLevel: 'normal',
    detail: '提交了“差旅报销 - 华南客户拜访”，材料待部门负责人审核。',
    time: '2026-07-12 09:20'
  },
  {
    id: 'log2',
    module: '安全治理',
    action: '触发采购风险检测',
    operatorName: '李清越',
    operatorRole: 'approver',
    riskLevel: 'high',
    detail: '采购金额 12800 元，系统要求进入二次安全确认流程。',
    time: '2026-07-10 11:00'
  },
  {
    id: 'log3',
    module: '系统管理',
    action: '查看权限申请',
    operatorName: '周承安',
    operatorRole: 'systemAdmin',
    riskLevel: 'normal',
    detail: '查看“权限申请 - 项目看板访问”的开通材料。',
    time: '2026-07-11 16:35'
  }
];

function copyStringArray(source: string[]): string[] {
  const target: string[] = [];
  source.forEach((item: string) => {
    target.push(item);
  });
  return target;
}

function copyUserRoleArray(source: UserRole[]): UserRole[] {
  const target: UserRole[] = [];
  source.forEach((item: UserRole) => {
    target.push(item);
  });
  return target;
}

function cloneApprovalRecord(item: ApprovalRecord): ApprovalRecord {
  return {
    id: item.id,
    nodeName: item.nodeName,
    operatorRole: item.operatorRole,
    operatorName: item.operatorName,
    decision: item.decision,
    comment: item.comment,
    time: item.time
  };
}

function copyApprovalRecords(source: ApprovalRecord[]): ApprovalRecord[] {
  const target: ApprovalRecord[] = [];
  source.forEach((item: ApprovalRecord) => {
    target.push(cloneApprovalRecord(item));
  });
  return target;
}

function cloneUser(item: User): User {
  return {
    id: item.id,
    name: item.name,
    account: item.account,
    password: item.password,
    department: item.department,
    role: item.role,
    roleLabel: item.roleLabel,
    permissions: copyStringArray(item.permissions),
    favoriteKnowledgeIds: copyStringArray(item.favoriteKnowledgeIds),
    recentKnowledgeIds: copyStringArray(item.recentKnowledgeIds),
    todoCount: item.todoCount
  };
}

function cloneCategory(item: KnowledgeCategory): KnowledgeCategory {
  return {
    id: item.id,
    name: item.name,
    description: item.description
  };
}

function cloneArticle(item: KnowledgeArticle): KnowledgeArticle {
  return {
    id: item.id,
    title: item.title,
    summary: item.summary,
    content: item.content,
    categoryId: item.categoryId,
    categoryName: item.categoryName,
    tags: copyStringArray(item.tags),
    updateTime: item.updateTime,
    version: item.version,
    status: item.status,
    attachments: copyStringArray(item.attachments),
    relatedWorkflowIds: copyStringArray(item.relatedWorkflowIds)
  };
}

function cloneTemplate(item: WorkflowTemplate): WorkflowTemplate {
  return {
    id: item.id,
    name: item.name,
    description: item.description,
    approverText: item.approverText,
    relatedKnowledgeIds: copyStringArray(item.relatedKnowledgeIds),
    riskLevel: item.riskLevel,
    riskHint: item.riskHint,
    defaultApproverRoles: copyUserRoleArray(item.defaultApproverRoles)
  };
}

function cloneInstance(item: WorkflowInstance): WorkflowInstance {
  return {
    id: item.id,
    templateId: item.templateId,
    title: item.title,
    applicantId: item.applicantId,
    applicantName: item.applicantName,
    status: item.status,
    currentNode: item.currentNode,
    currentApproverRole: item.currentApproverRole,
    createTime: item.createTime,
    latestComment: item.latestComment,
    relatedKnowledgeIds: copyStringArray(item.relatedKnowledgeIds),
    amount: item.amount,
    formSummary: item.formSummary,
    formDetail: copyStringArray(item.formDetail),
    approvalRecords: copyApprovalRecords(item.approvalRecords),
    riskLevel: item.riskLevel,
    riskReason: item.riskReason,
    requiresSecurityConfirm: item.requiresSecurityConfirm,
    securityConfirmed: item.securityConfirmed
  };
}

function cloneNotification(item: NotificationItem): NotificationItem {
  return {
    id: item.id,
    title: item.title,
    content: item.content,
    time: item.time,
    read: item.read,
    targetRoles: copyUserRoleArray(item.targetRoles)
  };
}

function cloneAuditLog(item: AuditLog): AuditLog {
  return {
    id: item.id,
    module: item.module,
    action: item.action,
    operatorName: item.operatorName,
    operatorRole: item.operatorRole,
    riskLevel: item.riskLevel,
    detail: item.detail,
    time: item.time
  };
}

export function getMockUsers(): User[] {
  const list: User[] = [];
  mockUsers.forEach((item: User) => {
    list.push(cloneUser(item));
  });
  return list;
}

export function getMockCategories(): KnowledgeCategory[] {
  const list: KnowledgeCategory[] = [];
  mockCategories.forEach((item: KnowledgeCategory) => {
    list.push(cloneCategory(item));
  });
  return list;
}

export function getMockArticles(): KnowledgeArticle[] {
  const list: KnowledgeArticle[] = [];
  mockArticles.forEach((item: KnowledgeArticle) => {
    list.push(cloneArticle(item));
  });
  return list;
}

export function getMockTemplates(): WorkflowTemplate[] {
  const list: WorkflowTemplate[] = [];
  mockTemplates.forEach((item: WorkflowTemplate) => {
    list.push(cloneTemplate(item));
  });
  return list;
}

export function getMockInstances(): WorkflowInstance[] {
  const list: WorkflowInstance[] = [];
  mockInstances.forEach((item: WorkflowInstance) => {
    list.push(cloneInstance(item));
  });
  return list;
}

export function getMockNotifications(): NotificationItem[] {
  const list: NotificationItem[] = [];
  mockNotifications.forEach((item: NotificationItem) => {
    list.push(cloneNotification(item));
  });
  return list;
}

export function getMockAuditLogs(): AuditLog[] {
  const list: AuditLog[] = [];
  mockAuditLogs.forEach((item: AuditLog) => {
    list.push(cloneAuditLog(item));
  });
  return list;
}

export function authenticateUser(account: string, password: string): User | null {
  const currentUser: User | undefined = mockUsers.find((item: User) => item.account === account && item.password === password);
  if (currentUser === undefined) {
    return null;
  }

  return cloneUser(currentUser);
}

export function buildWorkflowInstance(
  template: WorkflowTemplate,
  user: User,
  titleSuffix: string,
  formSummary: string,
  formDetail: string[],
  amount: number,
  riskReason: string,
  requiresSecurityConfirm: boolean
): WorkflowInstance {
  const timestamp: number = Date.now();
  return {
    id: `i${timestamp}`,
    templateId: template.id,
    title: `${template.name} - ${titleSuffix}`,
    applicantId: user.id,
    applicantName: user.name,
    status: '待审批',
    currentNode: `等待${template.approverText}处理`,
    currentApproverRole: template.defaultApproverRoles[0],
    createTime: '刚刚',
    latestComment: '已从移动端发起流程。',
    relatedKnowledgeIds: copyStringArray(template.relatedKnowledgeIds),
    amount: amount,
    formSummary: formSummary,
    formDetail: copyStringArray(formDetail),
    approvalRecords: [
      {
        id: `ar${timestamp}`,
        nodeName: '提交流程',
        operatorRole: user.role,
        operatorName: user.name,
        decision: 'submitted',
        comment: '提交了新的流程申请。',
        time: '刚刚'
      }
    ],
    riskLevel: requiresSecurityConfirm ? 'high' : 'normal',
    riskReason: riskReason,
    requiresSecurityConfirm: requiresSecurityConfirm,
    securityConfirmed: false
  };
}

export function askAssistant(question: string): AssistantReply {
  const keyword: string = question.trim();

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

  if (keyword.includes('采购') || keyword.includes('预算') || keyword.includes('合同')) {
    return {
      answer: '采购流程需补充用途、预算和期望到货时间，可参考《采购申请规范》后发起“采购申请”。',
      relatedKnowledgeIds: ['k3'],
      recommendedWorkflowId: 'wf3'
    };
  }

  return {
    answer: '我已经为你检索到相关知识入口。当前基础版本采用关键词匹配，后续可以接入更完整的智能问答能力。',
    relatedKnowledgeIds: ['k1', 'k2'],
    recommendedWorkflowId: 'wf1'
  };
}

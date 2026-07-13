import {
  AssistantReply,
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
    permissions: ['知识管理', '用户角色管理', '流程模板管理', '查看操作日志'],
    favoriteKnowledgeIds: ['k3'],
    recentKnowledgeIds: ['k1', 'k5'],
    todoCount: 3
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
    riskLevel: 'normal'
  },
  {
    id: 'wf2',
    name: '报销申请',
    description: '填写费用类型、金额、事由并上传材料，支持高金额安全确认。',
    approverText: '部门负责人 / 财务',
    relatedKnowledgeIds: ['k2'],
    riskLevel: 'high'
  },
  {
    id: 'wf3',
    name: '采购申请',
    description: '填写采购物品、预算、用途和期望到货时间。',
    approverText: '部门负责人 / 采购负责人',
    relatedKnowledgeIds: ['k3'],
    riskLevel: 'high'
  },
  {
    id: 'wf4',
    name: '权限申请',
    description: '申请业务系统账号或访问权限，可预填申请说明。',
    approverText: '部门负责人 / 系统管理员',
    relatedKnowledgeIds: ['k4'],
    riskLevel: 'normal'
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
    relatedKnowledgeIds: ['k2']
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
    relatedKnowledgeIds: ['k4']
  },
  {
    id: 'i3',
    templateId: 'wf1',
    title: '请假申请 - 7 月 15 日',
    applicantId: 'u2',
    applicantName: '李清越',
    status: '已通过',
    currentNode: '流程结束',
    currentApproverRole: 'approver',
    createTime: '2026-07-10 10:10',
    latestComment: '审批已完成。',
    relatedKnowledgeIds: ['k1']
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
    targetRoles: ['employee', 'approver', 'systemAdmin']
  },
  {
    id: 'n4',
    title: '管理台待完善',
    content: '请补充用户、角色与流程模板配置数据。',
    time: '今天',
    read: true,
    targetRoles: ['systemAdmin']
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

function cloneUser(item: User): User {
  const user: User = {
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
  return user;
}

function cloneCategory(item: KnowledgeCategory): KnowledgeCategory {
  const category: KnowledgeCategory = {
    id: item.id,
    name: item.name,
    description: item.description
  };
  return category;
}

function cloneArticle(item: KnowledgeArticle): KnowledgeArticle {
  const article: KnowledgeArticle = {
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
  return article;
}

function cloneTemplate(item: WorkflowTemplate): WorkflowTemplate {
  const template: WorkflowTemplate = {
    id: item.id,
    name: item.name,
    description: item.description,
    approverText: item.approverText,
    relatedKnowledgeIds: copyStringArray(item.relatedKnowledgeIds),
    riskLevel: item.riskLevel
  };
  return template;
}

function cloneInstance(item: WorkflowInstance): WorkflowInstance {
  const instance: WorkflowInstance = {
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
    relatedKnowledgeIds: copyStringArray(item.relatedKnowledgeIds)
  };
  return instance;
}

function cloneNotification(item: NotificationItem): NotificationItem {
  const notification: NotificationItem = {
    id: item.id,
    title: item.title,
    content: item.content,
    time: item.time,
    read: item.read,
    targetRoles: copyUserRoleArray(item.targetRoles)
  };
  return notification;
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

export function authenticateUser(account: string, password: string): User | null {
  const currentUser: User | undefined = mockUsers.find((item: User) => item.account === account && item.password === password);
  if (currentUser === undefined) {
    return null;
  }

  return cloneUser(currentUser);
}

export function buildWorkflowInstance(template: WorkflowTemplate, user: User): WorkflowInstance {
  const timestamp: number = Date.now();
  const instance: WorkflowInstance = {
    id: `i${timestamp}`,
    templateId: template.id,
    title: `${template.name} - ${user.name}`,
    applicantId: user.id,
    applicantName: user.name,
    status: '待审批',
    currentNode: '等待审批人处理',
    currentApproverRole: template.id === 'wf4' ? 'systemAdmin' : 'approver',
    createTime: '刚刚',
    latestComment: '已从移动端发起流程。',
    relatedKnowledgeIds: copyStringArray(template.relatedKnowledgeIds)
  };
  return instance;
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

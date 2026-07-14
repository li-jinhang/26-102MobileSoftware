import {
  AuditLog,
  KnowledgeArticle,
  NotificationItem,
  User,
  WorkflowInstance,
  WorkflowTemplate
} from '../../models/AppModels';

export function getArticleByIdUseCase(articles: KnowledgeArticle[], articleId: string): KnowledgeArticle | null {
  const item: KnowledgeArticle | undefined = articles.find((article: KnowledgeArticle) => article.id === articleId);
  return item === undefined ? null : item;
}

export function getTemplateByIdUseCase(templates: WorkflowTemplate[], templateId: string): WorkflowTemplate | null {
  const item: WorkflowTemplate | undefined = templates.find((template: WorkflowTemplate) => template.id === templateId);
  return item === undefined ? null : item;
}

export function getWorkflowByIdUseCase(workflowInstances: WorkflowInstance[], workflowId: string): WorkflowInstance | null {
  const item: WorkflowInstance | undefined = workflowInstances.find((workflow: WorkflowInstance) => workflow.id === workflowId);
  return item === undefined ? null : item;
}

export function getPublishedArticlesUseCase(articles: KnowledgeArticle[]): KnowledgeArticle[] {
  return articles.filter((item: KnowledgeArticle) => item.status === 'published');
}

export function getRecentArticlesUseCase(currentUser: User | null, articles: KnowledgeArticle[]): KnowledgeArticle[] {
  if (currentUser === null) {
    return [];
  }

  const list: KnowledgeArticle[] = [];
  currentUser.recentKnowledgeIds.forEach((id: string) => {
    const item: KnowledgeArticle | null = getArticleByIdUseCase(articles, id);
    if (item !== null) {
      list.push(item);
    }
  });
  return list;
}

export function getFavoriteArticlesUseCase(favoriteKnowledgeIds: string[], articles: KnowledgeArticle[]): KnowledgeArticle[] {
  const list: KnowledgeArticle[] = [];
  favoriteKnowledgeIds.forEach((id: string) => {
    const item: KnowledgeArticle | null = getArticleByIdUseCase(articles, id);
    if (item !== null) {
      list.push(item);
    }
  });
  return list;
}

export function getVisibleMessagesUseCase(currentUser: User | null, notifications: NotificationItem[]): NotificationItem[] {
  if (currentUser === null) {
    return [];
  }

  return notifications.filter((item: NotificationItem) => item.targetRoles.includes(currentUser.role));
}

export function getUnreadMessageCountUseCase(currentUser: User | null, notifications: NotificationItem[]): number {
  return getVisibleMessagesUseCase(currentUser, notifications).filter((item: NotificationItem) => !item.read).length;
}

export function getMyWorkflowsUseCase(currentUser: User | null, workflowInstances: WorkflowInstance[]): WorkflowInstance[] {
  if (currentUser === null) {
    return [];
  }

  return workflowInstances.filter((item: WorkflowInstance) => item.applicantId === currentUser.id);
}

export function getTodoWorkflowsUseCase(currentUser: User | null, workflowInstances: WorkflowInstance[]): WorkflowInstance[] {
  if (currentUser === null) {
    return [];
  }

  return workflowInstances.filter((item: WorkflowInstance) => {
    const isInCharge: boolean = item.currentApproverRole === currentUser.role;
    const isPending: boolean = item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
    return isInCharge && isPending;
  });
}

export function getDashboardTodoCountUseCase(currentUser: User | null, workflowInstances: WorkflowInstance[]): number {
  if (currentUser === null) {
    return 0;
  }

  if (currentUser.role === 'employee') {
    return getMyWorkflowsUseCase(currentUser, workflowInstances).filter((item: WorkflowInstance) => {
      return item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
    }).length;
  }

  return getTodoWorkflowsUseCase(currentUser, workflowInstances).length;
}

export function getActiveWorkflowCountUseCase(workflowInstances: WorkflowInstance[]): number {
  return workflowInstances.filter((item: WorkflowInstance) => {
    return item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
  }).length;
}

export function getHighRiskWorkflowCountUseCase(workflowInstances: WorkflowInstance[]): number {
  return workflowInstances.filter((item: WorkflowInstance) => item.riskLevel === 'high').length;
}

export function getSelectedTemplateUseCase(templates: WorkflowTemplate[], selectedTemplateId: string): WorkflowTemplate {
  const item: WorkflowTemplate | null = getTemplateByIdUseCase(templates, selectedTemplateId);
  return item === null ? templates[0] : item;
}

export function getSelectedArticleUseCase(articles: KnowledgeArticle[], selectedArticleId: string): KnowledgeArticle | null {
  return getArticleByIdUseCase(articles, selectedArticleId);
}

export function getSelectedArticleRequiredUseCase(articles: KnowledgeArticle[], selectedArticleId: string): KnowledgeArticle {
  const item: KnowledgeArticle | null = getSelectedArticleUseCase(articles, selectedArticleId);
  return item === null ? articles[0] : item;
}

export function getTemplateNameUseCase(templates: WorkflowTemplate[], templateId: string): string {
  const item: WorkflowTemplate | null = getTemplateByIdUseCase(templates, templateId);
  return item === null ? '流程' : item.name;
}

export function getRelatedKnowledgeTitlesUseCase(knowledgeIds: string[], articles: KnowledgeArticle[]): string {
  return knowledgeIds.map((item: string) => {
    const article: KnowledgeArticle | null = getArticleByIdUseCase(articles, item);
    return article === null ? '未命名知识' : article.title;
  }).join('、');
}

export function getSelectedArticleWorkflowNamesUseCase(
  articles: KnowledgeArticle[],
  selectedArticleId: string,
  templates: WorkflowTemplate[]
): string {
  const item: KnowledgeArticle | null = getSelectedArticleUseCase(articles, selectedArticleId);
  if (item === null) {
    return '';
  }

  return item.relatedWorkflowIds.map((workflowId: string) => {
    return getTemplateNameUseCase(templates, workflowId);
  }).join('、');
}

export function getVisibleAuditLogsUseCase(currentUser: User | null, auditLogs: AuditLog[]): AuditLog[] {
  if (currentUser === null) {
    return [];
  }

  if (currentUser.role === 'systemAdmin') {
    return auditLogs.slice(0, 6);
  }

  if (currentUser.role === 'knowledgeAdmin') {
    return auditLogs.filter((item: AuditLog) => item.module !== '身份认证').slice(0, 4);
  }

  return auditLogs.filter((item: AuditLog) => {
    return item.module === '流程审批' || item.module === '安全治理';
  }).slice(0, 4);
}

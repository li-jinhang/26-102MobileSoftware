import {
  AuditLog,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  WorkflowInstance,
  WorkflowTemplate
} from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export interface AppBootstrapData {
  categories: KnowledgeCategory[];
  articles: KnowledgeArticle[];
  templates: WorkflowTemplate[];
  workflowInstances: WorkflowInstance[];
  notifications: NotificationItem[];
  auditLogs: AuditLog[];
}

function mergeWorkflowInstances(myItems: WorkflowInstance[], todoItems: WorkflowInstance[]): WorkflowInstance[] {
  const map = new Map<string, WorkflowInstance>();
  myItems.forEach((item: WorkflowInstance) => {
    map.set(item.id, item);
  });
  todoItems.forEach((item: WorkflowInstance) => {
    map.set(item.id, item);
  });
  return Array.from(map.values()).sort((left: WorkflowInstance, right: WorkflowInstance) => {
    return right.createTime.localeCompare(left.createTime);
  });
}

export async function loadAppBootstrapData(): Promise<AppBootstrapData> {
  const categories: KnowledgeCategory[] = await repositories.knowledgeRepository.getCategories();
  const articles: KnowledgeArticle[] = await repositories.knowledgeRepository.getArticles();
  const templates: WorkflowTemplate[] = await repositories.workflowRepository.getTemplates();
  const myInstances: WorkflowInstance[] = await repositories.workflowRepository.getMyInstances();
  const todoInstances: WorkflowInstance[] = await repositories.workflowRepository.getTodoInstances();
  const notifications: NotificationItem[] = await repositories.notificationRepository.getNotifications();
  const auditLogs: AuditLog[] = await repositories.auditRepository.getAuditLogs();

  return {
    categories,
    articles,
    templates,
    workflowInstances: mergeWorkflowInstances(myInstances, todoInstances),
    notifications,
    auditLogs
  };
}

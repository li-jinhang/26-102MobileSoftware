import {
  askAssistant,
  authenticateUser,
  buildWorkflowInstance,
  getMockArticles,
  getMockAuditLogs,
  getMockCategories,
  getMockInstances,
  getMockNotifications,
  getMockTemplates
} from '../MockData';
import {
  AssistantReply,
  AuditLog,
  KnowledgeCorrection,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  User,
  WorkflowInstance,
  WorkflowTemplate
} from '../../models/AppModels';
import {
  AuditRepository,
  AssistantRepository,
  AuthLoginResult,
  AuthRepository,
  KnowledgeRepository,
  NotificationRepository,
  WorkflowRepository
} from '../../domain/contracts/AppRepositories';

class MockAuthRepository implements AuthRepository {
  async login(account: string, password: string): Promise<AuthLoginResult> {
    const user: User | null = authenticateUser(account, password);
    if (user === null) {
      throw new Error('账号或密码错误，请重试。');
    }
    return {
      token: 'mock-token',
      user
    };
  }

  async logout(): Promise<void> {
  }
}

class MockKnowledgeRepository implements KnowledgeRepository {
  async getCategories(): Promise<KnowledgeCategory[]> {
    return getMockCategories();
  }

  async getArticles(): Promise<KnowledgeArticle[]> {
    return getMockArticles();
  }

  async favorite(articleId: string): Promise<boolean> {
    return true;
  }

  async unfavorite(articleId: string): Promise<boolean> {
    return false;
  }

  async createCorrection(articleId: string, content: string): Promise<KnowledgeCorrection> {
    return {
      id: `correction-${Date.now()}`,
      articleId,
      userId: 'mock-user',
      content,
      createTime: '刚刚'
    };
  }
}

class MockWorkflowRepository implements WorkflowRepository {
  async getTemplates(): Promise<WorkflowTemplate[]> {
    return getMockTemplates();
  }

  async getMyInstances(): Promise<WorkflowInstance[]> {
    return getMockInstances();
  }

  async getTodoInstances(): Promise<WorkflowInstance[]> {
    return getMockInstances();
  }

  async getInstance(instanceId: string): Promise<WorkflowInstance> {
    const item: WorkflowInstance | undefined = getMockInstances().find((workflow: WorkflowInstance) => workflow.id === instanceId);
    if (item === undefined) {
      throw new Error('流程不存在');
    }
    return item;
  }

  async createInstance(input: {
    templateId: string;
    title: string;
    extraInput: string;
    dateInput: string;
    amountInput: number;
    reasonInput: string;
    attachmentInput: string;
  }): Promise<WorkflowInstance> {
    const template: WorkflowTemplate | undefined = getMockTemplates().find((item: WorkflowTemplate) => item.id === input.templateId);
    const user: User | null = authenticateUser('employee01', '123456');
    if (template === undefined || user === null) {
      throw new Error('流程模板不存在');
    }
    return buildWorkflowInstance(
      template,
      user,
      input.title,
      input.reasonInput,
      [input.extraInput, input.dateInput, input.attachmentInput],
      input.amountInput,
      '',
      false
    );
  }

  async approveInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    return this.getInstance(instanceId);
  }

  async rejectInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    return this.getInstance(instanceId);
  }

  async securityConfirmInstance(instanceId: string, comment: string): Promise<WorkflowInstance> {
    return this.getInstance(instanceId);
  }
}

class MockNotificationRepository implements NotificationRepository {
  async getNotifications(unreadOnly?: boolean): Promise<NotificationItem[]> {
    if (unreadOnly) {
      return getMockNotifications().filter((item: NotificationItem) => !item.read);
    }
    return getMockNotifications();
  }

  async markRead(notificationId: string): Promise<void> {
  }
}

class MockAssistantRepository implements AssistantRepository {
  async ask(question: string): Promise<AssistantReply> {
    return askAssistant(question);
  }
}

class MockAuditRepository implements AuditRepository {
  async getAuditLogs(): Promise<AuditLog[]> {
    return getMockAuditLogs();
  }
}

export const mockAuthRepository: AuthRepository = new MockAuthRepository();
export const mockKnowledgeRepository: KnowledgeRepository = new MockKnowledgeRepository();
export const mockWorkflowRepository: WorkflowRepository = new MockWorkflowRepository();
export const mockNotificationRepository: NotificationRepository = new MockNotificationRepository();
export const mockAssistantRepository: AssistantRepository = new MockAssistantRepository();
export const mockAuditRepository: AuditRepository = new MockAuditRepository();

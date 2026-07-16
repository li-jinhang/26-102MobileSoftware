import {
  getMockAttendanceRecords,
  getMockAttendanceTodaySummary,
  askAssistant,
  authenticateUser,
  buildWorkflowInstance,
  getMockArticles,
  getMockAuditLogs,
  getMockCategories,
  getMockInstances,
  getMockMails,
  getMockNotifications,
  getMockTemplates
} from '../MockData';
import {
  AttendanceRecord,
  AttendanceTodaySummary,
  AssistantAnalyzeInput,
  AssistantReply,
  AuditLog,
  KnowledgeCorrection,
  KnowledgeArticle,
  KnowledgeCategory,
  MailMessage,
  NotificationItem,
  DepartmentTreeItem,
  EmployeeDirectoryItem,
  OrganizationProfile,
  User,
  WorkflowInstance,
  WorkflowTemplate
} from '../../models/AppModels';
import {
  AttendanceRepository,
  AttendanceSubmitPayload,
  AuditRepository,
  AssistantRepository,
  AuthLoginResult,
  AuthRepository,
  KnowledgeRepository,
  MailRepository,
  MailSendPayload,
  NotificationRepository,
  OrganizationRepository,
  WorkflowCreatePayload,
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

  async createInstance(input: WorkflowCreatePayload): Promise<WorkflowInstance> {
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

class MockAttendanceRepository implements AttendanceRepository {
  async getTodaySummary(): Promise<AttendanceTodaySummary> {
    return getMockAttendanceTodaySummary();
  }

  async getMyRecords(): Promise<AttendanceRecord[]> {
    return getMockAttendanceRecords();
  }

  async checkIn(input: AttendanceSubmitPayload): Promise<AttendanceTodaySummary> {
    return getMockAttendanceTodaySummary();
  }

  async checkOut(input: AttendanceSubmitPayload): Promise<AttendanceTodaySummary> {
    return getMockAttendanceTodaySummary();
  }
}

class MockMailRepository implements MailRepository {
  async getInbox(): Promise<MailMessage[]> {
    return getMockMails().filter((item: MailMessage) => item.folder === 'inbox');
  }

  async getSent(): Promise<MailMessage[]> {
    return getMockMails().filter((item: MailMessage) => item.folder === 'sent');
  }

  async getMail(mailId: string): Promise<MailMessage> {
    const item: MailMessage | undefined = getMockMails().find((mail: MailMessage) => mail.id === mailId);
    if (item === undefined) {
      throw new Error('邮件不存在');
    }
    return item;
  }

  async sendMail(input: MailSendPayload): Promise<MailMessage> {
    return {
      id: `mail-${Date.now()}`,
      subject: input.subject,
      summary: input.content.slice(0, 36),
      content: input.content,
      senderId: 'u1',
      senderName: '张晓宁',
      recipients: [],
      folder: 'sent',
      importance: 'normal',
      createTime: '刚刚',
      read: true,
      relatedWorkflowId: input.relatedWorkflowId,
      relatedKnowledgeId: input.relatedKnowledgeId
    };
  }

  async markRead(mailId: string): Promise<void> {
  }

  async deleteMail(mailId: string): Promise<void> {
  }
}

class MockOrganizationRepository implements OrganizationRepository {
  async getMyOrganization(): Promise<OrganizationProfile> {
    const user: User | null = authenticateUser('employee01', '123456');
    const employee: EmployeeDirectoryItem = {
      id: user?.id ?? '',
      name: user?.name ?? '',
      account: user?.account ?? '',
      departmentId: user?.departmentId ?? '',
      departmentName: user?.department ?? '',
      jobTitle: user?.jobTitle ?? '',
      managerId: user?.managerId ?? '',
      managerName: '李清越',
      employmentStatus: user?.employmentStatus ?? 'active'
    };
    return {
      employee,
      manager: {
        id: 'u2', name: '李清越', account: 'manager01', departmentId: 'd-rd',
        departmentName: '产品研发部', jobTitle: '研发部负责人', managerId: '', managerName: '', employmentStatus: 'active'
      },
      directReports: [],
      departmentMembers: [employee, {
        id: 'u2', name: '李清越', account: 'manager01', departmentId: 'd-rd',
        departmentName: '产品研发部', jobTitle: '研发部负责人', managerId: '', managerName: '', employmentStatus: 'active'
      }]
    };
  }

  async getDepartmentTree(): Promise<DepartmentTreeItem[]> {
    return [];
  }

  async searchUsers(
    scope: 'department' | 'team' | 'all',
    keyword: string = '',
    departmentId: string = ''
  ): Promise<EmployeeDirectoryItem[]> {
    return (await this.getMyOrganization()).departmentMembers;
  }
}

class MockAssistantRepository implements AssistantRepository {
  async analyze(input: AssistantAnalyzeInput): Promise<AssistantReply> {
    const reply = askAssistant(input.text);
    return {
      answer: reply.answer,
      recognizedText: '',
      intent: 'unknown',
      relatedKnowledgeIds: reply.relatedKnowledgeIds,
      recommendedWorkflowId: reply.recommendedWorkflowId,
      confidence: 0,
      formDraft: {
        title: '', extra: '', date: '', amount: '', reason: '', attachment: ''
      },
      missingFields: [],
      action: { type: 'none', label: '', mailDraft: null }
    };
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
export const mockAttendanceRepository: AttendanceRepository = new MockAttendanceRepository();
export const mockMailRepository: MailRepository = new MockMailRepository();
export const mockOrganizationRepository: OrganizationRepository = new MockOrganizationRepository();
export const mockAssistantRepository: AssistantRepository = new MockAssistantRepository();
export const mockAuditRepository: AuditRepository = new MockAuditRepository();

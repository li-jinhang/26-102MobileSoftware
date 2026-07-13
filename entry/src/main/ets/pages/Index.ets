import { markNotificationRead } from '../common/services/MessageService';
import { validateCorrection } from '../common/services/KnowledgeService';
import { SectionBlock } from '../common/components/SectionBlock';
import { AssistantPage } from '../features/assistant/AssistantPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { KnowledgeDetailPage } from '../features/knowledge/KnowledgeDetailPage';
import { KnowledgePage } from '../features/knowledge/KnowledgePage';
import { MessagesPage } from '../features/messages/MessagesPage';
import { ProfilePage } from '../features/profile/ProfilePage';
import {
  AppSubPage,
  AssistantHistory,
  AssistantReply,
  KnowledgeArticle,
  KnowledgeCategory,
  KnowledgeCorrection,
  NotificationItem,
  ReadingFontScale,
  User,
  UserRole,
  WorkflowInstance,
  WorkflowTemplate
} from '../models/AppModels';
import {
  authenticateUser,
  buildWorkflowInstance,
  getMockArticles,
  getMockCategories,
  getMockInstances,
  getMockNotifications,
  getMockTemplates
} from '../mock/MockData';

@Entry
@Component
struct Index {
  private readonly categories: KnowledgeCategory[] = getMockCategories();
  private readonly articles: KnowledgeArticle[] = getMockArticles();
  private readonly templates: WorkflowTemplate[] = getMockTemplates();
  private readonly tabLabels: string[] = ['工作台', '知识库', '流程', '我的'];
  private readonly tabMarks: string[] = ['工', '知', '流', '我'];

  @State loginAccount: string = 'employee01';
  @State loginPassword: string = '123456';
  @State currentUser: User | null = null;
  @State activeTab: number = 0;
  @State selectedArticleId: string = 'k2';
  @State favoriteKnowledgeIds: string[] = [];
  @State workflowInstances: WorkflowInstance[] = getMockInstances();
  @State notifications: NotificationItem[] = getMockNotifications();
  @State assistantHistory: AssistantHistory[] = [];
  @State assistantQuestion: string = '';
  @State assistantReply: AssistantReply | null = null;
  @State activeSubPage: AppSubPage = 'none';
  @State detailReturnSubPage: AppSubPage = 'none';
  @State usefulKnowledgeIds: string[] = [];
  @State corrections: KnowledgeCorrection[] = [];
  @State readingFontScale: ReadingFontScale = 'standard';

  private copyStringArray(source: string[]): string[] {
    const target: string[] = [];
    source.forEach((item: string) => {
      target.push(item);
    });
    return target;
  }

  private cloneUser(user: User): User {
    const clonedUser: User = {
      id: user.id,
      name: user.name,
      account: user.account,
      password: user.password,
      department: user.department,
      role: user.role,
      roleLabel: user.roleLabel,
      permissions: this.copyStringArray(user.permissions),
      favoriteKnowledgeIds: this.copyStringArray(user.favoriteKnowledgeIds),
      recentKnowledgeIds: this.copyStringArray(user.recentKnowledgeIds),
      todoCount: user.todoCount
    };
    return clonedUser;
  }

  private cloneWorkflowInstance(
    item: WorkflowInstance,
    status: '草稿' | '待审批' | '审批中' | '已驳回' | '已通过' | '已归档',
    currentNode: string,
    currentApproverRole: UserRole,
    latestComment: string
  ): WorkflowInstance {
    const instance: WorkflowInstance = {
      id: item.id,
      templateId: item.templateId,
      title: item.title,
      applicantId: item.applicantId,
      applicantName: item.applicantName,
      status: status,
      currentNode: currentNode,
      currentApproverRole: currentApproverRole,
      createTime: item.createTime,
      latestComment: latestComment,
      relatedKnowledgeIds: this.copyStringArray(item.relatedKnowledgeIds)
    };
    return instance;
  }

  private prependWorkflowInstance(instance: WorkflowInstance): void {
    const list: WorkflowInstance[] = [];
    list.push(instance);
    this.workflowInstances.forEach((item: WorkflowInstance) => {
      list.push(item);
    });
    this.workflowInstances = list;
  }

  private prependNotification(notification: NotificationItem): void {
    const list: NotificationItem[] = [];
    list.push(notification);
    this.notifications.forEach((item: NotificationItem) => {
      list.push(item);
    });
    this.notifications = list;
  }

  build() {
    Column() {
      if (this.currentUser === null) {
        this.LoginView();
      } else {
        this.AppShell();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FB')
  }

  @Builder
  private LoginView() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('智协库')
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text('面向公司内部的知识库与流程协作鸿蒙应用基础框架')
          .fontSize(14)
          .fontColor('#667085')
          .textAlign(TextAlign.Center)
      }
      .margin({ top: 80, bottom: 18 })

      Column({ space: 14 }) {
        TextInput({ placeholder: '请输入账号', text: this.loginAccount })
          .height(52)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.loginAccount = value;
          })

        TextInput({ placeholder: '请输入密码', text: this.loginPassword })
          .type(InputType.Password)
          .height(52)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.loginPassword = value;
          })

        Button('登录并进入工作台')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#246BFD')
          .borderRadius(16)
          .onClick(() => {
            this.handleLogin();
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FDFEFF')
      .borderRadius(24)

      Column({ space: 10 }) {
        Text('课程演示账号')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .width('100%')

        this.DemoAccountCard('employee01', '普通员工', '查看知识、发起流程、跟踪进度');
        this.DemoAccountCard('manager01', '审批人', '处理待办、查看关联制度');
        this.DemoAccountCard('admin01', '系统管理员', '管理模板、用户角色与系统配置');
      }
      .width('100%')

      Text('默认密码：123456')
        .fontSize(12)
        .fontColor('#98A2B3')
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, bottom: 24 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private DemoAccountCard(account: string, roleLabel: string, description: string) {
    Row() {
      Column({ space: 4 }) {
        Text(account)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .width('100%')

        Text(`${roleLabel} · ${description}`)
          .fontSize(12)
          .fontColor('#667085')
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('填入')
        .fontSize(12)
        .height(34)
        .backgroundColor('#E9F0FF')
        .fontColor('#246BFD')
        .borderRadius(12)
        .onClick(() => {
          this.loginAccount = account;
          this.loginPassword = '123456';
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }

  @Builder
  private AppShell() {
    Column() {
      if (this.activeSubPage === 'knowledgeDetail') {
        KnowledgeDetailPage({
          article: this.getSelectedArticleRequired(),
          favorite: this.isFavorite(this.selectedArticleId),
          useful: this.usefulKnowledgeIds.includes(this.selectedArticleId),
          fontScale: this.readingFontScale,
          workflowNames: this.getSelectedArticleWorkflowNames(),
          onBack: () => {
            this.activeSubPage = this.detailReturnSubPage;
            this.detailReturnSubPage = 'none';
          },
          onToggleFavorite: (articleId: string) => {
            this.toggleFavorite(articleId);
          },
          onMarkUseful: (articleId: string) => {
            this.markKnowledgeUseful(articleId);
          },
          onSubmitCorrection: (articleId: string, content: string): boolean => {
            return this.submitCorrection(articleId, content);
          },
          onFontScaleChange: (scale: ReadingFontScale) => {
            this.readingFontScale = scale;
          },
          onStartWorkflow: (templateId: string) => {
            this.startWorkflow(templateId);
          }
        })
      } else if (this.activeSubPage === 'assistant') {
        AssistantPage({
          articles: this.getPublishedArticles(),
          templates: this.templates,
          history: $assistantHistory,
          question: $assistantQuestion,
          reply: $assistantReply,
          onBack: () => {
            this.activeSubPage = 'none';
          },
          onOpenArticle: (articleId: string) => {
            this.openArticle(articleId);
          },
          onStartWorkflow: (templateId: string) => {
            this.startWorkflow(templateId);
          }
        })
      } else if (this.activeSubPage === 'messages') {
        MessagesPage({
          notifications: this.getVisibleMessages(),
          onBack: () => {
            this.activeSubPage = 'none';
          },
          onMarkRead: (notificationId: string) => {
            this.notifications = markNotificationRead(this.notifications, notificationId);
          },
          onOpenKnowledge: (articleId: string) => {
            this.openArticle(articleId);
          },
          onOpenWorkflow: (instanceId: string) => {
            this.openWorkflowFromMessage(instanceId);
          }
        })
      } else {
        this.PageHeader();

        Scroll() {
          Column({ space: 14 }) {
            if (this.activeTab === 0) {
              DashboardPage({
                user: this.getCurrentUser(),
                articles: this.getPublishedArticles(),
                recentArticles: this.getRecentArticles(),
                favoriteArticles: this.getFavoriteArticles(),
                favoriteKnowledgeIds: this.favoriteKnowledgeIds,
                notifications: this.getVisibleMessages(),
                templates: this.templates,
                todoCount: this.getDashboardTodoCount(),
                onOpenArticle: (articleId: string) => {
                  this.openArticle(articleId);
                },
                onOpenAssistant: () => {
                  this.activeSubPage = 'assistant';
                },
                onOpenMessages: () => {
                  this.activeSubPage = 'messages';
                },
                onStartWorkflow: (templateId: string) => {
                  this.startWorkflow(templateId);
                }
              })
            } else if (this.activeTab === 1) {
              KnowledgePage({
                categories: this.categories,
                articles: this.articles,
                favoriteKnowledgeIds: this.favoriteKnowledgeIds,
                onOpenArticle: (articleId: string) => {
                  this.openArticle(articleId);
                }
              })
            } else if (this.activeTab === 2) {
              this.WorkflowTab();
            } else {
              ProfilePage({
                user: this.getCurrentUser(),
                favoriteArticles: this.getFavoriteArticles(),
                unreadCount: this.getUnreadMessageCount(),
                fontScale: this.readingFontScale,
                onOpenArticle: (articleId: string) => {
                  this.openArticle(articleId);
                },
                onOpenMessages: () => {
                  this.activeSubPage = 'messages';
                },
                onFontScaleChange: (scale: ReadingFontScale) => {
                  this.readingFontScale = scale;
                },
                onLogout: () => {
                  this.logout();
                }
              })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 20 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        this.BottomNav();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private PageHeader() {
    Row() {
      Column({ space: 4 }) {
        Text(this.tabLabels[this.activeTab])
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text(`${this.getCurrentUser().name} · ${this.getCurrentUser().roleLabel}`)
          .fontSize(13)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(this.getCurrentUser().department)
        .fontSize(12)
        .fontColor(this.getRoleColor(this.getCurrentUser().role))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 18, bottom: 14 })
    .backgroundColor('#F3F6FB')
  }

  @Builder
  private WorkflowTab() {
    SectionBlock({ title: '流程模板', subtitle: '已预置请假、报销、采购、权限申请四类模板，并关联知识制度。' }) {
      Column({ space: 10 }) {
        ForEach(this.templates, (item: WorkflowTemplate) => {
          Column({ space: 8 }) {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')

              Blank()

              Text(item.approverText)
                .fontSize(11)
                .fontColor('#667085')
            }

            Text(item.description)
              .fontSize(12)
              .fontColor('#667085')
              .lineHeight(18)
              .width('100%')

            Text(`关联制度：${this.getRelatedKnowledgeTitles(item.relatedKnowledgeIds)}`)
              .fontSize(12)
              .fontColor('#344054')

            Button('发起流程')
              .width('100%')
              .height(40)
              .backgroundColor('#246BFD')
              .borderRadius(12)
              .onClick(() => {
                this.startWorkflow(item.id);
              })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#F8FAFF')
          .borderRadius(18)
        }, (item: WorkflowTemplate) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '我的流程', subtitle: '展示当前账号发起的流程及最新状态。' }) {
      Column({ space: 10 }) {
        ForEach(this.getMyWorkflows(), (item: WorkflowInstance) => {
          this.WorkflowCard(item, false);
        }, (item: WorkflowInstance) => item.id)
      }
      .width('100%')
    }

    if (this.getTodoWorkflows().length > 0) {
      SectionBlock({ title: '审批待办', subtitle: '审批人和管理员可直接在这里处理当前节点。' }) {
        Column({ space: 10 }) {
          ForEach(this.getTodoWorkflows(), (item: WorkflowInstance) => {
            this.WorkflowCard(item, true);
          }, (item: WorkflowInstance) => item.id)
        }
        .width('100%')
      }
    }

  }

  @Builder
  private BottomNav() {
    Row() {
      ForEach(this.tabLabels, (item: string, index: number) => {
        Column({ space: 6 }) {
          Text(this.tabMarks[index])
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.activeTab === index ? '#FFFFFF' : '#667085')
            .width(28)
            .height(28)
            .textAlign(TextAlign.Center)
            .padding({ top: 5 })
            .backgroundColor(this.activeTab === index ? '#246BFD' : '#E5E7EB')
            .borderRadius(14)

          Text(item)
            .fontSize(11)
            .fontColor(this.activeTab === index ? '#246BFD' : '#667085')
        }
        .layoutWeight(1)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.activeTab = index;
        })
      }, (item: string) => item)
    }
    .width('100%')
    .padding({ left: 10, right: 10, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  private WorkflowCard(item: WorkflowInstance, showActions: boolean) {
    Column({ space: 8 }) {
      Row() {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .layoutWeight(1)

        Text(item.status)
          .fontSize(11)
          .fontColor(this.getStatusColor(item.status))
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
      }

      Text(`当前节点：${item.currentNode}`)
        .fontSize(12)
        .fontColor('#344054')
        .width('100%')

      Text(`关联制度：${this.getRelatedKnowledgeTitles(item.relatedKnowledgeIds)}`)
        .fontSize(12)
        .fontColor('#667085')
        .width('100%')

      Text(`最新动态：${item.latestComment}`)
        .fontSize(12)
        .fontColor('#667085')
        .lineHeight(18)
        .width('100%')

      if (showActions) {
        Row({ space: 10 }) {
          Button('通过')
            .layoutWeight(1)
            .height(38)
            .backgroundColor('#ECFDF3')
            .fontColor('#027A48')
            .borderRadius(12)
            .onClick(() => {
              this.handleWorkflowDecision(item.id, true);
            })

          Button('驳回')
            .layoutWeight(1)
            .height(38)
            .backgroundColor('#FEF3F2')
            .fontColor('#B42318')
            .borderRadius(12)
            .onClick(() => {
              this.handleWorkflowDecision(item.id, false);
            })
        }
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F8FAFC')
    .borderRadius(18)
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`Index toast failed: ${error}`);
    }
  }

  private markKnowledgeUseful(articleId: string): void {
    if (this.usefulKnowledgeIds.includes(articleId)) {
      return;
    }
    const ids: string[] = [articleId];
    this.usefulKnowledgeIds.forEach((item: string) => {
      ids.push(item);
    });
    this.usefulKnowledgeIds = ids;
  }

  private submitCorrection(articleId: string, content: string): boolean {
    const normalized: string = validateCorrection(content);
    if (normalized.length === 0 || this.currentUser === null) {
      return false;
    }
    const correction: KnowledgeCorrection = {
      id: `correction-${Date.now()}`,
      articleId: articleId,
      userId: this.currentUser.id,
      content: normalized,
      createTime: '刚刚'
    };
    const list: KnowledgeCorrection[] = [correction];
    this.corrections.forEach((item: KnowledgeCorrection) => {
      list.push(item);
    });
    this.corrections = list;
    return true;
  }

  private getUnreadMessageCount(): number {
    return this.getVisibleMessages().filter((item: NotificationItem) => !item.read).length;
  }

  private openWorkflowFromMessage(instanceId: string): void {
    const exists: boolean = this.workflowInstances.some((item: WorkflowInstance) => item.id === instanceId);
    if (!exists) {
      this.showMessage('关联流程暂不可用。');
      return;
    }
    this.activeSubPage = 'none';
    this.detailReturnSubPage = 'none';
    this.activeTab = 2;
    this.showMessage('已进入流程页面。');
  }

  private logout(): void {
    this.currentUser = null;
    this.activeTab = 0;
    this.activeSubPage = 'none';
    this.selectedArticleId = 'k2';
    this.favoriteKnowledgeIds = [];
    this.usefulKnowledgeIds = [];
    this.corrections = [];
    this.assistantHistory = [];
    this.assistantQuestion = '';
    this.assistantReply = null;
    this.readingFontScale = 'standard';
  }

  private handleLogin(): void {
    const user: User | null = authenticateUser(this.loginAccount.trim(), this.loginPassword.trim());
    if (user === null) {
      this.showMessage('账号或密码错误，请重试。');
      return;
    }

    this.currentUser = user;
    this.favoriteKnowledgeIds = this.copyStringArray(user.favoriteKnowledgeIds);
    this.selectedArticleId = user.recentKnowledgeIds.length > 0 ? user.recentKnowledgeIds[0] : 'k1';
    this.activeTab = 0;
    this.activeSubPage = 'none';
    this.detailReturnSubPage = 'none';
    this.usefulKnowledgeIds = [];
    this.corrections = [];
    this.assistantHistory = [];
    this.assistantQuestion = '';
    this.assistantReply = null;
    this.readingFontScale = 'standard';
    this.showMessage(`欢迎你，${user.name}`);
  }

  private startWorkflow(templateId: string): void {
    if (this.currentUser === null) {
      return;
    }

    const template: WorkflowTemplate | null = this.getTemplateById(templateId);
    if (template === null) {
      return;
    }

    const instance: WorkflowInstance = buildWorkflowInstance(template, this.getCurrentUser());
    this.prependWorkflowInstance(instance);
    const notification: NotificationItem = {
      id: `n${Date.now()}`,
      title: `${template.name}已提交`,
      content: `${this.getCurrentUser().name} 发起了新的${template.name}，当前等待处理。`,
      time: '刚刚',
      read: false,
      targetRoles: template.id === 'wf4' ? ['systemAdmin', 'employee'] : ['approver', 'employee'],
      targetType: 'workflow',
      targetId: instance.id
    };
    this.prependNotification(notification);
    this.activeSubPage = 'none';
    this.activeTab = 2;
    this.showMessage(`${template.name} 已创建`);
  }

  private handleWorkflowDecision(instanceId: string, isApproved: boolean): void {
    if (this.currentUser === null) {
      return;
    }

    this.workflowInstances = this.workflowInstances.map((item: WorkflowInstance) => {
      if (item.id !== instanceId) {
        return item;
      }

      if (!isApproved) {
        return this.cloneWorkflowInstance(
          item,
          '已驳回',
          '流程已驳回',
          item.currentApproverRole,
          `${this.getCurrentUser().name} 已驳回，请补充材料后重新提交。`
        );
      }

      if ((item.templateId === 'wf2' || item.templateId === 'wf3') && item.currentApproverRole === 'approver') {
        return this.cloneWorkflowInstance(
          item,
          '审批中',
          '进入下一审批节点',
          'systemAdmin',
          `${this.getCurrentUser().name} 已通过，等待下一审批角色处理。`
        );
      }

      return this.cloneWorkflowInstance(
        item,
        '已通过',
        '流程结束',
        item.currentApproverRole,
        `${this.getCurrentUser().name} 已完成审批。`
      );
    });

    const notification: NotificationItem = {
      id: `n${Date.now()}`,
      title: isApproved ? '流程审批已更新' : '流程被驳回',
      content: isApproved ? '待办流程已处理，申请人将收到新的状态提醒。' : '申请人需要根据审批意见补充并再次提交。',
      time: '刚刚',
      read: false,
      targetRoles: ['employee', 'approver', 'systemAdmin'],
      targetType: 'workflow',
      targetId: instanceId
    };
    this.prependNotification(notification);

    this.showMessage(isApproved ? '已通过当前节点。' : '已驳回该流程。');
  }

  private openArticle(articleId: string): void {
    const article: KnowledgeArticle | null = this.getArticleById(articleId);
    if (article === null || this.currentUser === null) {
      return;
    }

    const recentIds: string[] = [];
    recentIds.push(articleId);
    this.getCurrentUser().recentKnowledgeIds.forEach((id: string) => {
      if (id !== articleId && recentIds.length < 3) {
        recentIds.push(id);
      }
    });
    const updatedUser: User = this.cloneUser(this.getCurrentUser());
    updatedUser.recentKnowledgeIds = recentIds;
    this.currentUser = updatedUser;
    this.selectedArticleId = articleId;
    this.detailReturnSubPage = this.activeSubPage;
    this.activeSubPage = 'knowledgeDetail';
  }

  private toggleFavorite(articleId: string): void {
    if (this.favoriteKnowledgeIds.includes(articleId)) {
      this.favoriteKnowledgeIds = this.favoriteKnowledgeIds.filter((item: string) => item !== articleId);
      this.showMessage('已取消收藏。');
      return;
    }

    const favorites: string[] = [];
    favorites.push(articleId);
    this.favoriteKnowledgeIds.forEach((item: string) => {
      favorites.push(item);
    });
    this.favoriteKnowledgeIds = favorites;
    this.showMessage('已加入收藏。');
  }

  private getCurrentUser(): User {
    if (this.currentUser !== null) {
      return this.currentUser;
    }

    return {
      id: '',
      name: '',
      account: '',
      password: '',
      department: '',
      role: 'employee',
      roleLabel: '',
      permissions: [],
      favoriteKnowledgeIds: [],
      recentKnowledgeIds: [],
      todoCount: 0
    };
  }

  private getDashboardTodoCount(): number {
    if (this.currentUser === null) {
      return 0;
    }

    if (this.getCurrentUser().role === 'employee') {
      return this.getMyWorkflows().filter((item: WorkflowInstance) => item.status === '待审批' || item.status === '审批中').length;
    }

    return this.getTodoWorkflows().length;
  }

  private getPublishedArticles(): KnowledgeArticle[] {
    return this.articles.filter((item: KnowledgeArticle) => item.status === 'published');
  }

  private getRecentArticles(): KnowledgeArticle[] {
    if (this.currentUser === null) {
      return [];
    }

    const list: KnowledgeArticle[] = [];
    this.getCurrentUser().recentKnowledgeIds.forEach((id: string) => {
      const item: KnowledgeArticle | null = this.getArticleById(id);
      if (item !== null) {
        list.push(item);
      }
    });
    return list;
  }

  private getFavoriteArticles(): KnowledgeArticle[] {
    const list: KnowledgeArticle[] = [];
    this.favoriteKnowledgeIds.forEach((id: string) => {
      const item: KnowledgeArticle | null = this.getArticleById(id);
      if (item !== null) {
        list.push(item);
      }
    });
    return list;
  }

  private getVisibleMessages(): NotificationItem[] {
    if (this.currentUser === null) {
      return [];
    }

    return this.notifications.filter((item: NotificationItem) => item.targetRoles.includes(this.getCurrentUser().role));
  }

  private getMyWorkflows(): WorkflowInstance[] {
    if (this.currentUser === null) {
      return [];
    }

    return this.workflowInstances.filter((item: WorkflowInstance) => item.applicantId === this.getCurrentUser().id);
  }

  private getTodoWorkflows(): WorkflowInstance[] {
    if (this.currentUser === null) {
      return [];
    }

    return this.workflowInstances.filter((item: WorkflowInstance) => {
      const isInCharge: boolean = item.currentApproverRole === this.getCurrentUser().role;
      const isPending: boolean = item.status === '待审批' || item.status === '审批中';
      return isInCharge && isPending;
    });
  }

  private getArticleById(articleId: string): KnowledgeArticle | null {
    const item: KnowledgeArticle | undefined = this.articles.find((article: KnowledgeArticle) => article.id === articleId);
    return item ? item : null;
  }

  private getTemplateById(templateId: string): WorkflowTemplate | null {
    const item: WorkflowTemplate | undefined = this.templates.find((template: WorkflowTemplate) => template.id === templateId);
    return item ? item : null;
  }

  private getSelectedArticle(): KnowledgeArticle | null {
    return this.getArticleById(this.selectedArticleId);
  }

  private getSelectedArticleRequired(): KnowledgeArticle {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    if (item !== null) {
      return item;
    }
    return this.articles[0];
  }

  private getSelectedArticleWorkflowNames(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.relatedWorkflowIds.map((workflowId: string) => this.getTemplateName(workflowId)).join('、');
  }

  private getTemplateName(templateId: string): string {
    const item: WorkflowTemplate | null = this.getTemplateById(templateId);
    return item === null ? '流程' : item.name;
  }

  private getRelatedKnowledgeTitles(knowledgeIds: string[]): string {
    return knowledgeIds.map((item: string) => {
      const article: KnowledgeArticle | null = this.getArticleById(item);
      return article === null ? '未命名知识' : article.title;
    }).join('、');
  }

  private isFavorite(articleId: string): boolean {
    return this.favoriteKnowledgeIds.includes(articleId);
  }

  private getRoleColor(role: string): string {
    if (role === 'approver') {
      return '#175CD3';
    }
    if (role === 'systemAdmin') {
      return '#7A5AF8';
    }
    return '#039855';
  }

  private getStatusColor(status: string): string {
    if (status === '已通过') {
      return '#027A48';
    }
    if (status === '已驳回') {
      return '#B42318';
    }
    if (status === '审批中') {
      return '#175CD3';
    }
    return '#B54708';
  }
}

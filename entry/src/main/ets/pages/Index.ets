import { common } from '@kit.AbilityKit';
import {
  loadAttendanceOverviewUseCase,
  submitAttendanceCheckInUseCase,
  submitAttendanceCheckOutUseCase
} from '../app/usecases/AttendanceUseCases';
import { askAssistantUseCase } from '../app/usecases/AssistantUseCases';
import { loadAppBootstrapData, AppBootstrapData } from '../app/usecases/AppBootstrapUseCases';
import { loginWithAccount, logoutCurrentAccount } from '../app/usecases/AuthUseCases';
import {
  loadMailBoxUseCase,
  markMailReadUseCase,
  sendInternalMailUseCase
} from '../app/usecases/MailUseCases';
import {
  isFavoriteKnowledgeUseCase,
  markKnowledgeUsefulStateUseCase,
  submitCorrectionStateUseCase,
  toggleFavoriteKnowledgeUseCase
} from '../app/usecases/KnowledgeStateUseCases';
import {
  getActiveWorkflowCountUseCase,
  getArticleByIdUseCase,
  getDashboardTodoCountUseCase,
  getFavoriteArticlesUseCase,
  getHighRiskWorkflowCountUseCase,
  getMyWorkflowsUseCase,
  getPublishedArticlesUseCase,
  getRecentArticlesUseCase,
  getRelatedKnowledgeTitlesUseCase,
  getSelectedArticleRequiredUseCase,
  getSelectedArticleUseCase,
  getSelectedArticleWorkflowNamesUseCase,
  getSelectedTemplateUseCase,
  getTemplateByIdUseCase,
  getTemplateNameUseCase,
  getTodoWorkflowsUseCase,
  getUnreadMessageCountUseCase,
  getVisibleAuditLogsUseCase,
  getVisibleMessagesUseCase,
  getWorkflowByIdUseCase
} from '../app/usecases/AppQueryUseCases';
import {
  buildLoginStateUseCase,
  buildLogoutStateUseCase,
  buildOpenArticleStateUseCase,
  buildWorkflowMessageNavigationStateUseCase,
  markNotificationReadStateUseCase
} from '../app/usecases/AppStateUseCases';
import {
  applyWorkflowDecisionUseCase,
  applyWorkflowSecurityConfirmUseCase,
  createWorkflowUseCase
} from '../app/usecases/WorkflowUseCases';
import {
  buildOpenWorkflowComposerStateUseCase,
  buildStartWorkflowStateUseCase,
  WorkflowFormState
} from '../app/usecases/WorkflowFormStateUseCases';
import { EmptyState } from '../common/components/EmptyState';
import {
  DashboardSummary,
  loadReadingSettings,
  saveDashboardSummary,
  saveReadingSettings
} from '../common/services/ExperienceStateService';
import { selectAssistantImage } from '../common/services/AssistantMediaService';
import { SectionBlock } from '../common/components/SectionBlock';
import { AttendancePage } from '../features/attendance/AttendancePage';
import { AssistantPage } from '../features/assistant/AssistantPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { KnowledgeDetailPage } from '../features/knowledge/KnowledgeDetailPage';
import { KnowledgePage } from '../features/knowledge/KnowledgePage';
import { MailComposerPage } from '../features/mail/MailComposerPage';
import { MailDetailPage } from '../features/mail/MailDetailPage';
import { MailPage } from '../features/mail/MailPage';
import { MessagesPage } from '../features/messages/MessagesPage';
import { ProfilePage } from '../features/profile/ProfilePage';
import {
  AssistantAnalyzeInput,
  AssistantFormDraft,
  AssistantHistory,
  AssistantReply,
  AssistantSelectedImage,
  ApprovalRecord,
  AuditLog,
  AttendanceRecord,
  AttendanceTodaySummary,
  KnowledgeArticle,
  KnowledgeCategory,
  KnowledgeCorrection,
  MailMessage,
  NotificationItem,
  ReadingFontScale,
  ReadingFontWeight,
  User,
  WorkflowInstance,
  WorkflowTemplate
} from '../models/AppModels';

@Entry
@Component
struct Index {
  @StorageLink('launchPage') launchPage: string = '';
  private readonly tabLabels: string[] = ['工作台', '知识库', '流程', '我的'];
  private readonly tabMarks: string[] = ['工', '知', '流', '我'];

  @State loginAccount: string = 'employee01';
  @State loginPassword: string = '123456';
  @State isLoading: boolean = false;
  @State currentUser: User | null = null;
  @State categories: KnowledgeCategory[] = [];
  @State articles: KnowledgeArticle[] = [];
  @State templates: WorkflowTemplate[] = [];
  @State activeTab: number = 0;
  @State selectedArticleId: string = 'k2';
  @State favoriteKnowledgeIds: string[] = [];
  @State usefulKnowledgeIds: string[] = [];
  @State corrections: KnowledgeCorrection[] = [];
  @State workflowInstances: WorkflowInstance[] = [];
  @State notifications: NotificationItem[] = [];
  @State auditLogs: AuditLog[] = [];
  @State activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' | 'attendance' | 'mail' | 'mailDetail' | 'mailComposer' = 'none';
  @State detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' | 'attendance' | 'mail' | 'mailDetail' | 'mailComposer' = 'none';
  @State attendanceSummary: AttendanceTodaySummary = {
    date: '',
    checkedIn: false,
    checkedOut: false,
    checkInTime: '',
    checkOutTime: '',
    workDurationText: '',
    statusText: '考勤未加载',
    location: '',
    recentRecords: []
  };
  @State attendanceRecords: AttendanceRecord[] = [];
  @State inboxMails: MailMessage[] = [];
  @State sentMails: MailMessage[] = [];
  @State selectedMailId: string = '';
  @State assistantHistory: AssistantHistory[] = [];
  @State assistantQuestion: string = '';
  @State assistantReply: AssistantReply | null = null;
  @State assistantSelectedImage: AssistantSelectedImage | null = null;
  @State assistantLoading: boolean = false;
  @State readingFontScale: ReadingFontScale = 'standard';
  @State readingFontWeight: ReadingFontWeight = 'standard';
  @State activeWorkflowModule: 'overview' | 'apply' | 'mine' = 'overview';
  @State workflowPanelVisible: boolean = false;
  @State workflowComposerVisible: boolean = false;
  private hostContext: common.UIAbilityContext | null = null;

  aboutToAppear(): void {
    try {
      this.hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      loadReadingSettings(this.hostContext).then((settings) => {
        this.readingFontScale = settings.scale;
        this.readingFontWeight = settings.weight;
      });
      this.applyLaunchTarget();
    } catch (error) {
      console.error(`Index state initialization failed: ${error}`);
    }
  }

  onPageShow(): void {
    this.applyLaunchTarget();
    this.persistDashboardSummary();
  }

  private applyLaunchTarget(): void {
    if (this.launchPage !== 'knowledge' || this.currentUser === null) {
      return;
    }
    this.activeSubPage = 'none';
    this.activeTab = 1;
    this.launchPage = '';
  }

  private persistReadingSettings(): void {
    if (this.hostContext !== null) {
      saveReadingSettings(this.hostContext, {
        scale: this.readingFontScale,
        weight: this.readingFontWeight
      });
    }
  }

  private persistDashboardSummary(): void {
    if (this.hostContext === null || this.currentUser === null) {
      return;
    }
    const recent: KnowledgeArticle[] = this.getRecentArticles();
    const summary: DashboardSummary = {
      todoCount: this.getDashboardTodoCount(),
      unreadCount: this.getUnreadMessageCount(),
      recentTitle: recent.length > 0 ? recent[0].title : '打开知识库'
    };
    saveDashboardSummary(this.hostContext, summary);
  }
  @State selectedTemplateId: string = 'wf1';
  @State workflowTitleInput: string = '';
  @State workflowExtraInput: string = '';
  @State workflowDateInput: string = '';
  @State workflowEndDateInput: string = '';
  @State workflowAmountInput: string = '';
  @State workflowReasonInput: string = '';
  @State workflowAttachmentInput: string = '';
  @State approvalComment: string = '';
  @State selectedWorkflowId: string = '';

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
      .margin({ top: 60, bottom: 18 })

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

        Button(this.isLoading ? '正在连接后端...' : '登录并进入工作台')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#246BFD')
          .borderRadius(16)
          .enabled(!this.isLoading)
          .onClick(() => {
            void this.handleLogin();
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
        this.DemoAccountCard('admin01', '系统管理员', '管理模板、二次确认与操作日志');
        this.DemoAccountCard('knowledge01', '知识管理员', '维护分类、发布知识与查看审计摘要');
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
    Row({ space: 12 }) {
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
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button('填入')
        .fontSize(12)
        .width(56)
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
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private AppShell() {
    Stack() {
      Column() {
        if (this.activeSubPage === 'knowledgeDetail') {
          KnowledgeDetailPage({
            article: this.getSelectedArticleRequired(),
            favorite: this.isFavorite(this.selectedArticleId),
            useful: this.usefulKnowledgeIds.includes(this.selectedArticleId),
            fontScale: this.readingFontScale,
            fontWeight: this.readingFontWeight,
            workflowNames: this.getSelectedArticleWorkflowNames(),
            onBack: () => {
              this.activeSubPage = this.detailReturnSubPage;
              this.detailReturnSubPage = 'none';
            },
            onToggleFavorite: (articleId: string) => {
              void this.toggleFavorite(articleId);
            },
            onMarkUseful: (articleId: string) => {
              this.markKnowledgeUseful(articleId);
            },
            onSubmitCorrection: async (articleId: string, content: string): Promise<boolean> => {
              return this.submitCorrection(articleId, content);
            },
            onFontScaleChange: (scale: ReadingFontScale) => {
              this.readingFontScale = scale;
              this.persistReadingSettings();
            },
            onFontWeightChange: (weight: ReadingFontWeight) => {
              this.readingFontWeight = weight;
              this.persistReadingSettings();
            },
            onStartWorkflow: (templateId: string) => {
              this.startWorkflow(templateId);
            }
          })
        } else if (this.activeSubPage === 'attendance') {
          AttendancePage({
            todaySummary: this.attendanceSummary,
            records: this.attendanceRecords,
            onBack: () => {
              this.activeSubPage = 'none';
            },
            onCheckIn: (note: string) => {
              void this.handleAttendanceCheckIn(note);
            },
            onCheckOut: (note: string) => {
              void this.handleAttendanceCheckOut(note);
            }
          })
        } else if (this.activeSubPage === 'mail') {
          MailPage({
            inbox: this.inboxMails,
            sent: this.sentMails,
            onBack: () => {
              this.activeSubPage = 'none';
            },
            onOpenMail: (mailId: string) => {
              void this.openMailDetail(mailId);
            },
            onCompose: () => {
              this.activeSubPage = 'mailComposer';
            }
          })
        } else if (this.activeSubPage === 'mailDetail' && this.getSelectedMail() !== null) {
          MailDetailPage({
            mail: this.getSelectedMailRequired(),
            onBack: () => {
              this.activeSubPage = 'mail';
            },
            onOpenWorkflow: (workflowId: string) => {
              this.openWorkflowFromMessage(workflowId);
            },
            onOpenKnowledge: (knowledgeId: string) => {
              this.openArticle(knowledgeId);
            }
          })
        } else if (this.activeSubPage === 'mailComposer') {
          MailComposerPage({
            onBack: () => {
              this.activeSubPage = 'mail';
            },
            onSend: (
              receiverIds: string[],
              subject: string,
              content: string,
              relatedWorkflowId: string,
              relatedKnowledgeId: string
            ) => {
              void this.handleSendMail(receiverIds, subject, content, relatedWorkflowId, relatedKnowledgeId);
            }
          })
        } else if (this.activeSubPage === 'assistant') {
          AssistantPage({
            articles: this.getPublishedArticles(),
            templates: this.templates,
            history: $assistantHistory,
            question: $assistantQuestion,
            reply: $assistantReply,
            selectedImage: this.assistantSelectedImage,
            loading: this.assistantLoading,
            onBack: () => {
              this.activeSubPage = 'none';
            },
            onOpenArticle: (articleId: string) => {
              this.openArticle(articleId);
            },
            onSelectImage: () => {
              void this.handleAssistantImageSelect();
            },
            onClearImage: () => {
              this.assistantSelectedImage = null;
            },
            onOpenWorkflowWithoutDraft: (templateId: string) => {
              this.openWorkflowComposer(templateId);
            },
            onOpenWorkflowWithDraft: (templateId: string, draft: AssistantFormDraft) => {
              this.startWorkflow(templateId, draft);
            },
            onAsk: () => {
              void this.handleAssistantAsk();
            }
          })
        } else if (this.activeSubPage === 'messages') {
          MessagesPage({
            notifications: this.getVisibleMessages(),
            onBack: () => {
              this.activeSubPage = 'none';
            },
            onMarkRead: (notificationId: string) => {
              void this.handleMarkNotificationRead(notificationId);
            },
            onOpenKnowledge: (articleId: string) => {
              this.openArticle(articleId);
            },
            onOpenWorkflow: (instanceId: string) => {
              this.openWorkflowFromMessage(instanceId);
            },
            onOpenAttendance: () => {
              void this.openAttendancePage();
            },
            onOpenMail: (mailId: string) => {
              void this.openMailDetail(mailId);
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
                  attendanceStatus: this.getAttendanceStatusSummary(),
                  mailUnreadCount: this.getUnreadMailCount(),
                  onOpenArticle: (articleId: string) => {
                    this.openArticle(articleId);
                  },
                  onOpenAssistant: () => {
                    this.activeSubPage = 'assistant';
                  },
                  onOpenKnowledge: () => {
                    this.activeSubPage = 'none';
                    this.activeTab = 1;
                  },
                  onOpenMessages: () => {
                    this.activeSubPage = 'messages';
                  },
                  onOpenAttendance: () => {
                    void this.openAttendancePage();
                  },
                  onOpenMail: () => {
                    void this.openMailPage();
                  },
                  onOpenTodo: () => {
                    this.activeSubPage = 'none';
                    this.activeTab = 2;
                    this.openWorkflowModule('mine');
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
                  mailUnreadCount: this.getUnreadMailCount(),
                  attendanceStatus: this.getAttendanceStatusSummary(),
                  onOpenArticle: (articleId: string) => {
                    this.openArticle(articleId);
                  },
                  onOpenMessages: () => {
                    this.activeSubPage = 'messages';
                  },
                  onOpenAttendance: () => {
                    void this.openAttendancePage();
                  },
                  onOpenMail: () => {
                    void this.openMailPage();
                  },
                  onLogout: () => {
                    void this.logout();
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

      if (this.workflowPanelVisible) {
        this.WorkflowModuleDialog();
      }

      if (this.workflowComposerVisible) {
        this.WorkflowComposerDialog();
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
    SectionBlock({ title: '流程中心', subtitle: '' }) {
      Column({ space: 12 }) {
        this.WorkflowModuleCard(
          '申请流程',
          '',
          `共 ${this.templates.length} 个模板`,
          'apply'
        );
        this.WorkflowModuleCard(
          '我的流程',
          this.getMyWorkflowModuleSubtitle(),
          `共 ${this.getRoleWorkflowItems().length} 条流程`,
          'mine'
        );
      }
      .width('100%')
    }
  }

  @Builder
  private WorkflowModuleCard(title: string, description: string, statText: string, moduleKey: string) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isWorkflowModuleActive(moduleKey) ? '#175CD3' : '#1F2A44')
        .width('100%')

      if (description.length > 0) {
        Text(description)
          .fontSize(12)
          .fontColor('#667085')
          .lineHeight(18)
          .width('100%')
      }

      Blank()

      Text(statText)
        .fontSize(12)
        .fontColor(this.isWorkflowModuleActive(moduleKey) ? '#175CD3' : '#344054')
        .width('100%')

      Button(this.isWorkflowModuleActive(moduleKey) ? '当前模块' : '点击进入')
        .width('100%')
        .height(38)
        .backgroundColor(this.isWorkflowModuleActive(moduleKey) ? '#DCE7FF' : '#246BFD')
        .fontColor(this.isWorkflowModuleActive(moduleKey) ? '#175CD3' : '#FFFFFF')
        .borderRadius(12)
        .onClick(() => {
          this.openWorkflowModule(moduleKey);
        })
    }
    .width('100%')
    .height(156)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor(this.isWorkflowModuleActive(moduleKey) ? '#EEF4FF' : '#F8FAFF')
    .borderRadius(20)
    .onClick(() => {
      this.openWorkflowModule(moduleKey);
    })
  }

  @Builder
  private WorkflowModuleDialog() {
    Column() {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.getWorkflowModuleDialogTitle())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2A44')
              .width('100%')

            Text(this.getWorkflowModuleDialogStat())
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('关闭')
            .height(34)
            .fontSize(12)
            .backgroundColor('#EEF2F6')
            .fontColor('#344054')
            .borderRadius(10)
            .onClick(() => {
              this.closeWorkflowModuleDialog();
            })
        }

        Scroll() {
          Column({ space: 12 }) {
            if (this.activeWorkflowModule === 'mine') {
              this.WorkflowMinePanel();
            } else {
              this.WorkflowApplyPanel();
            }
          }
          .width('100%')
          .padding({ right: 2 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('82%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  @Builder
  private WorkflowApplyPanel() {
    Column({ space: 12 }) {
      ForEach(this.templates, (item: WorkflowTemplate) => {
        Column({ space: 10 }) {
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
            .width('100%')

          Text(item.riskHint)
            .fontSize(11)
            .fontColor(item.riskLevel === 'high' ? '#B54708' : '#246BFD')
            .lineHeight(18)
            .width('100%')

          Button('填写申请')
            .width('100%')
            .height(40)
            .backgroundColor('#246BFD')
            .fontColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              this.openWorkflowComposer(item.id);
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

  @Builder
  private WorkflowMinePanel() {
    Column({ space: 12 }) {
      if (this.getTodoWorkflows().length > 0) {
        Column({ space: 10 }) {
          Text('审批意见')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2A44')
            .width('100%')

          TextInput({ placeholder: '请输入审批意见', text: this.approvalComment })
            .height(46)
            .borderRadius(14)
            .backgroundColor('#F8FAFC')
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.approvalComment = value;
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F8FAFF')
        .borderRadius(18)
      }

      if (this.getRoleWorkflowItems().length === 0) {
        EmptyState({
          title: '当前没有流程记录',
          description: '你可以先进入申请流程选择模板，提交后会在这里按状态展示。',
          actionLabel: '去申请流程',
          onAction: () => {
            this.openWorkflowModule('apply');
          }
        })
      } else {
        ForEach(this.getWorkflowStatuses(), (status: string) => {
          if (this.getRoleWorkflowItemsByStatus(status).length > 0) {
            this.WorkflowStatusSection(status, this.getRoleWorkflowItemsByStatus(status));
          }
        }, (status: string) => status)
      }
    }
    .width('100%')
  }

  @Builder
  private WorkflowStatusSection(status: string, items: WorkflowInstance[]) {
    Column({ space: 10 }) {
      Row() {
        Text(status)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')

        Blank()

        Text(`${items.length} 条`)
          .fontSize(11)
          .fontColor('#667085')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#F2F4F7')
          .borderRadius(12)
      }

      ForEach(items, (item: WorkflowInstance) => {
        this.WorkflowCard(item, this.canHandleWorkflow(item));
      }, (item: WorkflowInstance) => item.id)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }

  @Builder
  private WorkflowComposerDialog() {
    Column() {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text(`编辑模板：${this.getSelectedTemplate().name}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2A44')
              .width('100%')

            Text(`审批链路：${this.getSelectedTemplate().approverText}`)
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('关闭')
            .height(34)
            .fontSize(12)
            .backgroundColor('#EEF2F6')
            .fontColor('#344054')
            .borderRadius(10)
            .onClick(() => {
              this.workflowComposerVisible = false;
            })
        }

        Scroll() {
          Column({ space: 12 }) {
            Text(this.getSelectedTemplate().riskHint)
              .fontSize(12)
              .fontColor(this.getSelectedTemplate().riskLevel === 'high' ? '#B54708' : '#246BFD')
              .lineHeight(18)
              .width('100%')

            this.WorkflowComposerFormFields();
          }
          .width('100%')
          .padding({ right: 2 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(42)
            .backgroundColor('#EEF2F6')
            .fontColor('#344054')
            .borderRadius(12)
            .onClick(() => {
              this.workflowComposerVisible = false;
            })

          Button('提交流程')
            .layoutWeight(1)
            .height(42)
            .backgroundColor('#246BFD')
            .fontColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              void this.handleCreateWorkflow();
            })
        }
      }
      .width('100%')
      .height('82%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .backgroundColor('#660B1220')
  }

  private padDateTimePart(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private parseWorkflowDateTime(value: string): Date {
    const parsed: Date = new Date(value.trim().replace(' ', 'T'));
    return Number.isNaN(parsed.getTime()) ? new Date() : parsed;
  }

  private workflowDateTimeMillis(value: string): number {
    if (value.trim().length === 0) {
      return -1;
    }
    const parsed: Date = new Date(value.trim().replace(' ', 'T'));
    return Number.isNaN(parsed.getTime()) ? -1 : parsed.getTime();
  }

  private formatWorkflowDateTime(value: Date): string {
    return `${value.getFullYear()}-${this.padDateTimePart(value.getMonth() + 1)}-${this.padDateTimePart(value.getDate())} ` +
      `${this.padDateTimePart(value.getHours())}:${this.padDateTimePart(value.getMinutes())}`;
  }

  private selectWorkflowDateTime(isEnd: boolean): void {
    if (isEnd && this.workflowDateInput.length === 0) {
      this.showMessage('请先选择开始时间。');
      return;
    }
    const currentValue: string = isEnd ? this.workflowEndDateInput : this.workflowDateInput;
    const selected: Date = this.parseWorkflowDateTime(currentValue);
    this.getUIContext().showDatePickerDialog({
      selected,
      onAccept: (dateResult: DatePickerResult) => {
        const selectedDate: Date = new Date(selected.getTime());
        const year: number = dateResult.year === undefined ? selected.getFullYear() : dateResult.year;
        const month: number = dateResult.month === undefined ? selected.getMonth() : dateResult.month;
        const day: number = dateResult.day === undefined ? selected.getDate() : dateResult.day;
        selectedDate.setFullYear(year, month, day);
        this.getUIContext().showTimePickerDialog({
          selected: selectedDate,
          useMilitaryTime: true,
          onAccept: (timeResult: TimePickerResult) => {
            selectedDate.setHours(timeResult.hour, timeResult.minute, 0, 0);
            const formatted: string = this.formatWorkflowDateTime(selectedDate);
            if (isEnd) {
              const startMillis: number = this.workflowDateTimeMillis(this.workflowDateInput);
              if (startMillis >= 0 && selectedDate.getTime() <= startMillis) {
                this.showMessage('结束时间必须晚于开始时间。');
                return;
              }
              this.workflowEndDateInput = formatted;
              return;
            }
            this.workflowDateInput = formatted;
            const endMillis: number = this.workflowDateTimeMillis(this.workflowEndDateInput);
            if (endMillis >= 0 && endMillis <= selectedDate.getTime()) {
              this.workflowEndDateInput = '';
            }
          }
        });
      }
    });
  }

  @Builder
  private WorkflowDateTimeSelector(label: string, value: string, isEnd: boolean) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#667085')
        .width('100%')
      Row() {
        Text(value.length > 0 ? value : '请选择日期和时间')
          .fontSize(14)
          .fontColor(value.length > 0 ? '#1F2A44' : '#98A2B3')
          .maxLines(1)
          .layoutWeight(1)
        Text('›')
          .fontSize(22)
          .fontColor('#667085')
      }
      .width('100%')
      .height(46)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#F8FAFC')
      .borderRadius(14)
      .onClick(() => {
        this.selectWorkflowDateTime(isEnd);
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private WorkflowComposerFormFields() {
    Column({ space: 12 }) {
      TextInput({ placeholder: '流程标题，例如：华南差旅报销', text: this.workflowTitleInput })
        .height(46)
        .borderRadius(14)
        .backgroundColor('#F8FAFC')
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.workflowTitleInput = value;
        })

      if (this.selectedTemplateId === 'wf1') {
        TextInput({ placeholder: '请假类型，例如：年假 / 病假', text: this.workflowExtraInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowExtraInput = value;
          })

        this.WorkflowDateTimeSelector('开始时间', this.workflowDateInput, false)
        this.WorkflowDateTimeSelector('结束时间', this.workflowEndDateInput, true)
      } else if (this.selectedTemplateId === 'wf2') {
        TextInput({ placeholder: '费用类型，例如：差旅 / 招待 / 打车', text: this.workflowExtraInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowExtraInput = value;
          })

        TextInput({ placeholder: '报销金额，例如：3680', text: this.workflowAmountInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowAmountInput = value;
          })
      } else if (this.selectedTemplateId === 'wf3') {
        TextInput({ placeholder: '采购物品，例如：会议平板 2 台', text: this.workflowExtraInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowExtraInput = value;
          })

        TextInput({ placeholder: '采购预算，例如：12800', text: this.workflowAmountInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowAmountInput = value;
          })

        TextInput({ placeholder: '期望到货时间，例如：2026-07-20', text: this.workflowDateInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowDateInput = value;
          })
      } else {
        TextInput({ placeholder: '系统名称，例如：项目看板 / 财务系统', text: this.workflowExtraInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowExtraInput = value;
          })

        TextInput({ placeholder: '申请期限，例如：2026-07 至 2026-12', text: this.workflowDateInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowDateInput = value;
          })
      }

      TextInput({ placeholder: '申请事由 / 审批说明', text: this.workflowReasonInput })
        .height(46)
        .borderRadius(14)
        .backgroundColor('#F8FAFC')
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.workflowReasonInput = value;
        })

      TextInput({ placeholder: '附件，例：发票+截图 / 采购清单 / 权限矩阵表', text: this.workflowAttachmentInput })
        .height(46)
        .borderRadius(14)
        .backgroundColor('#F8FAFC')
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.workflowAttachmentInput = value;
        })

      Text(`关联制度：${this.getRelatedKnowledgeTitles(this.getSelectedTemplate().relatedKnowledgeIds)}`)
        .fontSize(12)
        .fontColor('#667085')
        .width('100%')
    }
    .width('100%')
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

      Text(`表单摘要：${item.formSummary}`)
        .fontSize(12)
        .fontColor('#667085')
        .lineHeight(18)
        .width('100%')

      Text(`关联制度：${this.getRelatedKnowledgeTitles(item.relatedKnowledgeIds)}`)
        .fontSize(12)
        .fontColor('#667085')
        .width('100%')

      if (item.riskLevel === 'high') {
        Text(`风险提示：${item.riskReason}`)
          .fontSize(12)
          .fontColor('#B54708')
          .lineHeight(18)
          .width('100%')
      }

      Text(`最新动态：${item.latestComment}`)
        .fontSize(12)
        .fontColor('#667085')
        .lineHeight(18)
        .width('100%')

      if (showActions) {
        Row({ space: 10 }) {
          Button(item.status === '待二次确认' ? '二次确认并通过' : '通过')
            .layoutWeight(1)
            .height(38)
            .backgroundColor('#ECFDF3')
            .fontColor('#027A48')
            .borderRadius(12)
            .onClick(() => {
              if (item.status === '待二次确认') {
                void this.handleSecurityConfirm(item.id);
              } else {
                void this.handleWorkflowDecision(item.id, true);
              }
            })

          Button('驳回')
            .layoutWeight(1)
            .height(38)
            .backgroundColor('#FEF3F2')
            .fontColor('#B42318')
            .borderRadius(12)
            .onClick(() => {
              void this.handleWorkflowDecision(item.id, false);
            })
        }
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.selectedWorkflowId === item.id ? '#EEF4FF' : '#F8FAFC')
    .borderRadius(18)
    .onClick(() => {
      this.selectedWorkflowId = item.id;
    })
  }

  @Builder
  private TimelineItem(record: ApprovalRecord, isLast: boolean) {
    Row({ space: 10 }) {
      Column({ space: 0 }) {
        Text('●')
          .fontSize(12)
          .fontColor(this.getDecisionColor(record.decision))

        if (!isLast) {
          Text('│')
            .fontSize(18)
            .fontColor('#D0D5DD')
        }
      }
      .width(16)

      Column({ space: 4 }) {
        Text(`${record.nodeName} · ${this.getDecisionLabel(record.decision)}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .width('100%')

        Text(`${record.operatorName} (${this.getRoleLabel(record.operatorRole)})`)
          .fontSize(12)
          .fontColor('#667085')
          .width('100%')

        Text(record.comment)
          .fontSize(12)
          .fontColor('#344054')
          .lineHeight(18)
          .width('100%')

        Text(record.time)
          .fontSize(11)
          .fontColor('#98A2B3')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`Index toast failed: ${error}`);
    }
  }

  private applyBootstrapData(data: AppBootstrapData): void {
    this.categories = data.categories;
    this.articles = data.articles;
    this.templates = data.templates;
    this.workflowInstances = data.workflowInstances;
    this.notifications = data.notifications;
    this.auditLogs = data.auditLogs;
    if (this.selectedArticleId.length === 0 && data.articles.length > 0) {
      this.selectedArticleId = data.articles[0].id;
    }
    if (this.selectedTemplateId.length === 0 && data.templates.length > 0) {
      this.selectedTemplateId = data.templates[0].id;
    }
  }

  private markKnowledgeUseful(articleId: string): void {
    this.usefulKnowledgeIds = markKnowledgeUsefulStateUseCase(this.usefulKnowledgeIds, articleId);
  }

  private async submitCorrection(articleId: string, content: string): Promise<boolean> {
    const result = await submitCorrectionStateUseCase(this.corrections, articleId, content);
    this.corrections = result.corrections;
    return result.success;
  }

  private getUnreadMessageCount(): number {
    return getUnreadMessageCountUseCase(this.currentUser, this.notifications);
  }

  private openWorkflowFromMessage(instanceId: string): void {
    const result = buildWorkflowMessageNavigationStateUseCase(this.workflowInstances, instanceId);
    this.activeSubPage = result.activeSubPage;
    this.detailReturnSubPage = result.detailReturnSubPage;
    this.activeTab = result.activeTab;
    this.openWorkflowModule('mine');
    this.selectedWorkflowId = instanceId;
    this.showMessage(result.message);
  }

  private async logout(): Promise<void> {
    try {
      await logoutCurrentAccount();
    } catch (error) {
      console.error(`logout failed: ${error}`);
    }

    const result = buildLogoutStateUseCase();
    this.currentUser = result.currentUser;
    this.categories = [];
    this.articles = [];
    this.templates = [];
    this.activeTab = result.activeTab;
    this.activeSubPage = result.activeSubPage;
    this.detailReturnSubPage = 'none';
    this.selectedArticleId = result.selectedArticleId;
    this.favoriteKnowledgeIds = result.favoriteKnowledgeIds;
    this.usefulKnowledgeIds = result.usefulKnowledgeIds;
    this.corrections = [];
    this.workflowInstances = [];
    this.notifications = [];
    this.auditLogs = [];
    this.attendanceSummary = {
      date: '',
      checkedIn: false,
      checkedOut: false,
      checkInTime: '',
      checkOutTime: '',
      workDurationText: '',
      statusText: '考勤未加载',
      location: '',
      recentRecords: []
    };
    this.attendanceRecords = [];
    this.inboxMails = [];
    this.sentMails = [];
    this.selectedMailId = '';
    this.assistantHistory = result.assistantHistory;
    this.assistantQuestion = result.assistantQuestion;
    this.assistantReply = result.assistantReply;
    this.assistantSelectedImage = null;
    this.assistantLoading = false;
    this.readingFontScale = result.readingFontScale;
    this.readingFontWeight = 'standard';
    this.activeWorkflowModule = 'overview';
    this.workflowPanelVisible = false;
    this.workflowComposerVisible = false;
  }

  private async handleLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    try {
      const user: User = await loginWithAccount(this.loginAccount.trim(), this.loginPassword.trim());
      const bootstrapData: AppBootstrapData = await loadAppBootstrapData();
      const result = buildLoginStateUseCase(user);
      this.currentUser = result.currentUser;
      this.favoriteKnowledgeIds = result.favoriteKnowledgeIds;
      this.selectedArticleId = result.selectedArticleId;
      this.activeTab = result.activeTab;
      this.activeSubPage = result.activeSubPage;
      this.detailReturnSubPage = result.detailReturnSubPage;
      this.usefulKnowledgeIds = result.usefulKnowledgeIds;
      this.corrections = [];
      this.assistantHistory = result.assistantHistory;
      this.assistantQuestion = result.assistantQuestion;
      this.assistantReply = result.assistantReply;
      this.assistantSelectedImage = null;
      this.assistantLoading = false;
      this.activeWorkflowModule = 'overview';
      this.workflowPanelVisible = false;
      this.workflowComposerVisible = false;
      this.applyBootstrapData(bootstrapData);
      await this.loadAttendancePreview();
      await this.loadMailPreview();
      if (this.selectedArticleId.length === 0 && this.articles.length > 0) {
        this.selectedArticleId = this.articles[0].id;
      }
      this.applyLaunchTarget();
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '连接后端失败，请检查服务是否已启动。';
      this.showMessage(message);
    } finally {
      this.isLoading = false;
    }
  }

  private applyWorkflowFormState(state: WorkflowFormState): void {
    this.selectedTemplateId = state.selectedTemplateId;
    this.activeTab = state.activeTab;
    this.activeSubPage = state.activeSubPage;
    this.detailReturnSubPage = state.detailReturnSubPage;
    this.workflowTitleInput = state.workflowTitleInput;
    this.workflowExtraInput = state.workflowExtraInput;
    this.workflowDateInput = state.workflowDateInput;
    this.workflowEndDateInput = state.workflowEndDateInput;
    this.workflowAmountInput = state.workflowAmountInput;
    this.workflowReasonInput = state.workflowReasonInput;
    this.workflowAttachmentInput = state.workflowAttachmentInput;
    this.approvalComment = state.approvalComment;
  }

  private openWorkflowComposer(templateId: string): void {
    this.applyWorkflowFormState(buildOpenWorkflowComposerStateUseCase(templateId));
    this.activeWorkflowModule = 'apply';
    this.workflowComposerVisible = true;
  }

  private startWorkflow(templateId: string, draft?: AssistantFormDraft): void {
    this.applyWorkflowFormState(buildStartWorkflowStateUseCase(templateId, draft));
    this.activeWorkflowModule = 'apply';
    this.workflowComposerVisible = true;
  }

  private async handleCreateWorkflow(): Promise<void> {
    if (this.currentUser === null) {
      return;
    }

    try {
      let dateInput: string = this.workflowDateInput;
      if (this.selectedTemplateId === 'wf1') {
        if (this.workflowDateInput.length === 0 || this.workflowEndDateInput.length === 0) {
          this.showMessage('请选择请假开始时间和结束时间。');
          return;
        }
        const startMillis: number = this.workflowDateTimeMillis(this.workflowDateInput);
        const endMillis: number = this.workflowDateTimeMillis(this.workflowEndDateInput);
        if (startMillis < 0 || endMillis <= startMillis) {
          this.showMessage('结束时间必须晚于开始时间。');
          return;
        }
        dateInput = `${this.workflowDateInput} 至 ${this.workflowEndDateInput}`;
      }
      const result = await createWorkflowUseCase({
        template: this.getSelectedTemplate(),
        user: this.getCurrentUser(),
        workflowInstances: this.workflowInstances,
        notifications: this.notifications,
        titleInput: this.workflowTitleInput,
        extraInput: this.workflowExtraInput,
        dateInput,
        amountInput: this.workflowAmountInput,
        reasonInput: this.workflowReasonInput,
        attachmentInput: this.workflowAttachmentInput
      });
      if (!result.success) {
        this.showMessage(result.errorMessage);
        return;
      }

      this.workflowInstances = result.workflowInstances;
      this.notifications = result.notifications;
      this.activeWorkflowModule = 'mine';
      this.workflowPanelVisible = true;
      this.workflowComposerVisible = false;
      if (result.instance !== null) {
        this.selectedWorkflowId = result.instance.id;
      }
      this.showMessage('提交流程成功。');
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '提交流程失败。';
      this.showMessage(message);
    }
  }

  private async handleWorkflowDecision(instanceId: string, isApproved: boolean): Promise<void> {
    if (this.currentUser === null) {
      return;
    }

    try {
      const result = await applyWorkflowDecisionUseCase(
        instanceId,
        this.approvalComment,
        isApproved
      );
      this.workflowInstances = result.workflowInstances;
      this.notifications = result.notifications;
      this.activeWorkflowModule = 'mine';
      this.workflowPanelVisible = true;
      this.selectedWorkflowId = instanceId;
      this.showMessage(result.message);
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '流程处理失败。';
      this.showMessage(message);
    }
  }

  private async handleSecurityConfirm(instanceId: string): Promise<void> {
    if (this.currentUser === null) {
      return;
    }

    try {
      const result = await applyWorkflowSecurityConfirmUseCase(
        this.auditLogs,
        instanceId,
        this.getCurrentUser(),
        this.approvalComment
      );
      this.workflowInstances = result.workflowInstances;
      this.notifications = result.notifications;
      this.auditLogs = result.auditLogs;
      this.activeWorkflowModule = 'mine';
      this.workflowPanelVisible = true;
      if (result.selectedWorkflowId.length > 0) {
        this.selectedWorkflowId = result.selectedWorkflowId;
      }
      this.showMessage(result.message);
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '二次确认失败。';
      this.showMessage(message);
    }
  }

  private openArticle(articleId: string): void {
    const article: KnowledgeArticle | null = this.getArticleById(articleId);
    const result = buildOpenArticleStateUseCase(this.currentUser, article, articleId, this.activeSubPage);
    if (!result.success) {
      return;
    }
    this.currentUser = result.currentUser;
    this.selectedArticleId = result.selectedArticleId;
    this.detailReturnSubPage = result.detailReturnSubPage;
    this.activeSubPage = result.activeSubPage;
    this.persistDashboardSummary();
  }

  private async toggleFavorite(articleId: string): Promise<void> {
    try {
      const result = await toggleFavoriteKnowledgeUseCase(this.favoriteKnowledgeIds, articleId);
      this.favoriteKnowledgeIds = result.favoriteKnowledgeIds;
      this.showMessage(result.message);
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '收藏操作失败。';
      this.showMessage(message);
    }
  }

  private async handleMarkNotificationRead(notificationId: string): Promise<void> {
    try {
      this.notifications = await markNotificationReadStateUseCase(this.notifications, notificationId);
      this.persistDashboardSummary();
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '消息标记失败。';
      this.showMessage(message);
    }
  }

  private async handleAssistantImageSelect(): Promise<void> {
    try {
      const selected: AssistantSelectedImage | null = await selectAssistantImage();
      if (selected !== null) {
        this.assistantSelectedImage = selected;
        this.assistantReply = null;
      }
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '图片选择失败。';
      this.showMessage(message);
    }
  }

  private async handleAssistantAsk(): Promise<void> {
    if (this.assistantLoading) {
      return;
    }
    this.assistantLoading = true;
    try {
      const input: AssistantAnalyzeInput = {
        text: this.assistantQuestion,
        imageBase64: this.assistantSelectedImage === null ? '' : this.assistantSelectedImage.imageBase64,
        imageMimeType: this.assistantSelectedImage === null ? '' : this.assistantSelectedImage.imageMimeType
      };
      const result = await askAssistantUseCase(input, this.assistantHistory);
      if (!result.success) {
        this.showMessage(result.message);
        return;
      }
      this.assistantReply = result.reply;
      this.assistantHistory = result.history;
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '助手暂时不可用。';
      this.showMessage(message);
    } finally {
      this.assistantLoading = false;
    }
  }

  private async loadAttendancePreview(): Promise<void> {
    try {
      const data = await loadAttendanceOverviewUseCase();
      this.attendanceSummary = data.todaySummary;
      this.attendanceRecords = data.records;
    } catch (error) {
      this.attendanceSummary = {
        date: '',
        checkedIn: false,
        checkedOut: false,
        checkInTime: '',
        checkOutTime: '',
        workDurationText: '',
        statusText: '考勤暂不可用',
        location: '',
        recentRecords: []
      };
      this.attendanceRecords = [];
      console.error(`attendance preview failed: ${error}`);
    }
  }

  private async loadMailPreview(): Promise<void> {
    try {
      const mailbox = await loadMailBoxUseCase();
      this.inboxMails = mailbox.inbox;
      this.sentMails = mailbox.sent;
    } catch (error) {
      this.inboxMails = [];
      this.sentMails = [];
      console.error(`mail preview failed: ${error}`);
    }
  }

  private async openAttendancePage(): Promise<void> {
    await this.loadAttendancePreview();
    this.activeSubPage = 'attendance';
  }

  private async openMailPage(): Promise<void> {
    await this.loadMailPreview();
    this.activeSubPage = 'mail';
  }

  private async openMailDetail(mailId: string): Promise<void> {
    await this.loadMailPreview();
    this.selectedMailId = mailId;
    if (this.getSelectedMail() === null) {
      this.activeSubPage = 'mail';
      this.showMessage('邮件详情暂不可用。');
      return;
    }
    try {
      await markMailReadUseCase(mailId);
    } catch (error) {
      console.error(`mail read failed: ${error}`);
    }
    this.inboxMails = this.inboxMails.map((item: MailMessage) => {
      if (item.id !== mailId) {
        return item;
      }
      return {
        id: item.id,
        subject: item.subject,
        summary: item.summary,
        content: item.content,
        senderId: item.senderId,
        senderName: item.senderName,
        recipients: item.recipients,
        folder: item.folder,
        importance: item.importance,
        createTime: item.createTime,
        read: true,
        relatedWorkflowId: item.relatedWorkflowId,
        relatedKnowledgeId: item.relatedKnowledgeId
      };
    });
    this.activeSubPage = 'mailDetail';
  }

  private async handleAttendanceCheckIn(note: string): Promise<void> {
    try {
      const data = await submitAttendanceCheckInUseCase(note, '深圳南山办公区');
      this.attendanceSummary = data.todaySummary;
      this.attendanceRecords = data.records;
      this.showMessage('签到成功。');
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '签到失败。';
      this.showMessage(message);
    }
  }

  private async handleAttendanceCheckOut(note: string): Promise<void> {
    try {
      const data = await submitAttendanceCheckOutUseCase(note, '深圳南山办公区');
      this.attendanceSummary = data.todaySummary;
      this.attendanceRecords = data.records;
      this.showMessage('签退成功。');
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '签退失败。';
      this.showMessage(message);
    }
  }

  private async handleSendMail(
    receiverIds: string[],
    subject: string,
    content: string,
    relatedWorkflowId: string,
    relatedKnowledgeId: string
  ): Promise<void> {
    try {
      await sendInternalMailUseCase(receiverIds, subject, content, relatedWorkflowId, relatedKnowledgeId);
      await this.loadMailPreview();
      this.activeSubPage = 'mail';
      this.showMessage('邮件已发送。');
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '发送邮件失败。';
      this.showMessage(message);
    }
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

  private getSelectedTemplate(): WorkflowTemplate {
    return getSelectedTemplateUseCase(this.templates, this.selectedTemplateId);
  }

  private getDashboardTodoCount(): number {
    return getDashboardTodoCountUseCase(this.currentUser, this.workflowInstances);
  }

  private getActiveWorkflowCount(): number {
    return getActiveWorkflowCountUseCase(this.workflowInstances);
  }

  private getHighRiskWorkflowCount(): number {
    return getHighRiskWorkflowCountUseCase(this.workflowInstances);
  }

  private getPublishedArticles(): KnowledgeArticle[] {
    return getPublishedArticlesUseCase(this.articles);
  }

  private getRecentArticles(): KnowledgeArticle[] {
    return getRecentArticlesUseCase(this.currentUser, this.articles);
  }

  private getFavoriteArticles(): KnowledgeArticle[] {
    return getFavoriteArticlesUseCase(this.favoriteKnowledgeIds, this.articles);
  }

  private getVisibleMessages(): NotificationItem[] {
    return getVisibleMessagesUseCase(this.currentUser, this.notifications);
  }

  private getUnreadMailCount(): number {
    return this.inboxMails.filter((item: MailMessage) => !item.read).length;
  }

  private getAttendanceStatusSummary(): string {
    if (this.attendanceSummary.statusText.length === 0) {
      return '考勤未加载';
    }
    if (this.attendanceSummary.checkedOut) {
      return `${this.attendanceSummary.statusText} · 已签退`;
    }
    if (this.attendanceSummary.checkedIn) {
      return `${this.attendanceSummary.statusText} · 已签到 ${this.attendanceSummary.checkInTime}`;
    }
    return this.attendanceSummary.statusText;
  }

  private getMyWorkflows(): WorkflowInstance[] {
    return getMyWorkflowsUseCase(this.currentUser, this.workflowInstances);
  }

  private getTodoWorkflows(): WorkflowInstance[] {
    return getTodoWorkflowsUseCase(this.currentUser, this.workflowInstances);
  }

  private getWorkflowStatuses(): string[] {
    return ['待审批', '审批中', '待二次确认', '已通过', '已驳回'];
  }

  private getRoleWorkflowItems(): WorkflowInstance[] {
    const map = new Map<string, WorkflowInstance>();
    this.getMyWorkflows().forEach((item: WorkflowInstance) => {
      map.set(item.id, item);
    });
    this.getTodoWorkflows().forEach((item: WorkflowInstance) => {
      map.set(item.id, item);
    });
    return Array.from(map.values()).sort((left: WorkflowInstance, right: WorkflowInstance) => {
      return right.createTime.localeCompare(left.createTime);
    });
  }

  private getRoleWorkflowItemsByStatus(status: string): WorkflowInstance[] {
    return this.getRoleWorkflowItems().filter((item: WorkflowInstance) => item.status === status);
  }

  private getMyWorkflowModuleSubtitle(): string {
    return '';
  }

  private openWorkflowModule(moduleKey: string): void {
    this.activeWorkflowModule = moduleKey === 'mine' ? 'mine' : 'apply';
    this.workflowPanelVisible = true;
  }

  private closeWorkflowModuleDialog(): void {
    this.workflowPanelVisible = false;
    this.activeWorkflowModule = 'overview';
  }

  private getWorkflowModuleDialogTitle(): string {
    return this.activeWorkflowModule === 'mine' ? '我的流程' : '申请流程';
  }

  private getWorkflowModuleDialogStat(): string {
    if (this.activeWorkflowModule === 'mine') {
      return `共 ${this.getRoleWorkflowItems().length} 条流程`;
    }
    return `共 ${this.templates.length} 个模板`;
  }

  private isWorkflowModuleActive(moduleKey: string): boolean {
    return this.workflowPanelVisible && this.activeWorkflowModule === moduleKey;
  }

  private canHandleWorkflow(item: WorkflowInstance): boolean {
    if (this.currentUser === null) {
      return false;
    }

    const isInCharge: boolean = item.currentApproverRole === this.currentUser.role;
    const isPending: boolean = item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
    return isInCharge && isPending;
  }

  private getSelectedWorkflow(): WorkflowInstance | null {
    return this.getWorkflowById(this.selectedWorkflowId);
  }

  private getSelectedWorkflowTitle(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.title;
  }

  private getSelectedWorkflowStatus(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.status;
  }

  private getSelectedWorkflowNode(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.currentNode;
  }

  private getSelectedWorkflowApplicantName(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.applicantName;
  }

  private getSelectedWorkflowSummary(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.formSummary;
  }

  private getSelectedWorkflowFormDetail(): string[] {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? [] : item.formDetail;
  }

  private getSelectedWorkflowKnowledgeTitles(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : this.getRelatedKnowledgeTitles(item.relatedKnowledgeIds);
  }

  private getSelectedWorkflowRiskLevel(): 'normal' | 'high' {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? 'normal' : item.riskLevel;
  }

  private getSelectedWorkflowRiskReason(): string {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? '' : item.riskReason;
  }

  private getSelectedWorkflowApprovalRecords(): ApprovalRecord[] {
    const item: WorkflowInstance | null = this.getSelectedWorkflow();
    return item === null ? [] : item.approvalRecords;
  }

  private getWorkflowById(workflowId: string): WorkflowInstance | null {
    return getWorkflowByIdUseCase(this.workflowInstances, workflowId);
  }

  private getArticleById(articleId: string): KnowledgeArticle | null {
    return getArticleByIdUseCase(this.articles, articleId);
  }

  private getTemplateById(templateId: string): WorkflowTemplate | null {
    return getTemplateByIdUseCase(this.templates, templateId);
  }

  private getSelectedArticle(): KnowledgeArticle | null {
    return getSelectedArticleUseCase(this.articles, this.selectedArticleId);
  }

  private getSelectedArticleRequired(): KnowledgeArticle {
    return getSelectedArticleRequiredUseCase(this.articles, this.selectedArticleId);
  }

  private getSelectedMail(): MailMessage | null {
    const mails: MailMessage[] = this.inboxMails.concat(this.sentMails);
    const item: MailMessage | undefined = mails.find((mail: MailMessage) => mail.id === this.selectedMailId);
    return item === undefined ? null : item;
  }

  private getSelectedMailRequired(): MailMessage {
    const item: MailMessage | null = this.getSelectedMail();
    if (item !== null) {
      return item;
    }
    return {
      id: '',
      subject: '',
      summary: '',
      content: '',
      senderId: '',
      senderName: '',
      recipients: [],
      folder: 'inbox',
      importance: 'normal',
      createTime: '',
      read: true,
      relatedWorkflowId: '',
      relatedKnowledgeId: ''
    };
  }

  private getSelectedArticleWorkflowNames(): string {
    return getSelectedArticleWorkflowNamesUseCase(this.articles, this.selectedArticleId, this.templates);
  }

  private getTemplateName(templateId: string): string {
    return getTemplateNameUseCase(this.templates, templateId);
  }

  private getRelatedKnowledgeTitles(knowledgeIds: string[]): string {
    return getRelatedKnowledgeTitlesUseCase(knowledgeIds, this.articles);
  }

  private getArticleWorkflowCount(article: KnowledgeArticle): number {
    return article.relatedWorkflowIds.length;
  }

  private isFavorite(articleId: string): boolean {
    return isFavoriteKnowledgeUseCase(this.favoriteKnowledgeIds, articleId);
  }

  private canManageKnowledge(): boolean {
    return this.getCurrentUser().role === 'knowledgeAdmin' || this.getCurrentUser().role === 'systemAdmin';
  }

  private getVisibleAuditLogs(): AuditLog[] {
    return getVisibleAuditLogsUseCase(this.currentUser, this.auditLogs);
  }

  private getRoleLabel(role: string): string {
    if (role === 'approver') {
      return '审批人';
    }
    if (role === 'knowledgeAdmin') {
      return '知识管理员';
    }
    if (role === 'systemAdmin') {
      return '系统管理员';
    }
    return '普通员工';
  }

  private getRoleColor(role: string): string {
    if (role === 'approver') {
      return '#175CD3';
    }
    if (role === 'knowledgeAdmin') {
      return '#0E9384';
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
    if (status === '待二次确认') {
      return '#B54708';
    }
    return '#B54708';
  }

  private getDecisionLabel(decision: string): string {
    if (decision === 'submitted') {
      return '已提交';
    }
    if (decision === 'approved') {
      return '已通过';
    }
    if (decision === 'rejected') {
      return '已驳回';
    }
    return '二次确认';
  }

  private getDecisionColor(decision: string): string {
    if (decision === 'approved') {
      return '#039855';
    }
    if (decision === 'rejected') {
      return '#D92D20';
    }
    if (decision === 'securityConfirmed') {
      return '#B54708';
    }
    return '#246BFD';
  }
}

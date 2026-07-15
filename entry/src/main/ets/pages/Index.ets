import { common } from '@kit.AbilityKit';
import { askAssistantUseCase } from '../app/usecases/AssistantUseCases';
import { loadAppBootstrapData, AppBootstrapData } from '../app/usecases/AppBootstrapUseCases';
import { loginWithAccount, logoutCurrentAccount } from '../app/usecases/AuthUseCases';
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
import { SectionBlock } from '../common/components/SectionBlock';
import { AssistantPage } from '../features/assistant/AssistantPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { KnowledgeDetailPage } from '../features/knowledge/KnowledgeDetailPage';
import { KnowledgePage } from '../features/knowledge/KnowledgePage';
import { OcrResultPage } from '../features/knowledge/OcrResultPage';
import {
  OcrResult,
  recognizeBundledDemoImage,
  selectAndRecognizeImage
} from '../common/services/OcrService';
import { MessagesPage } from '../features/messages/MessagesPage';
import { ProfilePage } from '../features/profile/ProfilePage';
import {
  AssistantHistory,
  AssistantReply,
  ApprovalRecord,
  AuditLog,
  KnowledgeArticle,
  KnowledgeCategory,
  KnowledgeCorrection,
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
  @State activeSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' = 'none';
  @State detailReturnSubPage: 'none' | 'knowledgeDetail' | 'assistant' | 'messages' | 'ocrResult' = 'none';
  @State ocrResult: OcrResult | null = null;
  @State assistantHistory: AssistantHistory[] = [];
  @State assistantQuestion: string = '';
  @State assistantReply: AssistantReply | null = null;
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
  @State workflowExtraInput: string = '年假';
  @State workflowDateInput: string = '2026-07-18 09:00-18:00';
  @State workflowAmountInput: string = '';
  @State workflowReasonInput: string = '';
  @State workflowAttachmentInput: string = '';
  @State approvalComment: string = '材料齐全，建议通过。';
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
        } else if (this.activeSubPage === 'ocrResult' && this.ocrResult !== null) {
          OcrResultPage({
            result: this.ocrResult,
            articles: this.getPublishedArticles(),
            onBack: () => {
              this.activeSubPage = 'none';
              this.activeTab = 1;
            },
            onOpenArticle: (articleId: string) => {
              this.openArticle(articleId);
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
                  onOpenKnowledge: () => {
                    this.activeSubPage = 'none';
                    this.activeTab = 1;
                  },
                  onOpenMessages: () => {
                    this.activeSubPage = 'messages';
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
                  },
                  onSelectOcrImage: () => {
                    void this.startAlbumOcr();
                  },
                  onUseOcrDemo: () => {
                    void this.startDemoOcr();
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
                    this.persistReadingSettings();
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

        TextInput({ placeholder: '请假时间，例如：7 月 18 日 09:00-18:00', text: this.workflowDateInput })
          .height(46)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.workflowDateInput = value;
          })
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

      TextInput({ placeholder: '附件模拟，例如：发票+截图 / 采购清单 / 权限矩阵表', text: this.workflowAttachmentInput })
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

  private openOcrResult(result: OcrResult): void {
    this.ocrResult = result;
    this.activeSubPage = 'ocrResult';
  }

  private async startAlbumOcr(): Promise<void> {
    this.showMessage('请选择一张包含文字的图片。');
    const result: OcrResult | null = await selectAndRecognizeImage(this.getPublishedArticles());
    if (result === null) {
      return;
    }
    this.openOcrResult(result);
  }

  private async startDemoOcr(): Promise<void> {
    if (this.hostContext === null) {
      this.showMessage('应用资源尚未准备完成，请稍后重试。');
      return;
    }
    this.showMessage('正在识别内置报销凭证...');
    const result: OcrResult = await recognizeBundledDemoImage(
      this.hostContext,
      $r('app.media.ocr_demo_receipt').id,
      this.getPublishedArticles()
    );
    this.openOcrResult(result);
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
    this.assistantHistory = result.assistantHistory;
    this.assistantQuestion = result.assistantQuestion;
    this.assistantReply = result.assistantReply;
    this.readingFontScale = result.readingFontScale;
    this.readingFontWeight = 'standard';
    this.ocrResult = null;
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
      this.ocrResult = null;
      this.activeWorkflowModule = 'overview';
      this.workflowPanelVisible = false;
      this.workflowComposerVisible = false;
      this.applyBootstrapData(bootstrapData);
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

  private startWorkflow(templateId: string): void {
    this.applyWorkflowFormState(buildStartWorkflowStateUseCase(templateId));
    this.activeWorkflowModule = 'apply';
    this.workflowComposerVisible = true;
  }

  private async handleCreateWorkflow(): Promise<void> {
    if (this.currentUser === null) {
      return;
    }

    try {
      const result = await createWorkflowUseCase({
        template: this.getSelectedTemplate(),
        user: this.getCurrentUser(),
        workflowInstances: this.workflowInstances,
        notifications: this.notifications,
        titleInput: this.workflowTitleInput,
        extraInput: this.workflowExtraInput,
        dateInput: this.workflowDateInput,
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

  private async handleAssistantAsk(): Promise<void> {
    try {
      const result = await askAssistantUseCase(this.assistantQuestion, this.assistantHistory);
      if (!result.success) {
        this.showMessage(result.message);
        return;
      }
      this.assistantReply = result.reply;
      this.assistantHistory = result.history;
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '助手暂时不可用。';
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

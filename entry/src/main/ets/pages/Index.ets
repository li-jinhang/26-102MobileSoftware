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
 main
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
  getMockAuditLogs,
  getMockCategories,
  getMockInstances,
  getMockNotifications,
  getMockTemplates,
  getMockUsers
} from '../mock/MockData';

@Entry
@Component
struct Index {
  private readonly users: User[] = getMockUsers();
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
 main

  private copyStringArray(source: string[]): string[] {
    const target: string[] = [];
    source.forEach((item: string) => {
      target.push(item);
    });
    return target;
  }

  private copyApprovalRecords(source: ApprovalRecord[]): ApprovalRecord[] {
    const target: ApprovalRecord[] = [];
    source.forEach((item: ApprovalRecord) => {
      target.push({
        id: item.id,
        nodeName: item.nodeName,
        operatorRole: item.operatorRole,
        operatorName: item.operatorName,
        decision: item.decision,
        comment: item.comment,
        time: item.time
      });
    });
    return target;
  }

  private cloneUser(user: User): User {
    return {
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
  }

  private cloneWorkflowInstance(item: WorkflowInstance): WorkflowInstance {
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
      relatedKnowledgeIds: this.copyStringArray(item.relatedKnowledgeIds),
      amount: item.amount,
      formSummary: item.formSummary,
      formDetail: this.copyStringArray(item.formDetail),
      approvalRecords: this.copyApprovalRecords(item.approvalRecords),
      riskLevel: item.riskLevel,
      riskReason: item.riskReason,
      requiresSecurityConfirm: item.requiresSecurityConfirm,
      securityConfirmed: item.securityConfirmed
    };
  }

  private cloneAuditLog(item: AuditLog): AuditLog {
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

 main
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
 main
  private WorkflowTab() {
    SectionBlock({ title: '流程模板', subtitle: '已预置请假、报销、采购、权限申请四类模板，并配置审批角色与安全规则。' }) {
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

            Text(item.riskHint)
              .fontSize(11)
              .fontColor(item.riskLevel === 'high' ? '#B54708' : '#246BFD')
              .width('100%')

            Button(this.selectedTemplateId === item.id ? '当前已选模板' : '选择并填写')
              .width('100%')
              .height(40)
              .backgroundColor(this.selectedTemplateId === item.id ? '#DCE7FF' : '#246BFD')
              .fontColor(this.selectedTemplateId === item.id ? '#175CD3' : '#FFFFFF')
              .borderRadius(12)
              .onClick(() => {
                this.openWorkflowComposer(item.id);
              })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.selectedTemplateId === item.id ? '#EEF4FF' : '#F8FAFF')
          .borderRadius(18)
        }, (item: WorkflowTemplate) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '流程发起', subtitle: '补齐了表单填写、附件模拟、校验提交和高风险二次确认。' }) {
      Column({ space: 12 }) {
        Text(`当前模板：${this.getSelectedTemplate().name}`)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .width('100%')

        Text(`审批链路：${this.getSelectedTemplate().approverText}`)
          .fontSize(12)
          .fontColor('#667085')
          .width('100%')

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

        Button('提交流程')
          .width('100%')
          .height(44)
          .backgroundColor('#246BFD')
          .borderRadius(14)
          .onClick(() => {
            this.handleCreateWorkflow();
          })
      }
      .width('100%')
    }

    SectionBlock({ title: '我的流程', subtitle: '展示当前账号发起的流程、状态流转与风险标记。' }) {
      Column({ space: 10 }) {
        ForEach(this.getMyWorkflows(), (item: WorkflowInstance) => {
          this.WorkflowCard(item, false);
        }, (item: WorkflowInstance) => item.id)
      }
      .width('100%')
    }

    if (this.getTodoWorkflows().length > 0) {
      SectionBlock({ title: '审批意见', subtitle: '审批人和管理员可以先填写意见，再对待办执行通过、驳回或安全确认。' }) {
        Column({ space: 10 }) {
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
      }

      SectionBlock({ title: '审批待办', subtitle: '审批人能查看待办并通过或驳回，高风险流程会进入二次确认。' }) {
        Column({ space: 10 }) {
          ForEach(this.getTodoWorkflows(), (item: WorkflowInstance) => {
            this.WorkflowCard(item, true);
          }, (item: WorkflowInstance) => item.id)
        }
        .width('100%')
      }
    }

 main
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
                this.handleSecurityConfirm(item.id);
              } else {
                this.handleWorkflowDecision(item.id, true);
              }
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
 main
  }

  private openWorkflowComposer(templateId: string): void {
    this.selectedTemplateId = templateId;
    this.activeTab = 2;
    this.resetWorkflowForm();
  }

  private resetWorkflowForm(): void {
    const template: WorkflowTemplate = this.getSelectedTemplate();
    this.workflowTitleInput = '';
    this.workflowAmountInput = '';
    this.workflowReasonInput = '';
    this.workflowAttachmentInput = '';
    this.approvalComment = '材料齐全，建议通过。';

    if (template.id === 'wf1') {
      this.workflowExtraInput = '年假';
      this.workflowDateInput = '2026-07-18 09:00-18:00';
    } else if (template.id === 'wf2') {
      this.workflowExtraInput = '差旅';
      this.workflowAmountInput = '3680';
      this.workflowDateInput = '';
    } else if (template.id === 'wf3') {
      this.workflowExtraInput = '会议平板 2 台';
      this.workflowAmountInput = '12800';
      this.workflowDateInput = '2026-07-20';
    } else {
      this.workflowExtraInput = '项目看板';
      this.workflowDateInput = '2026-07 至 2026-12';
    }
  }

  private handleCreateWorkflow(): void {
    if (this.currentUser === null) {
      return;
    }

    const template: WorkflowTemplate = this.getSelectedTemplate();
    const amount: number = this.parseAmount(this.workflowAmountInput);
    if (!this.validateWorkflowForm(template.id, amount)) {
      return;
    }

    const titleSuffix: string = this.buildWorkflowTitleSuffix(template.id);
    const formSummary: string = this.buildWorkflowSummary(template.id, amount);
    const formDetail: string[] = this.buildWorkflowDetail(template.id, amount);
    const requiresSecurityConfirm: boolean = this.shouldRequireSecurityConfirm(template.id, amount);
    const riskReason: string = this.buildRiskReason(template.id, amount, requiresSecurityConfirm);
    const instance: WorkflowInstance = buildWorkflowInstance(
      template,
      this.getCurrentUser(),
      titleSuffix,
      formSummary,
      formDetail,
      amount,
      riskReason,
      requiresSecurityConfirm
    );

    this.prependWorkflowInstance(instance);
 main
  }

  private handleWorkflowDecision(instanceId: string, isApproved: boolean): void {
    if (this.currentUser === null) {
      return;
    }

    const opinion: string = this.approvalComment.trim().length > 0 ? this.approvalComment.trim() : '已处理当前节点。';
    this.workflowInstances = this.workflowInstances.map((item: WorkflowInstance) => {
      if (item.id !== instanceId) {
        return item;
      }

      const updatedItem: WorkflowInstance = this.cloneWorkflowInstance(item);
      const record: ApprovalRecord = {
        id: `ar${Date.now()}`,
        nodeName: updatedItem.currentNode,
        operatorRole: this.getCurrentUser().role,
        operatorName: this.getCurrentUser().name,
        decision: isApproved ? 'approved' : 'rejected',
        comment: opinion,
        time: '刚刚'
      };
      updatedItem.approvalRecords.push(record);

      if (!isApproved) {
        updatedItem.status = '已驳回';
        updatedItem.currentNode = '流程已驳回';
        updatedItem.latestComment = `${this.getCurrentUser().name}：${opinion}`;
        return updatedItem;
      }

      if (updatedItem.currentApproverRole === 'approver') {
        if (updatedItem.requiresSecurityConfirm && !updatedItem.securityConfirmed) {
          updatedItem.status = '待二次确认';
          updatedItem.currentNode = '等待数字盾二次确认';
          updatedItem.currentApproverRole = 'systemAdmin';
          updatedItem.latestComment = `${this.getCurrentUser().name} 已通过，进入二次安全确认。`;
          return updatedItem;
        }

        if (updatedItem.templateId === 'wf2' || updatedItem.templateId === 'wf3' || updatedItem.templateId === 'wf4') {
          updatedItem.status = '审批中';
          updatedItem.currentNode = '等待系统管理员复核';
          updatedItem.currentApproverRole = 'systemAdmin';
          updatedItem.latestComment = `${this.getCurrentUser().name} 已通过，流转至系统管理员。`;
          return updatedItem;
        }
      }

      updatedItem.status = '已通过';
      updatedItem.currentNode = '流程结束';
      updatedItem.latestComment = `${this.getCurrentUser().name} 已完成审批。`;
      return updatedItem;
    });

 main

    this.showMessage(isApproved ? '已通过当前节点。' : '已驳回该流程。');
  }

  private handleSecurityConfirm(instanceId: string): void {
    if (this.currentUser === null) {
      return;
    }

    const opinion: string = this.approvalComment.trim().length > 0 ? this.approvalComment.trim() : '已完成二次确认。';
    this.workflowInstances = this.workflowInstances.map((item: WorkflowInstance) => {
      if (item.id !== instanceId) {
        return item;
      }

      const updatedItem: WorkflowInstance = this.cloneWorkflowInstance(item);
      updatedItem.securityConfirmed = true;
      updatedItem.status = '已通过';
      updatedItem.currentNode = '流程结束';
      updatedItem.latestComment = `${this.getCurrentUser().name} 已完成二次确认。`;
      updatedItem.approvalRecords.push({
        id: `ar${Date.now()}`,
        nodeName: '数字盾二次确认',
        operatorRole: this.getCurrentUser().role,
        operatorName: this.getCurrentUser().name,
        decision: 'securityConfirmed',
        comment: opinion,
        time: '刚刚'
      });
      return updatedItem;
    });

    const currentItem: WorkflowInstance | null = this.getWorkflowById(instanceId);
    if (currentItem !== null) {
      this.selectedWorkflowId = currentItem.id;
      this.prependNotification({
        id: `n${Date.now()}`,
        title: '高风险流程已完成确认',
        content: `${currentItem.title} 已完成二次安全确认并通过。`,
        time: '刚刚',
        read: false,
        targetRoles: ['employee', 'approver', 'systemAdmin']
      });
      this.writeAuditLog(
        '完成二次确认',
        '安全治理',
        'high',
        `${this.getCurrentUser().name} 对“${currentItem.title}”执行了二次安全确认。`
      );
    }

    promptAction.showToast({ message: '已完成二次确认。' });
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

  private createWorkflowNotification(template: WorkflowTemplate, instance: WorkflowInstance, requiresSecurityConfirm: boolean): void {
    const targets: UserRole[] = template.id === 'wf4' || requiresSecurityConfirm
      ? ['approver', 'systemAdmin', 'employee']
      : ['approver', 'employee'];

    this.prependNotification({
      id: `n${Date.now()}`,
      title: `${template.name}已提交`,
      content: `${this.getCurrentUser().name} 发起了“${instance.title}”，${requiresSecurityConfirm ? '系统已标记为高风险流程。' : '等待下一审批节点处理。'}`,
      time: '刚刚',
      read: false,
      targetRoles: targets
    });
  }

  private writeAuditLog(action: string, module: string, riskLevel: 'normal' | 'high', detail: string): void {
    if (this.currentUser === null) {
      return;
    }

    this.prependAuditLog({
      id: `log${Date.now()}`,
      module: module,
      action: action,
      operatorName: this.getCurrentUser().name,
      operatorRole: this.getCurrentUser().role,
      riskLevel: riskLevel,
      detail: detail,
      time: '刚刚'
    });
  }

  private validateWorkflowForm(templateId: string, amount: number): boolean {
    if (this.workflowReasonInput.trim().length === 0) {
      promptAction.showToast({ message: '请填写申请事由。' });
      return false;
    }

    if (this.workflowAttachmentInput.trim().length === 0) {
      promptAction.showToast({ message: '请补充附件模拟内容。' });
      return false;
    }

    if (templateId === 'wf1' && (this.workflowExtraInput.trim().length === 0 || this.workflowDateInput.trim().length === 0)) {
      promptAction.showToast({ message: '请完整填写请假类型和时间。' });
      return false;
    }

    if ((templateId === 'wf2' || templateId === 'wf3') && (amount <= 0 || this.workflowExtraInput.trim().length === 0)) {
      promptAction.showToast({ message: '请填写金额和业务类型。' });
      return false;
    }

    if (templateId === 'wf3' && this.workflowDateInput.trim().length === 0) {
      promptAction.showToast({ message: '请填写期望到货时间。' });
      return false;
    }

    if (templateId === 'wf4' && (this.workflowExtraInput.trim().length === 0 || this.workflowDateInput.trim().length === 0)) {
      promptAction.showToast({ message: '请填写系统名称和申请期限。' });
      return false;
    }

    return true;
  }

  private parseAmount(value: string): number {
    const amount: number = Number(value.trim());
    return isNaN(amount) ? 0 : amount;
  }

  private shouldRequireSecurityConfirm(templateId: string, amount: number): boolean {
    if (templateId === 'wf2' && amount >= 5000) {
      return true;
    }
    if (templateId === 'wf3' && amount >= 10000) {
      return true;
    }
    return false;
  }

  private buildRiskReason(templateId: string, amount: number, enabled: boolean): string {
    if (!enabled) {
      return '';
    }
    if (templateId === 'wf2') {
      return `报销金额 ${amount} 元超过 5000 元阈值，需进行二次安全确认。`;
    }
    if (templateId === 'wf3') {
      return `采购金额 ${amount} 元超过 10000 元阈值，需进行二次安全确认。`;
    }
    return '系统检测到高风险操作，需进行额外确认。';
  }

  private buildWorkflowTitleSuffix(templateId: string): string {
    if (this.workflowTitleInput.trim().length > 0) {
      return this.workflowTitleInput.trim();
    }

    if (templateId === 'wf1') {
      return this.workflowDateInput.trim();
    }
    if (templateId === 'wf2' || templateId === 'wf3' || templateId === 'wf4') {
      return this.workflowExtraInput.trim();
    }
    return this.getCurrentUser().name;
  }

  private buildWorkflowSummary(templateId: string, amount: number): string {
    if (templateId === 'wf1') {
      return `${this.workflowExtraInput.trim()}，时间为 ${this.workflowDateInput.trim()}，原因：${this.workflowReasonInput.trim()}`;
    }
    if (templateId === 'wf2') {
      return `${this.workflowExtraInput.trim()}报销 ${amount} 元，原因：${this.workflowReasonInput.trim()}`;
    }
    if (templateId === 'wf3') {
      return `${this.workflowExtraInput.trim()}采购预算 ${amount} 元，用途：${this.workflowReasonInput.trim()}`;
    }
    return `申请 ${this.workflowExtraInput.trim()} 权限，期限 ${this.workflowDateInput.trim()}，场景：${this.workflowReasonInput.trim()}`;
  }

  private buildWorkflowDetail(templateId: string, amount: number): string[] {
    if (templateId === 'wf1') {
      return [
        `请假类型：${this.workflowExtraInput.trim()}`,
        `请假时间：${this.workflowDateInput.trim()}`,
        `请假原因：${this.workflowReasonInput.trim()}`,
        `附件：${this.workflowAttachmentInput.trim()}`
      ];
    }

    if (templateId === 'wf2') {
      return [
        `费用类型：${this.workflowExtraInput.trim()}`,
        `报销金额：${amount} 元`,
        `报销事由：${this.workflowReasonInput.trim()}`,
        `附件：${this.workflowAttachmentInput.trim()}`
      ];
    }

    if (templateId === 'wf3') {
      return [
        `采购物品：${this.workflowExtraInput.trim()}`,
        `采购预算：${amount} 元`,
        `采购用途：${this.workflowReasonInput.trim()}`,
        `期望到货：${this.workflowDateInput.trim()}`,
        `附件：${this.workflowAttachmentInput.trim()}`
      ];
    }

    return [
      `系统名称：${this.workflowExtraInput.trim()}`,
      `申请期限：${this.workflowDateInput.trim()}`,
      `业务场景：${this.workflowReasonInput.trim()}`,
      `附件：${this.workflowAttachmentInput.trim()}`
    ];
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
    const item: WorkflowTemplate | null = this.getTemplateById(this.selectedTemplateId);
    return item === null ? this.templates[0] : item;
  }

  private getDashboardTodoCount(): number {
    if (this.currentUser === null) {
      return 0;
    }

    if (this.getCurrentUser().role === 'employee') {
      return this.getMyWorkflows().filter((item: WorkflowInstance) =>
        item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认'
      ).length;
    }

    return this.getTodoWorkflows().length;
  }

  private getActiveWorkflowCount(): number {
    return this.workflowInstances.filter((item: WorkflowInstance) =>
      item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认'
    ).length;
  }

  private getHighRiskWorkflowCount(): number {
    return this.workflowInstances.filter((item: WorkflowInstance) => item.riskLevel === 'high').length;
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
      const isPending: boolean = item.status === '待审批' || item.status === '审批中' || item.status === '待二次确认';
      return isInCharge && isPending;
    });
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
    const item: WorkflowInstance | undefined = this.workflowInstances.find((workflow: WorkflowInstance) => workflow.id === workflowId);
    return item ? item : null;
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

  private getArticleWorkflowCount(article: KnowledgeArticle): number {
    return article.relatedWorkflowIds.length;
  }

  private isFavorite(articleId: string): boolean {
    return this.favoriteKnowledgeIds.includes(articleId);
  }

  private canManageKnowledge(): boolean {
    return this.getCurrentUser().role === 'knowledgeAdmin' || this.getCurrentUser().role === 'systemAdmin';
  }

  private getVisibleAuditLogs(): AuditLog[] {
    if (this.getCurrentUser().role === 'systemAdmin') {
      return this.auditLogs.slice(0, 6);
    }

    if (this.getCurrentUser().role === 'knowledgeAdmin') {
      return this.auditLogs.filter((item: AuditLog) => item.module !== '身份认证').slice(0, 4);
    }

    return this.auditLogs.filter((item: AuditLog) => item.module === '流程审批' || item.module === '安全治理').slice(0, 4);
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

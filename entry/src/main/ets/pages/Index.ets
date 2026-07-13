import { promptAction } from '@kit.ArkUI';
import {
  ApprovalRecord,
  AssistantHistory,
  AuditLog,
  KnowledgeArticle,
  KnowledgeCategory,
  NotificationItem,
  User,
  UserRole,
  WorkflowInstance,
  WorkflowTemplate
} from '../models/AppModels';
import {
  askAssistant,
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

@Component
struct SectionBlock {
  title: string = '';
  subtitle: string = '';
  @BuilderParam content: () => void = this.defaultBuilder;

  @Builder
  private defaultBuilder() {
  }

  build() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
          .width('100%')

        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#667085')
          .lineHeight(18)
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      this.content()
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
  }
}

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
  @State selectedCategoryId: string = 'all';
  @State searchKeyword: string = '';
  @State selectedArticleId: string = 'k2';
  @State favoriteKnowledgeIds: string[] = [];
  @State workflowInstances: WorkflowInstance[] = getMockInstances();
  @State notifications: NotificationItem[] = getMockNotifications();
  @State auditLogs: AuditLog[] = getMockAuditLogs();
  @State assistantQuestion: string = '';
  @State assistantAnswer: string = '';
  @State assistantRecommendedWorkflowId: string = '';
  @State assistantRelatedKnowledgeIds: string[] = [];
  @State assistantHistory: AssistantHistory[] = [];
  @State selectedTemplateId: string = 'wf2';
  @State selectedWorkflowId: string = 'i1';
  @State workflowTitleInput: string = '';
  @State workflowAmountInput: string = '';
  @State workflowReasonInput: string = '';
  @State workflowExtraInput: string = '';
  @State workflowDateInput: string = '';
  @State workflowAttachmentInput: string = '';
  @State approvalComment: string = '材料齐全，建议通过。';

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

  private prependAssistantHistory(history: AssistantHistory): void {
    const list: AssistantHistory[] = [];
    list.push(history);
    this.assistantHistory.forEach((item: AssistantHistory) => {
      list.push(item);
    });
    this.assistantHistory = list;
  }

  private prependAuditLog(log: AuditLog): void {
    const list: AuditLog[] = [];
    list.push(log);
    this.auditLogs.forEach((item: AuditLog) => {
      list.push(this.cloneAuditLog(item));
    });
    this.auditLogs = list;
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
      this.PageHeader();

      Scroll() {
        Column({ space: 14 }) {
          if (this.activeTab === 0) {
            this.WorkbenchTab();
          } else if (this.activeTab === 1) {
            this.KnowledgeTab();
          } else if (this.activeTab === 2) {
            this.WorkflowTab();
          } else {
            this.ProfileTab();
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 20 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      this.BottomNav();
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
  private WorkbenchTab() {
    SectionBlock({ title: '工作概览', subtitle: `${this.getCurrentUser().name}，今天建议先处理流程待办，再关注制度与安全提醒。` }) {
      Row({ space: 10 }) {
        this.StatCard('待处理', `${this.getDashboardTodoCount()}`, '#246BFD');
        this.StatCard('进行中流程', `${this.getActiveWorkflowCount()}`, '#12B76A');
        this.StatCard('风险提醒', `${this.getHighRiskWorkflowCount()}`, '#F79009');
      }
      .width('100%')
    }

    SectionBlock({ title: '快捷流程', subtitle: '成员 B 负责的流程协作线已经补齐模板选择、表单发起和风险提示。' }) {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.templates, (item: WorkflowTemplate) => {
          Column({ space: 8 }) {
            Text(item.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')

            Text(item.description)
              .fontSize(12)
              .fontColor('#667085')
              .lineHeight(18)
              .width('100%')

            Text(item.riskHint)
              .fontSize(11)
              .fontColor(item.riskLevel === 'high' ? '#B54708' : '#246BFD')
              .lineHeight(16)
              .width('100%')
          }
          .width('48%')
          .margin({ bottom: 12 })
          .padding(14)
          .backgroundColor('#F8FAFF')
          .borderRadius(18)
          .onClick(() => {
            this.openWorkflowComposer(item.id);
          })
        }, (item: WorkflowTemplate) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '智能助手', subtitle: '支持关键词问答，并能将结果直接导向流程发起。' }) {
      Column({ space: 10 }) {
        TextInput({ placeholder: '例如：报销打车费需要什么材料？', text: this.assistantQuestion })
          .height(48)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.assistantQuestion = value;
          })

        Button('立即提问')
          .width('100%')
          .height(44)
          .backgroundColor('#1D4ED8')
          .borderRadius(14)
          .onClick(() => {
            this.handleAskAssistant();
          })

        if (this.assistantAnswer.length > 0) {
          Column({ space: 8 }) {
            Text(this.assistantAnswer)
              .fontSize(13)
              .fontColor('#344054')
              .lineHeight(20)
              .width('100%')

            if (this.assistantRecommendedWorkflowId.length > 0) {
              Button(`去填写${this.getTemplateName(this.assistantRecommendedWorkflowId)}`)
                .fontSize(12)
                .height(36)
                .backgroundColor('#EAF1FF')
                .fontColor('#246BFD')
                .borderRadius(12)
                .onClick(() => {
                  this.openWorkflowComposer(this.assistantRecommendedWorkflowId);
                })
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#F8FAFF')
          .borderRadius(16)
        }
      }
      .width('100%')
    }

    SectionBlock({ title: '最近知识', subtitle: '工作台展示最近浏览与高频知识，便于二次进入。' }) {
      Column({ space: 10 }) {
        ForEach(this.getRecentArticles(), (item: KnowledgeArticle) => {
          this.ArticlePreview(item, true);
        }, (item: KnowledgeArticle) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '消息提醒', subtitle: '流程状态变化、风险确认和知识更新会统一汇总。' }) {
      Column({ space: 10 }) {
        ForEach(this.getVisibleMessages().slice(0, 4), (item: NotificationItem) => {
          Column({ space: 6 }) {
            Text(item.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')

            Text(item.content)
              .fontSize(12)
              .fontColor('#667085')
              .lineHeight(18)
              .width('100%')

            Text(item.time)
              .fontSize(11)
              .fontColor('#98A2B3')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(item.read ? '#F8FAFC' : '#EEF4FF')
          .borderRadius(16)
        }, (item: NotificationItem) => item.id)
      }
      .width('100%')
    }
  }

  @Builder
  private KnowledgeTab() {
    SectionBlock({ title: '知识检索', subtitle: '支持分类浏览、关键词搜索、详情查看与收藏。' }) {
      Column({ space: 12 }) {
        TextInput({ placeholder: '搜索制度、流程、操作指南', text: this.searchKeyword })
          .height(48)
          .borderRadius(14)
          .backgroundColor('#F8FAFC')
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.categories, (item: KnowledgeCategory) => {
              Text(item.name)
                .fontSize(12)
                .fontColor(this.selectedCategoryId === item.id ? '#FFFFFF' : '#475467')
                .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                .backgroundColor(this.selectedCategoryId === item.id ? '#246BFD' : '#F2F4F7')
                .borderRadius(18)
                .onClick(() => {
                  this.selectedCategoryId = item.id;
                })
            }, (item: KnowledgeCategory) => item.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
    }

    SectionBlock({ title: '知识列表', subtitle: `共检索到 ${this.getFilteredArticles().length} 条已发布知识。` }) {
      Column({ space: 10 }) {
        ForEach(this.getFilteredArticles(), (item: KnowledgeArticle) => {
          this.ArticlePreview(item, false);
        }, (item: KnowledgeArticle) => item.id)
      }
      .width('100%')
    }

    if (this.getSelectedArticle() !== null) {
      SectionBlock({ title: '知识详情', subtitle: '当前选中的知识详情会展示正文、附件与适用流程。' }) {
        Column({ space: 10 }) {
          Text(this.getSelectedArticleTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
            .width('100%')

          Text(this.getSelectedArticleContent())
            .fontSize(13)
            .fontColor('#344054')
            .lineHeight(22)
            .width('100%')

          Text(`标签：${this.getSelectedArticleTags()}`)
            .fontSize(12)
            .fontColor('#667085')

          Text(`附件：${this.getSelectedArticleAttachments()}`)
            .fontSize(12)
            .fontColor('#667085')

          Text(`适用流程：${this.getSelectedArticleWorkflowNames()}`)
            .fontSize(12)
            .fontColor('#667085')

          Row({ space: 10 }) {
            Button(this.isFavorite(this.selectedArticleId) ? '取消收藏' : '收藏知识')
              .height(38)
              .backgroundColor('#EAF1FF')
              .fontColor('#246BFD')
              .borderRadius(12)
              .onClick(() => {
                this.toggleFavorite(this.selectedArticleId);
              })

            Button('发起关联流程')
              .height(38)
              .backgroundColor('#FFF4ED')
              .fontColor('#C4320A')
              .borderRadius(12)
              .onClick(() => {
                this.openWorkflowComposer(this.getSelectedArticlePrimaryWorkflowId());
              })
          }
        }
        .width('100%')
      }
    }
  }

  @Builder
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

    if (this.getSelectedWorkflow() !== null) {
      SectionBlock({ title: '流程详情', subtitle: '展示申请内容、状态、审批记录、关联知识与时间线。' }) {
        Column({ space: 10 }) {
          Text(this.getSelectedWorkflowTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
            .width('100%')

          Row({ space: 10 }) {
            Text(this.getSelectedWorkflowStatus())
              .fontSize(11)
              .fontColor(this.getStatusColor(this.getSelectedWorkflowStatus()))
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('#F8FAFC')
              .borderRadius(12)

            Text(`当前节点：${this.getSelectedWorkflowNode()}`)
              .fontSize(12)
              .fontColor('#667085')
          }

          Text(`申请人：${this.getSelectedWorkflowApplicantName()}`)
            .fontSize(12)
            .fontColor('#344054')

          Text(`表单摘要：${this.getSelectedWorkflowSummary()}`)
            .fontSize(12)
            .fontColor('#344054')
            .lineHeight(18)
            .width('100%')

          ForEach(this.getSelectedWorkflowFormDetail(), (item: string) => {
            Text(item)
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }, (item: string) => item)

          Text(`关联制度：${this.getSelectedWorkflowKnowledgeTitles()}`)
            .fontSize(12)
            .fontColor('#667085')
            .width('100%')

          if (this.getSelectedWorkflowRiskLevel() === 'high') {
            Column({ space: 6 }) {
              Text('风险检测结果')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#B54708')
                .width('100%')

              Text(this.getSelectedWorkflowRiskReason())
                .fontSize(12)
                .fontColor('#B54708')
                .lineHeight(18)
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF7ED')
            .borderRadius(14)
          }

          Column({ space: 10 }) {
            Text('流程时间线')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')

            ForEach(this.getSelectedWorkflowApprovalRecords(), (record: ApprovalRecord, index: number) => {
              this.TimelineItem(record, index === this.getSelectedWorkflowApprovalRecords().length - 1);
            }, (record: ApprovalRecord) => record.id)
          }
          .width('100%')
        }
        .width('100%')
      }
    }

    if (this.assistantHistory.length > 0) {
      SectionBlock({ title: '最近问答记录', subtitle: '保留最近问答，便于和流程联动演示。' }) {
        Column({ space: 10 }) {
          ForEach(this.assistantHistory.slice(0, 3), (item: AssistantHistory) => {
            Column({ space: 6 }) {
              Text(item.question)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')
                .width('100%')

              Text(item.answer)
                .fontSize(12)
                .fontColor('#667085')
                .lineHeight(18)
                .width('100%')

              Text(item.time)
                .fontSize(11)
                .fontColor('#98A2B3')
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#F8FAFC')
            .borderRadius(16)
          }, (item: AssistantHistory) => item.id)
        }
        .width('100%')
      }
    }
  }

  @Builder
  private ProfileTab() {
    SectionBlock({ title: '个人信息', subtitle: '基础框架已经接入角色、权限与个性化知识入口。' }) {
      Column({ space: 10 }) {
        Text(`${this.getCurrentUser().name} · ${this.getCurrentUser().roleLabel}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        Text(`账号：${this.getCurrentUser().account}`)
          .fontSize(13)
          .fontColor('#667085')

        Text(`部门：${this.getCurrentUser().department}`)
          .fontSize(13)
          .fontColor('#667085')
      }
      .width('100%')
    }

    SectionBlock({ title: '我的收藏', subtitle: '收藏知识已和知识库模块打通。' }) {
      Column({ space: 10 }) {
        ForEach(this.getFavoriteArticles(), (item: KnowledgeArticle) => {
          this.ArticlePreview(item, true);
        }, (item: KnowledgeArticle) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '角色能力', subtitle: '系统会根据角色控制入口和操作限制。' }) {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.getCurrentUser().permissions, (item: string) => {
          Text(item)
            .fontSize(12)
            .fontColor('#175CD3')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#EAF1FF')
            .borderRadius(14)
            .margin({ right: 8, bottom: 8 })
        }, (item: string) => item)
      }
      .width('100%')
    }

    if (this.getCurrentUser().role === 'employee') {
      SectionBlock({ title: '管理权限', subtitle: '普通员工不能访问管理功能，这是 B 线里补上的权限拦截。' }) {
        Text('当前账号仅可发起流程、查看我的流程与接收状态消息，知识分类维护、流程模板管理和审计日志仅对管理角色开放。')
          .fontSize(13)
          .fontColor('#667085')
          .lineHeight(20)
          .width('100%')
      }
    } else if (this.getCurrentUser().role === 'approver') {
      SectionBlock({ title: '审批视角', subtitle: '审批人具备待办处理权，但不开放系统管理能力。' }) {
        Column({ space: 8 }) {
          Text(`当前待办：${this.getTodoWorkflows().length} 条`)
            .fontSize(13)
            .fontColor('#344054')
          Text('可执行操作：查看关联制度、填写审批意见、通过/驳回、跟进风险确认。')
            .fontSize(13)
            .fontColor('#344054')
          Text('受限能力：用户角色配置、流程模板维护、全量审计日志。')
            .fontSize(13)
            .fontColor('#667085')
        }
        .width('100%')
      }
    }

    if (this.canManageKnowledge()) {
      SectionBlock({ title: '知识分类管理', subtitle: '知识管理员和系统管理员可查看分类、发布状态和关联流程。' }) {
        Column({ space: 10 }) {
          ForEach(this.categories.filter((item: KnowledgeCategory) => item.id !== 'all'), (item: KnowledgeCategory) => {
            Column({ space: 6 }) {
              Text(item.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')
                .width('100%')

              Text(item.description)
                .fontSize(12)
                .fontColor('#667085')
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }, (item: KnowledgeCategory) => item.id)

          ForEach(this.articles.slice(0, 4), (item: KnowledgeArticle) => {
            Row() {
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(13)
                  .fontColor('#1F2A44')
                  .width('100%')

                Text(`状态：${item.status} · 关联流程：${this.getArticleWorkflowCount(item)} 个`)
                  .fontSize(11)
                  .fontColor('#667085')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(item.categoryName)
                .fontSize(11)
                .fontColor('#246BFD')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('#EAF1FF')
                .borderRadius(12)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }, (item: KnowledgeArticle) => item.id)
        }
        .width('100%')
      }
    }

    if (this.getCurrentUser().role === 'systemAdmin') {
      SectionBlock({ title: '系统管理台', subtitle: '展示用户/部门/角色、流程模板维护和安全治理概览。' }) {
        Column({ space: 10 }) {
          ForEach(this.users, (item: User) => {
            Row() {
              Column({ space: 4 }) {
                Text(item.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1F2A44')
                  .width('100%')

                Text(`${item.department} · ${item.roleLabel}`)
                  .fontSize(12)
                  .fontColor('#667085')
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(`${item.permissions.length} 项能力`)
                .fontSize(11)
                .fontColor('#344054')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }, (item: User) => item.id)
        }
        .width('100%')
      }

      SectionBlock({ title: '流程模板维护', subtitle: '管理员可查看审批链、风险等级和关联制度。' }) {
        Column({ space: 10 }) {
          ForEach(this.templates, (item: WorkflowTemplate) => {
            Column({ space: 6 }) {
              Text(item.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')
                .width('100%')

              Text(`审批链：${item.approverText}`)
                .fontSize(12)
                .fontColor('#667085')
                .width('100%')

              Text(`风险等级：${item.riskLevel} · 关联制度：${this.getRelatedKnowledgeTitles(item.relatedKnowledgeIds)}`)
                .fontSize(12)
                .fontColor('#667085')
                .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }, (item: WorkflowTemplate) => item.id)
        }
        .width('100%')
      }
    }

    if (this.getCurrentUser().role !== 'employee') {
      SectionBlock({ title: '操作日志', subtitle: '关键操作已经写入审计日志，高风险行为会单独标红展示。' }) {
        Column({ space: 10 }) {
          ForEach(this.getVisibleAuditLogs(), (item: AuditLog) => {
            Column({ space: 6 }) {
              Row() {
                Text(item.action)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1F2A44')
                  .layoutWeight(1)

                Text(item.riskLevel === 'high' ? '高风险' : '常规')
                  .fontSize(11)
                  .fontColor(item.riskLevel === 'high' ? '#B54708' : '#246BFD')
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(item.riskLevel === 'high' ? '#FFF3E8' : '#EAF1FF')
                  .borderRadius(12)
              }

              Text(`${item.module} · ${item.operatorName} (${this.getRoleLabel(item.operatorRole)})`)
                .fontSize(12)
                .fontColor('#667085')
                .width('100%')

              Text(item.detail)
                .fontSize(12)
                .fontColor('#344054')
                .lineHeight(18)
                .width('100%')

              Text(item.time)
                .fontSize(11)
                .fontColor('#98A2B3')
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#F8FAFC')
            .borderRadius(16)
          }, (item: AuditLog) => item.id)
        }
        .width('100%')
      }
    }

    Button('退出登录')
      .width('100%')
      .height(48)
      .margin({ top: 4, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .fontColor('#D92D20')
      .borderRadius(16)
      .onClick(() => {
        this.currentUser = null;
        this.activeTab = 0;
        this.assistantQuestion = '';
        this.assistantAnswer = '';
        this.assistantRecommendedWorkflowId = '';
        this.assistantRelatedKnowledgeIds = [];
        this.resetWorkflowForm();
      })
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
  private StatCard(title: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(12)
        .fontColor('#667085')

      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#F8FAFC')
    .borderRadius(16)
  }

  @Builder
  private ArticlePreview(item: KnowledgeArticle, openInKnowledgeTab: boolean) {
    Column({ space: 8 }) {
      Row() {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .layoutWeight(1)

        Text(item.categoryName)
          .fontSize(11)
          .fontColor('#246BFD')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EAF1FF')
          .borderRadius(12)
      }

      Text(item.summary)
        .fontSize(12)
        .fontColor('#667085')
        .lineHeight(18)
        .width('100%')

      Text(`标签：${item.tags.join(' / ')} · 更新：${item.updateTime}`)
        .fontSize(11)
        .fontColor('#98A2B3')
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F8FAFC')
    .borderRadius(18)
    .onClick(() => {
      this.openArticle(item.id);
      if (openInKnowledgeTab) {
        this.activeTab = 1;
      }
    })
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

  private handleLogin(): void {
    const user: User | null = authenticateUser(this.loginAccount.trim(), this.loginPassword.trim());
    if (user === null) {
      promptAction.showToast({ message: '账号或密码错误，请重试。' });
      return;
    }

    this.currentUser = user;
    this.favoriteKnowledgeIds = this.copyStringArray(user.favoriteKnowledgeIds);
    this.selectedArticleId = user.recentKnowledgeIds.length > 0 ? user.recentKnowledgeIds[0] : 'k1';
    this.activeTab = 0;
    this.writeAuditLog('登录系统', '身份认证', 'normal', `${user.name} 使用 ${user.roleLabel} 账号登录。`);
    promptAction.showToast({ message: `欢迎你，${user.name}` });
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
    this.selectedWorkflowId = instance.id;
    this.createWorkflowNotification(template, instance, requiresSecurityConfirm);
    this.writeAuditLog(
      '提交流程',
      '流程协作',
      requiresSecurityConfirm ? 'high' : 'normal',
      `${this.getCurrentUser().name} 提交了“${instance.title}”，当前节点：${instance.currentNode}。`
    );

    if (requiresSecurityConfirm) {
      this.writeAuditLog(
        '触发风险检测',
        '安全治理',
        'high',
        `${instance.title} 已触发二次安全确认。原因：${riskReason}`
      );
    }

    this.resetWorkflowForm();
    promptAction.showToast({
      message: requiresSecurityConfirm ? `${template.name} 已提交，并触发二次确认。` : `${template.name} 已创建`
    });
  }

  private handleAskAssistant(): void {
    if (this.assistantQuestion.trim().length === 0) {
      promptAction.showToast({ message: '请输入问题后再提问。' });
      return;
    }

    const result = askAssistant(this.assistantQuestion);
    this.assistantAnswer = result.answer;
    this.assistantRecommendedWorkflowId = result.recommendedWorkflowId;
    this.assistantRelatedKnowledgeIds = this.copyStringArray(result.relatedKnowledgeIds);
    const history: AssistantHistory = {
      id: `${Date.now()}`,
      question: this.assistantQuestion,
      answer: result.answer,
      time: '刚刚'
    };
    this.prependAssistantHistory(history);
    promptAction.showToast({ message: '已返回模拟问答结果。' });
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

    const currentItem: WorkflowInstance | null = this.getWorkflowById(instanceId);
    if (currentItem !== null) {
      this.selectedWorkflowId = currentItem.id;
      this.prependNotification({
        id: `n${Date.now()}`,
        title: isApproved ? '流程审批已更新' : '流程被驳回',
        content: isApproved
          ? `${currentItem.title} 已被处理，申请人可查看最新节点。`
          : `${currentItem.title} 已被驳回，请根据意见补充材料。`,
        time: '刚刚',
        read: false,
        targetRoles: ['employee', 'approver', 'systemAdmin']
      });
      this.writeAuditLog(
        isApproved ? '审批通过' : '审批驳回',
        '流程审批',
        currentItem.status === '待二次确认' ? 'high' : 'normal',
        `${this.getCurrentUser().name} 处理了“${currentItem.title}”，意见：${opinion}`
      );
    }

    promptAction.showToast({ message: isApproved ? '已通过当前节点。' : '已驳回该流程。' });
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
  }

  private toggleFavorite(articleId: string): void {
    if (this.favoriteKnowledgeIds.includes(articleId)) {
      this.favoriteKnowledgeIds = this.favoriteKnowledgeIds.filter((item: string) => item !== articleId);
      promptAction.showToast({ message: '已取消收藏。' });
      return;
    }

    const favorites: string[] = [];
    favorites.push(articleId);
    this.favoriteKnowledgeIds.forEach((item: string) => {
      favorites.push(item);
    });
    this.favoriteKnowledgeIds = favorites;
    promptAction.showToast({ message: '已加入收藏。' });
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

  private getFilteredArticles(): KnowledgeArticle[] {
    return this.getPublishedArticles().filter((item: KnowledgeArticle) => {
      const matchCategory: boolean = this.selectedCategoryId === 'all' || item.categoryId === this.selectedCategoryId;
      const keyword: string = this.searchKeyword.trim();
      const matchKeyword: boolean = keyword.length === 0
        || item.title.includes(keyword)
        || item.summary.includes(keyword)
        || item.tags.join(' ').includes(keyword);
      return matchCategory && matchKeyword;
    });
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

  private getSelectedArticleTitle(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.title;
  }

  private getSelectedArticleContent(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.content;
  }

  private getSelectedArticleTags(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.tags.join(' / ');
  }

  private getSelectedArticleAttachments(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.attachments.join('、');
  }

  private getSelectedArticleWorkflowNames(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null ? '' : item.relatedWorkflowIds.map((workflowId: string) => this.getTemplateName(workflowId)).join('、');
  }

  private getSelectedArticlePrimaryWorkflowId(): string {
    const item: KnowledgeArticle | null = this.getSelectedArticle();
    return item === null || item.relatedWorkflowIds.length === 0 ? 'wf1' : item.relatedWorkflowIds[0];
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

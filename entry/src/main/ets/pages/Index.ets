import { promptAction } from '@kit.ArkUI';
import {
  AssistantHistory,
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
  getMockCategories,
  getMockInstances,
  getMockNotifications,
  getMockTemplates
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
  @State assistantQuestion: string = '';
  @State assistantAnswer: string = '';
  @State assistantRecommendedWorkflowId: string = '';
  @State assistantRelatedKnowledgeIds: string[] = [];
  @State assistantHistory: AssistantHistory[] = [];

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

  private prependAssistantHistory(history: AssistantHistory): void {
    const list: AssistantHistory[] = [];
    list.push(history);
    this.assistantHistory.forEach((item: AssistantHistory) => {
      list.push(item);
    });
    this.assistantHistory = list;
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
    SectionBlock({ title: '工作概览', subtitle: `${this.getCurrentUser().name}，今天推荐先处理待办，再查看最新制度更新。` }) {
      Row({ space: 10 }) {
        this.StatCard('待处理', `${this.getDashboardTodoCount()}`, '#246BFD');
        this.StatCard('知识总数', `${this.getPublishedArticles().length}`, '#12B76A');
        this.StatCard('消息提醒', `${this.getVisibleMessages().length}`, '#F79009');
      }
      .width('100%')
    }

    SectionBlock({ title: '快捷流程', subtitle: '常用流程入口已根据需求文档预置为四类审批。' }) {
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

            Text(item.riskLevel === 'high' ? '含安全确认预留' : '常规流程')
              .fontSize(11)
              .fontColor(item.riskLevel === 'high' ? '#B54708' : '#246BFD')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(item.riskLevel === 'high' ? '#FFF3E8' : '#EAF1FF')
              .borderRadius(12)
          }
          .width('48%')
          .margin({ bottom: 12 })
          .padding(14)
          .backgroundColor('#F8FAFF')
          .borderRadius(18)
          .onClick(() => {
            this.startWorkflow(item.id);
          })
        }, (item: WorkflowTemplate) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '智能助手', subtitle: '基础版本已接入关键词问答，可从工作台直接进入使用。' }) {
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
              Button(`发起${this.getTemplateName(this.assistantRecommendedWorkflowId)}`)
                .fontSize(12)
                .height(36)
                .backgroundColor('#EAF1FF')
                .fontColor('#246BFD')
                .borderRadius(12)
                .onClick(() => {
                  this.startWorkflow(this.assistantRecommendedWorkflowId);
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

    SectionBlock({ title: '消息提醒', subtitle: '流程状态变化与知识更新会统一汇总到这里。' }) {
      Column({ space: 10 }) {
        ForEach(this.getVisibleMessages().slice(0, 3), (item: NotificationItem) => {
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
                this.startWorkflow(this.getSelectedArticlePrimaryWorkflowId());
              })
          }
        }
        .width('100%')
      }
    }
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

    if (this.assistantHistory.length > 0) {
      SectionBlock({ title: '最近问答记录', subtitle: '基础框架保留最近问答，便于后续接入真实智能能力。' }) {
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

    SectionBlock({ title: '我的收藏', subtitle: '收藏知识已和知识库模块打通，可继续扩展到消息提醒。' }) {
      Column({ space: 10 }) {
        ForEach(this.getFavoriteArticles(), (item: KnowledgeArticle) => {
          this.ArticlePreview(item, true);
        }, (item: KnowledgeArticle) => item.id)
      }
      .width('100%')
    }

    SectionBlock({ title: '角色能力', subtitle: '系统会根据角色控制入口和待办处理能力。' }) {
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

    if (this.getCurrentUser().role !== 'employee') {
      SectionBlock({ title: '管理预留', subtitle: '管理员与审批角色在这里预留后续的配置和日志能力入口。' }) {
        Column({ space: 10 }) {
          Text('1. 知识发布与下架')
            .fontSize(13)
            .fontColor('#344054')
          Text('2. 用户、角色与流程模板管理')
            .fontSize(13)
            .fontColor('#344054')
          Text('3. 安全确认与操作日志')
            .fontSize(13)
            .fontColor('#344054')
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
    promptAction.showToast({ message: `欢迎你，${user.name}` });
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
    this.activeTab = 2;
    promptAction.showToast({ message: `${template.name} 已创建` });
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

    promptAction.showToast({ message: isApproved ? '已通过当前节点。' : '已驳回该流程。' });
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

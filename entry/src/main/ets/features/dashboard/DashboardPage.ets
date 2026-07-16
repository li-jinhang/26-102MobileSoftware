import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { EdgeLightPanel } from '../../common/components/EdgeLightPanel';
import { SectionBlock } from '../../common/components/SectionBlock';
import {
  KnowledgeArticle,
  NotificationItem,
  User,
  WorkflowTemplate
} from '../../models/AppModels';

@Component
export struct DashboardPage {
  @Require
  @Prop
  user: User;
  @Require
  @Prop
  articles: KnowledgeArticle[];
  @Require
  @Prop
  recentArticles: KnowledgeArticle[];
  @Require
  @Prop
  favoriteArticles: KnowledgeArticle[];
  @Require
  @Prop
  favoriteKnowledgeIds: string[];
  @Require
  @Prop
  notifications: NotificationItem[];
  @Require
  @Prop
  templates: WorkflowTemplate[];
  @Prop
  todoCount: number = 0;
  @Prop
  attendanceStatus: string = '未加载';
  @Prop
  mailUnreadCount: number = 0;
  onOpenArticle: (articleId: string) => void = () => {
  };
  onOpenAssistant: () => void = () => {
  };
  onOpenMessages: () => void = () => {
  };
  onOpenKnowledge: () => void = () => {
  };
  onOpenTodo: () => void = () => {
  };
  onOpenAttendance: () => void = () => {
  };
  onOpenMail: () => void = () => {
  };
  onOpenOrganization: () => void = () => {
  };
  onStartWorkflow: (templateId: string) => void = () => {
  };

  private getUnreadCount(): number {
    return this.notifications.filter((item: NotificationItem) => !item.read).length;
  }

  @Builder
  private StatItem(label: string, value: string, color: string, onClick: () => void) {
    Column({ space: 5 }) {
      Text(value)
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor('#667085')
    }
    .layoutWeight(1)
    .height(78)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F8FAFC')
    .borderRadius(12)
    .onClick(() => {
      onClick();
    })
  }

  build() {
    Column({ space: 14 }) {
      EdgeLightPanel({
        radiusValue: 16,
        todoCount: this.todoCount,
        unreadCount: this.getUnreadCount()
      }) {
        SectionBlock({ title: `你好，${this.user.name}`, subtitle: `${this.user.department} · ${this.user.roleLabel}` }) {
          Row({ space: 8 }) {
            this.StatItem('待处理', `${this.todoCount}`, '#246BFD', () => {
              this.onOpenTodo();
            })
            this.StatItem('知识', `${this.articles.length}`, '#027A48', () => {
              this.onOpenKnowledge();
            })
            this.StatItem('未读消息', `${this.getUnreadCount()}`, '#B54708', () => {
              this.onOpenMessages();
            })
          }
          .width('100%')
        }
      }

      SectionBlock({ title: '快捷流程', subtitle: '常用申请可在两步内进入填写。' }) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.templates, (item: WorkflowTemplate) => {
            Column({ space: 6 }) {
              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1F2A44')
                .width('100%')
              Text(item.description)
                .fontSize(11)
                .fontColor('#667085')
                .lineHeight(17)
                .maxLines(2)
                .width('100%')
            }
            .width('48%')
            .constraintSize({ minHeight: 96 })
            .padding(12)
            .margin({ bottom: 10 })
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
            .onClick(() => {
              this.onStartWorkflow(item.id);
            })
          }, (item: WorkflowTemplate) => item.id)
        }
        .width('100%')
      }

      Column({ space: 10 }) {
        Row() {
          Column({ space: 4 }) {
            Text('智能知识助手')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('模拟 Agent / Skill：查制度并推荐流程')
              .fontSize(12)
              .fontColor('#DCE7FF')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('›')
            .fontSize(28)
            .fontColor('#FFFFFF')
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#175CD3')
      .borderRadius(16)
      .onClick(() => {
        this.onOpenAssistant();
      })

      SectionBlock({ title: '办公入口', subtitle: '签到签退和内部邮件可以从这里进入。' }) {
        Row({ space: 10 }) {
          Column({ space: 6 }) {
            Text('签到签退')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')
            Text(this.attendanceStatus)
              .fontSize(12)
              .fontColor('#667085')
              .lineHeight(18)
              .width('100%')
          }
          .layoutWeight(1)
          .padding(14)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .onClick(() => {
            this.onOpenAttendance();
          })

          Column({ space: 6 }) {
            Text('内部邮件')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')
            Text(`${this.mailUnreadCount} 封未读，进入收件箱`)
              .fontSize(12)
              .fontColor('#667085')
              .lineHeight(18)
              .width('100%')
          }
          .layoutWeight(1)
          .padding(14)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .onClick(() => {
            this.onOpenMail();
          })
        }
        .width('100%')
      }

      SectionBlock({ title: '团队关系', subtitle: `${this.user.department} · ${this.user.jobTitle}` }) {
        Row({ space: 10 }) {
          Column({ space: 4 }) {
            Text(this.user.managerId.length > 0 ? '已设置直属上级' : '暂未设置直属上级')
              .fontSize(14)
              .fontColor('#344054')
            Text('查看我的组织与部门成员')
              .fontSize(12)
              .fontColor('#667085')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text('›')
            .fontSize(18)
            .fontColor('#175CD3')
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          this.onOpenOrganization();
        })
      }

      if (this.recentArticles.length > 0) {
        SectionBlock({ title: '最近知识', subtitle: '继续阅读最近查看的制度和指南。' }) {
          Column({ space: 10 }) {
            ForEach(this.recentArticles.slice(0, 3), (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: this.favoriteKnowledgeIds.includes(item.id),
                onOpen: (articleId: string) => {
                  this.onOpenArticle(articleId);
                }
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      if (this.favoriteArticles.length > 0) {
        SectionBlock({ title: '我的收藏', subtitle: '工作台直接进入常用知识。' }) {
          Column({ space: 10 }) {
            ForEach(this.favoriteArticles.slice(0, 2), (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: true,
                onOpen: (articleId: string) => {
                  this.onOpenArticle(articleId);
                }
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      SectionBlock({ title: '消息提醒', subtitle: `当前有 ${this.getUnreadCount()} 条未读消息` }) {
        Column({ space: 10 }) {
          ForEach(this.notifications.slice(0, 3), (item: NotificationItem) => {
            Row({ space: 10 }) {
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1F2A44')
                  .width('100%')
                Text(item.content)
                  .fontSize(11)
                  .fontColor('#667085')
                  .maxLines(2)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              if (!item.read) {
                Circle({ width: 7, height: 7 })
                  .fill('#F04438')
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor(item.read ? '#F8FAFC' : '#EEF4FF')
            .borderRadius(12)
          }, (item: NotificationItem) => item.id)

          Button('查看全部消息')
            .width('100%')
            .height(40)
            .fontColor('#175CD3')
            .backgroundColor('#EAF1FF')
            .borderRadius(10)
            .onClick(() => {
              this.onOpenMessages();
            })
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}

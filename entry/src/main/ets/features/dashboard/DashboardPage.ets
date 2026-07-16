import { EdgeLightPanel } from '../../common/components/EdgeLightPanel';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import { KnowledgeArticle, NotificationItem, User, WorkflowTemplate } from '../../models/AppModels';

@Component
export struct DashboardPage {
  @Require @Prop user: User;
  @Require @Prop articles: KnowledgeArticle[];
  @Require @Prop recentArticles: KnowledgeArticle[];
  @Require @Prop favoriteArticles: KnowledgeArticle[];
  @Require @Prop favoriteKnowledgeIds: string[];
  @Require @Prop notifications: NotificationItem[];
  @Require @Prop templates: WorkflowTemplate[];
  @Prop todoCount: number = 0;
  @Prop attendanceStatus: string = '未加载';
  @Prop mailUnreadCount: number = 0;
  onOpenArticle: (articleId: string) => void = () => {};
  onOpenAssistant: () => void = () => {};
  onOpenMessages: () => void = () => {};
  onOpenKnowledge: () => void = () => {};
  onOpenTodo: () => void = () => {};
  onOpenAttendance: () => void = () => {};
  onOpenMail: () => void = () => {};
  onOpenOrganization: () => void = () => {};
  onStartWorkflow: (templateId: string) => void = () => {};

  private getUnreadCount(): number {
    return this.notifications.filter((item: NotificationItem) => !item.read).length;
  }

  @Builder
  private StatItem(label: string, value: string, color: string, onClick: () => void) {
    Column({ space: 3 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
      Text(label)
        .fontSize(Typography.captionSize())
        .fontColor(AppTheme.textSecondary())
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(68)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      onClick();
    })
  }

  @Builder
  private QuickEntry(mark: string, label: string, detail: string, onClick: () => void) {
    Column({ space: 7 }) {
      Text(mark)
        .fontSize(20)
        .fontColor(AppTheme.primary())
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .padding({ top: 7 })
        .backgroundColor(AppTheme.primarySoft())
        .borderRadius(AppTheme.radiusMedium())
      Text(label)
        .fontSize(Typography.bodySize())
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.textPrimary())
        .maxLines(1)
      Text(detail)
        .fontSize(Typography.microSize())
        .fontColor(AppTheme.textTertiary())
        .maxLines(1)
    }
    .layoutWeight(1)
    .constraintSize({ minWidth: 0, minHeight: 94 })
    .onClick(() => {
      onClick();
    })
  }

  build() {
    Column({ space: 12 }) {
      EdgeLightPanel({
        radiusValue: AppTheme.radiusMedium(),
        todoCount: this.todoCount,
        unreadCount: this.getUnreadCount()
      }) {
        Column({ space: 10 }) {
          Row() {
            Column({ space: 3 }) {
              Text(`你好，${this.user.name}`)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppTheme.textPrimary())
              Text(`${this.user.department} · ${this.user.roleLabel}`)
                .fontSize(Typography.metaSize())
                .fontColor(AppTheme.textSecondary())
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('今日工作')
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.primary())
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(AppTheme.primarySoft())
              .borderRadius(AppTheme.radiusSmall())
          }
          .width('100%')

          Row() {
            this.StatItem('待处理', `${this.todoCount}`, AppTheme.primary(), () => this.onOpenTodo())
            Divider().vertical(true).height(34).color(AppTheme.divider())
            this.StatItem('知识', `${this.articles.length}`, AppTheme.success(), () => this.onOpenKnowledge())
            Divider().vertical(true).height(34).color(AppTheme.divider())
            this.StatItem('未读', `${this.getUnreadCount()}`, AppTheme.warning(), () => this.onOpenMessages())
            Divider().vertical(true).height(34).color(AppTheme.divider())
            this.StatItem('邮件', `${this.mailUnreadCount}`, AppTheme.primaryPressed(), () => this.onOpenMail())
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
      }

      Column({ space: 8 }) {
        Row() {
          Column({ space: 3 }) {
            Text('智能知识助手')
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('文字或图片提问，查知识并处理表单')
              .fontSize(Typography.metaSize())
              .fontColor('#D6E4FF')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('✦')
            .fontSize(23)
            .fontColor('#78E6D0')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(AppTheme.primaryPressed())
      .borderRadius(AppTheme.radiusMedium())
      .onClick(() => {
        this.onOpenAssistant();
      })

      SectionBlock({ title: '常用应用', subtitle: '快速进入日常协作工具' }) {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            this.QuickEntry('✓', '签到签退', this.attendanceStatus, () => this.onOpenAttendance())
            this.QuickEntry('✉', '内部邮件', `${this.mailUnreadCount} 封未读`, () => this.onOpenMail())
            this.QuickEntry('⌘', '我的组织', this.user.department, () => this.onOpenOrganization())
            this.QuickEntry('▤', '知识库', `${this.articles.length} 条`, () => this.onOpenKnowledge())
          }
          .width('100%')

          if (this.templates.length > 0) {
            Divider().color(AppTheme.divider())
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.templates.slice(0, 4), (item: WorkflowTemplate) => {
                Row({ space: 8 }) {
                  Text('＋')
                    .fontSize(16)
                    .fontColor(AppTheme.primary())
                  Text(item.name)
                    .fontSize(Typography.metaSize())
                    .fontColor(AppTheme.textPrimary())
                    .maxLines(1)
                }
                .width('48%')
                .height(40)
                .padding({ left: 10, right: 10 })
                .margin({ bottom: 8 })
                .backgroundColor(AppTheme.surfaceMuted())
                .borderRadius(AppTheme.radiusSmall())
                .onClick(() => {
                  this.onStartWorkflow(item.id);
                })
              }, (item: WorkflowTemplate) => item.id)
            }
            .width('100%')
          }
        }
        .width('100%')
      }

      if (this.recentArticles.length > 0) {
        SectionBlock({ title: '最近知识', subtitle: '继续阅读最近查看的制度和指南' }) {
          Column() {
            ForEach(this.recentArticles.slice(0, 3), (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: this.favoriteKnowledgeIds.includes(item.id),
                onOpen: (articleId: string) => this.onOpenArticle(articleId)
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      if (this.favoriteArticles.length > 0) {
        SectionBlock({ title: '我的收藏', subtitle: `${this.favoriteArticles.length} 条常用内容` }) {
          Column() {
            ForEach(this.favoriteArticles.slice(0, 2), (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: true,
                onOpen: (articleId: string) => this.onOpenArticle(articleId)
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      if (this.notifications.length > 0) {
        SectionBlock({ title: '消息动态', subtitle: `${this.getUnreadCount()} 条未读` }) {
          Column() {
            ForEach(this.notifications.slice(0, 3), (item: NotificationItem) => {
              Row({ space: 10 }) {
                Column({ space: 3 }) {
                  Text(item.title)
                    .fontSize(Typography.bodySize())
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppTheme.textPrimary())
                    .maxLines(1)
                  Text(item.content)
                    .fontSize(Typography.captionSize())
                    .fontColor(AppTheme.textSecondary())
                    .maxLines(1)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                if (!item.read) {
                  Circle({ width: 7, height: 7 }).fill(AppTheme.danger())
                }
              }
              .width('100%')
              .padding({ top: 11, bottom: 11 })
              .border({ width: { bottom: 1 }, color: AppTheme.divider() })
            }, (item: NotificationItem) => item.id)
          }
          .width('100%')
          .onClick(() => this.onOpenMessages())
        }
      }
    }
    .width('100%')
  }
}

import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import { KnowledgeArticle, User } from '../../models/AppModels';

@Component
export struct ProfilePage {
  @Require @Prop user: User;
  @Require @Prop favoriteArticles: KnowledgeArticle[];
  @Prop unreadCount: number = 0;
  @Prop mailUnreadCount: number = 0;
  @Prop attendanceStatus: string = '未加载';
  onOpenArticle: (articleId: string) => void = () => {};
  onOpenMessages: () => void = () => {};
  onOpenAttendance: () => void = () => {};
  onOpenMail: () => void = () => {};
  onOpenOrganization: () => void = () => {};
  onLogout: () => void = () => {};

  @Builder
  private SettingRow(mark: string, title: string, value: string, onClick: () => void) {
    Row({ space: 12 }) {
      Text(mark)
        .fontSize(17)
        .fontColor(AppTheme.primary())
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .padding({ top: 6 })
        .backgroundColor(AppTheme.primarySoft())
        .borderRadius(AppTheme.radiusSmall())
      Text(title)
        .fontSize(Typography.bodySize())
        .fontColor(AppTheme.textPrimary())
        .layoutWeight(1)
      Text(value)
        .fontSize(Typography.metaSize())
        .fontColor(AppTheme.textSecondary())
        .maxLines(1)
      Text('›')
        .fontSize(20)
        .fontColor(AppTheme.textTertiary())
    }
    .width('100%')
    .height(52)
    .border({ width: { bottom: 1 }, color: AppTheme.divider() })
    .onClick(() => {
      onClick();
    })
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 14 }) {
        Text(this.user.name.substring(0, 1))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .padding({ top: 11 })
          .backgroundColor(AppTheme.primary())
          .borderRadius(28)

        Column({ space: 4 }) {
          Text(this.user.name)
            .fontSize(21)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.textPrimary())
          Text(`${this.user.department} · ${this.user.jobTitle}`)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
          Text(this.user.roleLabel)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.primary())
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 4, right: 4, top: 8, bottom: 8 })

      SectionBlock({ title: '工作与协作' }) {
        Column() {
          this.SettingRow('⌘', '我的组织', this.user.department, () => this.onOpenOrganization())
          this.SettingRow('✓', '签到签退', this.attendanceStatus, () => this.onOpenAttendance())
          this.SettingRow('✉', '内部邮件', `${this.mailUnreadCount} 封未读`, () => this.onOpenMail())
          this.SettingRow('●', '消息中心', `${this.unreadCount} 条未读`, () => this.onOpenMessages())
        }
        .width('100%')
      }

      SectionBlock({ title: '角色权限', subtitle: `${this.user.permissions.length} 项当前权限` }) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.user.permissions, (permission: string) => {
            Text(permission)
              .fontSize(Typography.captionSize())
              .fontColor(AppTheme.primaryPressed())
              .padding({ left: 9, right: 9, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(AppTheme.primarySoft())
              .borderRadius(AppTheme.radiusSmall())
          }, (permission: string) => permission)
        }
        .width('100%')
      }

      SectionBlock({ title: '收藏知识', subtitle: `${this.favoriteArticles.length} 条常用内容` }) {
        if (this.favoriteArticles.length === 0) {
          EmptyState({ title: '还没有收藏', description: '在知识详情页收藏后会显示在这里' })
        } else {
          Column() {
            ForEach(this.favoriteArticles, (item: KnowledgeArticle) => {
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

      Button('退出登录')
        .width('100%')
        .height(AppTheme.controlHeight())
        .fontColor(AppTheme.danger())
        .backgroundColor('#FFF0F0')
        .borderRadius(AppTheme.radiusMedium())
        .onClick(() => {
          this.onLogout();
        })
    }
    .width('100%')
  }
}

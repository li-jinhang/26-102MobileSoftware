import { EmptyState } from '../../common/components/EmptyState';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import { MailFolder, MailImportance, MailMessage } from '../../models/AppModels';

@Component
export struct MailPage {
  @Require
  @Prop
  inbox: MailMessage[];
  @Require
  @Prop
  sent: MailMessage[];
  onBack: () => void = () => {
  };
  onOpenMail: (mailId: string) => void = () => {
  };
  onCompose: () => void = () => {
  };
  @State currentFolder: MailFolder = 'inbox';

  private getVisibleMails(): MailMessage[] {
    if (this.currentFolder === 'sent') {
      return this.sent;
    }
    return this.inbox;
  }

  private getUnreadCount(): number {
    return this.inbox.filter((item: MailMessage) => !item.read).length;
  }

  private getImportanceLabel(importance: MailImportance): string {
    if (importance === 'urgent') {
      return '紧急';
    }
    if (importance === 'important') {
      return '重要';
    }
    return '普通';
  }

  private getImportanceColor(importance: MailImportance): string {
    if (importance === 'urgent') {
      return '#B42318';
    }
    if (importance === 'important') {
      return '#B54708';
    }
    return '#667085';
  }

  build() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(Typography.iconBackSize())
          .fontColor(AppTheme.textPrimary())
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack();
          })
        Column({ space: 3 }) {
          Text('内部邮件')
            .fontSize(Typography.pageTitleSize())
            .fontWeight(Typography.titleWeight())
            .fontColor(AppTheme.textPrimary())
          Text(`${this.getUnreadCount()} 封未读`)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('写邮件')
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor(AppTheme.primary())
          .backgroundColor(AppTheme.primarySoft())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.onCompose();
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Text('收件箱')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(Typography.metaSize())
          .fontColor(this.currentFolder === 'inbox' ? '#FFFFFF' : '#475467')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.currentFolder === 'inbox' ? '#246BFD' : '#F2F4F7')
          .borderRadius(12)
          .onClick(() => {
            this.currentFolder = 'inbox';
          })
        Text('已发送')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(Typography.metaSize())
          .fontColor(this.currentFolder === 'sent' ? '#FFFFFF' : '#475467')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.currentFolder === 'sent' ? '#246BFD' : '#F2F4F7')
          .borderRadius(12)
          .onClick(() => {
            this.currentFolder = 'sent';
          })
      }
      .width('100%')

      if (this.getVisibleMails().length === 0) {
        EmptyState({
          title: '暂无邮件',
          description: '往来邮件会显示在这里。'
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.getVisibleMails(), (item: MailMessage) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(item.subject)
                    .fontSize(Typography.cardTitleSize())
                    .fontWeight(Typography.emphasisWeight())
                    .fontColor('#1F2A44')
                    .layoutWeight(1)
                    .maxLines(1)
                  Text(this.getImportanceLabel(item.importance))
                    .fontSize(Typography.microSize())
                    .fontColor(this.getImportanceColor(item.importance))
                }
                .width('100%')

                Text(item.summary)
                  .fontSize(Typography.metaSize())
                  .fontColor('#667085')
                  .lineHeight(Typography.summaryLineHeight())
                  .maxLines(2)
                  .width('100%')

                Row() {
                  Text(this.currentFolder === 'inbox' ? item.senderName : `收件人 ${item.recipients.length} 人`)
                    .fontSize(Typography.captionSize())
                    .fontColor('#475467')
                  Blank()
                  Text(item.createTime)
                    .fontSize(Typography.microSize())
                    .fontColor('#98A2B3')
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(item.read ? '#FFFFFF' : '#EEF4FF')
              .borderRadius(12)
              .onClick(() => {
                this.onOpenMail(item.id);
              })
            }, (item: MailMessage) => item.id)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(AppTheme.pageBackground())
  }
}

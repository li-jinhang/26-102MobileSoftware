import { EmptyState } from '../../common/components/EmptyState';
import { AppTopBar } from '../../common/components/AppTopBar';
import { filterNotifications } from '../../common/services/MessageService';
import { AppTheme } from '../../common/theme/AppTheme';
import { NotificationItem } from '../../models/AppModels';

@Component
export struct MessagesPage {
  @Require
  @Prop
  notifications: NotificationItem[];
  onBack: () => void = () => {
  };
  onMarkRead: (notificationId: string) => void = () => {
  };
  onOpenKnowledge: (articleId: string) => void = () => {
  };
  onOpenWorkflow: (instanceId: string) => void = () => {
  };
  onOpenAttendance: () => void = () => {
  };
  onOpenMail: (mailId: string) => void = () => {
  };
  @State unreadOnly: boolean = false;

  private getItems(): NotificationItem[] {
    return filterNotifications(this.notifications, this.unreadOnly);
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`MessagesPage toast failed: ${error}`);
    }
  }

  private openMessage(item: NotificationItem): void {
    this.onMarkRead(item.id);
    if (item.targetType === 'knowledge' && item.targetId.length > 0) {
      this.onOpenKnowledge(item.targetId);
      return;
    }
    if (item.targetType === 'workflow' && item.targetId.length > 0) {
      this.onOpenWorkflow(item.targetId);
      return;
    }
    if (item.targetType === 'attendance') {
      this.onOpenAttendance();
      return;
    }
    if (item.targetType === 'mail' && item.targetId.length > 0) {
      this.onOpenMail(item.targetId);
      return;
    }
    this.showMessage('这是一条通知消息，没有关联页面。');
  }

  build() {
    Column() {
      AppTopBar({
        title: '消息',
        subtitle: `${this.notifications.filter((item: NotificationItem) => !item.read).length} 条未读`,
        onBack: () => this.onBack()
      })

      Row({ space: 6 }) {
        Text('全部')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(13)
          .fontColor(this.unreadOnly ? '#475467' : '#FFFFFF')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.unreadOnly ? AppTheme.surfaceMuted() : AppTheme.primary())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.unreadOnly = false;
          })
        Text('未读')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(13)
          .fontColor(this.unreadOnly ? '#FFFFFF' : '#475467')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.unreadOnly ? AppTheme.primary() : AppTheme.surfaceMuted())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.unreadOnly = true;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      Scroll() {
        if (this.getItems().length === 0) {
          EmptyState({
            title: this.unreadOnly ? '没有未读消息' : '暂无消息',
            description: this.unreadOnly ? '所有消息都已处理。' : '流程和知识更新会显示在这里。'
          })
        } else {
          Column({ space: 10 }) {
            ForEach(this.getItems(), (item: NotificationItem) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(item.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2A44')
                    .layoutWeight(1)
                  if (!item.read) {
                    Text('未读')
                      .fontSize(10)
                      .fontColor('#B42318')
                      .padding({ left: 7, right: 7, top: 4, bottom: 4 })
                      .backgroundColor('#FEE4E2')
                      .borderRadius(12)
                  }
                }
                .width('100%')

                Text(item.content)
                  .fontSize(12)
                  .fontColor('#667085')
                  .lineHeight(19)
                  .width('100%')

                Row() {
                  Text(item.time)
                    .fontSize(10)
                    .fontColor('#98A2B3')
                  Blank()
                  if (!item.read) {
                    Button('标记已读')
                      .height(32)
                      .fontSize(11)
                      .fontColor('#175CD3')
                      .backgroundColor('#EAF1FF')
                      .borderRadius(12)
                      .onClick(() => {
                        this.onMarkRead(item.id);
                      })
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(item.read ? '#FFFFFF' : '#EEF4FF')
              .borderRadius(12)
              .onClick(() => {
                this.openMessage(item);
              })
            }, (item: NotificationItem) => item.id)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 24 })
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.pageBackground())
  }
}

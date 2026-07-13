import { EmptyState } from '../../common/components/EmptyState';
import { filterNotifications } from '../../common/services/MessageService';
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
    this.showMessage('这是一条通知消息，没有关联页面。');
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(30)
          .fontColor('#1F2A44')
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack();
          })
        Column({ space: 3 }) {
          Text('消息')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
          Text(`${this.notifications.filter((item: NotificationItem) => !item.read).length} 条未读`)
            .fontSize(11)
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Row({ space: 6 }) {
        Text('全部')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(13)
          .fontColor(this.unreadOnly ? '#475467' : '#FFFFFF')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.unreadOnly ? '#F2F4F7' : '#246BFD')
          .borderRadius(8)
          .onClick(() => {
            this.unreadOnly = false;
          })
        Text('未读')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(13)
          .fontColor(this.unreadOnly ? '#FFFFFF' : '#475467')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.unreadOnly ? '#246BFD' : '#F2F4F7')
          .borderRadius(8)
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
                      .borderRadius(6)
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
                      .borderRadius(8)
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
              .borderRadius(8)
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
    .backgroundColor('#F3F6FB')
  }
}

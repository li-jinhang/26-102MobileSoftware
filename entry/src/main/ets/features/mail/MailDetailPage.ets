import { Typography } from '../../common/theme/Typography';
import { MailMessage, MailRecipient } from '../../models/AppModels';

@Component
export struct MailDetailPage {
  @Require
  @Prop
  mail: MailMessage;
  onBack: () => void = () => {
  };
  onOpenWorkflow: (workflowId: string) => void = () => {
  };
  onOpenKnowledge: (knowledgeId: string) => void = () => {
  };

  private getRecipientsLabel(): string {
    const names: string[] = [];
    this.mail.recipients.forEach((item: MailRecipient) => {
      names.push(item.userName);
    });
    return names.join('、');
  }

  build() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(Typography.iconBackSize())
          .fontColor('#1F2A44')
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack();
          })
        Text('邮件详情')
          .fontSize(Typography.pageTitleSize())
          .fontWeight(Typography.titleWeight())
          .fontColor('#1F2A44')
      }
      .width('100%')

      Column({ space: 10 }) {
        Text(this.mail.subject)
          .fontSize(Typography.pageTitleSize())
          .fontWeight(Typography.titleWeight())
          .fontColor('#1F2A44')
          .width('100%')
        Text(`发件人：${this.mail.senderName}`)
          .fontSize(Typography.metaSize())
          .fontColor('#475467')
          .width('100%')
        Text(`收件人：${this.getRecipientsLabel()}`)
          .fontSize(Typography.metaSize())
          .fontColor('#475467')
          .width('100%')
        Text(`时间：${this.mail.createTime}`)
          .fontSize(Typography.metaSize())
          .fontColor('#667085')
          .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Column() {
        Text(this.mail.content)
          .fontSize(Typography.bodySize())
          .lineHeight(Typography.bodyLineHeight())
          .fontColor('#1F2A44')
          .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Row({ space: 10 }) {
        if (this.mail.relatedWorkflowId.length > 0) {
          Button('查看关联流程')
            .layoutWeight(1)
            .height(40)
            .fontColor('#175CD3')
            .backgroundColor('#EAF1FF')
            .borderRadius(12)
            .onClick(() => {
              this.onOpenWorkflow(this.mail.relatedWorkflowId);
            })
        }
        if (this.mail.relatedKnowledgeId.length > 0) {
          Button('查看关联知识')
            .layoutWeight(1)
            .height(40)
            .fontColor('#175CD3')
            .backgroundColor('#EAF1FF')
            .borderRadius(12)
            .onClick(() => {
              this.onOpenKnowledge(this.mail.relatedKnowledgeId);
            })
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F3F6FB')
  }
}

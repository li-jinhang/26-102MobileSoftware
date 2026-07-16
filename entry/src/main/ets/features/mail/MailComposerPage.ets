import { AppTopBar } from '../../common/components/AppTopBar';
import { AppTheme } from '../../common/theme/AppTheme';

@Component
export struct MailComposerPage {
  onBack: () => void = () => {
  };
  onSend: (
    receiverIds: string[],
    subject: string,
    content: string,
    relatedWorkflowId: string,
    relatedKnowledgeId: string
  ) => void = () => {
  };
  @State receiverInput: string = '';
  @State subjectInput: string = '';
  @State contentInput: string = '';
  @State relatedWorkflowId: string = '';
  @State relatedKnowledgeId: string = '';

  private getReceiverIds(): string[] {
    return this.receiverInput
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
  }

  private canSend(): boolean {
    return this.getReceiverIds().length > 0 && this.subjectInput.trim().length > 0 && this.contentInput.trim().length > 0;
  }

  build() {
    Column({ space: 14 }) {
      AppTopBar({ title: '写邮件', onBack: () => this.onBack() })

      Column({ space: 12 }) {
        TextInput({ placeholder: '收件人 ID，多个用英文逗号分隔', text: this.receiverInput })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.receiverInput = value;
          })

        TextInput({ placeholder: '邮件主题', text: this.subjectInput })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.subjectInput = value;
          })

        TextInput({ placeholder: '邮件正文', text: this.contentInput })
          .width('100%')
          .height(120)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.contentInput = value;
          })

        TextInput({ placeholder: '关联流程 ID（可选）', text: this.relatedWorkflowId })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.relatedWorkflowId = value;
          })

        TextInput({ placeholder: '关联知识 ID（可选）', text: this.relatedKnowledgeId })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .onChange((value: string) => {
            this.relatedKnowledgeId = value;
          })
      }
      .width('100%')

      Button('发送邮件')
        .width('100%')
        .height(44)
        .fontColor('#FFFFFF')
        .backgroundColor(this.canSend() ? '#175CD3' : '#D0D5DD')
        .borderRadius(12)
        .enabled(this.canSend())
        .onClick(() => {
          this.onSend(
            this.getReceiverIds(),
            this.subjectInput,
            this.contentInput,
            this.relatedWorkflowId.trim(),
            this.relatedKnowledgeId.trim()
          );
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(AppTheme.pageBackground())
  }
}

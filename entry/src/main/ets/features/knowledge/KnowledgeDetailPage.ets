import { KnowledgeArticle, ReadingFontScale } from '../../models/AppModels';

@Component
export struct KnowledgeDetailPage {
  @Require
  @Prop
  article: KnowledgeArticle;
  @Prop
  favorite: boolean = false;
  @Prop
  useful: boolean = false;
  @Prop
  fontScale: ReadingFontScale = 'standard';
  @Prop
  workflowNames: string = '';
  onBack: () => void = () => {
  };
  onToggleFavorite: (articleId: string) => void = () => {
  };
  onMarkUseful: (articleId: string) => void = () => {
  };
  onSubmitCorrection: (articleId: string, content: string) => Promise<boolean> = async () => false;
  onFontScaleChange: (scale: ReadingFontScale) => void = () => {
  };
  onStartWorkflow: (templateId: string) => void = () => {
  };
  @State correctionText: string = '';

  private getBodyFontSize(): number {
    if (this.fontScale === 'small') {
      return 14;
    }
    if (this.fontScale === 'large') {
      return 19;
    }
    return 16;
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`KnowledgeDetailPage toast failed: ${error}`);
    }
  }

  private async submitCorrection(): Promise<void> {
    if (!await this.onSubmitCorrection(this.article.id, this.correctionText)) {
      this.showMessage('请填写具体的纠错内容。');
      return;
    }
    this.correctionText = '';
    this.showMessage('纠错建议已提交。');
  }

  @Builder
  private FontScaleOption(scale: ReadingFontScale, label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.fontScale === scale ? '#FFFFFF' : '#475467')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 9, bottom: 9 })
      .backgroundColor(this.fontScale === scale ? '#246BFD' : '#F2F4F7')
      .borderRadius(6)
      .onClick(() => {
        this.onFontScaleChange(scale);
      })
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
          Text('知识详情')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
          Text(`${this.article.categoryName} · ${this.article.version}`)
            .fontSize(12)
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F3F6FB')

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 10 }) {
            Text(this.article.title)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#172B4D')
              .lineHeight(34)
              .width('100%')

            Text(`${this.article.updateTime} 更新 · ${this.article.tags.join(' / ')}`)
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#EAF1FF')
          .borderRadius(8)

          Column({ space: 12 }) {
            Row() {
              Text('阅读字号')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#344054')
              Blank()
              Text('HarmonyOS 阅读体验')
                .fontSize(11)
                .fontColor('#175CD3')
            }
            .width('100%')

            Row({ space: 6 }) {
              this.FontScaleOption('small', '小')
              this.FontScaleOption('standard', '标准')
              this.FontScaleOption('large', '大')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)

          Column({ space: 14 }) {
            Text(this.article.content)
              .fontSize(this.getBodyFontSize())
              .fontColor('#344054')
              .lineHeight(this.getBodyFontSize() + 10)
              .width('100%')

            Text(`附件：${this.article.attachments.length > 0 ? this.article.attachments.join('、') : '无'}`)
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')

            if (this.workflowNames.length > 0) {
              Text(`适用流程：${this.workflowNames}`)
                .fontSize(12)
                .fontColor('#667085')
                .width('100%')
            }
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)

          Row({ space: 10 }) {
            Button(this.favorite ? '取消收藏' : '收藏')
              .layoutWeight(1)
              .height(42)
              .fontColor('#175CD3')
              .backgroundColor('#EAF1FF')
              .borderRadius(8)
              .onClick(() => {
                this.onToggleFavorite(this.article.id);
              })

            Button(this.useful ? '已反馈有用' : '这篇有用')
              .layoutWeight(1)
              .height(42)
              .fontColor(this.useful ? '#027A48' : '#FFFFFF')
              .backgroundColor(this.useful ? '#ECFDF3' : '#12B76A')
              .borderRadius(8)
              .enabled(!this.useful)
              .onClick(() => {
                this.onMarkUseful(this.article.id);
                this.showMessage('感谢你的反馈。');
              })
          }
          .width('100%')

          if (this.article.relatedWorkflowIds.length > 0) {
            Button(`发起${this.workflowNames}`)
              .width('100%')
              .height(44)
              .backgroundColor('#246BFD')
              .borderRadius(8)
              .onClick(() => {
                this.onStartWorkflow(this.article.relatedWorkflowIds[0]);
              })
          }

          Column({ space: 10 }) {
            Text('纠错建议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2A44')
              .width('100%')

            TextArea({ placeholder: '请说明过期内容、错误信息或建议修改位置', text: this.correctionText })
              .height(110)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.correctionText = value;
              })

            Button('提交纠错')
              .width('100%')
              .height(42)
              .backgroundColor('#344054')
              .borderRadius(8)
              .onClick(() => {
                void this.submitCorrection();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FB')
  }
}

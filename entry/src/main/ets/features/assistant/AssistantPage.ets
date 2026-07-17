import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { AppTopBar } from '../../common/components/AppTopBar';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import {
  AssistantFormDraft,
  AssistantAction,
  AssistantHistory,
  AssistantMailDraft,
  AssistantReply,
  AssistantSelectedImage,
  KnowledgeArticle,
  WorkflowTemplate
} from '../../models/AppModels';

@Component
export struct AssistantPage {
  @Require @Prop articles: KnowledgeArticle[];
  @Require @Prop templates: WorkflowTemplate[];
  @Require @Prop selectedImage: AssistantSelectedImage | null;
  @Require @Prop loading: boolean;
  @Link history: AssistantHistory[];
  @Link question: string;
  @Link reply: AssistantReply | null;
  onBack: () => void = () => {};
  onOpenArticle: (articleId: string) => void = () => {};
  onSelectImage: () => void = () => {};
  onClearImage: () => void = () => {};
  onOpenWorkflowWithoutDraft: (templateId: string) => void = () => {};
  onOpenWorkflowWithDraft: (templateId: string, draft: AssistantFormDraft) => void = () => {};
  onOpenMailComposer: (draft: AssistantMailDraft) => void = () => {};
  onAsk: () => void = () => {};

  private getRelatedArticles(): KnowledgeArticle[] {
    if (this.reply === null) {
      return [];
    }
    return this.articles.filter((item: KnowledgeArticle) => {
      return this.reply !== null && this.reply.relatedKnowledgeIds.includes(item.id);
    });
  }

  private hasRecommendedWorkflow(): boolean {
    if (this.reply === null || this.reply.recommendedWorkflowId.length === 0) {
      return false;
    }
    return this.templates.some((item: WorkflowTemplate) => item.id === this.reply?.recommendedWorkflowId);
  }

  private getRecommendedWorkflowName(): string {
    if (this.reply === null) {
      return '';
    }
    const template: WorkflowTemplate | undefined = this.templates.find((item: WorkflowTemplate) => {
      return this.reply !== null && item.id === this.reply.recommendedWorkflowId;
    });
    return template === undefined ? '' : template.name;
  }

  private canAsk(): boolean {
    return !this.loading && (this.question.trim().length > 0 || this.selectedImage !== null);
  }

  private hasMailDraft(): boolean {
    if (this.reply === null) {
      return false;
    }
    const action: AssistantAction | null | undefined = this.reply.action;
    return action !== null && action !== undefined && action.type === 'mail' && action.mailDraft !== null;
  }

  build() {
    Column() {
      AppTopBar({
        title: '智能助手',
        subtitle: '文字与图片均由大模型分析',
        onBack: () => this.onBack()
      })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 10 }) {
            TextArea({
              placeholder: '描述工作需求，例如给上级发邮件说明新功能已完成',
              text: this.question
            })
              .width('100%')
              .height(92)
              .backgroundColor(AppTheme.surface())
              .border({ width: 1, color: AppTheme.border() })
              .borderRadius(AppTheme.radiusMedium())
              .padding(12)
              .onChange((value: string) => {
                this.question = value;
              })

            if (this.selectedImage !== null) {
              Column({ space: 8 }) {
                Image(this.selectedImage.previewUri)
                  .width('100%')
                  .height(170)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F8FAFC')
                  .borderRadius(8)
                Button('移除图片')
                  .height(36)
                  .fontColor('#B42318')
                  .backgroundColor('#FEF3F2')
                  .borderRadius(8)
                  .onClick(() => {
                    this.onClearImage();
                  })
              }
              .width('100%')
            }

            Row({ space: 10 }) {
              Button('从相册选择')
                .layoutWeight(1)
                .height(44)
                .fontColor(AppTheme.primary())
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(AppTheme.radiusMedium())
                .enabled(!this.loading)
                .onClick(() => {
                  this.onSelectImage();
                })
              Button(this.loading ? '分析中...' : '发送')
                .layoutWeight(1)
                .height(44)
                .fontColor('#FFFFFF')
                .backgroundColor(this.canAsk() ? AppTheme.primary() : AppTheme.textDisabled())
                .borderRadius(AppTheme.radiusMedium())
                .enabled(this.canAsk())
                .onClick(() => {
                  this.onAsk();
                })
            }
            .width('100%')
          }
          .width('100%')

          if (this.reply !== null) {
            Column({ space: 12 }) {
              Text('大模型回答')
                .fontSize(Typography.metaSize())
                .fontColor('#175CD3')
                .width('100%')

              if (this.reply.recognizedText.length > 0) {
                Column({ space: 5 }) {
                  Text('图片识别文字')
                    .fontSize(Typography.metaSize())
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#475467')
                  Text(this.reply.recognizedText)
                    .fontSize(Typography.metaSize())
                    .fontColor('#667085')
                    .lineHeight(19)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(12)
                .backgroundColor('#F8FAFC')
                .borderRadius(8)
              }

              Text(this.reply.answer)
                .fontSize(Typography.bodyLargeSize())
                .fontColor('#344054')
                .lineHeight(Typography.bodyLargeLineHeight())
                .width('100%')

              if (this.hasMailDraft() && this.reply !== null && this.reply.action.mailDraft !== null) {
                Column({ space: 8 }) {
                  Text(this.reply.action.mailDraft.receiverNames.length > 0
                    ? `收件人：${this.reply.action.mailDraft.receiverNames.join('、')}`
                    : '收件人：请在邮件页选择')
                    .fontSize(Typography.metaSize())
                    .fontColor(AppTheme.textSecondary())
                    .width('100%')
                  Text(`主题：${this.reply.action.mailDraft.subject}`)
                    .fontSize(Typography.bodySize())
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppTheme.textPrimary())
                    .maxLines(1)
                  Button('填写邮件')
                    .width('100%')
                    .height(42)
                    .fontColor('#FFFFFF')
                    .backgroundColor(AppTheme.primary())
                    .borderRadius(AppTheme.radiusSmall())
                    .onClick(() => {
                      if (this.reply !== null && this.reply.action.mailDraft !== null) {
                        this.onOpenMailComposer(this.reply.action.mailDraft);
                      }
                    })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(AppTheme.primarySoft())
                .borderRadius(AppTheme.radiusSmall())
              }

              ForEach(this.getRelatedArticles(), (item: KnowledgeArticle) => {
                KnowledgeCard({
                  article: item,
                  onOpen: (articleId: string) => {
                    this.onOpenArticle(articleId);
                  }
                })
              }, (item: KnowledgeArticle) => item.id)

              if (this.hasRecommendedWorkflow() && this.reply !== null) {
                Column({ space: 9 }) {
                  Text(`推荐流程：${this.getRecommendedWorkflowName()}`)
                    .fontSize(Typography.bodySize())
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2A44')
                  if (this.reply.missingFields.length > 0) {
                    Text(`仍需补充：${this.reply.missingFields.join('、')}`)
                      .fontSize(Typography.captionSize())
                      .fontColor('#B54708')
                  }
                  Row({ space: 10 }) {
                    Button('打开表单')
                      .layoutWeight(1)
                      .height(42)
                      .fontColor('#175CD3')
                      .backgroundColor('#EAF1FF')
                      .borderRadius(8)
                      .onClick(() => {
                        if (this.reply !== null) {
                          this.onOpenWorkflowWithoutDraft(this.reply.recommendedWorkflowId);
                        }
                      })
                    Button('智能预填')
                      .layoutWeight(1)
                      .height(42)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#12B76A')
                      .borderRadius(8)
                      .onClick(() => {
                        if (this.reply !== null) {
                          this.onOpenWorkflowWithDraft(this.reply.recommendedWorkflowId, this.reply.formDraft);
                        }
                      })
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F0FDF4')
                .borderRadius(8)
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }

          Column({ space: 10 }) {
            Text('最近问答')
              .fontSize(Typography.sectionTitleSize())
              .fontWeight(Typography.titleWeight())
              .fontColor('#1F2A44')
              .width('100%')
            if (this.history.length === 0) {
              EmptyState({ title: '还没有问答记录', description: '输入文字或选择图片开始使用。' })
            } else {
              ForEach(this.history, (item: AssistantHistory) => {
                Column({ space: 6 }) {
                  Text(item.question)
                    .fontSize(Typography.bodySize())
                    .fontWeight(Typography.emphasisWeight())
                    .fontColor('#1F2A44')
                    .width('100%')
                  Text(item.answer)
                    .fontSize(Typography.metaSize())
                    .fontColor('#667085')
                    .lineHeight(Typography.summaryLineHeight())
                    .maxLines(3)
                    .width('100%')
                  Text(item.time)
                    .fontSize(Typography.microSize())
                    .fontColor('#98A2B3')
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
              }, (item: AssistantHistory) => item.id)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.pageBackground())
  }
}

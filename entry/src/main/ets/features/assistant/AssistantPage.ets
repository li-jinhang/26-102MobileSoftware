import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { Typography } from '../../common/theme/Typography';
import {
  AssistantHistory,
  AssistantReply,
  KnowledgeArticle,
  WorkflowTemplate
} from '../../models/AppModels';

@Component
export struct AssistantPage {
  @Require
  @Prop
  articles: KnowledgeArticle[];
  @Require
  @Prop
  templates: WorkflowTemplate[];
  @Link history: AssistantHistory[];
  @Link question: string;
  @Link reply: AssistantReply | null;
  onBack: () => void = () => {
  };
  onOpenArticle: (articleId: string) => void = () => {
  };
  onStartWorkflow: (templateId: string) => void = () => {
  };
  onAsk: () => void = () => {
  };
  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (error) {
      console.error(`AssistantPage toast failed: ${error}`);
    }
  }

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

  private ask(): void {
    this.onAsk();
  }

  build() {
    Column() {
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
        Column({ space: 3 }) {
          Text('智能知识助手')
            .fontSize(Typography.pageTitleSize())
            .fontWeight(Typography.titleWeight())
            .fontColor('#1F2A44')
          Text('关键词匹配演示 · Agent / Skill 接口预留')
            .fontSize(Typography.captionSize())
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 10 }) {
            TextInput({ placeholder: '例如：报销打车费需要什么材料？', text: this.question })
              .height(50)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ left: 14, right: 14 })
              .onChange((value: string) => {
                this.question = value;
              })
            Button('发送问题')
              .width('100%')
              .height(44)
              .backgroundColor('#175CD3')
              .borderRadius(12)
              .onClick(() => {
                this.ask();
              })
          }
          .width('100%')

          if (this.reply !== null) {
            Column({ space: 12 }) {
              Text('回答')
                .fontSize(Typography.metaSize())
                .fontColor('#175CD3')
                .width('100%')
              Text(this.reply.answer)
                .fontSize(Typography.bodyLargeSize())
                .fontColor('#344054')
                .lineHeight(Typography.bodyLargeLineHeight())
                .width('100%')

              ForEach(this.getRelatedArticles(), (item: KnowledgeArticle) => {
                KnowledgeCard({
                  article: item,
                  onOpen: (articleId: string) => {
                    this.onOpenArticle(articleId);
                  }
                })
              }, (item: KnowledgeArticle) => item.id)

              if (this.hasRecommendedWorkflow() && this.reply !== null) {
                Button(`立即发起${this.getRecommendedWorkflowName()}`)
                  .width('100%')
                  .height(42)
                  .backgroundColor('#12B76A')
                  .borderRadius(12)
                  .onClick(() => {
                    if (this.reply !== null) {
                      this.onStartWorkflow(this.reply.recommendedWorkflowId);
                    }
                  })
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
              EmptyState({ title: '还没有问答记录', description: '提出一个制度或流程问题开始使用。' })
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
    .backgroundColor('#F3F6FB')
  }
}

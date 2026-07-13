import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { buildAssistantReply } from '../../common/services/AssistantService';
import {
  AssistantHistory,
  AssistantReply,
  KnowledgeArticle,
  WorkflowTemplate
} from '../../models/AppModels';

@Component
export struct AssistantPage {
  articles: KnowledgeArticle[];
  templates: WorkflowTemplate[];
  @Link history: AssistantHistory[];
  onBack: () => void = () => {
  };
  onOpenArticle: (articleId: string) => void = () => {
  };
  onStartWorkflow: (templateId: string) => void = () => {
  };
  @State question: string = '';
  @State reply: AssistantReply | null = null;

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

  private prependHistory(history: AssistantHistory): void {
    const list: AssistantHistory[] = [history];
    this.history.forEach((item: AssistantHistory) => {
      list.push(item);
    });
    this.history = list;
  }

  private ask(): void {
    const result: AssistantReply | null = buildAssistantReply(this.question);
    if (result === null) {
      this.showMessage('请输入问题后再提问。');
      return;
    }
    this.reply = result;
    this.prependHistory({
      id: `${Date.now()}`,
      question: this.question.trim(),
      answer: result.answer,
      time: '刚刚'
    });
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
          Text('智能知识助手')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
          Text('关键词匹配演示 · Agent / Skill 接口预留')
            .fontSize(11)
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
              .borderRadius(8)
              .padding({ left: 14, right: 14 })
              .onChange((value: string) => {
                this.question = value;
              })
            Button('发送问题')
              .width('100%')
              .height(44)
              .backgroundColor('#175CD3')
              .borderRadius(8)
              .onClick(() => {
                this.ask();
              })
          }
          .width('100%')

          if (this.reply !== null) {
            Column({ space: 12 }) {
              Text('模拟回答')
                .fontSize(12)
                .fontColor('#175CD3')
                .width('100%')
              Text(this.reply.answer)
                .fontSize(15)
                .fontColor('#344054')
                .lineHeight(24)
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
                  .borderRadius(8)
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
            .borderRadius(8)
          }

          Column({ space: 10 }) {
            Text('最近问答')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2A44')
              .width('100%')
            if (this.history.length === 0) {
              EmptyState({ title: '还没有问答记录', description: '提出一个制度或流程问题开始使用。' })
            } else {
              ForEach(this.history, (item: AssistantHistory) => {
                Column({ space: 6 }) {
                  Text(item.question)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2A44')
                    .width('100%')
                  Text(item.answer)
                    .fontSize(12)
                    .fontColor('#667085')
                    .lineHeight(18)
                    .maxLines(3)
                    .width('100%')
                  Text(item.time)
                    .fontSize(10)
                    .fontColor('#98A2B3')
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
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

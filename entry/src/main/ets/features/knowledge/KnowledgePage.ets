import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { searchKnowledge } from '../../common/services/KnowledgeService';
import { AppTheme } from '../../common/theme/AppTheme';
import { KnowledgeArticle, KnowledgeCategory, WorkflowTemplate } from '../../models/AppModels';

@Component
export struct KnowledgePage {
  @Require
  @Prop
  categories: KnowledgeCategory[];
  @Require
  @Prop
  articles: KnowledgeArticle[];
  @Require
  @Prop
  favoriteKnowledgeIds: string[];
  @Require
  @Prop
  templates: WorkflowTemplate[];
  onOpenArticle: (articleId: string) => void = () => {
  };
  onStartWorkflow: (templateId: string) => void = () => {
  };
  @State selectedCategoryId: string = 'all';

  private getResults(): KnowledgeArticle[] {
    return searchKnowledge(this.articles, this.selectedCategoryId, '');
  }

  private clearFilters(): void {
    this.selectedCategoryId = 'all';
  }

  build() {
    Column({ space: 12 }) {
      SectionBlock({ title: '知识分类', subtitle: '按分类浏览公司制度与操作指南' }) {
        Column({ space: 8 }) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories, (item: KnowledgeCategory) => {
                Text(item.name)
                  .fontSize(12)
                  .fontColor(this.selectedCategoryId === item.id ? '#FFFFFF' : AppTheme.textSecondary())
                  .height(34)
                  .padding({ left: 14, right: 14, top: 7 })
                  .backgroundColor(this.selectedCategoryId === item.id ? AppTheme.primary() : AppTheme.surfaceMuted())
                  .borderRadius(AppTheme.radiusSmall())
                  .onClick(() => {
                    this.selectedCategoryId = item.id;
                  })
              }, (item: KnowledgeCategory) => item.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .width('100%')
      }

      SectionBlock({ title: '全部知识', subtitle: `${this.getResults().length} 条内容` }) {
        if (this.getResults().length === 0) {
          EmptyState({
            title: '没有匹配的知识',
            description: '可以更换关键词或恢复全部分类。',
            actionLabel: '清除筛选',
            onAction: () => {
              this.clearFilters();
            }
          })
        } else {
          Column() {
            ForEach(this.getResults(), (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: this.favoriteKnowledgeIds.includes(item.id),
                onOpen: (articleId: string) => {
                  this.onOpenArticle(articleId);
                }
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      SectionBlock({ title: '申报模板', subtitle: `${this.templates.length} 个可直接填写的申请模板` }) {
        if (this.templates.length === 0) {
          EmptyState({ title: '暂无申报模板', description: '可用申请模板会显示在这里。' })
        } else {
          Column() {
            ForEach(this.templates, (item: WorkflowTemplate) => {
              Row({ space: 10 }) {
                Column({ space: 3 }) {
                  Text(item.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppTheme.textPrimary())
                    .maxLines(1)
                  Text(item.description)
                    .fontSize(12)
                    .fontColor(AppTheme.textSecondary())
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('填写')
                  .fontSize(13)
                  .fontColor(AppTheme.primary())
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .border({ width: { bottom: 1 }, color: AppTheme.divider() })
              .onClick(() => {
                this.onStartWorkflow(item.id);
              })
            }, (item: WorkflowTemplate) => item.id)
          }
          .width('100%')
        }
      }
    }
    .width('100%')
  }
}

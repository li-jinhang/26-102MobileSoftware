import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { searchKnowledge } from '../../common/services/KnowledgeService';
import { AppTheme } from '../../common/theme/AppTheme';
import { KnowledgeArticle, KnowledgeCategory } from '../../models/AppModels';

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
  onOpenArticle: (articleId: string) => void = () => {
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
    }
    .width('100%')
  }
}

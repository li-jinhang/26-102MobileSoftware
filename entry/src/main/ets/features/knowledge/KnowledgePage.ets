import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { searchKnowledge } from '../../common/services/KnowledgeService';
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
  onSelectOcrImage: () => void = () => {
  };
  onUseOcrDemo: () => void = () => {
  };
  @State selectedCategoryId: string = 'all';
  @State searchKeyword: string = '';

  private getResults(): KnowledgeArticle[] {
    return searchKnowledge(this.articles, this.selectedCategoryId, this.searchKeyword);
  }

  private clearFilters(): void {
    this.selectedCategoryId = 'all';
    this.searchKeyword = '';
  }

  build() {
    Column({ space: 14 }) {
      SectionBlock({ title: '知识检索', subtitle: '按分类或关键词查找已发布的公司制度与操作指南。' }) {
        Column({ space: 12 }) {
          TextInput({ placeholder: '搜索制度、流程、标签', text: this.searchKeyword })
            .height(48)
            .borderRadius(8)
            .backgroundColor('#F8FAFC')
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.searchKeyword = value;
            })

          Row({ space: 10 }) {
            Button('从相册选择')
              .layoutWeight(1)
              .height(42)
              .fontColor('#FFFFFF')
              .backgroundColor('#246BFD')
              .borderRadius(8)
              .onClick(() => {
                this.onSelectOcrImage();
              })

            Button('使用内置演示图片')
              .layoutWeight(1)
              .height(42)
              .fontSize(13)
              .fontColor('#175CD3')
              .backgroundColor('#EAF1FF')
              .borderRadius(8)
              .onClick(() => {
                this.onUseOcrDemo();
              })
          }
          .width('100%')

          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories, (item: KnowledgeCategory) => {
                Text(item.name)
                  .fontSize(12)
                  .fontColor(this.selectedCategoryId === item.id ? '#FFFFFF' : '#475467')
                  .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                  .backgroundColor(this.selectedCategoryId === item.id ? '#246BFD' : '#F2F4F7')
                  .borderRadius(8)
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

      SectionBlock({ title: '知识列表', subtitle: `共找到 ${this.getResults().length} 条内容` }) {
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
          Column({ space: 10 }) {
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

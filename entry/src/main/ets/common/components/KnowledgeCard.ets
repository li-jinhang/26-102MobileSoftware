import { KnowledgeArticle } from '../../models/AppModels';

@Component
export struct KnowledgeCard {
  article: KnowledgeArticle;
  favorite: boolean = false;
  onOpen: (articleId: string) => void = () => {
  };

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text(this.article.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
          .layoutWeight(1)
          .maxLines(2)

        Text(this.favorite ? '已收藏' : this.article.categoryName)
          .fontSize(11)
          .fontColor(this.favorite ? '#B54708' : '#175CD3')
      }
      .width('100%')

      Text(this.article.summary)
        .fontSize(12)
        .fontColor('#667085')
        .lineHeight(18)
        .maxLines(2)
        .width('100%')

      Text(`${this.article.tags.join(' / ')} · ${this.article.updateTime}`)
        .fontSize(11)
        .fontColor('#98A2B3')
        .width('100%')
        .maxLines(1)
    }
    .width('100%')
    .constraintSize({ minHeight: 104 })
    .padding(14)
    .backgroundColor('#F8FAFC')
    .borderRadius(8)
    .onClick(() => {
      this.onOpen(this.article.id);
    })
  }
}

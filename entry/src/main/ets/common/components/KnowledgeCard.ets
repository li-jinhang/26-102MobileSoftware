import { KnowledgeArticle } from '../../models/AppModels';
import { Typography } from '../theme/Typography';

@Component
export struct KnowledgeCard {
  @Require
  @Prop
  article: KnowledgeArticle;
  @Prop
  favorite: boolean = false;
  onOpen: (articleId: string) => void = () => {
  };

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text(this.article.title)
          .fontSize(Typography.cardTitleSize())
          .fontWeight(Typography.emphasisWeight())
          .fontColor('#1F2A44')
          .layoutWeight(1)
          .maxLines(2)

        Text(this.favorite ? '已收藏' : this.article.categoryName)
          .fontSize(Typography.captionSize())
          .fontColor(this.favorite ? '#B54708' : '#175CD3')
      }
      .width('100%')

      Text(this.article.summary)
        .fontSize(Typography.metaSize())
        .fontColor('#667085')
        .lineHeight(Typography.summaryLineHeight())
        .maxLines(2)
        .width('100%')

      Text(`${this.article.tags.join(' / ')} · ${this.article.updateTime}`)
        .fontSize(Typography.captionSize())
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

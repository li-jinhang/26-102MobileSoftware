import { KnowledgeArticle } from '../../models/AppModels';
import { Typography } from '../theme/Typography';
import { AppTheme } from '../theme/AppTheme';

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
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Text(this.article.title)
          .fontSize(Typography.cardTitleSize())
          .fontWeight(Typography.emphasisWeight())
          .fontColor(AppTheme.textPrimary())
          .layoutWeight(1)
          .maxLines(2)

        Text(this.favorite ? '已收藏' : this.article.categoryName)
          .fontSize(Typography.captionSize())
          .fontColor(this.favorite ? AppTheme.warning() : AppTheme.primary())
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(this.favorite ? '#FFF3E8' : AppTheme.primarySoft())
          .borderRadius(AppTheme.radiusSmall())
      }
      .width('100%')

      Text(this.article.summary)
        .fontSize(Typography.metaSize())
        .fontColor(AppTheme.textSecondary())
        .lineHeight(Typography.summaryLineHeight())
        .maxLines(2)
        .width('100%')

      Text(`${this.article.tags.join(' / ')} · ${this.article.updateTime}`)
        .fontSize(Typography.captionSize())
        .fontColor(AppTheme.textTertiary())
        .width('100%')
        .maxLines(1)
    }
    .width('100%')
    .constraintSize({ minHeight: 92 })
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(AppTheme.surface())
    .border({ width: { bottom: 1 }, color: AppTheme.divider() })
    .onClick(() => {
      this.onOpen(this.article.id);
    })
  }
}

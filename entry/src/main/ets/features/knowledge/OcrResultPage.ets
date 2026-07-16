import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { AppTopBar } from '../../common/components/AppTopBar';
import { OcrResult } from '../../common/services/OcrService';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import { KnowledgeArticle } from '../../models/AppModels';

@Component
export struct OcrResultPage {
  @Require @Prop result: OcrResult;
  @Require @Prop articles: KnowledgeArticle[];
  onBack: () => void = () => {};
  onOpenArticle: (articleId: string) => void = () => {};

  private getRelatedArticles(): KnowledgeArticle[] {
    return this.articles.filter((item: KnowledgeArticle) => this.result.relatedArticleIds.includes(item.id));
  }

  build() {
    Column() {
      AppTopBar({
        title: '图片文字识别',
        subtitle: this.result.source === 'system'
          ? 'HarmonyOS OCR 识别完成'
          : this.result.source === 'cloud' ? '视觉大模型 OCR 识别完成' : '演示降级结果',
        onBack: () => this.onBack()
      })

      Scroll() {
        Column({ space: 14 }) {
          if (this.result.previewUri.length > 0) {
            Image(this.result.previewUri).width('100%').height(180).objectFit(ImageFit.Contain).backgroundColor('#FFFFFF')
          }
          if (this.result.fallbackReason.length > 0) {
            Text(this.result.fallbackReason).fontSize(Typography.metaSize()).lineHeight(Typography.summaryLineHeight()).fontColor('#B54708').width('100%').padding(12)
              .backgroundColor('#FFFAEB').borderRadius(12)
          }
          Column({ space: 10 }) {
            Text('识别全文').fontSize(Typography.bodyLargeSize()).fontWeight(Typography.emphasisWeight()).fontColor('#1F2A44').width('100%')
            Text(this.result.text).fontSize(Typography.bodyLargeSize()).lineHeight(Typography.bodyLargeLineHeight()).fontColor('#344054').width('100%')
          }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)

          if (this.result.keywords.length > 0) {
            Text(`关键词：${this.result.keywords.join('、')}`).fontSize(Typography.metaSize()).fontColor('#175CD3').width('100%')
          }
          ForEach(this.getRelatedArticles(), (item: KnowledgeArticle) => {
            KnowledgeCard({ article: item, onOpen: (id: string) => this.onOpenArticle(id) })
          }, (item: KnowledgeArticle) => item.id)
        }.width('100%').padding({ left: 16, right: 16, bottom: 24 })
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor(AppTheme.pageBackground())
  }
}

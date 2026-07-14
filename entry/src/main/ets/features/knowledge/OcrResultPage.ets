import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { OcrResult } from '../../common/services/OcrService';
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
      Row({ space: 12 }) {
        Text('‹').fontSize(30).width(36).height(36).textAlign(TextAlign.Center).onClick(() => this.onBack())
        Column({ space: 3 }) {
          Text('图片文字识别').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1F2A44')
          Text(this.result.success ? 'HarmonyOS OCR 识别完成' : '演示降级结果').fontSize(11).fontColor('#667085')
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Scroll() {
        Column({ space: 14 }) {
          if (this.result.previewUri.length > 0) {
            Image(this.result.previewUri).width('100%').height(180).objectFit(ImageFit.Contain).backgroundColor('#FFFFFF')
          }
          if (this.result.fallbackReason.length > 0) {
            Text(this.result.fallbackReason).fontSize(12).fontColor('#B54708').width('100%').padding(12)
              .backgroundColor('#FFFAEB').borderRadius(8)
          }
          Column({ space: 10 }) {
            Text('识别全文').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1F2A44').width('100%')
            Text(this.result.text).fontSize(15).lineHeight(24).fontColor('#344054').width('100%')
          }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8)

          if (this.result.keywords.length > 0) {
            Text(`关键词：${this.result.keywords.join('、')}`).fontSize(12).fontColor('#175CD3').width('100%')
          }
          ForEach(this.getRelatedArticles(), (item: KnowledgeArticle) => {
            KnowledgeCard({ article: item, onOpen: (id: string) => this.onOpenArticle(id) })
          }, (item: KnowledgeArticle) => item.id)
        }.width('100%').padding({ left: 16, right: 16, bottom: 24 })
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor('#F3F6FB')
  }
}

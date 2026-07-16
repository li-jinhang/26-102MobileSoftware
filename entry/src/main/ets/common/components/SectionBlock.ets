import { Typography } from '../theme/Typography';

@Component
export struct SectionBlock {
  title: string = '';
  subtitle: string = '';
  @BuilderParam content: () => void = this.defaultBuilder;

  @Builder
  private defaultBuilder() {
  }

  build() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Typography.sectionTitleSize())
          .fontWeight(Typography.titleWeight())
          .fontColor('#1F2A44')
          .width('100%')

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Typography.metaSize())
            .fontColor('#667085')
            .lineHeight(Typography.summaryLineHeight())
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)

      this.content()
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}

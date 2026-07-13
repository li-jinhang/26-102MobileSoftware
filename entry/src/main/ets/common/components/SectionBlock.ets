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
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
          .width('100%')

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor('#667085')
            .lineHeight(18)
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)

      this.content()
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }
}

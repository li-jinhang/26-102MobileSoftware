@Component
export struct EmptyState {
  title: string = '暂无内容';
  description: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {
  };

  build() {
    Column({ space: 8 }) {
      Text('○')
        .fontSize(30)
        .fontColor('#98A2B3')

      Text(this.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#344054')

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(12)
          .fontColor('#667085')
          .textAlign(TextAlign.Center)
      }

      if (this.actionLabel.length > 0) {
        Button(this.actionLabel)
          .height(36)
          .fontSize(12)
          .borderRadius(8)
          .onClick(() => {
            this.onAction();
          })
      }
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
  }
}

import { Typography } from '../theme/Typography';

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
        .fontSize(Typography.iconBackSize())
        .fontColor('#98A2B3')

      Text(this.title)
        .fontSize(Typography.cardTitleSize())
        .fontWeight(Typography.emphasisWeight())
        .fontColor('#344054')

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(Typography.metaSize())
          .fontColor('#667085')
          .lineHeight(Typography.summaryLineHeight())
          .textAlign(TextAlign.Center)
      }

      if (this.actionLabel.length > 0) {
        Button(this.actionLabel)
          .height(36)
          .fontSize(Typography.metaSize())
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

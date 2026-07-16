import { Typography } from '../theme/Typography';
import { AppTheme } from '../theme/AppTheme';

@Component
export struct EmptyState {
  title: string = '暂无内容';
  description: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {
  };

  build() {
    Column({ space: 8 }) {
      Text('暂无内容')
        .fontSize(Typography.captionSize())
        .fontColor(AppTheme.textTertiary())

      Text(this.title)
        .fontSize(Typography.cardTitleSize())
        .fontWeight(Typography.emphasisWeight())
        .fontColor(AppTheme.textPrimary())

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(Typography.metaSize())
          .fontColor(AppTheme.textSecondary())
          .lineHeight(Typography.summaryLineHeight())
          .textAlign(TextAlign.Center)
      }

      if (this.actionLabel.length > 0) {
        Button(this.actionLabel)
          .height(36)
          .fontSize(Typography.metaSize())
          .fontColor(AppTheme.primary())
          .backgroundColor(AppTheme.primarySoft())
          .borderRadius(AppTheme.radiusSmall())
          .onClick(() => {
            this.onAction();
          })
      }
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
  }
}

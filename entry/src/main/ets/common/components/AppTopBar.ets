import { AppTheme } from '../theme/AppTheme';
import { Typography } from '../theme/Typography';

@Component
export struct AppTopBar {
  title: string = '';
  subtitle: string = '';
  onBack: () => void = () => {
  };

  build() {
    Row({ space: 8 }) {
      Text('‹')
        .fontSize(32)
        .fontColor(AppTheme.textPrimary())
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.onBack();
        })

      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(Typography.pageTitleSize())
          .fontWeight(Typography.titleWeight())
          .fontColor(AppTheme.textPrimary())
          .maxLines(1)

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Typography.captionSize())
            .fontColor(AppTheme.textSecondary())
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(56)
    .padding({ right: AppTheme.pagePadding() })
    .backgroundColor(AppTheme.surface())
    .border({ width: { bottom: 1 }, color: AppTheme.divider() })
  }
}

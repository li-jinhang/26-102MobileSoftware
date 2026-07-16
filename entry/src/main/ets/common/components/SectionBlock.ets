import { Typography } from '../theme/Typography';
import { AppTheme } from '../theme/AppTheme';

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
          .fontColor(AppTheme.textPrimary())
          .width('100%')

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Typography.metaSize())
            .fontColor(AppTheme.textSecondary())
            .lineHeight(Typography.summaryLineHeight())
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)

      this.content()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(AppTheme.surface())
    .borderRadius(AppTheme.radiusMedium())
    .border({ width: 1, color: AppTheme.divider() })
  }
}

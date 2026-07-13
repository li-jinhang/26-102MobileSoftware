import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { KnowledgeArticle, ReadingFontScale, User } from '../../models/AppModels';

@Component
export struct ProfilePage {
  user: User;
  favoriteArticles: KnowledgeArticle[];
  unreadCount: number = 0;
  fontScale: ReadingFontScale = 'standard';
  onOpenArticle: (articleId: string) => void = () => {
  };
  onOpenMessages: () => void = () => {
  };
  onFontScaleChange: (scale: ReadingFontScale) => void = () => {
  };
  onLogout: () => void = () => {
  };

  @Builder
  private FontOption(scale: ReadingFontScale, label: string) {
    Text(label)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .fontSize(12)
      .fontColor(this.fontScale === scale ? '#FFFFFF' : '#475467')
      .padding({ top: 9, bottom: 9 })
      .backgroundColor(this.fontScale === scale ? '#246BFD' : '#F2F4F7')
      .borderRadius(6)
      .onClick(() => {
        this.onFontScaleChange(scale);
      })
  }

  build() {
    Column({ space: 14 }) {
      Column({ space: 8 }) {
        Text(this.user.name.substring(0, 1))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(64)
          .height(64)
          .textAlign(TextAlign.Center)
          .backgroundColor('#175CD3')
          .borderRadius(32)
        Text(this.user.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
        Text(`${this.user.department} · ${this.user.roleLabel}`)
          .fontSize(12)
          .fontColor('#667085')
      }
      .width('100%')
      .padding({ top: 20, bottom: 12 })

      SectionBlock({ title: '角色权限', subtitle: '当前账号可使用的主要能力。' }) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.user.permissions, (permission: string) => {
            Text(permission)
              .fontSize(11)
              .fontColor('#175CD3')
              .padding({ left: 10, right: 10, top: 7, bottom: 7 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor('#EAF1FF')
              .borderRadius(6)
          }, (permission: string) => permission)
        }
        .width('100%')
      }

      SectionBlock({ title: '消息与阅读', subtitle: '个人偏好在当前应用会话内生效。' }) {
        Column({ space: 12 }) {
          Row() {
            Text('未读消息')
              .fontSize(14)
              .fontColor('#344054')
            Blank()
            Text(`${this.unreadCount} 条 ›`)
              .fontSize(13)
              .fontColor('#175CD3')
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
          .onClick(() => {
            this.onOpenMessages();
          })

          Text('知识正文字号')
            .fontSize(14)
            .fontColor('#344054')
            .width('100%')
          Row({ space: 6 }) {
            this.FontOption('small', '小')
            this.FontOption('standard', '标准')
            this.FontOption('large', '大')
          }
          .width('100%')
        }
        .width('100%')
      }

      SectionBlock({ title: '收藏知识', subtitle: `${this.favoriteArticles.length} 条常用内容` }) {
        if (this.favoriteArticles.length === 0) {
          EmptyState({ title: '还没有收藏', description: '在知识详情页点击收藏后会显示在这里。' })
        } else {
          Column({ space: 10 }) {
            ForEach(this.favoriteArticles, (item: KnowledgeArticle) => {
              KnowledgeCard({
                article: item,
                favorite: true,
                onOpen: (articleId: string) => {
                  this.onOpenArticle(articleId);
                }
              })
            }, (item: KnowledgeArticle) => item.id)
          }
          .width('100%')
        }
      }

      Button('退出登录')
        .width('100%')
        .height(44)
        .fontColor('#B42318')
        .backgroundColor('#FEE4E2')
        .borderRadius(8)
        .onClick(() => {
          this.onLogout();
        })
    }
    .width('100%')
  }
}

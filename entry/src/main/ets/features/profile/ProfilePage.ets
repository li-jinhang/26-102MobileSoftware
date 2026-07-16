import { EmptyState } from '../../common/components/EmptyState';
import { KnowledgeCard } from '../../common/components/KnowledgeCard';
import { SectionBlock } from '../../common/components/SectionBlock';
import { KnowledgeArticle, User } from '../../models/AppModels';

@Component
export struct ProfilePage {
  @Require
  @Prop
  user: User;
  @Require
  @Prop
  favoriteArticles: KnowledgeArticle[];
  @Prop
  unreadCount: number = 0;
  @Prop
  mailUnreadCount: number = 0;
  @Prop
  attendanceStatus: string = '未加载';
  onOpenArticle: (articleId: string) => void = () => {
  };
  onOpenMessages: () => void = () => {
  };
  onOpenAttendance: () => void = () => {
  };
  onOpenMail: () => void = () => {
  };
  onOpenOrganization: () => void = () => {
  };
  onLogout: () => void = () => {
  };

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

      SectionBlock({ title: '我的组织', subtitle: `${this.user.department} · ${this.user.jobTitle}` }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.user.managerId.length > 0 ? '查看直属上级与团队成员' : '查看部门成员')
              .fontSize(14)
              .fontColor('#344054')
              .fontWeight(FontWeight.Medium)
              .width('100%')
            Text('组织关系会根据人员目录实时更新')
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text('›')
            .fontSize(18)
            .fontColor('#175CD3')
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          this.onOpenOrganization();
        })
      }

      SectionBlock({ title: '签到签退' }) {
        Row() {
          Text('签到签退')
            .fontSize(14)
            .fontColor('#344054')
          Blank()
          Text(`${this.attendanceStatus} ›`)
            .fontSize(13)
            .fontColor('#175CD3')
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          this.onOpenAttendance();
        })
      }

      SectionBlock({ title: '角色权限' }) {
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

      SectionBlock({ title: '内部邮件', subtitle: `${this.mailUnreadCount} 封未读` }) {
        Row() {
          Column({ space: 4 }) {
            Text('进入邮件中心')
              .fontSize(14)
              .fontColor('#344054')
              .fontWeight(FontWeight.Medium)
              .width('100%')
            Text('查看收件箱、已发送邮件和撰写内部邮件')
              .fontSize(12)
              .fontColor('#667085')
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text('›')
            .fontSize(18)
            .fontColor('#175CD3')
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          this.onOpenMail();
        })
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

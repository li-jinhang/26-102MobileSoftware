import { EmptyState } from '../../common/components/EmptyState';
import { AppTopBar } from '../../common/components/AppTopBar';
import { SectionBlock } from '../../common/components/SectionBlock';
import { AppTheme } from '../../common/theme/AppTheme';
import { Typography } from '../../common/theme/Typography';
import { EmployeeDirectoryItem, OrganizationProfile } from '../../models/AppModels';

@Component
export struct OrganizationPage {
  @Require
  @Prop
  profile: OrganizationProfile;
  onBack: () => void = () => {
  };

  @Builder
  private PersonRow(item: EmployeeDirectoryItem, relation: string) {
    Row({ space: 10 }) {
      Text(item.name.substring(0, 1))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#175CD3')
        .width(38)
        .height(38)
        .textAlign(TextAlign.Center)
        .backgroundColor('#EAF1FF')
        .borderRadius(19)
      Column({ space: 3 }) {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2A44')
        Text(`${relation} · ${item.jobTitle}`)
          .fontSize(12)
          .fontColor('#667085')
        Text(item.departmentName)
          .fontSize(11)
          .fontColor('#98A2B3')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column({ space: 14 }) {
      AppTopBar({
        title: '我的组织',
        subtitle: '查看直属关系与部门成员',
        onBack: () => this.onBack()
      })

      SectionBlock({ title: '汇报关系' }) {
        Column({ space: 4 }) {
          if (this.profile.manager !== null) {
            this.PersonRow(this.profile.manager, '直属上级')
          } else {
            Text('当前未设置直属上级')
              .fontSize(13)
              .fontColor('#667085')
              .width('100%')
              .padding({ top: 8, bottom: 8 })
          }
          this.PersonRow(this.profile.employee, '本人')
          if (this.profile.directReports.length > 0) {
            ForEach(this.profile.directReports, (item: EmployeeDirectoryItem) => {
              this.PersonRow(item, '直属下属')
            }, (item: EmployeeDirectoryItem) => item.id)
          }
        }
        .width('100%')
      }

      SectionBlock({ title: '部门成员', subtitle: `${this.profile.employee.departmentName} · ${this.profile.departmentMembers.length} 人` }) {
        if (this.profile.departmentMembers.length === 0) {
          EmptyState({ title: '暂无成员', description: '当前没有可展示的在职成员。' })
        } else {
          Column({ space: 2 }) {
            ForEach(this.profile.departmentMembers, (item: EmployeeDirectoryItem) => {
              this.PersonRow(item, item.id === this.profile.employee.id ? '本人' : '部门成员')
            }, (item: EmployeeDirectoryItem) => item.id)
          }
          .width('100%')
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(AppTheme.pageBackground())
  }
}

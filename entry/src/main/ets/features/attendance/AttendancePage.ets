import { EmptyState } from '../../common/components/EmptyState';
import { AttendanceRecord, AttendanceRecordStatus, AttendanceRecordType, AttendanceTodaySummary } from '../../models/AppModels';

@Component
export struct AttendancePage {
  @Require
  @Prop
  todaySummary: AttendanceTodaySummary;
  @Require
  @Prop
  records: AttendanceRecord[];
  onBack: () => void = () => {
  };
  onCheckIn: (note: string) => void = () => {
  };
  onCheckOut: (note: string) => void = () => {
  };
  @State noteInput: string = '';

  private getRecordTypeLabel(type: AttendanceRecordType): string {
    return type === 'checkIn' ? '签到' : '签退';
  }

  private getRecordStatusLabel(status: AttendanceRecordStatus): string {
    if (status === 'late') {
      return '迟到';
    }
    if (status === 'earlyLeave') {
      return '早退';
    }
    if (status === 'offsite') {
      return '外勤';
    }
    return '正常';
  }

  private getRecordStatusColor(status: AttendanceRecordStatus): string {
    if (status === 'late' || status === 'earlyLeave') {
      return '#B54708';
    }
    if (status === 'offsite') {
      return '#175CD3';
    }
    return '#027A48';
  }

  private canCheckIn(): boolean {
    return !this.todaySummary.checkedIn;
  }

  private canCheckOut(): boolean {
    return this.todaySummary.checkedIn && !this.todaySummary.checkedOut;
  }

  build() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(30)
          .fontColor('#1F2A44')
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack();
          })
        Column({ space: 3 }) {
          Text('签到签退')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A44')
          Text(this.todaySummary.date)
            .fontSize(11)
            .fontColor('#667085')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Column({ space: 10 }) {
        Text(this.todaySummary.statusText)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')
        Row({ space: 8 }) {
          Column({ space: 4 }) {
            Text('签到时间')
              .fontSize(11)
              .fontColor('#667085')
            Text(this.todaySummary.checkInTime.length > 0 ? this.todaySummary.checkInTime : '--:--')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#175CD3')
          }
          .layoutWeight(1)

          Column({ space: 4 }) {
            Text('签退时间')
              .fontSize(11)
              .fontColor('#667085')
            Text(this.todaySummary.checkOutTime.length > 0 ? this.todaySummary.checkOutTime : '--:--')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#027A48')
          }
          .layoutWeight(1)
        }
        .width('100%')

        Text(`地点：${this.todaySummary.location}`)
          .fontSize(12)
          .fontColor('#475467')
        Text(this.todaySummary.workDurationText)
          .fontSize(12)
          .fontColor('#475467')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Column({ space: 10 }) {
        TextInput({ placeholder: '备注，例如：外出拜访客户 / 正常到岗', text: this.noteInput })
          .width('100%')
          .height(44)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .onChange((value: string) => {
            this.noteInput = value;
          })

        Row({ space: 10 }) {
          Button('签到')
            .layoutWeight(1)
            .height(42)
            .fontColor('#FFFFFF')
            .backgroundColor(this.canCheckIn() ? '#175CD3' : '#D0D5DD')
            .borderRadius(12)
            .enabled(this.canCheckIn())
            .onClick(() => {
              this.onCheckIn(this.noteInput);
            })
          Button('签退')
            .layoutWeight(1)
            .height(42)
            .fontColor('#FFFFFF')
            .backgroundColor(this.canCheckOut() ? '#027A48' : '#D0D5DD')
            .borderRadius(12)
            .enabled(this.canCheckOut())
            .onClick(() => {
              this.onCheckOut(this.noteInput);
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Column({ space: 10 }) {
        Text('最近记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2A44')

        if (this.records.length === 0) {
          EmptyState({
            title: '暂无考勤记录',
            description: '签到和签退记录会显示在这里。'
          })
        } else {
          Column({ space: 10 }) {
            ForEach(this.records, (item: AttendanceRecord) => {
              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text(this.getRecordTypeLabel(item.type))
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1F2A44')
                  Text(`${item.time} · ${item.location}`)
                    .fontSize(11)
                    .fontColor('#667085')
                  if (item.note.length > 0) {
                    Text(item.note)
                      .fontSize(11)
                      .fontColor('#475467')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text(this.getRecordStatusLabel(item.status))
                  .fontSize(11)
                  .fontColor(this.getRecordStatusColor(item.status))
                  .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                  .backgroundColor('#F2F4F7')
                  .borderRadius(12)
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
            }, (item: AttendanceRecord) => item.id)
          }
          .width('100%')
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F3F6FB')
  }
}

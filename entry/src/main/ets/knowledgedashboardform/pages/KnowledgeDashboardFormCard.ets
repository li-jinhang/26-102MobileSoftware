const storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct KnowledgeDashboardFormCard {
  @LocalStorageProp('data') data: string = '{}';

  private value(key: string, fallback: string): string {
    try {
      const summary: Record<string, Object> = JSON.parse(this.data) as Record<string, Object>;
      const value: Object | undefined = summary[key];
      return value === undefined ? fallback : `${value}`;
    } catch (error) {
      return fallback;
    }
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('智协库')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Blank()
        Text('工作台')
          .fontSize(11)
          .fontColor('#DCE7FF')
      }
      .width('100%')

      Row({ space: 8 }) {
        Column({ space: 4 }) {
          Text(this.value('todoCount', '0'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('待办')
            .fontSize(11)
            .fontColor('#DCE7FF')
        }
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(this.value('unreadCount', '0'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('未读')
            .fontSize(11)
            .fontColor('#DCE7FF')
        }
        .layoutWeight(1)
      }
      .width('100%')

      Text(this.value('recentTitle', '打开知识库'))
        .fontSize(12)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#175CD3')
    .borderRadius(16)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        moduleName: 'entry',
        params: { page: 'knowledge' }
      });
    })
  }
}

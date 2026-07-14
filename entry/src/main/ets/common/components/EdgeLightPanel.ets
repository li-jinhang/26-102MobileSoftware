@Component
export struct EdgeLightPanel {
  @BuilderParam content: () => void;
  @Prop radiusValue: number = 8;
  @State blueShift: number = -120;
  @State greenShift: number = 220;

  aboutToAppear(): void {
    animateTo({ duration: 2400, iterations: -1, curve: Curve.EaseInOut }, () => {
      this.blueShift = 230;
      this.greenShift = -120;
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.content()
      }
      .width('100%')

      Row()
        .width(92)
        .height(4)
        .backgroundColor('#246BFD')
        .borderRadius(4)
        .opacity(0.9)
        .shadow({ radius: 10, color: '#246BFD', offsetX: 0, offsetY: 1 })
        .translate({ x: this.blueShift, y: 0 })

      Row()
        .width(76)
        .height(4)
        .backgroundColor('#12B76A')
        .borderRadius(4)
        .opacity(0.86)
        .shadow({ radius: 10, color: '#12B76A', offsetX: 0, offsetY: 1 })
        .translate({ x: this.greenShift, y: 0 })
    }
    .width('100%')
    .clip(true)
    .borderRadius(this.radiusValue)
    .border({ width: 1, color: '#B2CCFF' })
    .shadow({ radius: 18, color: '#1F246BFD', offsetX: 0, offsetY: 6 })
  }
}

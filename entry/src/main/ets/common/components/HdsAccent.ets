import {
  DualEdgeFlowLightWithMaskParam,
  HdsSceneController,
  HdsSceneType,
  HdsVisualComponent
} from '@kit.UIDesignKit';

@Component
export struct HdsAccent {
  @Prop heightValue: number = 72;
  @State hdsSupported: boolean = true;
  @State glowShift: number = -80;
  private readonly controller: HdsSceneController = new HdsSceneController();

  aboutToAppear(): void {
    try {
      const params: DualEdgeFlowLightWithMaskParam = {
        backgroundMaskColors: ['#EAF1FF', '#ECFDF3'],
        firstEdgeFlowLight: {
          startPos: 0.02,
          endPos: 0.30,
          color: '#246BFD'
        },
        secondEdgeFlowLight: {
          startPos: 0.52,
          endPos: 0.82,
          color: '#12B76A'
        }
      };
      this.controller.setSceneParams(params).start();
      animateTo({ duration: 2200, iterations: -1, curve: Curve.EaseInOut }, () => {
        this.glowShift = this.glowShift > 0 ? -80 : 80;
      });
    } catch (error) {
      this.hdsSupported = false;
      console.error(`HdsAccent fallback enabled: ${error}`);
    }
  }

  aboutToDisappear(): void {
    if (this.hdsSupported) {
      try {
        this.controller.stop();
      } catch (error) {
        console.error(`HdsAccent stop failed: ${error}`);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.hdsSupported) {
        HdsVisualComponent()
          .width('100%')
          .height(this.heightValue)
          .scene(HdsSceneType.DUAL_EDGE_FLOW_LIGHT_WITH_BACKGROUND_MASK, this.controller)
      }

      Row() {
        Row()
          .width('24%')
          .height(6)
          .backgroundColor('#246BFD')
          .borderRadius(6)
        Row()
          .width('18%')
          .height(6)
          .margin({ left: 8 })
          .backgroundColor('#12B76A')
          .borderRadius(6)
      }
      .width('100%')
      .height(12)
      .justifyContent(FlexAlign.Start)
      .translate({ x: this.glowShift, y: 0 })
      .backgroundColor(this.hdsSupported ? '#F8FBFF' : '#EAF1FF')
      .opacity(this.hdsSupported ? 0.92 : 0.88)
      .border({ width: 1, color: '#B2CCFF' })
      .borderRadius(8)
    }
    .width('100%')
    .height(this.heightValue)
  }
}

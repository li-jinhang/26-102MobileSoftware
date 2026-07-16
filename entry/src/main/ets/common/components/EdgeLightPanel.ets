@Component
export struct EdgeLightPanel {
  @BuilderParam content: () => void;
  @Prop radiusValue: number = 16;
  @Prop todoCount: number = 0;
  @Prop unreadCount: number = 0;
  @State pulseStrength: number = 0.12;

  aboutToAppear(): void {
    animateTo({
      duration: 1600,
      iterations: -1,
      playMode: PlayMode.Alternate,
      curve: Curve.EaseInOut
    }, () => {
      this.pulseStrength = 0.32;
    });
  }

  private hasAttention(): boolean {
    return this.todoCount > 0 || this.unreadCount > 0;
  }

  // Unread messages take precedence when both kinds of attention are present.
  private accentRgb(): string {
    return this.unreadCount > 0 ? '181, 71, 8' : '36, 107, 253';
  }

  private accentColor(alpha: number): string {
    return `rgba(${this.accentRgb()}, ${alpha})`;
  }

  private panelBorderColor(): string {
    return this.hasAttention() ? this.accentColor(this.pulseStrength + 0.28) : '#B2CCFF';
  }

  private glowRadius(): number {
    return this.hasAttention() ? 8 + this.pulseStrength * 28 : 18;
  }

  private glowColor(): string {
    return this.hasAttention() ? this.accentColor(this.pulseStrength) : '#1F246BFD';
  }

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(this.radiusValue)
    .border({ width: 1, color: this.panelBorderColor() })
    .shadow({ radius: this.glowRadius(), color: this.glowColor(), offsetX: 0, offsetY: 4 })
  }
}

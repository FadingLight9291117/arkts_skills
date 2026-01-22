// ArkTS Basic Component Template
// Replace {{ComponentName}} with your component name

@Entry
@Component
struct {{ComponentName}} {
  // State management
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // Lifecycle
  aboutToAppear(): void {
    this.loadData();
  }

  aboutToDisappear(): void {
    // Cleanup resources
  }

  // Methods
  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // Load data here
    } catch (error) {
      this.errorMessage = 'Failed to load data';
    } finally {
      this.isLoading = false;
    }
  }

  // Build
  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
      } else if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor(Color.Red)
        Button('Retry')
          .onClick(() => { this.loadData(); })
      } else {
        // Main content here
        Text('{{ComponentName}}')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// ArkTS List Page Template
// Replace {{PageName}}, {{ItemType}}, {{itemName}} with your values

import { router } from '@kit.ArkUI';

interface {{ItemType}} {
  id: string;
  title: string;
  description: string;
}

@Entry
@Component
struct {{PageName}} {
  @State items: {{ItemType}}[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    this.loadItems();
  }

  async loadItems(): Promise<void> {
    this.isLoading = true;
    try {
      // TODO: Fetch items from API
      this.items = [
        { id: '1', title: 'Item 1', description: 'Description 1' },
        { id: '2', title: 'Item 2', description: 'Description 2' },
      ];
    } finally {
      this.isLoading = false;
    }
  }

  async refreshItems(): Promise<void> {
    this.isRefreshing = true;
    await this.loadItems();
    this.isRefreshing = false;
  }

  navigateToDetail(item: {{ItemType}}): void {
    router.pushUrl({
      url: 'pages/{{PageName}}Detail',
      params: { id: item.id }
    });
  }

  @Builder
  ItemCard(item: {{ItemType}}) {
    Column() {
      Text(item.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      
      Text(item.description)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => { this.navigateToDetail(item); })
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('{{PageName}}')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Button('Add')
          .onClick(() => {
            router.pushUrl({ url: 'pages/{{PageName}}Create' });
          })
      }
      .width('100%')
      .padding(16)

      // Content
      if (this.isLoading && this.items.length === 0) {
        Column() {
          LoadingProgress().width(50).height(50)
          Text('Loading...').margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.items.length === 0) {
        Column() {
          Text('No items found')
            .fontSize(16)
            .fontColor('#999999')
          Button('Refresh')
            .margin({ top: 16 })
            .onClick(() => { this.loadItems(); })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 12 }) {
            ForEach(this.items, (item: {{ItemType}}) => {
              ListItem() {
                this.ItemCard(item)
              }
            }, (item: {{ItemType}}) => item.id)
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .onRefreshing(() => { this.refreshItems(); })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

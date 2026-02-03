# State Management V2 状态管理 V2

ArkTS 状态管理 V2 是 HarmonyOS 推荐的新一代状态管理方案，提供更强大的深度观察能力和更灵活的状态同步机制。

> **重要**: V2 组件必须使用 `@ComponentV2` 装饰器，而非 V1 的 `@Component`。

## V2 装饰器概览

| 装饰器 | 功能 | V1 对应 |
|--------|------|---------|
| `@ComponentV2` | V2 组件装饰器 | `@Component` |
| `@Local` | 组件内部状态 | `@State` |
| `@Param` | 父→子单向传递 | `@Prop` |
| `@Once` | 仅首次同步 | 无 |
| `@Event` | 子→父事件回调 | 无（使用回调函数） |
| `@Provider` / `@Consumer` | 跨层级双向绑定 | `@Provide` / `@Consume` |
| `@ObservedV2` | 类深度观察 | `@Observed` |
| `@Trace` | 属性变更追踪 | `@Track` |
| `@Monitor` | 状态变化监听 | `@Watch` |
| `@Computed` | 计算属性 | 无 |

## @Local - 组件内部状态

等同于 V1 的 `@State`，用于组件内部状态管理。

```typescript
@Entry
@ComponentV2
struct HomePage {
  @Local count: number = 0;
  @Local isLoading: boolean = false;
  @Local message: string = 'Hello V2!';

  build() {
    Column({ space: 10 }) {
      Text(this.message)
      Text(`Count: ${this.count}`)
      Button('Add')
        .onClick(() => { this.count++; })
    }
  }
}
```

## @Param - 父子单向传递

从父组件向子组件单向传递数据，子组件**不能**修改该值。

```typescript
// 父组件
@Entry
@ComponentV2
struct ParentPage {
  @Local title: string = 'Parent Title';

  build() {
    Column() {
      ChildComponent({ title: this.title })
    }
  }
}

// 子组件
@ComponentV2
struct ChildComponent {
  @Param title: string = '';  // 接收父组件传值

  build() {
    Text(this.title)
  }
}
```

### @Require - 必传参数

```typescript
@ComponentV2
struct RequiredChild {
  @Require @Param title: string = '';  // 必须从父组件传入

  build() {
    Text(this.title)
  }
}
```

## @Once + @Param - 仅首次同步

`@Once` 与 `@Param` 配合使用，父组件仅在首次传值给子组件，之后子组件自行维护数据。

```typescript
@ComponentV2
struct EditableChild {
  @Once @Param initialValue: string = '';  // 首次同步后可修改

  build() {
    Column() {
      Text(this.initialValue)
      Button('Modify')
        .onClick(() => {
          this.initialValue = 'Modified by child';  // 允许修改
        })
    }
  }
}
```

## @Event - 子组件事件回调

用于子组件向父组件传递事件/数据。

```typescript
// 父组件
@Entry
@ComponentV2
struct ParentPage {
  @Local status: string = '';

  handleStatusChange = (newStatus: string): void => {
    this.status = newStatus;
  }

  build() {
    Column() {
      Text(`Status: ${this.status}`)
      ChildComponent({ onStatusChange: this.handleStatusChange })
    }
  }
}

// 子组件
@ComponentV2
struct ChildComponent {
  @Event onStatusChange: (status: string) => void = (status: string) => {};

  build() {
    Button('Update Status')
      .onClick(() => {
        this.onStatusChange('Completed');
      })
  }
}
```

## @Provider / @Consumer - 跨层级双向绑定

V2 版本真正实现了跨层级双向通信（V1 的 `@Provide/@Consume` 仅支持单向）。

```typescript
// 祖先组件
@Entry
@ComponentV2
struct AncestorPage {
  @Provider() theme: string = 'light';

  build() {
    Column() {
      Text(`Current Theme: ${this.theme}`)
      MiddleComponent()
      Button('Toggle Theme')
        .onClick(() => {
          this.theme = this.theme === 'light' ? 'dark' : 'light';
        })
    }
  }
}

// 中间组件（无需传递）
@ComponentV2
struct MiddleComponent {
  build() {
    DescendantComponent()
  }
}

// 后代组件
@ComponentV2
struct DescendantComponent {
  @Consumer() theme: string = 'light';

  build() {
    Column() {
      Text(`Theme in Descendant: ${this.theme}`)
      Button('Change from Descendant')
        .onClick(() => {
          this.theme = 'custom';  // V2 支持双向修改
        })
    }
  }
}
```

## @ObservedV2 + @Trace - 深度观察

用于类的深度观察，使嵌套对象属性变更能被追踪，实现局部刷新。

```typescript
@ObservedV2
class UserInfo {
  @Trace name: string = '';
  @Trace age: number = 0;
  @Trace address: Address = new Address();
}

@ObservedV2
class Address {
  @Trace city: string = '';
  @Trace street: string = '';
}

@Entry
@ComponentV2
struct UserPage {
  @Local user: UserInfo = new UserInfo();

  build() {
    Column({ space: 10 }) {
      Text(`Name: ${this.user.name}`)
      Text(`City: ${this.user.address.city}`)  // 深层属性变化也会触发更新
      Button('Update City')
        .onClick(() => {
          this.user.address.city = 'Beijing';  // 触发局部刷新
        })
    }
  }
}
```

## @Monitor - 状态变化监听

替代 V1 的 `@Watch`，支持深度监听和多属性同时监听。

```typescript
@ObservedV2
class Counter {
  @Trace count: number = 0;
}

@Entry
@ComponentV2
struct MonitorExample {
  @Local counter: Counter = new Counter();

  // 监听单个属性
  @Monitor('counter.count')
  onCountChange(): void {
    console.log(`Count changed to: ${this.counter.count}`);
  }

  // 监听多个属性
  @Monitor('counter.count', 'isEnabled')
  onMultipleChange(): void {
    console.log('Counter or isEnabled changed');
  }

  @Local isEnabled: boolean = true;

  build() {
    Column() {
      Text(`Count: ${this.counter.count}`)
      Button('Increment')
        .onClick(() => { this.counter.count++; })
    }
  }
}
```

### @Monitor vs @Watch 对比

| 特性 | @Watch (V1) | @Monitor (V2) |
|------|-------------|---------------|
| 监听数量 | 单个状态变量 | 多个状态变量 |
| 观察深度 | 一层 | 深层（需配合 @Trace） |
| 嵌套对象 | 不支持 | 支持 |
| 数组项监听 | 不支持 | 支持 |

## @Computed - 计算属性

用于定义派生状态，当依赖的状态变化时自动重新计算。

```typescript
@ObservedV2
class ShoppingCart {
  @Trace items: CartItem[] = [];
}

@ObservedV2
class CartItem {
  @Trace price: number = 0;
  @Trace quantity: number = 1;
}

@Entry
@ComponentV2
struct CartPage {
  @Local cart: ShoppingCart = new ShoppingCart();

  // 计算属性：总价
  @Computed
  get totalPrice(): number {
    return this.cart.items.reduce((sum, item) => {
      return sum + item.price * item.quantity;
    }, 0);
  }

  // 计算属性：商品总数
  @Computed
  get itemCount(): number {
    return this.cart.items.length;
  }

  build() {
    Column() {
      Text(`Items: ${this.itemCount}`)
      Text(`Total: ¥${this.totalPrice}`)
    }
  }
}
```

## AppStorageV2 - 全局状态管理

V2 提供了更强大的全局状态管理方案。

```typescript
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class GlobalState {
  @Trace isLogin: boolean = false;
  @Trace userId: string = '';
  @Trace theme: string = 'light';
  @Trace statusBarHeight: number = 0;

  static connect(): GlobalState {
    return AppStorageV2.connect<GlobalState>(GlobalState, () => new GlobalState())!;
  }
}

// 在任意组件中使用
@Entry
@ComponentV2
struct AnyPage {
  @Local globalState: GlobalState = GlobalState.connect();

  build() {
    Column() {
      Text(`Login: ${this.globalState.isLogin}`)
      Text(`Theme: ${this.globalState.theme}`)
      Button('Login')
        .onClick(() => {
          this.globalState.isLogin = true;
          this.globalState.userId = 'user123';
        })
    }
  }
}

// 在其他地方修改，所有使用该状态的组件都会自动更新
GlobalState.connect().isLogin = true;
```

## V1 与 V2 混用规则

### V1 组件中使用 V2 组件

| V1 变量类型 | V2 接收方式 | 限制 |
|------------|------------|------|
| 普通变量 | `@Param` | 无 |
| 状态变量（`@State` 等） | `@Param` | 仅支持简单类型（boolean, number, string, enum） |

### V2 组件中使用 V1 组件

| V2 变量类型 | V1 接收方式 | 限制 |
|------------|------------|------|
| 普通变量 | `@State`, `@Prop`, `@Provide` | 无 |
| 状态变量 | `@State`, `@Prop`, `@Provide` | 不支持 Array, Set, Map, Date |

### 混用限制

- V2 装饰器不能在 V1 组件（`@Component`）中使用
- V1 装饰器不能在 V2 组件（`@ComponentV2`）中使用
- 建议新项目统一使用 V2，维护项目逐步迁移

## V1 到 V2 迁移对照表

| V1 写法 | V2 写法 |
|---------|---------|
| `@Component` | `@ComponentV2` |
| `@State value: T` | `@Local value: T` |
| `@Prop value: T` | `@Param value: T` |
| `@Link value: T` | `@Param` + `@Event` 组合 |
| `@Provide/@Consume` | `@Provider()/@Consumer()` |
| `@Observed class` | `@ObservedV2 class` |
| `@Track property` | `@Trace property` |
| `@Watch('prop')` | `@Monitor('prop')` |
| `@ObjectLink` | 直接使用 `@ObservedV2` 类 |

## 完整示例：V2 状态管理

```typescript
import { AppStorageV2 } from '@kit.ArkUI';

// 全局状态定义
@ObservedV2
class AppState {
  @Trace counter: number = 0;
  @Trace user: UserInfo | null = null;

  static connect(): AppState {
    return AppStorageV2.connect<AppState>(AppState, () => new AppState())!;
  }
}

@ObservedV2
class UserInfo {
  @Trace name: string = '';
  @Trace email: string = '';
}

// 主页面
@Entry
@ComponentV2
struct MainPage {
  @Local appState: AppState = AppState.connect();
  @Local localMessage: string = 'Hello';

  @Monitor('appState.counter')
  onCounterChange(): void {
    console.log(`Counter changed: ${this.appState.counter}`);
  }

  @Computed
  get displayText(): string {
    return `${this.localMessage} - Count: ${this.appState.counter}`;
  }

  build() {
    Column({ space: 16 }) {
      Text(this.displayText)
        .fontSize(24)

      CounterControl({
        count: this.appState.counter,
        onIncrement: () => { this.appState.counter++; },
        onDecrement: () => { this.appState.counter--; }
      })

      if (this.appState.user) {
        UserCard({ user: this.appState.user })
      }
    }
    .width('100%')
    .padding(16)
  }
}

// 计数器控制组件
@ComponentV2
struct CounterControl {
  @Param count: number = 0;
  @Event onIncrement: () => void = () => {};
  @Event onDecrement: () => void = () => {};

  build() {
    Row({ space: 16 }) {
      Button('-')
        .onClick(() => { this.onDecrement(); })
      Text(`${this.count}`)
        .fontSize(20)
      Button('+')
        .onClick(() => { this.onIncrement(); })
    }
  }
}

// 用户卡片组件
@ComponentV2
struct UserCard {
  @Require @Param user: UserInfo = new UserInfo();

  build() {
    Column({ space: 8 }) {
      Text(this.user.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(this.user.email)
        .fontSize(14)
        .fontColor('#666')
    }
    .padding(16)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
  }
}
```

## 参考资料

- [官方状态管理 V2 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v2)
- [V1 到 V2 迁移指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V14/arkts-v1-v2-migration-V14)

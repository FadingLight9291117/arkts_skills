---
name: arkts-development
description: HarmonyOS ArkTS application development with ArkUI declarative UI framework. Use when building HarmonyOS/OpenHarmony apps, creating ArkUI components, implementing state management with decorators (@State, @Prop, @Link), migrating from TypeScript to ArkTS, or working with HarmonyOS-specific APIs (router, http, preferences). Covers component lifecycle, layout patterns, and ArkTS language constraints.
---

# ArkTS Development

Build HarmonyOS applications using ArkTS and the ArkUI declarative UI framework.

## Quick Start

Create a basic component:

```typescript
@Entry
@Component
struct HelloWorld {
  @State message: string = 'Hello, ArkTS!';

  build() {
    Column() {
      Text(this.message)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Button('Click Me')
        .onClick(() => { this.message = 'Button Clicked!'; })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## State Management Decorators

| Decorator | Usage | Description |
|-----------|-------|-------------|
| `@State` | `@State count: number = 0` | Component internal state |
| `@Prop` | `@Prop title: string` | Parent → Child (one-way) |
| `@Link` | `@Link value: number` | Parent ↔ Child (two-way, use `$varName`) |
| `@Provide/@Consume` | Cross-level | Ancestor → Descendant |
| `@Observed/@ObjectLink` | Nested objects | Deep object observation |

## Common Layouts

```typescript
// Vertical
Column({ space: 10 }) { Text('A'); Text('B'); }
  .alignItems(HorizontalAlign.Center)

// Horizontal
Row({ space: 10 }) { Text('A'); Text('B'); }
  .justifyContent(FlexAlign.SpaceBetween)

// Stack (overlay)
Stack({ alignContent: Alignment.Center }) {
  Image($r('app.media.bg'))
  Text('Overlay')
}

// List with ForEach
List({ space: 10 }) {
  ForEach(this.items, (item: string) => {
    ListItem() { Text(item) }
  }, (item: string) => item)
}
```

## Component Lifecycle

```typescript
@Entry
@Component
struct Page {
  aboutToAppear() { /* Init data */ }
  onPageShow() { /* Page visible */ }
  onPageHide() { /* Page hidden */ }
  aboutToDisappear() { /* Cleanup */ }
  build() { Column() { Text('Page') } }
}
```

## Navigation

```typescript
import { router } from '@kit.ArkUI';

// Push
router.pushUrl({ url: 'pages/Detail', params: { id: 123 } });

// Replace
router.replaceUrl({ url: 'pages/New' });

// Back
router.back();

// Get params
const params = router.getParams() as Record<string, Object>;
```

## Network Request

```typescript
import { http } from '@kit.NetworkKit';

const req = http.createHttp();
const res = await req.request('https://api.example.com/data', {
  method: http.RequestMethod.GET,
  header: { 'Content-Type': 'application/json' }
});
if (res.responseCode === 200) {
  const data = JSON.parse(res.result as string);
}
req.destroy();
```

## Local Storage

```typescript
import { preferences } from '@kit.ArkData';

const prefs = await preferences.getPreferences(this.context, 'store');
await prefs.put('key', 'value');
await prefs.flush();
const val = await prefs.get('key', 'default');
```

## ArkTS Language Constraints

ArkTS enforces stricter rules than TypeScript for performance and safety:

| Prohibited | Use Instead |
|------------|-------------|
| `any`, `unknown` | Explicit types, interfaces |
| `var` | `let`, `const` |
| Dynamic property access `obj['key']` | Fixed object structure |
| `for...in`, `delete`, `with` | `for...of`, array methods |
| `#privateField` | `private` keyword |
| Structural typing | Explicit `implements`/`extends` |

See [references/migration-guide.md](references/migration-guide.md) for complete TypeScript → ArkTS migration details.

## Reference Files

- **Migration Guide**: [references/migration-guide.md](references/migration-guide.md) - Complete TypeScript to ArkTS migration rules and examples
- **Component Patterns**: [references/component-patterns.md](references/component-patterns.md) - Advanced component patterns and best practices
- **API Reference**: [references/api-reference.md](references/api-reference.md) - Common HarmonyOS APIs

## Development Environment

- **IDE**: DevEco Studio
- **SDK**: HarmonyOS SDK
- **Simulator**: Built-in DevEco Studio emulator

# State Management V2: Migration from V1

Step-by-step guide for migrating components from State Management V1 to V2. For decorator details, see [state-management-v2.md](state-management-v2.md).

## Step-by-Step Migration Guide

**1. Update Component Decorator**

```typescript
// Before (V1)
@Entry
@Component
struct MyPage { }

// After (V2)
@Entry
@ComponentV2
struct MyPage { }
```

**2. Replace State Decorators**

| V1 | V2 | Notes |
|----|----|----|
| `@State` | `@Local` | Internal state only |
| `@Prop` | `@Param` | Efficient reference passing |
| `@Link` | `@Param` + `@Event` | Use callback pattern |
| `@Provide`/`@Consume` | `@Provider`/`@Consumer` | Similar usage |
| `@Observed` | `@ObservedV2` | On classes |
| `@ObjectLink` | Direct use with `@Trace` | No special decorator needed |

**3. Add @Trace to Observed Properties**

```typescript
// Before (V1)
@Observed
class Person {
  name: string;
  age: number;
}

// After (V2)
@ObservedV2
class Person {
  @Trace name: string;
  @Trace age: number;
}
```

**4. Replace @Link with @Param + @Event**

```typescript
// Before (V1)
@Component
struct Child {
  @Link count: number;
  build() {
    Button('Increment').onClick(() => this.count++)
  }
}
@Entry
@Component
struct Parent {
  @State count: number = 0;
  build() {
    Child({ count: $count })  // $ syntax
  }
}

// After (V2)
@ComponentV2
struct Child {
  @Param count: number = 0;
  @Event onIncrement: () => void = () => {};
  build() {
    Button('Increment').onClick(() => this.onIncrement())
  }
}
@Entry
@ComponentV2
struct Parent {
  @Local count: number = 0;
  build() {
    Child({
      count: this.count,
      onIncrement: () => this.count++
    })
  }
}
```

**5. Replace @Watch with @Monitor**

```typescript
// Before (V1)
@Entry
@Component
struct Page {
  @State @Watch('onCountChange') count: number = 0;
  
  onCountChange() {
    console.log('Count changed');
  }
  
  build() { }
}

// After (V2)
@Entry
@ComponentV2
struct Page {
  @Local count: number = 0;
  
  @Monitor('count')
  onCountChange(monitor: IMonitor) {
    const change = monitor.value();
    console.log(`Count changed from ${change?.before} to ${change?.now}`);
  }
  
  build() { }
}
```

## Migration Checklist

- [ ] Update all `@Component` to `@ComponentV2`
- [ ] Replace `@State` with `@Local` for internal state
- [ ] Replace `@Prop` with `@Param` for parent input
- [ ] Convert `@Link` to `@Param` + `@Event` pattern
- [ ] Update `@Observed` classes to `@ObservedV2` with `@Trace`
- [ ] Remove `@ObjectLink` usage (use `@Trace` directly)
- [ ] Replace `@Watch` with `@Monitor`
- [ ] Update `@Provide`/`@Consume` to `@Provider`/`@Consumer`
- [ ] Test nested object updates
- [ ] Test collection (Array, Map, Set) updates
- [ ] Verify computed properties work correctly

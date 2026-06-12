# State Management V2: Best Practices & Troubleshooting

Best practices and common issues for State Management V2. For decorator details, see [state-management-v2.md](state-management-v2.md).

## Best Practices

### 1. Choose the Right Decorator

**For Component State:**
- Use `@Local` for internal state (not shared externally)
- Use `@Param` for read-only input from parent
- Use `@Event` when child needs to request parent state changes

**For Class Observation:**
- Always use `@ObservedV2` on class + `@Trace` on observable properties
- Only decorate properties that actually need observation (performance)

### 2. Minimize @Trace Usage

```typescript
// Bad: Over-decorating
@ObservedV2
class Config {
  @Trace id: string;           // Rarely changes
  @Trace createdAt: Date;      // Never changes
  @Trace lastModified: Date;   // Never changes
  @Trace settings: Settings;   // Frequently changes
}

// Good: Only observe what changes
@ObservedV2
class Config {
  id: string;                  // No @Trace
  createdAt: Date;             // No @Trace
  lastModified: Date;          // No @Trace
  @Trace settings: Settings;   // Only this needs observation
}
```

### 3. Use @Computed for Expensive Calculations

```typescript
@Entry
@ComponentV2
struct ProductList {
  @Local products: Product[] = [];
  @Local searchQuery: string = "";
  
  // Good: Computed property caches result
  @Computed
  get filteredProducts(): Product[] {
    console.log("Filtering...");  // Only logs when products or searchQuery change
    return this.products.filter(p => 
      p.name.toLowerCase().includes(this.searchQuery.toLowerCase())
    );
  }
  
  build() {
    List() {
      // Each scroll doesn't re-filter
      ForEach(this.filteredProducts, (p: Product) => {
        ListItem() { Text(p.name) }
      })
    }
  }
}
```

### 4. Prefer @Param + @Event Over Two-Way Binding

```typescript
// Good: Clear data flow
@ComponentV2
struct Counter {
  @Param count: number = 0;
  @Event onIncrement: () => void = () => {};
  @Event onDecrement: () => void = () => {};
  
  build() {
    Row() {
      Button('-').onClick(() => this.onDecrement())
      Text(`${this.count}`)
      Button('+').onClick(() => this.onIncrement())
    }
  }
}

@Entry
@ComponentV2
struct App {
  @Local count: number = 0;
  
  build() {
    Counter({
      count: this.count,
      onIncrement: () => this.count++,
      onDecrement: () => this.count--
    })
  }
}
```

### 5. Use @Provider/@Consumer Sparingly

- Only use for truly cross-cutting concerns (theme, auth, i18n)
- Prefer explicit prop passing for most component communication
- Document Provider/Consumer pairs clearly

### 6. Structure Complex State

```typescript
// Good: Separate concerns
@ObservedV2
class UserProfile {
  @Trace name: string;
  @Trace email: string;
  @Trace avatarUrl: string;
}

@ObservedV2
class UserSettings {
  @Trace theme: 'light' | 'dark';
  @Trace language: string;
  @Trace notifications: boolean;
}

@ObservedV2
class AppState {
  @Trace profile: UserProfile = new UserProfile();
  @Trace settings: UserSettings = new UserSettings();
  @Trace isLoading: boolean = false;
}
```

### 7. Avoid Circular Dependencies in @Computed

```typescript
// Bad: Circular dependency
@Entry
@ComponentV2
struct Bad {
  @Local a: number = 1;
  
  @Computed
  get b(): number {
    return this.a + this.c;  // Depends on c
  }
  
  @Computed
  get c(): number {
    return this.a + this.b;  // Depends on b → circular!
  }
}

// Good: Linear dependencies
@Entry
@ComponentV2
struct Good {
  @Local a: number = 1;
  
  @Computed
  get b(): number {
    return this.a * 2;
  }
  
  @Computed
  get c(): number {
    return this.b + 10;  // c depends on b, b depends on a
  }
}
```

### 8. Use @Monitor for Side Effects

```typescript
@ObservedV2
class DataStore {
  @Trace data: string[] = [];
  
  @Monitor('data')
  onDataChange(monitor: IMonitor) {
    // Side effects: logging, analytics, persistence
    console.log('Data changed, syncing to server...');
    this.syncToServer();
  }
  
  private syncToServer(): void {
    // Persist changes
  }
}
```

---

## Troubleshooting

### Issue: Changes Not Triggering Re-renders

**Symptom:** Modifying nested object properties doesn't update UI.

**Cause:** Property not decorated with `@Trace`.

**Solution:**
```typescript
// Bad
@ObservedV2
class Person {
  name: string;  // Missing @Trace
}

// Good
@ObservedV2
class Person {
  @Trace name: string;
}
```

---

### Issue: @Computed Recalculates Too Often

**Symptom:** Computed property logs/executes on every render.

**Cause:** Depends on non-observable data or incorrectly implemented.

**Solution:**
```typescript
// Bad: Depends on method call (not observable)
@Computed
get result(): number {
  return this.calculate();  // calculate() not observable
}

// Good: Depends on observable state
@Computed
get result(): number {
  return this.value * 2;  // this.value is @Local or @Trace
}
```

---

### Issue: @Monitor Not Triggering

**Symptom:** `@Monitor` callback never called.

**Possible Causes:**

1. **Property not observable:**
   ```typescript
   // Bad
   @ObservedV2
   class Data {
     value: number = 0;  // No @Trace
     
     @Monitor('value')
     onChange() { }  // Never triggers
   }
   
   // Good
   @ObservedV2
   class Data {
     @Trace value: number = 0;
     
     @Monitor('value')
     onChange() { }
   }
   ```

2. **Wrong component decorator:**
   ```typescript
   // Bad
   @Component  // V1 component
   struct Page {
     @State count: number = 0;
     @Monitor('count') onChange() { }  // Won't work
   }
   
   // Good
   @ComponentV2  // V2 component
   struct Page {
     @Local count: number = 0;
     @Monitor('count') onChange() { }
   }
   ```

---

### Issue: Cannot Modify @Param in Child

**Symptom:** Error when trying to assign to `@Param` variable.

**Cause:** `@Param` is read-only in child component.

**Solution:** Use `@Event` to request parent to change:
```typescript
@ComponentV2
struct Child {
  @Param value: number = 0;
  @Event onChange: (newValue: number) => void = () => {};
  
  build() {
    Button('Update').onClick(() => {
      // Bad: this.value = 10;
      
      // Good: Request parent to change
      this.onChange(10);
    })
  }
}
```

---

### Issue: @Provider/@Consumer Not Syncing

**Symptom:** Consumer doesn't receive Provider updates.

**Possible Causes:**

1. **Alias mismatch:**
   ```typescript
   // Bad
   @Provider('user') data: User = new User();
   @Consumer('userData') data: User = new User();  // Different alias
   
   // Good
   @Provider('user') data: User = new User();
   @Consumer('user') data: User = new User();
   ```

2. **No Provider in ancestor tree:**
   ```typescript
   // Consumer will use its default value if no Provider found
   @Consumer() theme: string = 'light';  // Falls back to 'light'
   ```

---

### Issue: Mixing V1 and V2 Decorators

**Symptom:** Runtime errors or unexpected behavior.

**Cause:** Cannot mix V1 and V2 state management systems.

**Solution:** Fully migrate component to V2:
```typescript
// Bad: Mixing
@ComponentV2
struct Mixed {
  @State count: number = 0;   // V1 decorator
  @Local name: string = "";   // V2 decorator
}

// Good: All V2
@ComponentV2
struct AllV2 {
  @Local count: number = 0;
  @Local name: string = "";
}
```

---

### Issue: @ObservedV2 Class Cannot Use JSON.stringify

**Symptom:** `JSON.stringify()` produces incorrect output.

**Cause:** `@ObservedV2` adds proxies that interfere with serialization.

**Solution:** Use `UIUtils.getTarget()` to get raw object:
```typescript
import { UIUtils } from '@kit.ArkUI';

@ObservedV2
class Data {
  @Trace value: number = 42;
}

const observed = new Data();

// Bad
const json = JSON.stringify(observed);  // Incorrect output

// Good
const raw = UIUtils.getTarget(observed);
const json = JSON.stringify(raw);  // Correct output
```

---

### Performance: Repeated Value Assignments Trigger Re-renders

**Symptom:** Assigning same value repeatedly triggers re-renders.

**Cause:** Proxy objects (Array, Map, Set, Date) are compared by reference, not value.

**Solution:** Check equality before assigning:
```typescript
import { UIUtils } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Page {
  list: string[][] = [['a'], ['b']];
  @Local data: string[] = this.list[0];
  
  build() {
    Button('Reassign Same').onClick(() => {
      // Bad: Always triggers re-render
      // this.data = this.list[0];
      
      // Good: Check if actually different
      if (UIUtils.getTarget(this.data) !== this.list[0]) {
        this.data = this.list[0];
      }
    })
  }
}
```

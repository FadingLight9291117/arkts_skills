// State Management V2 - Quick Reference Examples

// ============================================
// 1. BASIC COMPONENT WITH @Local STATE
// ============================================
@Entry
@ComponentV2
struct CounterApp {
  @Local count: number = 0;
  @Local step: number = 1;
  
  build() {
    Column({ space: 10 }) {
      Text(`Count: ${this.count}`)
        .fontSize(30)
      Button(`+${this.step}`)
        .onClick(() => this.count += this.step)
      Button(`-${this.step}`)
        .onClick(() => this.count -= this.step)
    }
  }
}

// ============================================
// 2. NESTED OBJECTS WITH @ObservedV2/@Trace
// ============================================
@ObservedV2
class Address {
  @Trace city: string;
  @Trace street: string;
  
  constructor(city: string, street: string) {
    this.city = city;
    this.street = street;
  }
}

@ObservedV2
class Person {
  @Trace name: string;
  @Trace age: number;
  @Trace address: Address;
  
  constructor(name: string, age: number, address: Address) {
    this.name = name;
    this.age = age;
    this.address = address;
  }
}

@Entry
@ComponentV2
struct PersonProfile {
  person: Person = new Person(
    "Tom", 
    25, 
    new Address("Beijing", "Main St")
  );
  
  build() {
    Column({ space: 10 }) {
      Text(`${this.person.name}, ${this.person.age}`)
      Text(`${this.person.address.city}`)
      Button('Birthday').onClick(() => {
        this.person.age++;  // Observable
      })
      Button('Move').onClick(() => {
        this.person.address.city = "Shanghai";  // Observable
      })
    }
  }
}

// ============================================
// 3. PARENT-CHILD WITH @Param/@Event
// ============================================
@ComponentV2
struct Counter {
  @Param count: number = 0;
  @Event onIncrement: () => void = () => {};
  @Event onDecrement: () => void = () => {};
  
  build() {
    Row({ space: 10 }) {
      Button('-').onClick(() => this.onDecrement())
      Text(`${this.count}`).fontSize(30)
      Button('+').onClick(() => this.onIncrement())
    }
  }
}

@Entry
@ComponentV2
struct ParentApp {
  @Local count: number = 0;
  
  build() {
    Column({ space: 20 }) {
      Text('Parent Count: ' + this.count)
      Counter({
        count: this.count,
        onIncrement: () => this.count++,
        onDecrement: () => this.count--
      })
    }
  }
}

// ============================================
// 4. COMPUTED PROPERTIES
// ============================================
@ObservedV2
class CartItem {
  @Trace name: string;
  @Trace price: number;
  @Trace quantity: number;
  
  constructor(name: string, price: number, quantity: number) {
    this.name = name;
    this.price = price;
    this.quantity = quantity;
  }
}

@Entry
@ComponentV2
struct ShoppingCart {
  @Local items: CartItem[] = [
    new CartItem("Apple", 5, 3),
    new CartItem("Banana", 3, 5)
  ];
  @Local taxRate: number = 0.1;
  
  @Computed
  get subtotal(): number {
    console.log("Computing subtotal");  // Only logs when items change
    return this.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  }
  
  @Computed
  get tax(): number {
    return this.subtotal * this.taxRate;
  }
  
  @Computed
  get total(): number {
    return this.subtotal + this.tax;
  }
  
  build() {
    Column({ space: 10 }) {
      ForEach(this.items, (item: CartItem) => {
        Row() {
          Text(`${item.name}: $${item.price} × ${item.quantity}`)
          Button('+').onClick(() => item.quantity++)
        }
      }, (item: CartItem, idx: number) => item.name + idx)
      
      Divider()
      Text(`Subtotal: $${this.subtotal.toFixed(2)}`)
      Text(`Tax (${this.taxRate * 100}%): $${this.tax.toFixed(2)}`)
      Text(`Total: $${this.total.toFixed(2)}`).fontWeight(FontWeight.Bold)
    }
  }
}

// ============================================
// 5. MONITOR CHANGES
// ============================================
@ObservedV2
class Product {
  @Trace name: string = "Laptop";
  @Trace price: number = 1000;
  @Trace stock: number = 10;
  
  @Monitor('price')
  onPriceChange(monitor: IMonitor) {
    const change = monitor.value();
    console.log(`Price changed from ${change?.before} to ${change?.now}`);
    if (change && change.now > change.before) {
      console.log(`Price increased by ${change.now - change.before}`);
    }
  }
  
  @Monitor('stock')
  onStockChange(monitor: IMonitor) {
    const change = monitor.value();
    if (change && change.now < 5) {
      console.warn(`Low stock alert: ${change.now} items`);
    }
  }
}

@Entry
@ComponentV2
struct ProductManager {
  product: Product = new Product();
  
  @Monitor('product.price', 'product.stock')
  onProductChange(monitor: IMonitor) {
    console.log('Product properties changed:', monitor.dirty);
  }
  
  build() {
    Column({ space: 10 }) {
      Text(`${this.product.name}`)
      Text(`Price: $${this.product.price}`)
      Text(`Stock: ${this.product.stock}`)
      
      Button('Increase Price').onClick(() => {
        this.product.price += 100;
      })
      Button('Decrease Stock').onClick(() => {
        this.product.stock--;
      })
    }
  }
}

// ============================================
// 6. PROVIDER/CONSUMER (CROSS-LEVEL)
// ============================================
@Entry
@ComponentV2
struct AppRoot {
  @Provider('app-theme') theme: string = 'light';
  @Provider('user-name') userName: string = 'Alice';
  
  build() {
    Column({ space: 20 }) {
      Text(`App Theme: ${this.theme}`)
      Button('Toggle Theme').onClick(() => {
        this.theme = this.theme === 'light' ? 'dark' : 'light';
      })
      
      MiddleComponent()
    }
  }
}

@ComponentV2
struct MiddleComponent {
  build() {
    Column({ space: 10 }) {
      Text('Middle Component')
      DeepNestedComponent()
    }
  }
}

@ComponentV2
struct DeepNestedComponent {
  @Consumer('app-theme') theme: string = 'default';
  @Consumer('user-name') userName: string = 'Guest';
  
  build() {
    Column({ space: 10 }) {
      Text(`User: ${this.userName}`)
      Text(`Theme: ${this.theme}`)
        .backgroundColor(this.theme === 'dark' ? Color.Black : Color.White)
        .fontColor(this.theme === 'dark' ? Color.White : Color.Black)
      
      Button('Change from Deep Component').onClick(() => {
        this.theme = 'custom';  // Updates provider in AppRoot
      })
    }
  }
}

// ============================================
// 7. FORM INPUT PATTERN
// ============================================
@ObservedV2
class FormData {
  @Trace username: string = "";
  @Trace email: string = "";
  @Trace password: string = "";
}

@ComponentV2
struct FormField {
  @Param label: string = "";
  @Param value: string = "";
  @Param type: InputType = InputType.Normal;
  @Event onChange: (text: string) => void = () => {};
  
  build() {
    Column({ space: 5 }) {
      Text(this.label).fontSize(14)
      TextInput({ text: this.value })
        .type(this.type)
        .onChange((text: string) => this.onChange(text))
    }
  }
}

@Entry
@ComponentV2
struct RegistrationForm {
  @Local formData: FormData = new FormData();
  @Local isValid: boolean = false;
  
  @Monitor('formData.username', 'formData.email', 'formData.password')
  validateForm(monitor: IMonitor) {
    this.isValid = 
      this.formData.username.length >= 3 &&
      this.formData.email.includes('@') &&
      this.formData.password.length >= 8;
  }
  
  build() {
    Column({ space: 15 }) {
      Text('Registration').fontSize(24).fontWeight(FontWeight.Bold)
      
      FormField({
        label: 'Username',
        value: this.formData.username,
        onChange: (text: string) => {
          this.formData.username = text;
        }
      })
      
      FormField({
        label: 'Email',
        value: this.formData.email,
        type: InputType.Email,
        onChange: (text: string) => {
          this.formData.email = text;
        }
      })
      
      FormField({
        label: 'Password',
        value: this.formData.password,
        type: InputType.Password,
        onChange: (text: string) => {
          this.formData.password = text;
        }
      })
      
      Button('Submit')
        .enabled(this.isValid)
        .backgroundColor(this.isValid ? Color.Blue : Color.Gray)
        .onClick(() => {
          console.log('Form submitted:', this.formData);
        })
    }
    .padding(20)
  }
}

// ============================================
// 8. TODO LIST EXAMPLE
// ============================================
@ObservedV2
class TodoItem {
  @Trace id: string;
  @Trace title: string;
  @Trace completed: boolean;
  
  constructor(title: string) {
    this.id = Date.now().toString() + Math.random();
    this.title = title;
    this.completed = false;
  }
}

@ObservedV2
class TodoStore {
  @Trace items: TodoItem[] = [];
  
  addItem(title: string): void {
    this.items.push(new TodoItem(title));
  }
  
  removeItem(id: string): void {
    const index = this.items.findIndex(item => item.id === id);
    if (index !== -1) {
      this.items.splice(index, 1);
    }
  }
  
  toggleItem(id: string): void {
    const item = this.items.find(item => item.id === id);
    if (item) {
      item.completed = !item.completed;
    }
  }
}

@ComponentV2
struct TodoItemView {
  @Param item: TodoItem = new TodoItem("");
  @Event onToggle: () => void = () => {};
  @Event onDelete: () => void = () => {};
  
  build() {
    Row({ space: 10 }) {
      Checkbox({ select: this.item.completed })
        .onChange(() => this.onToggle())
      
      Text(this.item.title)
        .decoration({ type: this.item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
        .opacity(this.item.completed ? 0.5 : 1)
        .layoutWeight(1)
      
      Button('Delete')
        .onClick(() => this.onDelete())
    }
    .padding(10)
    .width('100%')
  }
}

@Entry
@ComponentV2
struct TodoApp {
  @Local store: TodoStore = new TodoStore();
  @Local inputText: string = "";
  
  @Computed
  get completedCount(): number {
    return this.store.items.filter(item => item.completed).length;
  }
  
  @Computed
  get totalCount(): number {
    return this.store.items.length;
  }
  
  build() {
    Column({ space: 15 }) {
      Text('Todo List').fontSize(30).fontWeight(FontWeight.Bold)
      
      Text(`${this.completedCount} / ${this.totalCount} completed`)
      
      Row({ space: 10 }) {
        TextInput({ text: this.inputText, placeholder: 'New task...' })
          .layoutWeight(1)
          .onChange((text: string) => {
            this.inputText = text;
          })
        
        Button('Add')
          .enabled(this.inputText.trim().length > 0)
          .onClick(() => {
            if (this.inputText.trim()) {
              this.store.addItem(this.inputText.trim());
              this.inputText = "";
            }
          })
      }
      
      List({ space: 5 }) {
        ForEach(this.store.items, (item: TodoItem) => {
          ListItem() {
            TodoItemView({
              item: item,
              onToggle: () => this.store.toggleItem(item.id),
              onDelete: () => this.store.removeItem(item.id)
            })
          }
        }, (item: TodoItem) => item.id)
      }
      .layoutWeight(1)
    }
    .padding(20)
    .height('100%')
  }
}

// ============================================
// 9. COLLECTION TYPES (Array, Map, Set)
// ============================================
@ObservedV2
class CollectionDemo {
  @Trace numbers: number[] = [1, 2, 3];
  @Trace userMap: Map<string, string> = new Map([['id1', 'Alice'], ['id2', 'Bob']]);
  @Trace tags: Set<string> = new Set(['typescript', 'arkts', 'harmonyos']);
}

@Entry
@ComponentV2
struct CollectionsExample {
  demo: CollectionDemo = new CollectionDemo();
  
  build() {
    Column({ space: 15 }) {
      // Array
      Text('Array:').fontWeight(FontWeight.Bold)
      ForEach(this.demo.numbers, (num: number, idx: number) => {
        Text(`[${idx}] = ${num}`)
      }, (num: number, idx: number) => num.toString() + idx)
      Button('Array.push').onClick(() => {
        this.demo.numbers.push(Math.floor(Math.random() * 100));
      })
      
      Divider()
      
      // Map
      Text('Map:').fontWeight(FontWeight.Bold)
      ForEach(Array.from(this.demo.userMap.entries()), (entry: [string, string]) => {
        Text(`${entry[0]}: ${entry[1]}`)
      }, (entry: [string, string]) => entry[0])
      Button('Map.set').onClick(() => {
        const id = 'id' + Date.now();
        this.demo.userMap.set(id, 'New User');
      })
      
      Divider()
      
      // Set
      Text('Set:').fontWeight(FontWeight.Bold)
      ForEach(Array.from(this.demo.tags.values()), (tag: string) => {
        Text(`• ${tag}`)
      }, (tag: string) => tag)
      Button('Set.add').onClick(() => {
        this.demo.tags.add('tag' + Date.now());
      })
    }
    .padding(20)
  }
}

# AGENTS.md - OpenCode Skills Repository

This repository contains AI coding agent skills for HarmonyOS/ArkTS development. Skills teach AI assistants how to build, deploy, and develop HarmonyOS applications.

## Repository Structure

```
skills/
├── arkts-development/          # ArkTS/ArkUI development skill
│   ├── SKILL.md               # Main skill definition
│   ├── assets/                # Code templates (.ets files)
│   └── references/            # API docs, migration guide, patterns
└── harmonyos-build-deploy/    # Build & deploy skill
    ├── SKILL.md               # Main skill definition
    └── references/            # Device installation guide
```

## Build/Lint/Test Commands

This is a documentation repository - no build system for the repo itself. However, the skills document these HarmonyOS CLI tools:

### Build Commands (hvigorw)

```bash
# Incremental build (default for development)
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon

# Clean build
hvigorw clean --no-daemon
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon

# Build single module (faster iteration)
hvigorw assembleHap -p module=entry@default --mode module -p buildMode=release --no-daemon

# Run tests
hvigorw onDeviceTest -p module=entry -p coverage=true    # On-device test
hvigorw test -p module=entry                              # Local test
```

### Package Manager (ohpm)

```bash
ohpm install --all              # Install all dependencies
ohpm clean && ohpm cache clean  # Deep clean
```

### Code Linter (codelinter)

```bash
codelinter                      # Check current project
codelinter --fix                # Check and auto-fix
codelinter -f json -o report.json  # JSON output
codelinter -i                   # Incremental (Git changes only)
codelinter --exit-on error,warn # CI/CD with exit codes
```

### Device Commands (hdc)

```bash
hdc list targets                # List devices (returns UDID)
hdc -t <UDID> file send <local> <remote>  # Push files
hdc -t <UDID> shell "bm install -p <path>" # Install app
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>" # Launch app
```

## Code Style Guidelines

### ArkTS Language Constraints

ArkTS is stricter than TypeScript. These are prohibited:

| Prohibited | Use Instead |
|------------|-------------|
| `any`, `unknown` | Explicit types, interfaces |
| `var` | `let`, `const` |
| Dynamic property `obj['key']` | Fixed object structure |
| `for...in`, `delete`, `with` | `for...of`, array methods |
| `#privateField` | `private` keyword |
| Structural typing | Explicit `implements`/`extends` |

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Components (struct) | PascalCase | `HomePage`, `UserCard` |
| Methods | camelCase | `loadData()`, `handleClick()` |
| Properties/Variables | camelCase | `isLoading`, `userName` |
| Interfaces | PascalCase | `UserInfo`, `ApiResponse` |
| Constants | camelCase or UPPER_SNAKE | `maxRetries`, `API_URL` |
| Files (skill docs) | kebab-case | `api-reference.md` |
| Skill directories | kebab-case | `arkts-development` |

### Type Annotations

Always use explicit type annotations:

```typescript
// Required: Explicit types on declarations
@State isLoading: boolean = false;
@State items: ItemType[] = [];

// Required: Return types on methods
async loadData(): Promise<void> { }
navigateToDetail(item: ItemType): void { }

// Required: Parameter types
ForEach(this.items, (item: ItemType) => { ... }, (item: ItemType) => item.id)
```

### Component Structure

Follow this standard component layout:

```typescript
@Entry
@Component
struct ComponentName {
  // 1. State decorators
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // 2. Lifecycle methods
  aboutToAppear(): void { this.loadData(); }
  aboutToDisappear(): void { /* cleanup */ }

  // 3. Business methods
  async loadData(): Promise<void> { }

  // 4. Builder methods (reusable UI blocks)
  @Builder ItemCard(item: ItemType) { }

  // 5. Build method (always last)
  build() { }
}
```

### Error Handling Pattern

```typescript
async loadData(): Promise<void> {
  this.isLoading = true;
  try {
    // async operation
  } catch (error) {
    this.errorMessage = 'Failed to load data';
  } finally {
    this.isLoading = false;
  }
}
```

### Import Style

Use HarmonyOS Kit imports:

```typescript
import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
```

## Skill File Format

Each skill follows this structure:

```markdown
---
name: skill-name
description: Detailed description for AI agent matching
---

# Skill Title

## Quick Start / Quick Reference
## Main Content Sections
## Troubleshooting
## Reference Files
```

### YAML Frontmatter

Required fields:
- `name`: kebab-case identifier matching directory name
- `description`: Detailed description for AI agent matching (trigger keywords)

## Documentation Conventions

- Use tables for command references and parameters
- Include code blocks with language specifiers (`typescript`, `bash`)
- Cross-reference related skills and reference files
- Use bilingual content (Chinese/English) for HarmonyOS context
- Structure: Quick Reference first, then detailed sections

## File Organization

- Main skill definition: `SKILL.md` (uppercase)
- Code templates: `assets/*.ets`
- Reference documentation: `references/*.md`
- All filenames: kebab-case

## Common Patterns

### State Management Decorators

| Decorator | Direction | Usage |
|-----------|-----------|-------|
| `@State` | Internal | Component's own mutable state |
| `@Prop` | Parent → Child | One-way binding (child copy) |
| `@Link` | Parent ↔ Child | Two-way binding (pass with `$var`) |
| `@Provide/@Consume` | Ancestor → Descendant | Cross-level state sharing |

### Layout Components

```typescript
Column({ space: 10 }) { }  // Vertical layout
Row({ space: 10 }) { }     // Horizontal layout
Stack() { }                 // Overlay layout
List({ space: 10 }) { }    // Scrollable list
```

### ForEach Pattern

Always provide explicit types and key generator:

```typescript
ForEach(this.items, (item: ItemType) => {
  ListItem() { Text(item.title) }
}, (item: ItemType) => item.id)  // Key generator for efficient updates
```

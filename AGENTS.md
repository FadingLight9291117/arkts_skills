# AGENTS.md - OpenCode Skills Repository

AI coding agent skills for HarmonyOS/ArkTS development. This is a **documentation-only** repo -- no build system for the repo itself. The skills teach agents how to build, deploy, and develop HarmonyOS apps.

## Repository Structure

```
arkts-development/              # ArkTS/ArkUI development skill
├── SKILL.md                   # Main skill definition (loaded by agent)
├── assets/*.ets               # Code templates
└── references/*.md            # API docs, migration guide, patterns
harmonyos-build-deploy/         # Build & deploy skill
├── SKILL.md                   # Main skill definition (loaded by agent)
└── references/*.md            # Device installation guide
```

## Build / Lint / Test Commands

These commands apply to **HarmonyOS projects** that the skills describe, not this repo.

### Build (hvigorw)

```bash
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon  # Full app
hvigorw assembleHap -p module=entry@default --mode module -p buildMode=release --no-daemon  # Single module (faster)
hvigorw clean --no-daemon                                                                # Clean artifacts
hvigorw --sync -p product=default -p buildMode=release --no-daemon                       # Sync after config change
```

### Test

```bash
# Run all tests for a module (on-device)
hvigorw onDeviceTest -p module=entry -p coverage=true --no-daemon

# Run all tests for a module (local / host-side)
hvigorw test -p module=entry --no-daemon

# Run a single test suite or single test (on-device) -- use -p testParam
hvigorw onDeviceTest -p module=entry -p testParam="{\"unittest\":\"TestClassName\"}" --no-daemon
hvigorw onDeviceTest -p module=entry -p testParam="{\"unittest\":\"TestClassName#testMethodName\"}" --no-daemon
```

### Dependencies (ohpm)

```bash
ohpm install --all                           # Install all deps
ohpm clean && ohpm cache clean               # Deep clean
```

### Lint (codelinter)

```bash
codelinter                                   # Check project
codelinter --fix                             # Auto-fix
codelinter -i                                # Incremental (git changes only)
codelinter --exit-on error,warn              # CI mode (non-zero exit on issues)
codelinter -f json -o report.json            # JSON report
```

### Device (hdc)

```bash
hdc list targets                                        # List devices (returns UDID)
hdc -t <UDID> file send <local_path> <device_path>     # Push files
hdc -t <UDID> shell "bm install -p <dir>"              # Install app
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"  # Launch app
```

## Code Style Guidelines

### ArkTS Language Constraints

ArkTS is stricter than TypeScript. These features are **prohibited**:

| Prohibited              | Use Instead                        |
|-------------------------|------------------------------------|
| `any`, `unknown`        | Explicit types, interfaces         |
| `var`                   | `let`, `const`                     |
| `obj['key']` (dynamic)  | Fixed object structure             |
| `for...in`              | `for...of`, array methods          |
| `delete`, `with`        | Optional properties, explicit refs |
| `#privateField`         | `private` keyword                  |
| Structural typing       | Explicit `implements` / `extends`  |
| `eval()`, `Function()`  | Arrow functions, static code       |

### Naming Conventions

| Element               | Convention      | Example                     |
|-----------------------|-----------------|-----------------------------|
| Components (struct)   | PascalCase      | `HomePage`, `UserCard`      |
| Interfaces            | PascalCase      | `UserInfo`, `ApiResponse`   |
| Methods / Functions   | camelCase       | `loadData()`, `handleClick` |
| Properties / Variables| camelCase       | `isLoading`, `userName`     |
| Constants             | camelCase or UPPER_SNAKE | `maxRetries`, `API_URL` |
| Skill directories     | kebab-case      | `arkts-development`         |
| Filenames (docs)      | kebab-case      | `api-reference.md`          |

### Type Annotations

Always use **explicit** type annotations on declarations, parameters, and return types:

```typescript
@State isLoading: boolean = false;
@State items: ItemType[] = [];
async loadData(): Promise<void> { }
navigateToDetail(item: ItemType): void { }
ForEach(this.items, (item: ItemType) => { ... }, (item: ItemType) => item.id)
```

### Imports

Use HarmonyOS Kit-style imports:

```typescript
import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
```

### Component Structure

Follow this ordering inside every `@Component` struct:

```typescript
@Entry
@Component
struct ComponentName {
  // 1. State decorators
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  // 2. Lifecycle
  aboutToAppear(): void { this.loadData(); }
  aboutToDisappear(): void { /* cleanup */ }
  // 3. Business methods
  async loadData(): Promise<void> { }
  // 4. @Builder methods (reusable UI blocks)
  @Builder ItemCard(item: ItemType) { }
  // 5. build() -- always last
  build() { }
}
```

### Error Handling

Wrap async work in try/catch/finally with loading state:

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

### ForEach -- always provide types and a key generator

```typescript
ForEach(this.items, (item: ItemType) => {
  ListItem() { Text(item.title) }
}, (item: ItemType) => item.id)
```

## Skill File Format

Every skill directory contains a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name          # kebab-case, matches directory name
description: ...          # Detailed description for agent matching
---
# Skill Title
## Quick Start / Quick Reference
## Detailed Sections
## Troubleshooting
## Reference Files
```

### File Organization Rules

- Main definition: `SKILL.md` (uppercase)
- Code templates: `assets/*.ets`
- Reference docs: `references/*.md`
- All filenames: **kebab-case**

## Documentation Conventions

- Use **tables** for command references and parameter lists.
- Use **fenced code blocks** with language specifiers (`typescript`, `bash`).
- Structure content as: Quick Reference first, then detailed sections.
- Cross-reference related skills and reference files by relative path.

## Maintaining Documentation

### When to Update README.md

**ALWAYS check and update README.md after making changes to the repository.**

Update README when:
- ✅ **Adding/removing files** - Update the repository structure section
- ✅ **Adding new features/sections** - Update the "Covers" section of relevant skills
- ✅ **Modifying project structure** - Update the file tree diagram
- ✅ **Adding new skill directories** - Add to the "Available Skills" section

Do NOT update README for:
- ❌ Bug fixes that don't change functionality
- ❌ Content improvements that don't add new features
- ❌ Wording/typo corrections
- ❌ Internal refactoring without user-visible changes

### Update Checklist

When making changes, follow this checklist:

1. Make your changes to skill files
2. **Check**: Did I add/remove files? → Update file tree in README
3. **Check**: Did I add new functionality? → Update "Covers" section in README
4. Commit changes (include README if updated)
5. Push to **both** remotes: `origin` (GitHub) and `gitea`

### Example Workflow

```bash
# After making changes
git add <changed-files>
git add README.md  # If updated

git commit -m "descriptive message"

# Push to both remotes
git push origin master
git push gitea master
```


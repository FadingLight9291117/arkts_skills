# OpenCode Skills - HarmonyOS Development

AI coding agent skills for HarmonyOS/ArkTS application development.

## What are Skills?

Skills are structured documentation that teach AI coding assistants (like OpenCode) how to perform specific development tasks. Each skill contains:

- **SKILL.md** - Main skill definition with quick reference and detailed guides
- **assets/** - Code templates and examples
- **references/** - Supporting documentation

## Available Skills

### arkts-development

ArkTS/ArkUI development for HarmonyOS applications.

**Covers:**
- ArkUI declarative UI framework
- State management decorators (@State, @Prop, @Link)
- Component lifecycle and navigation
- Network requests and local storage
- TypeScript to ArkTS migration

### harmonyos-build-deploy

Build, package, and deploy HarmonyOS applications.

**Covers:**
- hvigorw build commands
- ohpm package manager
- hdc device installation
- Troubleshooting common errors

## Usage

These skills are automatically loaded by OpenCode when relevant tasks are detected. The AI agent uses the skill documentation to:

1. Follow correct build/deploy procedures
2. Write code following ArkTS conventions
3. Troubleshoot common issues
4. Use proper HarmonyOS APIs

## Repository Structure

```
skills/
├── AGENTS.md                   # Guidelines for AI agents
├── README.md                   # This file
├── arkts-development/
│   ├── SKILL.md
│   ├── assets/
│   │   ├── component-template.ets
│   │   └── list-page-template.ets
│   └── references/
│       ├── api-reference.md
│       ├── codelinter.md
│       ├── component-patterns.md
│       ├── hstack.md
│       ├── hvigor-commandline.md
│       └── migration-guide.md
└── harmonyos-build-deploy/
    ├── SKILL.md
    └── references/
        └── device-installation.md
```

## Contributing

To add a new skill:

1. Create a directory with kebab-case name: `my-new-skill/`
2. Add `SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: my-new-skill
   description: Detailed description for AI agent matching
   ---
   ```
3. Add supporting files in `assets/` and `references/`
4. Follow conventions in [AGENTS.md](AGENTS.md)

## License

MIT

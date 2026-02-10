# AI Skills - HarmonyOS/ArkTS Development

AI coding agent skills for HarmonyOS/ArkTS application development.

## What are Skills?

Skills are structured documentation that teach AI coding assistants how to perform specific development tasks. Each skill contains:

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

## Quick Deploy

Use [skills.sh](https://skills.sh/) to deploy skills to your project with a single command.

### Install all skills

```bash
npx skills add FadingLight9291117/arkts_skills
```

### Install a single skill

You can install a specific skill from this repo using the `--skill` flag:

```bash
npx skills add https://github.com/FadingLight9291117/arkts_skills --skill harmonyos-build-deploy
npx skills add https://github.com/FadingLight9291117/arkts_skills --skill arkts-development
```

Or search for skills on [skills.sh](https://skills.sh/) and run the corresponding install command:

```bash
npx skills add <owner/repo>
```

Once installed, the skill is automatically configured for your AI agent (supports Cursor, Claude Code, Copilot, and other major agents).

> No additional CLI installation required — `npx` downloads and runs it automatically. To disable anonymous telemetry, set the environment variable `DISABLE_TELEMETRY=1`.

## Usage

These skills are automatically loaded by the AI agent when relevant tasks are detected. The agent uses the skill documentation to:

1. Follow correct build/deploy procedures
2. Write code following ArkTS conventions
3. Troubleshoot common issues
4. Use proper HarmonyOS APIs

## Repository Structure

```
AGENTS.md                       # Guidelines for AI agents
README.md                       # This file
arkts-development/
├── SKILL.md
├── assets/
│   ├── component-template.ets
│   └── list-page-template.ets
└── references/
    ├── api-reference.md
    ├── arkguard-obfuscation.md
    ├── codelinter.md
    ├── component-patterns.md
    ├── hstack.md
    ├── hvigor-commandline.md
    └── migration-guide.md
harmonyos-build-deploy/
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

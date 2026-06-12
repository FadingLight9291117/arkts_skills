# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [1.1.0] - 2026-06-12

### Fixed

- **README**: Removed outdated "wireless debugging" from harmonyos-build-deploy Covers section (feature was removed from the skill)
- **harmonyos-build-deploy**: Removed stale directory-push guidance from device-installation.md — `install file path invalid` section now clarifies the error only occurs with whole-directory push, not the recommended per-file workflow
- **harmonyos-build-deploy**: versionCode verification scripts now check `.hap` files in addition to `.hsp`
- **harmonyos-build-deploy**: install.sh device auto-detection now handles hdc's `[Empty]` output and Windows `\r` line endings
- **harmonyos-build-deploy**: Replaced placeholder code block in module-discovery.md with an actual module type discovery command

### Changed

- **harmonyos-build-deploy**: Quick Reference no longer duplicates the full Push and Install script — now cross-references the section
- **arkts-development**: Replaced duplicated hvigorw build section with cross-reference to harmonyos-build-deploy skill; kept test commands (not covered by the build skill)

- **harmonyos-build-deploy**: Translated Chinese UI strings to English in SKILL.md
- **harmonyos-build-deploy**: Removed agent-framework coupling (question() tool, Task() subagent references) — workflows are now framework-agnostic but marked for subagent delegation
- **harmonyos-build-deploy**: Deduplicated content between SKILL.md and device-installation.md — reference file now focuses on version verification and install script
- **harmonyos-build-deploy**: Fixed module type identification — now uses `module.json5` `type` field instead of heuristic based on `targets` presence
- **harmonyos-build-deploy**: Extracted module discovery, build outputs, and unwanted modules into `references/module-discovery.md` (~138 lines moved out of SKILL.md)
- **harmonyos-build-deploy**: Fixed unquoted variable in install.sh script
- **harmonyos-build-deploy**: Deploy Only workflow now checks for empty output directory and collects signed artifacts from module build directories
- **harmonyos-build-deploy**: Simplified build output path from `outputs/default/bundles/signed/` to `outputs/`
- **harmonyos-build-deploy**: Device push now filters by `.hap`/`.hsp` extension instead of sending entire directory

### Removed

- **harmonyos-build-deploy**: Wireless debugging (hdc tconn) section — environment setup, not build/deploy
- **harmonyos-build-deploy**: Restart App workflow — runtime operation, not build/deploy
- **harmonyos-build-deploy**: `aa dump -a` command — runtime debugging, not build/deploy
- **harmonyos-build-deploy**: Build Types section — redundant with Single Module Build and Module Types table
- **harmonyos-build-deploy**: Duplicate installation workflow and troubleshooting from device-installation.md (consolidated into SKILL.md)

### Added

- **CLAUDE.md** with repo guidance for Claude Code (structure, content rules, maintenance workflow)
- **arkts-development**: Split state-management-v2.md (1711 lines) into three files — new `references/state-management-v2-migration.md` (V1→V2 migration) and `references/state-management-v2-practices.md` (best practices & troubleshooting)
- **harmonyos-build-deploy**: Additional bm commands (install -r reinstall, clean cache/data)
- **harmonyos-build-deploy**: Cross-reference to arkts-development skill
- **harmonyos-build-deploy**: New reference file `references/module-discovery.md`

## [1.0.1] - 2026-02-11

### Added

- **harmonyos-build-deploy**: Finding Modules section (module definitions in build-profile.json5, module type identification)
- **harmonyos-build-deploy**: Finding Module Build Outputs section (output paths, signed/unsigned artifacts, search commands)

## [1.0.0] - 2026-02-10

### Added

- **arkts-development** skill
  - ArkUI declarative UI framework guide
  - State management V1 decorators (@State, @Prop, @Link, @Provide/@Consume, @Observed/@ObjectLink)
  - State management V2 decorators (@ComponentV2, @Local, @Param, @Event, @ObservedV2, @Trace, @Computed, @Monitor, @Provider/@Consumer)
  - Component lifecycle and navigation (router)
  - Network requests (http) and local storage (preferences)
  - TypeScript to ArkTS migration guide
  - Code templates: component-template.ets, list-page-template.ets, state-management-v2-examples.ets
  - Reference docs: API reference, component patterns, ArkGuard obfuscation, CodeLinter, hstack, hvigorw command-line
- **harmonyos-build-deploy** skill
  - hvigorw build commands (assembleApp, assembleHap, assembleHsp, assembleHar)
  - ohpm dependency management
  - hdc device installation and management
  - Troubleshooting common build/deploy errors
  - Device installation reference guide
- **AGENTS.md** with coding conventions and documentation guidelines

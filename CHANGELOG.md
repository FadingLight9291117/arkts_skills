# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- **harmonyos-build-deploy**: Translated Chinese UI strings to English in SKILL.md
- **harmonyos-build-deploy**: Removed agent-framework coupling (question() tool, Task() subagent references) — workflows are now framework-agnostic but marked for subagent delegation
- **harmonyos-build-deploy**: Deduplicated content between SKILL.md and device-installation.md — reference file now focuses on version verification, install script, and detailed troubleshooting
- **harmonyos-build-deploy**: Fixed module type identification — now uses `module.json5` `type` field instead of heuristic based on `targets` presence
- **harmonyos-build-deploy**: Extracted module discovery, build outputs, and unwanted modules into `references/module-discovery.md` (~138 lines moved out of SKILL.md)
- **harmonyos-build-deploy**: Fixed unquoted variable in install.sh script

### Added

- **harmonyos-build-deploy**: Device logging section (hilog commands, filtering options, ArkTS logging example)
- **harmonyos-build-deploy**: Wireless debugging documentation (hdc tconn)
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

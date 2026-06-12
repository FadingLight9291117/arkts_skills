# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A **documentation-only** repository of AI agent skills for HarmonyOS/ArkTS development. There is no build system, linter, or test suite for the repo itself — the content *teaches agents* how to build, test, and deploy HarmonyOS apps. The build/test/lint commands documented here (hvigorw, ohpm, codelinter, hdc) apply to the HarmonyOS projects the skills describe, not to this repo.

See `AGENTS.md` for the full reference: HarmonyOS command cheatsheet, ArkTS language constraints, naming conventions, and component structure rules that all code examples in this repo must follow.

## Structure

Each skill is a top-level kebab-case directory:

- `SKILL.md` (uppercase) — main definition loaded by agents. YAML frontmatter with `name` (must match directory name) and `description` (used for agent task matching). Body is organized Quick Reference first, then detailed sections, then troubleshooting.
- `references/*.md` — supporting docs, cross-referenced from SKILL.md by relative path.
- `assets/*.ets` — code templates (arkts-development only).

Current skills: `arkts-development` (ArkUI, state management V1/V2, migration) and `harmonyos-build-deploy` (hvigorw build, hdc install).

## Content Rules

- Keep SKILL.md and reference files deduplicated: SKILL.md holds workflows and quick reference; detail that exceeds ~100 lines gets extracted into a `references/` file.
- Skills must stay framework-agnostic — no references to specific agent tools (e.g., `question()`, `Task()` subagents).
- Code examples must follow ArkTS constraints (no `any`/`unknown`/`var`, explicit type annotations everywhere, Kit-style imports like `@kit.ArkUI`).
- Device paths in hdc examples use `//` prefix (e.g., `//data/local/tmp`) for Git Bash compatibility on Windows.
- Build/deploy skills cover build and deploy only — runtime debugging and environment setup were deliberately removed; don't reintroduce them.

## Required Maintenance on Every Change

1. **CHANGELOG.md** — update the `[Unreleased]` section for every commit (Keep a Changelog format, entries prefixed with the skill name in bold).
2. **README.md** — update only when files are added/removed (file tree), new functionality is added ("Covers" sections), or a new skill directory is created. Skip for typo fixes and internal rewording.
3. **Version badge** — sync the badge in README.md whenever the CHANGELOG.md version changes.

## Git

- Working branch is `develop`; PRs target `master`.

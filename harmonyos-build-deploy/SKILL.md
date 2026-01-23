---
name: harmonyos-build-deploy
description: HarmonyOS application build, clean, package and device installation. Use when building HarmonyOS projects with hvigorw, cleaning build artifacts, managing ohpm dependencies, packaging HAP/HSP/APP bundles, installing to devices via hdc, or troubleshooting installation errors like "version code not same".
---

# HarmonyOS Build & Deploy

Complete workflow for building, cleaning, packaging, and installing HarmonyOS applications.

## Quick Reference

```bash
# For time-consuming operations (build, deploy), use subagent Task tool
# See "Workflow with Subagent" section below for details

# Build complete app (incremental)
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon

# Install to device (check actual output path in your project)
hdc -t <UDID> shell "rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install"
hdc -t <UDID> file send <output_path>/signed /data/local/tmp/install
hdc -t <UDID> shell "bm install -p /data/local/tmp/install/signed"
```

**Note:** Build output path varies by project. Common paths:
- `outputs/default/signed/`
- `outputs/project/bundles/signed/`

Check your project's actual output after build.

## Workflow with Subagent

For time-consuming operations (build, clean, deploy), use the **general** subagent to handle the entire workflow:

### Clean Build & Deploy

```bash
# Launch subagent to clean, build, and deploy to device
Task(description="Clean build and deploy", prompt="Clean build and deploy the HarmonyOS app to device.

1. Run: hvigorw clean --no-daemon
2. Run: ohpm install --all
3. Run: hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
4. Find the build output directory (outputs/project/ or outputs/default/)
5. Deploy to device using hdc commands:
   - Clean device temp: hdc -t <UDID> shell \"rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install\"
   - Send files: hdc -t <UDID> file send <output_path> /data/local/tmp/install/
   - Install: hdc -t <UDID> shell \"bm install -p /data/local/tmp/install/project/bundles/signed\"
   - Launch: hdc -t <UDID> shell \"aa start -a EntryAbility -b <bundleName>\"
6. Report success/failure with details.", subagent_type="general")
```

### Deploy Only (No Rebuild)

```bash
# Launch subagent to deploy existing build to device
Task(description="Deploy app to device", prompt="Deploy the HarmonyOS application to device <UDID>.

1. Read AppScope/app.json5 to get bundleName
2. Clean device temp: hdc -t <UDID> shell \"rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install\"
3. Send build output to device: hdc -t <UDID> file send \"<output_path>/project/\" \"/data/local/tmp/install/\"
4. Install: hdc -t <UDID> shell \"bm install -p /data/local/tmp/install/project/bundles/signed\"
5. Launch: hdc -t <UDID> shell \"aa start -a EntryAbility -b <bundleName>\"
6. Report success/failure with details.", subagent_type="general")
```

### Restart App

```bash
# Launch subagent to restart the app
Task(description="Restart app", prompt="Restart the HarmonyOS app on device <UDID>.

1. Force stop: hdc -t <UDID> shell \"aa force-stop <bundleName>\"
2. Launch: hdc -t <UDID> shell \"aa start -a EntryAbility -b <bundleName>\"
3. Report success/failure.", subagent_type="general")
```

### Clean App Cache/Data

```bash
# Launch subagent to clean app data
Task(description="Clean app data", prompt="Clean app data on device <UDID>.

1. Clean cache: hdc -t <UDID> shell \"bm clean -n <bundleName> -c\"
2. Clean data: hdc -t <UDID> shell \"bm clean -n <bundleName> -d\"
3. Report success/failure.", subagent_type="general")
```

**Why use subagent?**
- Long-running operations (build ~30s, file transfer ~20s) don't timeout
- Better error handling and reporting
- User gets clear progress updates

## Build Commands (hvigorw)

### Incremental Build (Default)

Use incremental build for normal development - only changed modules are rebuilt:

```bash
# Build complete app (incremental)
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
```

### Single Module Build

Build only a specific module for faster iteration:

```bash
# Build single HAP module
hvigorw assembleHap -p module=entry@default --mode module -p buildMode=release --no-daemon

# Build single HSP module
hvigorw assembleHsp -p module=feature_module@default --mode module -p buildMode=release --no-daemon

# Build single HAR module
hvigorw assembleHar -p module=library@default --mode module -p buildMode=release --no-daemon

# Build multiple modules at once
hvigorw assembleHsp -p module=module1@default,module2@default --mode module -p buildMode=release --no-daemon
```

**Module name format:** `{moduleName}@{targetName}`
- `moduleName`: Directory name of the module (e.g., `entry`, `feature_home`)
- `targetName`: Target defined in module's `build-profile.json5` (usually `default`)

**When to use single module build:**
- Developing/debugging a specific module
- Faster build times during iteration
- Testing changes in isolated module

**Note:** After single module build, you still need to run `assembleApp` to package the complete application for installation.

### Clean Build (When Needed)

Only perform clean build when:
- First time building the project
- Encountering unexplained build errors
- After modifying `build-profile.json5` or SDK version
- Dependency resolution issues

```bash
# Clean build artifacts
hvigorw clean --no-daemon

# Deep clean (for dependency issues)
ohpm clean && ohpm cache clean
ohpm install --all
hvigorw --sync -p product=default -p buildMode=release --no-daemon
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
```

### Install Dependencies (ohpm)

```bash
# Install all dependencies (after clean or first clone)
ohpm install --all

# With custom registry
ohpm install --all --registry "https://repo.harmonyos.com/ohpm/"
```

### Sync Project

Only needed after modifying `build-profile.json5` or `oh-package.json5`:

```bash
hvigorw --sync -p product=default -p buildMode=release --no-daemon
```

### Build Types

```bash
hvigorw assembleHap    # Build HAP (Harmony Ability Package)
hvigorw assembleHsp    # Build HSP (Harmony Shared Package)
hvigorw assembleHar    # Build HAR (Harmony Archive)
hvigorw assembleApp    # Build complete APP bundle
```

### Build Parameters

| Parameter | Description |
|-----------|-------------|
| `-p product={name}` | Target product defined in build-profile.json5 |
| `-p buildMode={debug\|release}` | Build mode |
| `-p module={name}@{target}` | Target module with `--mode module` |
| `--mode project` | Build all modules in project |
| `--mode module` | Build specific module only |
| `--no-daemon` | Disable daemon (recommended for CI) |
| `--analyze=advanced` | Enable build analysis |

## Build Outputs

Build output path varies by project configuration. Common patterns:

```
outputs/
├── default/signed/                      # Pattern 1
│   ├── entry-default-signed.hap
│   └── *.hsp
└── project/bundles/signed/              # Pattern 2
    ├── entry-default-signed.hap
    └── *.hsp
```

**Tip:** After build, check the actual output directory in your project.

### Module Types

| Type | Extension | Description |
|------|-----------|-------------|
| HAP | `.hap` | Harmony Ability Package - Application entry module |
| HSP | `.hsp` | Harmony Shared Package - Dynamic shared library |
| HAR | `.har` | Harmony Archive - Static library (compiled into HAP) |
| APP | `.app` | Complete application bundle (all HAP + HSP) |

## Unwanted Modules in Output Directory

Sometimes HSP files appear in the output directory that are **not listed in `build-profile.json5`**. These modules should not be deployed.

**Cause:** Build scripts or dependency configurations may copy precompiled HSP files to the output directory, even though they are not part of the current build.

**How to identify:**

1. Check `build-profile.json5` → `modules` array
2. If an HSP file in output is not in the modules list, it should be removed before installation

**Solution:** Remove these HSP files before installation:

```bash
# Example: Remove modules not in build-profile.json5
rm <output_path>/signed/unwanted-module-default-signed.hsp
```

**Note:** Installation will fail with "version code not same" error if these unwanted modules have a different versionCode than the main app. The root cause is that these modules shouldn't be deployed at all.

## Device Installation (hdc)

hdc (HarmonyOS Device Connector) is the CLI tool for device communication, similar to Android's adb.

### Check Device

```bash
hdc list targets              # List connected devices (returns UDID)
hdc -t <UDID> shell "whoami"  # Test connection
```

### Push and Install

```bash
# Clear device directory
hdc -t <UDID> shell "rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install"

# Push signed bundles
hdc -t <UDID> file send path/to/signed /data/local/tmp/install

# Install all HAP/HSP in directory
hdc -t <UDID> shell "bm install -p /data/local/tmp/install/signed"
```

### Verify and Launch

```bash
# Check installation
hdc -t <UDID> shell "bm dump -n <bundleName>"

# Launch app (default ability)
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

### Uninstall

```bash
hdc -t <UDID> shell "bm uninstall -n <bundleName>"
```

## hdc Command Reference

| Command | Description |
|---------|-------------|
| `hdc list targets` | List connected devices |
| `hdc -t <UDID> shell "<cmd>"` | Execute shell command on device |
| `hdc -t <UDID> file send <local> <remote>` | Push file/directory to device |
| `hdc -t <UDID> file recv <remote> <local>` | Pull file/directory from device |
| `hdc kill` | Kill hdc server |
| `hdc start` | Start hdc server |
| `hdc version` | Show hdc version |

## Bundle Manager (bm)

Run via `hdc -t <UDID> shell "bm ..."`:

| Command | Description |
|---------|-------------|
| `bm install -p <path>` | Install from directory (all HAP/HSP) |
| `bm install -p <file.hap>` | Install single HAP file |
| `bm uninstall -n <bundleName>` | Uninstall application |
| `bm dump -n <bundleName>` | Show package info |
| `bm dump -a` | List all installed packages |

## Ability Assistant (aa)

Run via `hdc -t <UDID> shell "aa ..."`:

| Command | Description |
|---------|-------------|
| `aa start -a <ability> -b <bundle>` | Start specific ability |
| `aa force-stop <bundleName>` | Force stop application |
| `aa dump -a` | Dump all running abilities |

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `version code not same` | HSP in output not in build-profile.json5 | Remove unwanted HSP files before install |
| `install parse profile prop check error` | Signature/profile mismatch | Check signing config in build-profile.json5 |
| `install failed due to older sdk version` | Device SDK < app's compatibleSdkVersion | Update device or lower compatibleSdkVersion |
| Device not found | Connection issue | Check USB, enable debugging, `hdc kill && hdc start` |
| `signature verification failed` | Invalid or expired certificate | Regenerate signing certificate |

## Key Configuration Files

| File | Description |
|------|-------------|
| `AppScope/app.json5` | App metadata (bundleName, versionCode, versionName) |
| `build-profile.json5` | Modules list, products, signing configs |
| `{module}/src/main/module.json5` | Module config (abilities, permissions) |
| `{module}/oh-package.json5` | Module dependencies |

## Reference Files

- **Complete Installation Guide**: [references/device-installation.md](references/device-installation.md)

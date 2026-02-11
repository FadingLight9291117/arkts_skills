---
name: harmonyos-build-deploy
description: HarmonyOS application build, clean, package and device installation. Use when building HarmonyOS projects with hvigorw, cleaning build artifacts, managing ohpm dependencies, packaging HAP/HSP/APP bundles, installing to devices via hdc, or troubleshooting installation errors like "version code not same".
---

# HarmonyOS Build & Deploy

Complete workflow for building, cleaning, packaging, and installing HarmonyOS applications.

## First Step: Confirm Operation with User

**IMPORTANT:** Before executing any build or deploy operation, confirm which specific operation(s) the user wants to perform. Ask the user to choose from:

| Operation | Description |
|-----------|-------------|
| Clean build artifacts | Remove previous build cache and outputs |
| Install dependencies | Use ohpm to install project dependencies |
| Build project | Use hvigorw to build HAP/APP packages |
| Install to device | Use hdc to install the app on a device |
| Full pipeline | Clean → install deps → build → deploy to device |

**Why confirm first:**
- Different scenarios require different operations (e.g., incremental build vs clean build)
- Avoid unnecessary time-consuming operations
- Give user control over the workflow
- Prevent accidental device installation

**After user responds:**
- Execute only the selected operations
- Report progress and results clearly

## Quick Reference

```bash
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

## Workflows

### Clean Build & Deploy

```bash
# 1. Clean
hvigorw clean --no-daemon

# 2. Install dependencies
ohpm install --all

# 3. Build
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon

# 4. Find build output (check outputs/default/signed/ or outputs/project/bundles/signed/)

# 5. Deploy to device
hdc -t <UDID> shell "rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install"
hdc -t <UDID> file send <output_path>/signed /data/local/tmp/install
hdc -t <UDID> shell "bm install -p /data/local/tmp/install/signed"

# 6. Launch
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

### Deploy Only (No Rebuild)

```bash
# 1. Read AppScope/app.json5 to get bundleName

# 2. Push existing build output to device
hdc -t <UDID> shell "rm -rf /data/local/tmp/install && mkdir -p /data/local/tmp/install"
hdc -t <UDID> file send <output_path>/signed /data/local/tmp/install
hdc -t <UDID> shell "bm install -p /data/local/tmp/install/signed"

# 3. Launch
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

### Restart App

```bash
hdc -t <UDID> shell "aa force-stop <bundleName>"
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

### Clean App Cache/Data

```bash
hdc -t <UDID> shell "bm clean -n <bundleName> -c"   # Clean cache
hdc -t <UDID> shell "bm clean -n <bundleName> -d"   # Clean data
```

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

## Finding Modules

All modules are defined in `build-profile.json5` at the project root, in the `modules` array.

### Module Definition Structure

```json5
{
  "modules": [
    {
      "name": "entry",              // Module name (used in build commands)
      "srcPath": "./entry",         // Module source path (relative to project root)
      "targets": [                  // Build target config (optional)
        {
          "name": "default",
          "applyToProducts": ["default", "app_store"]
        }
      ]
    },
    {
      "name": "support_http",
      "srcPath": "./support/support_http",
      "targets": [...]
    }
  ]
}
```

### Key Fields

| Field | Description |
|-------|-------------|
| `name` | Module name, used in build commands (e.g., `-p module=entry@default`) |
| `srcPath` | Module source path relative to project root |
| `targets` | Build target config, specifies which products this module applies to |

### Module Type Identification

The module type is defined in each module's `module.json5` file:

```json5
// {module}/src/main/module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",    // "entry" = HAP, "shared" = HSP, "har" = HAR
    ...
  }
}
```

| `type` field value | Module Type | Description |
|--------------------|-------------|-------------|
| `"entry"` | **HAP** | Application entry point |
| `"feature"` | **HAP** | Feature module (also a HAP) |
| `"shared"` | **HSP** | Dynamic shared package |
| `"har"` | **HAR** | Static library (compiled into other modules) |

**To identify all module types in a project:**

```bash
# Read type from each module's module.json5
# Check {srcPath}/src/main/module.json5 for each module in build-profile.json5
```

## Finding Module Build Outputs

Module build outputs are located at:

```
{srcPath}/build/default/outputs/default/
```

**Note:** Debug and Release builds output to the same directory. The difference is in the signing configuration used (defined in `build-profile.json5` → `signingConfigs`).

### Output Files

| File | Description |
|------|-------------|
| `{name}-default-signed.hsp` | **Signed HSP** (ready for installation) |
| `{name}-default-unsigned.hsp` | Unsigned HSP |
| `{name}.har` | HAR static library |
| `app/{name}-default.hsp` | Intermediate artifact |
| `mapping/sourceMaps.map` | Source maps for debugging |

### Example

For module `support_http` with `srcPath: "./support/support_http"`:

```
support/support_http/build/default/outputs/default/
├── support_http-default-signed.hsp    ← Signed, ready to install
├── support_http-default-unsigned.hsp
├── support_http.har
├── app/
│   └── support_http-default.hsp
├── mapping/
│   └── sourceMaps.map
└── pack.info
```

### Search Commands

```bash
# Find all signed HSP/HAP outputs
dir /s /b "*-signed.hsp" "*-signed.hap" 2>nul           # Windows
find . -name "*-signed.hsp" -o -name "*-signed.hap"     # Linux/macOS

# Find specific module's output
dir /s /b "{srcPath}\build\default\outputs\default\*"   # Windows
ls -la {srcPath}/build/default/outputs/default/         # Linux/macOS
```

### Notes

1. **Build required**: If `build/` directory doesn't exist, run build first
2. **Project-level outputs**: Complete app bundle is in project root `outputs/` after `assembleApp`
3. **oh_modules outputs**: Dependency modules may have outputs in `oh_modules/@xxx/build/...` (these are resolved dependencies)

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
| `hdc tconn <IP>:<port>` | Connect to device over Wi-Fi |
| `hdc kill` | Kill hdc server |
| `hdc start` | Start hdc server |
| `hdc version` | Show hdc version |

### Wireless Debugging (Wi-Fi)

Connect to a device over the network instead of USB:

```bash
# 1. Connect device via USB first and get its IP address
hdc -t <UDID> shell "ifconfig"    # Find wlan0 IP

# 2. Enable TCP port on device (if supported)
hdc -t <UDID> shell "param set persist.hdc.port 5555"

# 3. Connect wirelessly
hdc tconn <device_IP>:5555

# 4. Verify connection
hdc list targets
# Should show the IP-based target alongside or instead of USB target
```

**Note:** Wireless debugging may require the device and host to be on the same network. Not all devices support `hdc tconn`.

## Bundle Manager (bm)

Run via `hdc -t <UDID> shell "bm ..."`:

| Command | Description |
|---------|-------------|
| `bm install -p <path>` | Install from directory (all HAP/HSP) |
| `bm install -p <file.hap>` | Install single HAP file |
| `bm install -r -p <path>` | Reinstall (replace existing, keep data) |
| `bm uninstall -n <bundleName>` | Uninstall application |
| `bm dump -n <bundleName>` | Show package info |
| `bm dump -a` | List all installed packages |
| `bm clean -n <bundleName> -c` | Clean application cache |
| `bm clean -n <bundleName> -d` | Clean application data |

## Ability Assistant (aa)

Run via `hdc -t <UDID> shell "aa ..."`:

| Command | Description |
|---------|-------------|
| `aa start -a <ability> -b <bundle>` | Start specific ability |
| `aa force-stop <bundleName>` | Force stop application |
| `aa dump -a` | Dump all running abilities |

## Device Logging (hilog)

Use hilog to view device logs for debugging. Run via `hdc -t <UDID> shell "hilog ..."`:

```bash
# Stream all logs (like adb logcat)
hdc -t <UDID> shell "hilog"

# Filter by tag
hdc -t <UDID> shell "hilog -T <tag>"

# Filter by log level (DEBUG, INFO, WARN, ERROR, FATAL)
hdc -t <UDID> shell "hilog -L ERROR"

# Combine tag and level filters
hdc -t <UDID> shell "hilog -T MyApp -L WARN"

# Clear log buffer
hdc -t <UDID> shell "hilog -r"

# Show only recent logs (last N lines)
hdc -t <UDID> shell "hilog -t 100"
```

### Common hilog Options

| Option | Description |
|--------|-------------|
| `-T <tag>` | Filter by log tag |
| `-L <level>` | Minimum log level: DEBUG, INFO, WARN, ERROR, FATAL |
| `-D <domain>` | Filter by domain (hex, e.g., `0x0001`) |
| `-r` | Clear log buffer |
| `-t <count>` | Show only last N log entries |
| `-x` | Exit after printing existing logs (no streaming) |

### Logging in ArkTS Code

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0000;
const TAG: string = 'MyApp';

hilog.info(DOMAIN, TAG, 'Application started');
hilog.error(DOMAIN, TAG, 'Failed to load data: %{public}s', error.message);
```

**Note:** Use `%{public}s` for string parameters that should be visible in logs. Without `{public}`, parameters are masked as `<private>` in release builds.

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

- **Complete Installation Guide**: [references/device-installation.md](references/device-installation.md) - Detailed troubleshooting, version verification scripts, and installation script

## Related Skills

- **arkts-development**: ArkTS/ArkUI development patterns, state management, component lifecycle, and API usage. Use alongside this skill when developing HarmonyOS application code.

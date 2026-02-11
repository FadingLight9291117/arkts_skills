# Device Installation Guide

Detailed guide for verifying build outputs and automating device installation. This supplements the main [SKILL.md](../SKILL.md) with version verification scripts and an installation script.

## Prerequisites

- **hdc**: HarmonyOS Device Connector (included in HarmonyOS SDK)
- **Device**: HarmonyOS device with USB debugging enabled
- **Build Output**: Signed HAP/HSP files from `hvigorw assembleApp`

## Verifying Build Outputs Before Installation

All HAP/HSP modules must have the **same versionCode**. Mismatched versions cause `"version code not same"` errors during installation.

### Check versionCode of All Modules

```bash
# Using Python (cross-platform)
python3 -c "
import zipfile, json, glob
for f in glob.glob('outputs/*.hsp'):
    z = zipfile.ZipFile(f)
    data = json.loads(z.read('module.json'))
    print(f\"{f.split('/')[-1]}: versionCode = {data['app']['versionCode']}\")
"

# Using unzip + grep (Linux/macOS)
for f in outputs/*.hsp; do
    echo -n "$(basename $f): "
    unzip -p "$f" module.json | grep -o '"versionCode":[0-9]*'
done
```

### Identifying Problematic Modules

A module should be removed from the output before installation if:

1. Module directory has no `src/` folder (precompiled binary only)
2. Module not listed in `build-profile.json5` modules array
3. Module versionCode differs from `AppScope/app.json5`

```bash
rm outputs/problematic-module-default-signed.hsp
```

## Quick Installation Script

Save as `install.sh` (Linux/macOS) or run with Git Bash on Windows:

```bash
#!/bin/bash

# === Configuration ===
DEVICE_ID="${1:-$(hdc list targets | head -1)}"
SIGNED_PATH="${2:-outputs}"
BUNDLE_NAME="${3:-}"
REMOTE_PATH="/data/local/tmp/install_$(date +%s)"

if [ -z "$DEVICE_ID" ]; then
    echo "Error: No device found. Connect a device or specify UDID as first argument."
    exit 1
fi

echo "Device: $DEVICE_ID"
echo "Source: $SIGNED_PATH"
echo "Remote: $REMOTE_PATH"

# === Create remote directory ===
hdc -t "$DEVICE_ID" shell "mkdir -p $REMOTE_PATH"

# === Push only .hap and .hsp files ===
for f in "$SIGNED_PATH"/*.hap "$SIGNED_PATH"/*.hsp; do
    [ -f "$f" ] && hdc -t "$DEVICE_ID" file send "$f" "$REMOTE_PATH/"
done

# === Install ===
hdc -t "$DEVICE_ID" shell "bm install -p $REMOTE_PATH"

# === Clean up ===
hdc -t "$DEVICE_ID" shell "rm -rf $REMOTE_PATH"

echo ""
echo "Installation complete!"

# === Optional: Launch app ===
if [ -n "$BUNDLE_NAME" ]; then
    echo "Launching $BUNDLE_NAME..."
    hdc -t "$DEVICE_ID" shell "aa start -a EntryAbility -b $BUNDLE_NAME"
fi
```

Usage:

```bash
# Auto-detect device, use default path
./install.sh

# Specify device UDID
./install.sh 1234567890ABCDEF

# Specify device and path
./install.sh 1234567890ABCDEF outputs

# Specify device, path, and bundle name (auto-launch)
./install.sh 1234567890ABCDEF outputs com.example.app
```

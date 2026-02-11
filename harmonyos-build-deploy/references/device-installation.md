# Device Installation Guide

Detailed guide for packaging and installing HarmonyOS applications to physical devices. This supplements the main [SKILL.md](../SKILL.md) with deeper troubleshooting, version verification, and an installation script.

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
for f in glob.glob('outputs/default/signed/*.hsp'):
    z = zipfile.ZipFile(f)
    data = json.loads(z.read('module.json'))
    print(f\"{f.split('/')[-1]}: versionCode = {data['app']['versionCode']}\")
"

# Using unzip + grep (Linux/macOS)
for f in outputs/default/signed/*.hsp; do
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
rm outputs/default/signed/problematic-module-default-signed.hsp
```

## Complete Installation Workflow

### Step 1: Check Device Connection

```bash
hdc list targets
# Output: device UDID (e.g., 1234567890ABCDEF)
```

If no device found:
1. Check USB connection
2. Enable Developer Options on device: Settings > About > Tap build number 7 times
3. Enable USB debugging: Settings > Developer options > USB debugging
4. Run `hdc kill && hdc start` to restart hdc server

### Step 2: Push Files to Device

```bash
# Clear and create installation directory on device
hdc -t <UDID> shell "rm -rf /data/local/tmp/app_install && mkdir -p /data/local/tmp/app_install"

# Push signed HAP/HSP files
hdc -t <UDID> file send outputs/default/signed /data/local/tmp/app_install
```

### Step 3: Install Application

```bash
# Install all HAP/HSP from directory
hdc -t <UDID> shell "bm install -p /data/local/tmp/app_install/signed"

# Expected output: "install bundle successfully."
```

### Step 4: Verify and Launch

```bash
# Check package info
hdc -t <UDID> shell "bm dump -n <bundleName>"

# Launch application
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

## Quick Installation Script

Save as `install.sh` (Linux/macOS) or run with Git Bash on Windows:

```bash
#!/bin/bash

# === Configuration ===
DEVICE_ID="${1:-$(hdc list targets | head -1)}"
SIGNED_PATH="${2:-outputs/default/signed}"
BUNDLE_NAME="${3:-}"
REMOTE_PATH="/data/local/tmp/app_install"

if [ -z "$DEVICE_ID" ]; then
    echo "Error: No device found. Connect a device or specify UDID as first argument."
    exit 1
fi

echo "Device: $DEVICE_ID"
echo "Source: $SIGNED_PATH"

# === Clear remote directory ===
hdc -t "$DEVICE_ID" shell "rm -rf $REMOTE_PATH && mkdir -p $REMOTE_PATH"

# === Push signed files ===
hdc -t "$DEVICE_ID" file send "$SIGNED_PATH" "$REMOTE_PATH"

# === Install ===
BASENAME="$(basename "$SIGNED_PATH")"
hdc -t "$DEVICE_ID" shell "bm install -p $REMOTE_PATH/$BASENAME"

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
./install.sh 1234567890ABCDEF outputs/default/signed

# Specify device, path, and bundle name (auto-launch)
./install.sh 1234567890ABCDEF outputs/default/signed com.example.app
```

## Build Output Structure

```
outputs/
└── {product}/                              # e.g., default/
    ├── {project}-{product}-signed.app      # Complete APP bundle
    ├── signed/
    │   ├── entry-{product}-signed.hap      # Main entry HAP
    │   ├── feature-{product}-signed.hap    # Feature HAP (if any)
    │   └── *.hsp                           # Shared library modules
    └── unsigned/
        └── ...                             # Unsigned versions
```

## Troubleshooting Details

### Error: "version code not same"

**Cause:** Some HAP/HSP modules have different versionCode than others.

**Solution:**
1. Use the version check commands above to find modules with different versionCode
2. Remove those modules from signed directory before installation
3. Usually caused by precompiled modules not in build-profile.json5

### Error: "install parse profile prop check error"

**Cause:** Signature or profile configuration mismatch.

**Solution:**
1. Check signing config in `build-profile.json5`
2. Ensure certificate and profile match
3. Verify profile bundleName matches app.json5 bundleName
4. Check certificate is not expired

### Error: Device not found

**Cause:** Connection or hdc service issue.

**Solution:**
1. Check USB cable connection
2. Enable Developer Options: Settings > About > Tap build number 7 times
3. Enable USB debugging: Settings > Developer options > USB debugging
4. Restart hdc server: `hdc kill && hdc start`
5. Try different USB port or cable

### Error: "install failed due to older sdk version in the device"

**Cause:** Device system version is lower than app's minimum requirement.

**Solution:**
1. Update device to latest system version
2. Or lower `compatibleSdkVersion` in `build-profile.json5`

### Error: "signature verification failed"

**Cause:** Certificate issues.

**Solution:**
1. Regenerate debug/release certificate in DevEco Studio
2. Check certificate validity period
3. Ensure using correct signing config for build type

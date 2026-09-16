# Android Emulator & Device Execution Guide

This guide walks through running, testing, and debugging **SliceUPI** on Android emulators and physical devices using the Android SDK and `adb`.

---

## 1. Prerequisites

- **Android SDK Tools** (`platform-tools/adb.exe`, `emulator/emulator.exe`) installed at `%LOCALAPPDATA%\Android\Sdk` (or configured on your system `PATH`).
- **Node.js** (v18+) and **npm**.
- An existing Android Virtual Device (AVD), such as `Pixel_9`, `Pixel_9_GMS`, or `Pixel_Tablet`.

---

## 2. Launching the App on the Emulator (Step-by-Step)

### Step 1: Start the Development Server
Bind the Vite dev server to all network interfaces (`0.0.0.0`) so it is accessible to both the host machine and the Android guest network:

```powershell
cd D:\Antigravity\upi-split-app
npm run dev -- --host 0.0.0.0 --port 5173
```

### Step 2: Boot the Android Virtual Device
In a separate terminal, launch the emulator (using `swiftshader` GPU acceleration if running in headless/virtualized environments):

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_9 -no-snapshot -gpu swiftshader_indirect -no-audio
```

Or using the Android CLI tool:
```powershell
android emulator start Pixel_9
```

### Step 3: Configure Reverse Port Forwarding
By default, the emulator can access the host machine via `http://10.0.2.2:5173`. To enable `http://localhost:5173` inside the emulator:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:5173 tcp:5173
```

### Step 4: Launch the App in the Android Browser / WebView
Dispatch an Android intent to open the application directly:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell am start -a android.intent.action.VIEW -d "http://localhost:5173"
```

---

## 3. Verified Emulator Screenshots

| View | Screenshot |
| :--- | :--- |
| **Home Screen & Architecture Selector** | ![Home Screen](images/01_emulator_home.png) |
| **Split Plan & Rules Engine** | ![Split Plan](images/02_emulator_plan.png) |
| **Mode A: Intent Runner** | ![Intent Runner](images/03_emulator_intent_runner.png) |
| **Mode B: Escrow AutoPay Dispersal** | ![Escrow Dispersal](images/04_emulator_escrow_dispersing.png) |
| **Settlement Summary Receipt** | ![Receipt](images/05_emulator_receipt.png) |

---

## 4. Useful ADB Commands for Testing

### Screen Capture & Recording
```powershell
# Capture a screenshot from the running emulator:
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png ./screenshot.png

# Record a video of the user flow:
adb shell screenrecord /sdcard/demo.mp4
# (Press Ctrl+C to stop)
adb pull /sdcard/demo.mp4 ./demo.mp4
```

### Simulating Touch and Navigation
```powershell
# Tap at specific coordinates (e.g. x=540, y=1750)
adb shell input tap 540 1750

# Swipe / Scroll down:
adb shell input swipe 500 1500 500 600 300

# Press Back button:
adb shell input keyevent 4
```

---

## 5. Packaging into Native Android APK (Capacitor)

To compile this web core into a standalone `.apk`:

```powershell
# 1. Install Capacitor core and CLI
npm install @capacitor/core @capacitor/android
npm install -D @capacitor/cli

# 2. Initialize Capacitor configuration
npx cap init "SliceUPI" "com.sliceupi.app" --web-dir dist

# 3. Build production bundle
npm run build

# 4. Add Android platform
npx cap add android

# 5. Sync web assets into Android project
npx cap sync

# 6. Open project in Android Studio or compile APK
npx cap open android
```

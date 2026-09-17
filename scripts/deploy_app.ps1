$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$emulator = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
$apk = "D:\Antigravity\upi-split-app\flutter_app\build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "Scanning for ADB devices..."
$deviceLines = & $adb devices | Where-Object { $_ -match "\bdevice\b" }

if (-not $deviceLines) {
    Write-Host "No active devices found. Launching Pixel 9 emulator with GUI..."
    Start-Process -FilePath $emulator -ArgumentList "-avd Pixel_9 -no-snapshot"
    Write-Host "Waiting for ADB connection..."
    & $adb wait-for-device
    Write-Host "Waiting for system boot completion..."
    & $adb shell 'while [[ "$(getprop sys.boot_completed)" != "1" ]]; do sleep 2; done'
    Write-Host "Emulator booted successfully!"
}

$deviceLines = & $adb devices | Where-Object { $_ -match "\bdevice\b" }

if (-not $deviceLines) {
    Write-Error "No connected device or emulator available."
    exit 1
}

foreach ($line in $deviceLines) {
    $serial = ($line -split "\s+")[0].Trim()
    Write-Host "=========================================="
    Write-Host "Deploying SlicePay APK to: $serial"
    Write-Host "=========================================="
    
    $installResult = & $adb -s $serial install -r $apk
    Write-Host $installResult

    Write-Host "Unlocking keyguard on $serial..."
    & $adb -s $serial shell input keyevent 82

    Write-Host "Launching SlicePay on $serial..."
    & $adb -s $serial shell monkey -p com.slicepay.flutter_slicepay -c android.intent.category.LAUNCHER 1
    
    Write-Host "Deployment completed on $serial!"
}

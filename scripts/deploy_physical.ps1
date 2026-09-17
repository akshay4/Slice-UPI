$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apk = "D:\Antigravity\upi-split-app\flutter_app\build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "Waiting for physical device to connect via ADB..."
Write-Host "Please ensure USB Debugging is ENABLED on your phone and the 'Allow USB Debugging' prompt is accepted."

$found = $false
for ($i = 0; $i -lt 60; $i++) {
    $devices = & $adb devices -l | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "emulator" }
    if ($devices) {
        $found = $true
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $found) {
    Write-Host "Timeout waiting for physical device."
    exit 1
}

foreach ($line in $devices) {
    $serial = ($line -split "\s+")[0].Trim()
    Write-Host "Found physical device: $serial"
    Write-Host "Installing APK ($apk)..."
    $res = & $adb -s $serial install -r $apk
    Write-Host $res
    Write-Host "Launching SlicePay on $serial..."
    & $adb -s $serial shell monkey -p com.slicepay.flutter_slicepay -c android.intent.category.LAUNCHER 1
    Write-Host "SUCCESS: SlicePay deployed to physical device $serial!"
}

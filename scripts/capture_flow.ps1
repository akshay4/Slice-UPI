$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$emulator = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"

Write-Host "Starting emulator with auto GPU..."
$proc = Start-Process -FilePath $emulator -ArgumentList "-avd Pixel_9 -no-snapshot -no-audio" -PassThru

try {
    Write-Host "Waiting for device..."
    & $adb wait-for-device
    Write-Host "Waiting for boot..."
    & $adb shell 'while [[ "$(getprop sys.boot_completed)" != "1" ]]; do sleep 1; done'
    Write-Host "Boot completed!"

    Start-Sleep -Seconds 2
    & $adb shell input keyevent 82
    Start-Sleep -Seconds 1
    & $adb shell monkey -p com.slicepay.flutter_slicepay -c android.intent.category.LAUNCHER 1
    Write-Host "App launched, waiting for render..."
    Start-Sleep -Seconds 6

    Write-Host "Navigating to Accounts (tap 900 2300)..."
    & $adb shell input tap 900 2300
    Start-Sleep -Seconds 2

    Write-Host "Capturing accounts screenshot..."
    & $adb shell screencap -p /sdcard/accounts.png
    & $adb pull /sdcard/accounts.png docs/images/flutter_v2_accounts.png

    $item = Get-Item docs/images/flutter_v2_accounts.png
    Write-Host "Accounts capture size: $($item.Length) bytes"
} finally {
    Write-Host "Closing emulator..."
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
}


$ErrorActionPreference = "Stop"

$downloadFolder = "$env:USERPROFILE\Downloads"
$deviceFolder = "/sdcard/Pictures"

adb -s emulator-5554 shell mkdir -p $deviceFolder

$images = Get-ChildItem $downloadFolder -File |
    Where-Object { $_.Extension -match '^\.(jpg|jpeg|png|webp)$' }

foreach ($image in $images) {
    adb -s emulator-5554 push "$($image.FullName)" "$deviceFolder/$($image.Name)"
}

adb -s emulator-5554 shell am broadcast `
    -a android.intent.action.MEDIA_SCANNER_SCAN_FILE `
    -d file:///sdcard/Pictures

Write-Host "Da chuyen anh vao Android!"

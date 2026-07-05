# Renders the Play Store graphics from the HTML sources to exact-size PNGs
# using headless Chrome. Run from anywhere:  pwsh store/assets/render.ps1
#
# To localize the screenshots, edit the caption text in shot1..shot5.html
# (and the mock UI strings if desired), then re-run this script.

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) {
    $chrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}
$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$base = "file:///" + ($dir -replace '\\', '/') + "/"

function Render($html, $png, $w, $h) {
    & $chrome --headless=new --disable-gpu --no-sandbox --hide-scrollbars `
        --force-device-scale-factor=1 --window-size="$w,$h" `
        --screenshot="$dir\$png" ($base + $html) 2>&1 | Out-Null
    Start-Sleep -Milliseconds 700
    "{0,-14} {1}" -f $png, (Test-Path "$dir\$png")
}

Render "feature.html" "feature.png" 1024 500
foreach ($n in 1..5) { Render "shot$n.html" "shot$n.png" 1080 2160 }

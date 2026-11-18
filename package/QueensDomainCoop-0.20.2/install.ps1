# Installs the Queen's Domain co-op mod into a Queen's Domain installation.
#   install.ps1 [-GameDir "<folder that has QueensDomain.exe>"]
# Any game build installs: the mod checks the game each time it starts and switches off whatever does not fit (see
# QDCoop\Logs\core.log). The builds it was tested on are listed below.
# Without -GameDir it looks for the game in your Steam libraries. Nothing of the game is changed or removed: the mod
# adds xinput1_3.dll (a small loader) and the QDCoop folder next to the game exe. An xinput1_3.dll that is already
# there (another mod) is kept as xinput1_3.dll.qdcoop-backup and put back by uninstall.ps1.
param(
    [string]$GameDir = "",
    [switch]$Force  # kept for older instructions; no longer needed
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = Join-Path $here "files"
# Game builds this mod was tested on: exe time stamp -> the game's version.
$TestedBuilds = [ordered]@{ "6AE3DAC2" = "1.01.03"; "6AEBF261" = "1.01.05"; "6AF55DEF" = "1.01.06a" }
# An update of the game that changes only its data keeps the exe: 1.01.07 (2026-11-14) has the exe of 1.01.06a. For
# the newest exe the game's own build number (version.txt in the game folder) therefore says which update it is.
$NewestStamp = "6AF55DEF"
$TestedNumbers = [ordered]@{ "13565" = "1.01.06a"; "13571" = "1.01.07" }

. (Join-Path $here "common.ps1")

if (-not $GameDir) { $GameDir = Find-QueensDomain }
if (-not $GameDir) { throw "Queen's Domain was not found. Run again with -GameDir `"<folder that has QueensDomain.exe>`"." }
$bin = Join-Path $GameDir "QueensDomain\Binaries\Win64"
$exe = Join-Path $bin "QueensDomain-Win64-Shipping.exe"
if (-not (Test-Path $exe)) { throw "Not a Queen's Domain folder (no $exe)." }
if (Get-Process -Name "QueensDomain-Win64-Shipping" -ErrorAction SilentlyContinue) { throw "Close Queen's Domain first." }

# game build (PE header TimeDateStamp): informational, the mod checks the game itself when it starts
$bytes = [System.IO.File]::ReadAllBytes($exe)
$pe = [BitConverter]::ToInt32($bytes, 0x3C)
$stamp = "{0:X8}" -f [BitConverter]::ToUInt32($bytes, $pe + 8)
$gameVersionTxt = Join-Path $GameDir "version.txt"
$number = ""
if (Test-Path $gameVersionTxt) { $number = "$(Get-Content $gameVersionTxt -Raw)".Trim() }
if ($stamp -eq $NewestStamp -and $number -match '^\d+$' -and -not $TestedNumbers.Contains($number)) {
    Write-Host "Game build $number (exe $stamp, the exe of version $($TestedBuilds[$stamp])): an update of the game this mod was not"
    Write-Host "tested on ($(($TestedNumbers.Values) -join ', ') were). That is usually fine: the mod checks the game each time it starts and"
    Write-Host "switches off any part that does not fit (QDCoop\Logs\core.log says what it found)."
} elseif ($stamp -eq $NewestStamp -and $TestedNumbers.Contains($number)) {
    Write-Host "Game version $($TestedNumbers[$number]) (build $number, exe $stamp): tested with this mod."
} elseif ($TestedBuilds.Contains($stamp)) {
    Write-Host "Game version $($TestedBuilds[$stamp]) (exe $stamp): tested with this mod."
} else {
    Write-Host "Game build exe $stamp is not one this mod was tested on ($(($TestedBuilds.Values) -join ', '))."
    Write-Host "That is fine: the mod checks the game each time it starts and switches off any part that does not fit"
    Write-Host "(QDCoop\Logs\core.log says what it found). You can play together with players whose game is compatible."
}

# The package belongs anywhere but the game folder (Steam's): say so, and point out a game file an older package
# overwrote when it was unpacked there (its VERSION.txt replaced the game's own version.txt).
$hereFull = (Resolve-Path $here).Path.TrimEnd('\')
$gameFull = (Resolve-Path $GameDir).Path.TrimEnd('\')
if ($hereFull.StartsWith($gameFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Host "Note: this package was unpacked inside the game folder. It works, but keep it somewhere else next time."
}
if ($number -match '^0\.9\.0$') {
    Write-Host "Note: the game's version.txt was replaced by the 0.9.0 package of this mod when it was unpacked in the game"
    Write-Host "folder. Restore it with Steam: Queen's Domain > Properties > Installed Files > Verify integrity of game files."
}

$modDir = Join-Path $bin "QDCoop"
New-Item -ItemType Directory -Force -Path $modDir | Out-Null
$manifest = [ordered]@{ version = (Get-Content (Join-Path $here "QDCoop-VERSION.txt") -Raw).Trim(); installed = (Get-Date).ToString("s"); gameExe = $stamp; files = @(); backup = $null }

$loaderDst = Join-Path $bin "xinput1_3.dll"
$prevManifest = Join-Path $modDir "install-manifest.json"
$prev = $null
if (Test-Path $prevManifest) { try { $prev = Get-Content $prevManifest -Raw | ConvertFrom-Json } catch {} }
# Updating over an earlier install: the file that earlier install kept is still the one to put back on uninstall.
if ($prev -and $prev.backup -and (Test-Path (Join-Path $bin $prev.backup))) { $manifest.backup = $prev.backup }
if (Test-Path $loaderDst) {
    $theirs = (Get-FileHash $loaderDst -Algorithm SHA256).Hash
    $ours = (Get-FileHash (Join-Path $files "xinput1_3.dll") -Algorithm SHA256).Hash
    $wasOurs = $prev -and (($prev.files | Where-Object { $_.sha256 -eq $theirs }) -ne $null)
    if ($theirs -ne $ours -and -not $wasOurs -and -not (Test-Path "$loaderDst.qdcoop-backup")) {
        Copy-Item $loaderDst "$loaderDst.qdcoop-backup" -Force
        $manifest.backup = "xinput1_3.dll.qdcoop-backup"
        Write-Host "Kept the existing xinput1_3.dll as xinput1_3.dll.qdcoop-backup"
    }
}
Copy-Item (Join-Path $files "xinput1_3.dll") $loaderDst -Force
Copy-Item (Join-Path $files "QDCoop\QDCoop.dll") (Join-Path $modDir "QDCoop.dll") -Force
Copy-Item (Join-Path $files "QDCoop\compat.ini") (Join-Path $modDir "compat.ini") -Force  # mod data, not a setting
$ini = Join-Path $modDir "QDCoop.ini"
if (-not (Test-Path $ini)) { Copy-Item (Join-Path $files "QDCoop\QDCoop.ini") $ini } else { Write-Host "Kept your QDCoop.ini" }
foreach ($f in @($loaderDst, (Join-Path $modDir "QDCoop.dll"), (Join-Path $modDir "compat.ini"))) {
    $manifest.files += [ordered]@{ path = $f.Substring($GameDir.Length).TrimStart('\'); sha256 = (Get-FileHash $f -Algorithm SHA256).Hash }
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 (Join-Path $modDir "install-manifest.json")
Write-Host "Installed the co-op mod in $GameDir"
Write-Host "Start the game from Steam. For the co-op menu press F8, or hold View / Select on a controller for about half a"
Write-Host "second. R3 (the right stick's click) pings."

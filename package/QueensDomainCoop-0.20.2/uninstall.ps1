# Removes the Queen's Domain co-op mod.
#   uninstall.ps1 [-GameDir "<folder that has QueensDomain.exe>"] [-RemoveSettings]
# Deletes only the files install.ps1 put there (checked by hash), puts back an xinput1_3.dll it had kept, and leaves
# your settings and co-op campaign file (QDCoop\QDCoop.ini, QDCoop\Saves) unless -RemoveSettings. Game saves
# (including the co-op slots World8.sav / World9.sav) are the game's own and are never touched.
param(
    [string]$GameDir = "",
    [switch]$RemoveSettings
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "common.ps1")
if (-not $GameDir) { $GameDir = Find-QueensDomain }
if (-not $GameDir) { throw "Run again with -GameDir `"<folder that has QueensDomain.exe>`"." }
if (Get-Process -Name "QueensDomain-Win64-Shipping" -ErrorAction SilentlyContinue) { throw "Close Queen's Domain first." }
$bin = Join-Path $GameDir "QueensDomain\Binaries\Win64"
$modDir = Join-Path $bin "QDCoop"
$mf = Join-Path $modDir "install-manifest.json"
if (-not (Test-Path $mf)) { throw "The co-op mod is not installed here (no $mf)." }
$manifest = Get-Content $mf -Raw | ConvertFrom-Json
foreach ($f in $manifest.files) {
    $p = Join-Path $GameDir $f.path
    if (Test-Path $p) {
        if ((Get-FileHash $p -Algorithm SHA256).Hash -eq $f.sha256) { Remove-Item $p -Force }
        else { Write-Host "Left $p in place: it changed since install" }
    }
}
if ($manifest.backup) {
    $b = Join-Path $bin $manifest.backup
    if (Test-Path $b) { Move-Item $b (Join-Path $bin "xinput1_3.dll") -Force; Write-Host "Put the previous xinput1_3.dll back" }
}
Remove-Item $mf -Force
foreach ($d in @("bin", "Logs", "Dumps")) { $p = Join-Path $modDir $d; if (Test-Path $p) { Remove-Item $p -Recurse -Force } }
if ($RemoveSettings) { Remove-Item $modDir -Recurse -Force }
elseif ((Get-ChildItem $modDir -Force | Measure-Object).Count -eq 0) { Remove-Item $modDir -Force }
Write-Host "Removed the co-op mod from $GameDir"

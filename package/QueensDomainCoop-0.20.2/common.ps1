# Shared by install.ps1 and uninstall.ps1: find Queen's Domain in the Steam libraries.
function Find-QueensDomain {
    $roots = @()
    foreach ($key in @("HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam")) {
        try {
            $p = (Get-ItemProperty -Path $key -ErrorAction Stop)
            if ($p.SteamPath) { $roots += $p.SteamPath }
            if ($p.InstallPath) { $roots += $p.InstallPath }
        } catch {}
    }
    $libs = @()
    foreach ($r in $roots | Select-Object -Unique) {
        $libs += $r
        $vdf = Join-Path $r "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += $m.Groups[1].Value -replace '\\', '\' }
        }
    }
    foreach ($l in $libs | Select-Object -Unique) {
        $g = Join-Path $l "steamapps\common\QueensDomain"
        if (Test-Path (Join-Path $g "QueensDomain\Binaries\Win64\QueensDomain-Win64-Shipping.exe")) { return $g }
    }
    return $null
}

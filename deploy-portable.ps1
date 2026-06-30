param(
    [string]$BuildDirectory = "C:\Users\User\Documents\TechAim software\build-app-check",
    [string]$OutputDirectory = "C:\Users\User\Documents\TechAim software\dist\TechAimTarget-Portable"
)

$ErrorActionPreference = "Stop"

$projectDirectory = $PSScriptRoot
$qtDirectory = "C:\Qt\6.5.3\mingw_64"
$mingwDirectory = "C:\Qt\Tools\mingw1120_64"
$runtimeSeed = "C:\Users\User\Documents\TechAim Portable"
$executable = Join-Path $BuildDirectory "release\TechAimTarget.exe"
$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$allowedRoot = [System.IO.Path]::GetFullPath(
    "C:\Users\User\Documents\TechAim software\dist"
)

if (-not $outputRoot.StartsWith($allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Portable output must remain inside $allowedRoot"
}

if (-not (Test-Path -LiteralPath $executable)) {
    throw "Application build was not found: $executable"
}

if (-not (Test-Path -LiteralPath (Join-Path $runtimeSeed "Qt6Core.dll"))) {
    throw "Verified portable Qt runtime was not found: $runtimeSeed"
}

if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
Get-ChildItem -LiteralPath $runtimeSeed -Filter "*.dll" -File |
    Copy-Item -Destination $outputRoot
Copy-Item -LiteralPath (Join-Path $runtimeSeed "plugins") `
    -Destination $outputRoot -Recurse
Copy-Item -LiteralPath (Join-Path $runtimeSeed "qml") `
    -Destination $outputRoot -Recurse
Copy-Item -LiteralPath (Join-Path $runtimeSeed "qt.conf") `
    -Destination $outputRoot
Copy-Item -LiteralPath $executable -Destination $outputRoot
Copy-Item -LiteralPath (Join-Path $projectDirectory "config.ini") -Destination $outputRoot

$requiredFiles = @(
    "TechAimTarget.exe",
    "Qt6Core.dll",
    "Qt6Gui.dll",
    "Qt6Qml.dll",
    "Qt6Quick.dll",
    "config.ini",
    "plugins\platforms\qwindows.dll",
    "libgcc_s_seh-1.dll",
    "libstdc++-6.dll",
    "libwinpthread-1.dll"
)

foreach ($requiredFile in $requiredFiles) {
    $requiredPath = Join-Path $outputRoot $requiredFile
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Portable build is incomplete. Missing: $requiredFile"
    }
}

$launcher = @"
@echo off
cd /d "%~dp0"
start "" "TechAimTarget.exe"
"@
Set-Content -LiteralPath (Join-Path $outputRoot "Start TechAim.cmd") `
    -Value $launcher -Encoding Ascii

Write-Host "Portable build created at: $outputRoot"

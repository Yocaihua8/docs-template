# test-doc-links.ps1
#
# Self-contained positive and negative fixtures for check-doc-links.ps1/.sh.
# Fixtures are created only under the system temporary directory.

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$powerShellChecker = Join-Path $PSScriptRoot "check-doc-links.ps1"
$bashChecker = Join-Path $PSScriptRoot "check-doc-links.sh"

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-ExitCode {
    param(
        [pscustomobject]$Result,
        [int]$Expected,
        [string]$Label
    )

    Assert-True ($Result.ExitCode -eq $Expected) "$Label expected exit $Expected but got $($Result.ExitCode).`n$($Result.Output)"
}

function Resolve-WorkingBash {
    $candidates = [System.Collections.Generic.List[string]]::new()

    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        foreach ($candidate in @(
            (Join-Path $env:ProgramFiles "Git\bin\bash.exe"),
            (Join-Path $env:ProgramFiles "Git\usr\bin\bash.exe"),
            $(if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} "Git\bin\bash.exe" })
        )) {
            if ($candidate -and (Test-Path -LiteralPath $candidate)) {
                $candidates.Add($candidate)
            }
        }
    }

    foreach ($command in @(Get-Command bash -All -CommandType Application -ErrorAction SilentlyContinue)) {
        if ($command.Source) {
            $candidates.Add($command.Source)
        }
    }

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($candidate in $candidates) {
        if (-not $seen.Add($candidate)) {
            continue
        }

        $probeOutput = @(& $candidate --noprofile --norc -c 'printf DOC_LINK_BASH_OK' 2>&1)
        $probeExit = $LASTEXITCODE
        if ($probeExit -eq 0 -and (($probeOutput | Out-String).Trim() -eq 'DOC_LINK_BASH_OK')) {
            return $candidate
        }
    }

    throw "No working Bash runtime was found. Git Bash was checked before PATH candidates on Windows."
}

function Invoke-PowerShellChecker {
    param(
        [string]$WorkingDirectory,
        [string[]]$Arguments
    )

    Push-Location $WorkingDirectory
    try {
        $output = @(& pwsh -NoProfile -File $powerShellChecker @Arguments 2>&1)
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output   = ($output | Out-String)
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-BashChecker {
    param(
        [string]$Bash,
        [string]$WorkingDirectory,
        [string]$ScriptPath,
        [string[]]$Arguments
    )

    Push-Location $WorkingDirectory
    try {
        $output = @(& $Bash --noprofile --norc $ScriptPath @Arguments 2>&1)
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output   = ($output | Out-String)
        }
    }
    finally {
        Pop-Location
    }
}

function Set-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

Assert-True (Test-Path -LiteralPath $powerShellChecker) "Missing PowerShell checker: $powerShellChecker"
Assert-True (Test-Path -LiteralPath $bashChecker) "Missing Bash checker: $bashChecker"
Assert-True ($null -ne (Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue)) "pwsh is required to run link checker tests."

$bash = Resolve-WorkingBash
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("docs-template-link-tests-" + [guid]::NewGuid().ToString("N"))
$tempRoot = [System.IO.Path]::GetFullPath($tempRoot)
Assert-True ($tempRoot.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) "Refusing to use a temporary directory outside the system temp root: $tempRoot"

try {
    $positiveRoot = Join-Path $tempRoot "positive"
    $negativeRoot = Join-Path $tempRoot "negative"
    New-Item -ItemType Directory -Path $positiveRoot, $negativeRoot -Force | Out-Null
    Copy-Item -LiteralPath $bashChecker -Destination (Join-Path $tempRoot "check-doc-links.sh")

    Set-Utf8File (Join-Path $positiveRoot "README.md") @'
# Project Home

[guide](docs/Guide.md "title")
[directory](docs/)
![logo](assets/logo.png)
[same file](#project-home)
[duplicate heading](#repeat-1)
[cross file](docs/Guide.md#install-guide)
[root relative](/docs/Guide.md#install-guide)
[explicit anchor](docs/Guide.md#manual-anchor)
[encoded path](docs/My%20Guide.md#space-guide)
[angle path](<docs/My Guide.md>)
[external](https://example.com/docs#section)
[mail](mailto:docs@example.com)
[query](?view=compact)
[reference link][guide-ref]

[guide-ref]: docs/Guide.md#install-guide

## Repeat

## Repeat

```markdown
[ignored fenced link](missing.md#not-there)
```
'@

    Set-Utf8File (Join-Path $positiveRoot "docs\Guide.md") @'
# Install Guide

<a id="manual-anchor"></a>

[home](../README.md#project-home)
'@

    Set-Utf8File (Join-Path $positiveRoot "docs\My Guide.md") @'
# Space Guide
'@

    New-Item -ItemType Directory -Path (Join-Path $positiveRoot "assets") -Force | Out-Null
    [System.IO.File]::WriteAllBytes((Join-Path $positiveRoot "assets\logo.png"), [byte[]](0x89, 0x50, 0x4E, 0x47))

    Set-Utf8File (Join-Path $negativeRoot "README.md") @'
# Broken Links

[missing file](docs/missing.md)
[missing anchor](docs/Guide.md#not-there)
[wrong case](docs/guide.md)
![missing image](assets/missing.png)
[anchor on image](assets/logo.png#not-an-anchor)
![directory as image](docs/)

```markdown
[ignored fenced link](also-missing.md)
```
'@

    Set-Utf8File (Join-Path $negativeRoot "docs\Guide.md") "# Existing Guide"
    New-Item -ItemType Directory -Path (Join-Path $negativeRoot "assets") -Force | Out-Null
    [System.IO.File]::WriteAllBytes((Join-Path $negativeRoot "assets\logo.png"), [byte[]](0x89, 0x50, 0x4E, 0x47))

    Write-Host "==> PowerShell checker accepts positive fixture with absolute, relative, default, and file targets"
    $psPositiveAbsolute = Invoke-PowerShellChecker $tempRoot @("-Target", $positiveRoot)
    Assert-ExitCode $psPositiveAbsolute 0 "PowerShell positive absolute target"
    $psPositiveRelative = Invoke-PowerShellChecker $tempRoot @("-Target", "positive")
    Assert-ExitCode $psPositiveRelative 0 "PowerShell positive relative target"
    $psPositiveDefault = Invoke-PowerShellChecker $positiveRoot @()
    Assert-ExitCode $psPositiveDefault 0 "PowerShell positive default target"
    $psPositiveFile = Invoke-PowerShellChecker $tempRoot @("-Target", (Join-Path $positiveRoot "README.md"))
    Assert-ExitCode $psPositiveFile 0 "PowerShell positive Markdown file target"

    Write-Host "==> Bash checker accepts the same positive fixture"
    $bashTempPathOutput = @()
    Push-Location $tempRoot
    try {
        $bashTempPathOutput = @(& $bash --noprofile --norc -c 'pwd -P' 2>&1)
        $bashTempPathExit = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    Assert-True ($bashTempPathExit -eq 0) "Unable to obtain Bash temporary path: $($bashTempPathOutput | Out-String)"
    $bashTempPath = ($bashTempPathOutput | Out-String).Trim()
    $bashPositiveAbsolute = Invoke-BashChecker $bash $tempRoot "./check-doc-links.sh" @("--target", "$bashTempPath/positive")
    Assert-ExitCode $bashPositiveAbsolute 0 "Bash positive absolute target"
    $bashPositiveRelative = Invoke-BashChecker $bash $tempRoot "./check-doc-links.sh" @("positive")
    Assert-ExitCode $bashPositiveRelative 0 "Bash positive relative target"
    $bashPositiveDefault = Invoke-BashChecker $bash $positiveRoot "../check-doc-links.sh" @()
    Assert-ExitCode $bashPositiveDefault 0 "Bash positive default target"
    $bashPositiveFile = Invoke-BashChecker $bash $tempRoot "./check-doc-links.sh" @("$bashTempPath/positive/README.md")
    Assert-ExitCode $bashPositiveFile 0 "Bash positive Markdown file target"

    Write-Host "==> both checkers reject missing files, images, anchors, case mismatches, and image directories"
    $psNegative = Invoke-PowerShellChecker $tempRoot @("-Target", $negativeRoot)
    $bashNegative = Invoke-BashChecker $bash $tempRoot "./check-doc-links.sh" @("negative")
    Assert-ExitCode $psNegative 1 "PowerShell negative fixture"
    Assert-ExitCode $bashNegative 1 "Bash negative fixture"
    Assert-True ($psNegative.Output -match 'FAIL found 6 invalid local Markdown link\(s\)') $psNegative.Output
    Assert-True ($bashNegative.Output -match 'FAIL found 6 invalid local Markdown link\(s\)') $bashNegative.Output
    foreach ($expected in @("docs/missing.md", "docs/Guide.md#not-there", "docs/guide.md", "assets/missing.png", "assets/logo.png#not-an-anchor", "docs/")) {
        Assert-True ($psNegative.Output.Contains($expected)) "PowerShell negative output did not mention $expected.`n$($psNegative.Output)"
        Assert-True ($bashNegative.Output.Contains($expected)) "Bash negative output did not mention $expected.`n$($bashNegative.Output)"
    }
    if ($IsWindows) {
        Assert-True ($psNegative.Output -match '\[case-mismatch\] docs/guide\.md') "PowerShell did not enforce exact link-path casing on Windows.`n$($psNegative.Output)"
        Assert-True ($bashNegative.Output -match '\[case-mismatch\] docs/guide\.md') "Bash did not enforce exact link-path casing on Windows.`n$($bashNegative.Output)"
    }

    Write-Host "==> both checkers return 2 for a missing target"
    $psMissing = Invoke-PowerShellChecker $tempRoot @("-Target", "does-not-exist")
    $bashMissing = Invoke-BashChecker $bash $tempRoot "./check-doc-links.sh" @("does-not-exist")
    Assert-ExitCode $psMissing 2 "PowerShell missing target"
    Assert-ExitCode $bashMissing 2 "Bash missing target"

    Write-Host "OK doc link checker tests passed with PowerShell/Bash parity."
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        if ($resolvedTempRoot.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

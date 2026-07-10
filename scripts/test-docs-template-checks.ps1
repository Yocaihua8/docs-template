# test-docs-template-checks.ps1
#
# Lightweight regression checks for this template repository's maintenance scripts
# and lifecycle documentation.

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-ContainsLine {
    param(
        [string]$Content,
        [string]$ExpectedLine,
        [string]$Message
    )

    $lines = $Content -split "\r?\n"
    Assert-True (@($lines | Where-Object { $_ -eq $ExpectedLine }).Count -gt 0) $Message
}

function Invoke-CapturedPwsh {
    param(
        [string[]]$Arguments,
        [string]$WorkingDirectory
    )

    Push-Location $WorkingDirectory
    try {
        $output = & pwsh @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Output   = ($output | Out-String)
    }
}

function Get-BashExecutable {
    $gitBash = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path -LiteralPath $gitBash) { return $gitBash }

    $bash = Get-Command bash -ErrorAction Stop
    return $bash.Source
}

function Convert-ToBashPath {
    param([string]$Path)
    return ([System.IO.Path]::GetFullPath($Path) -replace '\\', '/')
}

function Invoke-CapturedBash {
    param(
        [string[]]$Arguments,
        [string]$WorkingDirectory
    )

    Push-Location $WorkingDirectory
    try {
        $output = & $script:BashExecutable @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Output   = ($output | Out-String)
    }
}

function Invoke-PlaceholderPair {
    param(
        [string]$RepositoryRoot,
        [string]$Target,
        [ValidateSet("Consumer", "TemplateRepository")]
        [string]$Mode = "Consumer"
    )

    $powerShellArguments = @(
        "-NoProfile",
        "-File",
        (Join-Path $RepositoryRoot "scripts\check-placeholders.ps1"),
        "-Target",
        $Target,
        "-Mode",
        $Mode
    )
    $bashArguments = @((Convert-ToBashPath (Join-Path $RepositoryRoot "scripts\check-placeholders.sh")))
    if ($Mode -eq "TemplateRepository") {
        $bashArguments += @("--mode", "template")
    }
    $bashArguments += $Target

    [pscustomobject]@{
        PowerShell = Invoke-CapturedPwsh -Arguments $powerShellArguments -WorkingDirectory $RepositoryRoot
        Bash       = Invoke-CapturedBash -Arguments $bashArguments -WorkingDirectory $RepositoryRoot
    }
}

function Assert-PlaceholderPairExitCode {
    param(
        [pscustomobject]$Pair,
        [int]$ExpectedExitCode,
        [string]$Message
    )

    Assert-True ($Pair.PowerShell.ExitCode -eq $ExpectedExitCode) "$Message`nPowerShell:`n$($Pair.PowerShell.Output)"
    Assert-True ($Pair.Bash.ExitCode -eq $ExpectedExitCode) "$Message`nBash:`n$($Pair.Bash.Output)"
}

$script:BashExecutable = Get-BashExecutable

Write-Host "==> PowerShell and Bash placeholder checks support template repository mode"
$templatePlaceholder = Invoke-PlaceholderPair -RepositoryRoot $repoRoot -Target "." -Mode TemplateRepository
Assert-PlaceholderPairExitCode $templatePlaceholder 0 "Template repository placeholder checks should pass."

Write-Host "==> example project remains placeholder-clean in both implementations"
$examplePlaceholder = Invoke-PlaceholderPair -RepositoryRoot $repoRoot -Target "examples"
Assert-PlaceholderPairExitCode $examplePlaceholder 0 "Example placeholder checks should pass."

Write-Host "==> placeholder checks reject residual, malformed, missing-target, and CODEOWNERS markers consistently"
$placeholderTempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docs-template-placeholder-" + [guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "scripts") -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\check-placeholders.ps1") -Destination (Join-Path $placeholderTempRoot "scripts\check-placeholders.ps1")
    Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\check-placeholders.sh") -Destination (Join-Path $placeholderTempRoot "scripts\check-placeholders.sh")

    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\clean\docs") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\clean\docs\project.md") -Encoding UTF8 -Value "# Filled project"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\clean\docs\feature-template.md") -Encoding UTF8 -Value "# {{FEATURE_NAME}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\clean\ignored.txt") -Encoding UTF8 -Value "{{IGNORED_NON_DOCUMENT_FILE}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\unsupported.txt") -Encoding UTF8 -Value "{{UNSUPPORTED_SINGLE_FILE}}"

    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\unresolved\.github\ISSUE_TEMPLATE") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\unresolved\docs") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\unresolved\CHANGELOG.md") -Encoding UTF8 -Value "- {{REAL_CHANGE}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\unresolved\.github\ISSUE_TEMPLATE\config.yml") -Encoding UTF8 -Value 'url: "{{SUPPORT_URL}}"'
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\unresolved\docs\README.md") -Encoding UTF8 -Value @"
> Owner: {{OWNER}}
> Last Updated: {{CURRENT_DATE}}
Open marker: {{BROKEN
Close marker: BROKEN}}
"@

    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\codeowners\.github") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\codeowners\.github\CODEOWNERS") -Encoding UTF8 -Value "* @your-org/maintainers"

    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "docs") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "docs\valid.md") -Encoding UTF8 -Value "# {{PROJECT_NAME}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "docs\style-guide.md") -Encoding UTF8 -Value "Invalid syntax example: {{xxx}}"

    $cleanPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/clean"
    Assert-PlaceholderPairExitCode $cleanPair 0 "Filled consumer docs and authorized template files should pass."

    $unresolvedPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/unresolved"
    Assert-PlaceholderPairExitCode $unresolvedPair 1 "Consumer mode should reject every balanced and incomplete placeholder marker."
    foreach ($result in @($unresolvedPair.PowerShell, $unresolvedPair.Bash)) {
        foreach ($term in @("{{REAL_CHANGE}}", "{{SUPPORT_URL}}", "{{CURRENT_DATE}}", "incomplete double-brace marker")) {
            Assert-True ($result.Output -match [regex]::Escape($term)) $result.Output
        }
    }

    $codeownersPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/codeowners"
    Assert-PlaceholderPairExitCode $codeownersPair 1 "Consumer mode should reject @your-org/ in CODEOWNERS."
    Assert-True ($codeownersPair.PowerShell.Output -match "@your-org/") $codeownersPair.PowerShell.Output
    Assert-True ($codeownersPair.Bash.Output -match "@your-org/") $codeownersPair.Bash.Output

    $missingPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/missing"
    Assert-PlaceholderPairExitCode $missingPair 2 "A missing target should return exit code 2."

    $unsupportedPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/unsupported.txt"
    Assert-PlaceholderPairExitCode $unsupportedPair 2 "A single unsupported file target should return exit code 2."

    $invalidModePowerShell = Invoke-CapturedPwsh -WorkingDirectory $placeholderTempRoot -Arguments @(
        "-NoProfile", "-File", (Join-Path $placeholderTempRoot "scripts\check-placeholders.ps1"),
        "-Target", "cases/clean", "-Mode", "invalid"
    )
    $invalidModeBash = Invoke-CapturedBash -WorkingDirectory $placeholderTempRoot -Arguments @(
        (Convert-ToBashPath (Join-Path $placeholderTempRoot "scripts\check-placeholders.sh")),
        "--mode", "invalid", "cases/clean"
    )
    Assert-True ($invalidModePowerShell.ExitCode -eq 2) "PowerShell invalid mode should return 2.`n$($invalidModePowerShell.Output)"
    Assert-True ($invalidModeBash.ExitCode -eq 2) "Bash invalid mode should return 2.`n$($invalidModeBash.Output)"

    $secondTargetPowerShell = Invoke-CapturedPwsh -WorkingDirectory $placeholderTempRoot -Arguments @(
        "-NoProfile", "-File", (Join-Path $placeholderTempRoot "scripts\check-placeholders.ps1"),
        "cases/clean", "cases/unresolved"
    )
    $secondTargetBash = Invoke-CapturedBash -WorkingDirectory $placeholderTempRoot -Arguments @(
        (Convert-ToBashPath (Join-Path $placeholderTempRoot "scripts\check-placeholders.sh")),
        "cases/clean", "cases/unresolved"
    )
    Assert-True ($secondTargetPowerShell.ExitCode -eq 2) "PowerShell second positional target should return 2.`n$($secondTargetPowerShell.Output)"
    Assert-True ($secondTargetBash.ExitCode -eq 2) "Bash second positional target should return 2.`n$($secondTargetBash.Output)"

    $validTemplatePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "docs" -Mode TemplateRepository
    Assert-PlaceholderPairExitCode $validTemplatePair 0 "Template mode should allow valid tokens and the narrow style-guide syntax example."

    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "docs\invalid.md") -Encoding UTF8 -Value @"
Invalid token: {{bad-token}}
Incomplete token: {{BROKEN
"@
    $invalidTemplatePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "docs" -Mode TemplateRepository
    Assert-PlaceholderPairExitCode $invalidTemplatePair 1 "Template mode should reject invalid token syntax and incomplete markers."
    foreach ($result in @($invalidTemplatePair.PowerShell, $invalidTemplatePair.Bash)) {
        Assert-True ($result.Output -match "invalid placeholder token") $result.Output
        Assert-True ($result.Output -match "incomplete double-brace marker") $result.Output
    }

    Write-Host "==> consumer placeholder allowlist is derived exactly from state.tsv"
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot ".docs-template") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\state-positive\docs") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\state-replace\docs") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $placeholderTempRoot "cases\state-shadow\docs") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\state-positive\docs\feature-template.md") -Encoding UTF8 -Value "# {{PROJECT_NAME}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\state-replace\docs\feature-template.md") -Encoding UTF8 -Value "# {{FEATURE_NAME}}"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "cases\state-shadow\docs\feature-template.md") -Encoding UTF8 -Value "# {{PROJECT_NAME}}"

    $stateHeader = "schema_version`ttemplate_version`tdestination`tsource`tpacks`tplaceholder_policy`tsha256"
    $stateHash = (Get-FileHash -LiteralPath (Join-Path $placeholderTempRoot "cases\state-positive\docs\feature-template.md") -Algorithm SHA256).Hash.ToLowerInvariant()
    $syntacticHash = "0" * 64
    $validState = @(
        $stateHeader,
        "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore`tpreserve-template`t$stateHash",
        "1`t1.0.0`tcases/state-replace/docs/feature-template.md`tdocs/source.md`tcore`treplace`t$syntacticHash"
    ) -join "`n"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($validState + "`n")

    $statePositivePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-positive"
    Assert-PlaceholderPairExitCode $statePositivePair 0 "Consumer mode should allow the exact preserve-template destination from state.tsv."

    $stateReplacePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-replace"
    Assert-PlaceholderPairExitCode $stateReplacePair 1 "A replace destination must not be exempt even when its filename matches the legacy allowlist."
    $stateShadowPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-shadow"
    Assert-PlaceholderPairExitCode $stateShadowPair 1 "A preserve-template destination must not exempt the same basename at another path."

    Write-Host "==> consumer state rejects policy escalation and tampered integrity fields"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "docs\README.md") -Encoding UTF8 -Value "# {{PROJECT_NAME}}"
    $activeReadmeHash = (Get-FileHash -LiteralPath (Join-Path $placeholderTempRoot "docs\README.md") -Algorithm SHA256).Hash.ToLowerInvariant()
    $activeReadmeState = @(
        $stateHeader,
        "1`t1.0.0`tdocs/README.md`tdocs/README.md`tcore`tpreserve-template`t$activeReadmeHash"
    ) -join "`n"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($activeReadmeState + "`n")
    $activeReadmePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "docs/README.md"
    Assert-PlaceholderPairExitCode $activeReadmePair 2 "An active docs/README.md must never become exempt through a tampered preserve-template policy."
    foreach ($result in @($activeReadmePair.PowerShell, $activeReadmePair.Bash)) {
        Assert-True ($result.Output -match "unauthorized preserve-template destination") $result.Output
    }

    Set-Content -LiteralPath (Join-Path $placeholderTempRoot "docs\BACKLOG.md") -Encoding UTF8 -Value "# {{ITEM_TITLE}}"
    $activeBacklogHash = (Get-FileHash -LiteralPath (Join-Path $placeholderTempRoot "docs\BACKLOG.md") -Algorithm SHA256).Hash.ToLowerInvariant()
    $activeBacklogState = @(
        $stateHeader,
        "1`t1.0.0`tdocs/BACKLOG.md`tdocs/BACKLOG.md`ttracking`tpreserve-template`t$activeBacklogHash"
    ) -join "`n"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($activeBacklogState + "`n")
    $activeBacklogPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "docs/BACKLOG.md"
    Assert-PlaceholderPairExitCode $activeBacklogPair 2 "An active BACKLOG.md must never become exempt through a tampered preserve-template policy."
    foreach ($result in @($activeBacklogPair.PowerShell, $activeBacklogPair.Bash)) {
        Assert-True ($result.Output -match "unauthorized preserve-template destination") $result.Output
    }

    $invalidStateCases = @(
        @{
            Name = "preserve-template hash mismatch"
            Row = "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore`tpreserve-template`t$syntacticHash"
            Output = "sha256 mismatch"
        },
        @{
            Name = "unsafe source"
            Row = "1`t1.0.0`tcases/state-positive/docs/feature-template.md`t../source.md`tcore`tpreserve-template`t$stateHash"
            Output = "unsafe source"
        },
        @{
            Name = "invalid packs"
            Row = "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore;;tracking`tpreserve-template`t$stateHash"
            Output = "invalid packs"
        },
        @{
            Name = "invalid template semver"
            Row = "1`t1.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore`tpreserve-template`t$stateHash"
            Output = "invalid template_version"
        },
        @{
            Name = "invalid lowercase sha256 syntax"
            Row = "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore`tpreserve-template`t$('A' * 64)"
            Output = "invalid sha256"
        },
        @{
            Name = "state destination self-reference"
            Row = "1`t1.0.0`t.docs-template/state.tsv`tdocs/source.md`tcore`tnone`t$syntacticHash"
            Output = "cannot reference itself"
        },
        @{
            Name = "state source self-reference"
            Row = "1`t1.0.0`tcases/state-positive/docs/feature-template.md`t.docs-template/state.tsv`tcore`treplace`t$syntacticHash"
            Output = "cannot reference itself"
        },
        @{
            Name = "missing preserve-template destination"
            Row = "1`t1.0.0`tcases/state-positive/docs/missing-template.md`tdocs/source.md`tcore`tpreserve-template`t$syntacticHash"
            Output = "does not exist as a file"
        }
    )
    foreach ($case in $invalidStateCases) {
        $invalidState = @($stateHeader, $case.Row) -join "`n"
        Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($invalidState + "`n")
        $invalidStatePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-positive"
        Assert-PlaceholderPairExitCode $invalidStatePair 2 "Invalid state should be rejected: $($case.Name)"
        Assert-True ($invalidStatePair.PowerShell.Output -match [regex]::Escape($case.Output)) $invalidStatePair.PowerShell.Output
        Assert-True ($invalidStatePair.Bash.Output -match [regex]::Escape($case.Output)) $invalidStatePair.Bash.Output
    }

    $duplicateState = @(
        $stateHeader,
        "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/source.md`tcore`tpreserve-template`t$stateHash",
        "1`t1.0.0`tcases/state-positive/docs/feature-template.md`tdocs/other.md`ttracking`treplace`t$syntacticHash"
    ) -join "`n"
    Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($duplicateState + "`n")
    $duplicateStatePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-positive"
    Assert-PlaceholderPairExitCode $duplicateStatePair 2 "Duplicate state destinations should be rejected."
    Assert-True ($duplicateStatePair.PowerShell.Output -match "duplicate destination") $duplicateStatePair.PowerShell.Output
    Assert-True ($duplicateStatePair.Bash.Output -match "duplicate destination") $duplicateStatePair.Bash.Output

    $invalidStateDestinations = @(
        "../escape.md",
        "/absolute.md",
        "docs\windows-path.md",
        "docs/../escape.md"
    )
    foreach ($invalidDestination in $invalidStateDestinations) {
        $invalidState = @(
            $stateHeader,
            "1`t1.0.0`t$invalidDestination`tdocs/source.md`tcore`tpreserve-template`t$stateHash"
        ) -join "`n"
        Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value ($invalidState + "`n")
        $invalidStatePair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-positive"
        Assert-PlaceholderPairExitCode $invalidStatePair 2 "Unsafe state destination should be rejected: $invalidDestination"
        Assert-True ($invalidStatePair.PowerShell.Output -match "unsafe destination") $invalidStatePair.PowerShell.Output
        Assert-True ($invalidStatePair.Bash.Output -match "unsafe destination") $invalidStatePair.Bash.Output
    }

    Set-Content -LiteralPath (Join-Path $placeholderTempRoot ".docs-template\state.tsv") -Encoding UTF8 -NoNewline -Value "schema_version`tdestination`n"
    $invalidStateHeaderPair = Invoke-PlaceholderPair -RepositoryRoot $placeholderTempRoot -Target "cases/state-positive"
    Assert-PlaceholderPairExitCode $invalidStateHeaderPair 2 "An unexpected state.tsv header should be rejected."
}
finally {
    if (Test-Path -LiteralPath $placeholderTempRoot) {
        Remove-Item -LiteralPath $placeholderTempRoot -Recurse -Force
    }
}

Write-Host "==> consistency check rejects duplicate basename false positives"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docs-template-consistency-" + [guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "scripts") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "docs\foo") -Force | Out-Null

    Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\check-docs-consistency.ps1") `
        -Destination (Join-Path $tempRoot "scripts\check-docs-consistency.ps1")

    Set-Content -LiteralPath (Join-Path $tempRoot "README.md") -Encoding UTF8 -Value @"
# Minimal Template

This document mentions README.md, but not the nested docs/foo/README.md path.
"@

    Set-Content -LiteralPath (Join-Path $tempRoot "template-mapping.md") -Encoding UTF8 -Value @"
# Mapping

This document also mentions README.md only.
"@

    Set-Content -LiteralPath (Join-Path $tempRoot "docs\README.md") -Encoding UTF8 -Value @"
# Docs

## 2. Directory

- foo/
"@

    Set-Content -LiteralPath (Join-Path $tempRoot "docs\foo\README.md") -Encoding UTF8 -Value "# Foo"

    $consistency = Invoke-CapturedPwsh `
        -Arguments @("-NoProfile", "-File", (Join-Path $tempRoot "scripts\check-docs-consistency.ps1")) `
        -WorkingDirectory $tempRoot

    Assert-True ($consistency.ExitCode -ne 0) "Expected duplicate README.md basename to be rejected, but consistency check passed."
    Assert-True ($consistency.Output -match "docs/foo/README\.md") $consistency.Output
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host "==> current repository indexes stay synchronized"
$currentConsistency = Invoke-CapturedPwsh `
    -Arguments @("-NoProfile", "-File", (Join-Path $repoRoot "scripts\check-docs-consistency.ps1")) `
    -WorkingDirectory $repoRoot
Assert-True ($currentConsistency.ExitCode -eq 0) $currentConsistency.Output

if ($env:DOCS_TEMPLATE_SKIP_META_CHECKS -ne "1") {
    Write-Host "==> full template check rejects stale current-repository indexes"
    $fullCheckTempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docs-template-full-check-" + [guid]::NewGuid().ToString("N"))
    try {
        Copy-Item -LiteralPath $repoRoot -Destination $fullCheckTempRoot -Recurse -Force
        New-Item -ItemType Directory -Path (Join-Path $fullCheckTempRoot "docs\unindexed") -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $fullCheckTempRoot "docs\unindexed\new-doc.md") -Encoding UTF8 -Value "# New Doc"

        $previousSkipMeta = $env:DOCS_TEMPLATE_SKIP_META_CHECKS
        $env:DOCS_TEMPLATE_SKIP_META_CHECKS = "1"
        try {
            $staleIndexCheck = Invoke-CapturedPwsh `
                -Arguments @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Join-Path $fullCheckTempRoot "scripts\test-docs-template-checks.ps1")) `
                -WorkingDirectory $fullCheckTempRoot
        }
        finally {
            $env:DOCS_TEMPLATE_SKIP_META_CHECKS = $previousSkipMeta
        }

        Assert-True ($staleIndexCheck.ExitCode -ne 0) "Full docs-template checks should fail when a current docs file is missing from the indexes."
        Assert-True ($staleIndexCheck.Output -match "docs/unindexed/new-doc\.md|unindexed") $staleIndexCheck.Output
    }
    finally {
        if (Test-Path -LiteralPath $fullCheckTempRoot) {
            Remove-Item -LiteralPath $fullCheckTempRoot -Recurse -Force
        }
    }
}

Write-Host "==> BACKLOG template keeps placeholder rows only"
$backlog = Get-Content -LiteralPath (Join-Path $repoRoot "docs\BACKLOG.md") -Raw -Encoding UTF8
Assert-True ($backlog -notmatch "模板仓库维护提示|本模板仓库|真实任务台账") "docs/BACKLOG.md is distributable and should not contain template-repository maintenance-only instructions."
$backlogTemplateSection = [regex]::Match($backlog, "(?s)## 6\. 待办清单模板.*?## 7\. 已知问题模板").Value
Assert-True ($backlogTemplateSection.Length -gt 0) "docs/BACKLOG.md should include a backlog template section."
$backlogTemplateRows = @($backlogTemplateSection -split "\r?\n" | Where-Object { $_ -match "^\| B-\d{3} \|" })
Assert-True ($backlogTemplateRows.Count -gt 0) "docs/BACKLOG.md should include placeholder backlog rows."
foreach ($row in $backlogTemplateRows) {
    Assert-True (($row -match "\{\{ITEM_TITLE\}\}") -and ($row -match "\{\{DESCRIPTION\}\}")) "docs/BACKLOG.md is a template source file; backlog rows must remain placeholders: $row"
}

Write-Host "==> CHANGELOG template keeps placeholder entries only"
$changelog = Get-Content -LiteralPath (Join-Path $repoRoot "CHANGELOG.md") -Raw -Encoding UTF8
Assert-True ($changelog -notmatch "模板仓库维护提示|本模板仓库|真实变更日志") "CHANGELOG.md is distributable and should not contain template-repository maintenance-only instructions."
$unreleasedSection = [regex]::Match($changelog, "(?s)## \[Unreleased\].*?## \[\{\{RELEASE_VERSION\}\}\]").Value
Assert-True ($unreleasedSection.Length -gt 0) "CHANGELOG.md should include Unreleased and placeholder version sections."
$unreleasedRows = @($unreleasedSection -split "\r?\n" | Where-Object { $_ -match "^- " })
Assert-True ($unreleasedRows.Count -gt 0) "CHANGELOG.md should include placeholder rows under Unreleased."
foreach ($row in $unreleasedRows) {
    Assert-True ($row -match "\{\{") "CHANGELOG.md is a template source file; Unreleased rows must remain placeholders: $row"
}

Write-Host "==> devlog entries are grouped by year and month"
$devlogReadme = Get-Content -LiteralPath (Join-Path $repoRoot "docs\devlog\README.md") -Raw -Encoding UTF8
$plansReadme = Get-Content -LiteralPath (Join-Path $repoRoot "docs\plans\README.md") -Raw -Encoding UTF8
Assert-True ($devlogReadme -notmatch "devlog/archive|archive/") "docs/devlog/README.md still references devlog/archive."
Assert-True ($devlogReadme -match "docs/devlog/YYYY/MM/") "docs/devlog/README.md should require year/month grouping for log entries."
Assert-True ($devlogReadme -match "根目录只保留") "docs/devlog/README.md should make root-directory boundaries explicit."
Assert-True ($plansReadme -match "../devlog/YYYY/MM/") "docs/plans/README.md should point process records to ../devlog/YYYY/MM/."

Write-Host "==> AGENTS template requires low coupling and boundary preservation"
$agents = Get-Content -LiteralPath (Join-Path $repoRoot "AGENTS.md") -Raw -Encoding UTF8
Assert-True ($agents -notmatch "模板仓库自身维护提示|当前仓库是文档模板仓库|真实变更日志") "AGENTS.md is distributable and should not contain template-repository maintenance-only instructions."
Assert-True ($agents -match "低耦合") "AGENTS.md should explicitly require low coupling."
Assert-True ($agents -match "跨层直接依赖|跨模块直接依赖") "AGENTS.md should prohibit cross-layer or cross-module direct dependencies."
Assert-True ($agents -match "模块边界") "AGENTS.md should require preserving module boundaries."

Write-Host "==> template repository maintenance notes are kept outside distributable templates"
$maintenancePath = Join-Path $repoRoot "TEMPLATE_REPOSITORY_MAINTENANCE.md"
Assert-True (Test-Path -LiteralPath $maintenancePath) "TEMPLATE_REPOSITORY_MAINTENANCE.md should exist."
$maintenance = Get-Content -LiteralPath $maintenancePath -Raw -Encoding UTF8
foreach ($term in @("模板源文件边界", "docs/BACKLOG.md", "CHANGELOG.md", "docs/plans/plan-template.md", "AGENTS.md", "真实维护过程")) {
    Assert-True ($maintenance -match [regex]::Escape($term)) "TEMPLATE_REPOSITORY_MAINTENANCE.md should include: $term."
}

Write-Host "==> team collaboration template covers roles, RACI, flow, ownership, and review gates"
$teamCollaborationPath = Join-Path $repoRoot "docs\guides\team-collaboration.md"
Assert-True (Test-Path -LiteralPath $teamCollaborationPath) "docs/guides/team-collaboration.md should exist."
$teamCollaboration = Get-Content -LiteralPath $teamCollaborationPath -Raw -Encoding UTF8
foreach ($role in @("Owner", "Tech Lead", "Reviewer", "Dev", "QA", "Ops")) {
    Assert-True ($teamCollaboration -match [regex]::Escape($role)) "team-collaboration.md should include role: $role."
}
foreach ($term in @("RACI", "沟通渠道", "升级路径", "BACKLOG", "branch", "PR", "review", "merge", "release", "模块 Owner", "备份负责人", "关键风险")) {
    Assert-True ($teamCollaboration -match [regex]::Escape($term)) "team-collaboration.md should include: $term."
}

$branchConventions = Get-Content -LiteralPath (Join-Path $repoRoot "docs\guides\branch-conventions.md") -Raw -Encoding UTF8
foreach ($term in @("是否要求 PR", "启用 PR 流程时", "最少 Review", "已配置 CI 时必须通过", "Merge / Squash / Rebase", "分支过期", "冲突处理")) {
    Assert-True ($branchConventions -match [regex]::Escape($term)) "branch-conventions.md should include: $term."
}

$contributing = Get-Content -LiteralPath (Join-Path $repoRoot "CONTRIBUTING.md") -Raw -Encoding UTF8
foreach ($term in @("Definition of Ready", "Definition of Done", "Code Review 标准", "文件/模块锁定")) {
    Assert-True ($contributing -match [regex]::Escape($term)) "CONTRIBUTING.md should include: $term."
}

Write-Host "==> code comment policy distinguishes single-line, multi-line, and documentation comments"
foreach ($term in @("代码注释规范", "单行注释", "多行注释", "文档注释", "技术债", "BACKLOG")) {
    Assert-True ($contributing -match [regex]::Escape($term)) "CONTRIBUTING.md should include code comment policy term: $term."
}
Assert-True (($contributing -match "why") -or ($contributing -match "意图")) "CONTRIBUTING.md should explain that comments document why or intent."

foreach ($term in @("注释边界", "why", "constraint", "invariant", "技术债", "docs/BACKLOG.md")) {
    Assert-True ($agents -match [regex]::Escape($term)) "AGENTS.md should include AI comment boundary term: $term."
}

$styleGuide = Get-Content -LiteralPath (Join-Path $repoRoot "docs\style-guide.md") -Raw -Encoding UTF8
foreach ($term in @("代码块与注释示例", "单行注释", "多行注释", "文档注释")) {
    Assert-True ($styleGuide -match [regex]::Escape($term)) "docs/style-guide.md should include comment example term: $term."
}

Write-Host "==> GitHub PR gates cover parallel-development isolation"
$prTemplatePath = Join-Path $repoRoot ".github\pull_request_template.md"
Assert-True (Test-Path -LiteralPath $prTemplatePath) ".github/pull_request_template.md should exist."
$prTemplate = Get-Content -LiteralPath $prTemplatePath -Raw -Encoding UTF8
foreach ($term in @("影响范围", "文件/模块锁定", "并行冲突扫描", "模块 Owner", "默认 Reviewer", "高风险变更", "CODEOWNERS Review", "CI")) {
    Assert-True ($prTemplate -match [regex]::Escape($term)) "pull_request_template.md should include: $term."
}
foreach ($term in @("模板仓库维护变更", "BACKLOG / plan / CHANGELOG", "N/A")) {
    Assert-True ($prTemplate -match [regex]::Escape($term)) "pull_request_template.md should include template-repository maintenance exception: $term."
}

$codeownersPath = Join-Path $repoRoot ".github\CODEOWNERS"
Assert-True (Test-Path -LiteralPath $codeownersPath) ".github/CODEOWNERS should exist."
$codeowners = Get-Content -LiteralPath $codeownersPath -Raw -Encoding UTF8
foreach ($term in @("模块 Owner", "默认 Reviewer", "@your-org")) {
    Assert-True ($codeowners -match [regex]::Escape($term)) "CODEOWNERS should include: $term."
}

$workflowPath = Join-Path $repoRoot ".github\workflows\docs-template-checks.yml"
Assert-True (Test-Path -LiteralPath $workflowPath) ".github/workflows/docs-template-checks.yml should exist."
$workflow = Get-Content -LiteralPath $workflowPath -Raw -Encoding UTF8
foreach ($term in @("pull_request", "push", "pwsh", "scripts/test-docs-template-checks.ps1")) {
    Assert-True ($workflow -match [regex]::Escape($term)) "docs-template-checks.yml should include: $term."
}
foreach ($term in @("scripts/check-docs-consistency.ps1", "scripts/check-placeholders.ps1", "TemplateRepository")) {
    Assert-True ($workflow -match [regex]::Escape($term)) "docs-template-checks.yml should run current repository consistency and placeholder checks: $term."
}

foreach ($term in @("CODEOWNERS", "分支保护", "PR -> CODEOWNERS Review -> CI", "并行冲突扫描")) {
    Assert-True ($teamCollaboration -match [regex]::Escape($term)) "team-collaboration.md should include: $term."
}

foreach ($term in @("Require pull request reviews", "Require status checks", "Require review from Code Owners", "Restrict direct pushes")) {
    Assert-True ($branchConventions -match [regex]::Escape($term)) "branch-conventions.md should include: $term."
}

foreach ($term in @("并行冲突扫描", "高风险变更", "CODEOWNERS")) {
    Assert-True ($contributing -match [regex]::Escape($term)) "CONTRIBUTING.md should include: $term."
}

Write-Host "==> business quotation template covers pricing, schedule, and cost estimation"
$quotationPath = Join-Path $repoRoot "docs\business\quotation-estimate.md"
Assert-True (Test-Path -LiteralPath $quotationPath) "docs/business/quotation-estimate.md should exist."
$quotation = Get-Content -LiteralPath $quotationPath -Raw -Encoding UTF8
foreach ($term in @("报价预估", "工期预估", "范围内", "范围外", "工时", "成本", "风险缓冲", "报价汇总", "付款节点", "变更计费", "关键路径")) {
    Assert-True ($quotation -match [regex]::Escape($term)) "quotation-estimate.md should include: $term."
}

$rootReadme = Get-Content -LiteralPath (Join-Path $repoRoot "README.md") -Raw -Encoding UTF8
$docsReadme = Get-Content -LiteralPath (Join-Path $repoRoot "docs\README.md") -Raw -Encoding UTF8
$templateMapping = Get-Content -LiteralPath (Join-Path $repoRoot "template-mapping.md") -Raw -Encoding UTF8
foreach ($content in @($rootReadme, $docsReadme, $templateMapping)) {
    Assert-True ($content -match [regex]::Escape("business/quotation-estimate.md")) "README, docs README, and template-mapping should reference business/quotation-estimate.md."
}

Write-Host "==> real project practice templates cover integration, contract checks, migration, and postmortems"
$practiceTemplates = @(
    @{
        Path = "docs\guides\integration-guide-template.md"
        Terms = @("接入目标", "调用方", "环境", "认证", "请求示例", "响应示例", "错误码", "联调检查", "故障排查")
    },
    @{
        Path = "docs\design\frontend-backend-contract-check.md"
        Terms = @("前端行为", "现有接口", "缺失接口", "优先级", "修复建议", "相关文件索引")
    },
    @{
        Path = "docs\guides\technical-migration-plan.md"
        Terms = @("原系统盘点", "目标方案", "组件映射", "阶段计划", "工时预估", "风险点", "回滚策略")
    },
    @{
        Path = "docs\devlog\postmortem-template.md"
        Terms = @("背景", "时间线", "失败方案", "最终方案", "根因", "防复发", "BACKLOG", "ADR")
    }
)

foreach ($template in $practiceTemplates) {
    $path = Join-Path $repoRoot $template.Path
    Assert-True (Test-Path -LiteralPath $path) "$($template.Path) should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in $template.Terms) {
        Assert-True ($content -match [regex]::Escape($term)) "$($template.Path) should include: $term."
    }
}

$practiceTemplateRefs = @(
    "docs/guides/integration-guide-template.md",
    "docs/design/frontend-backend-contract-check.md",
    "docs/guides/technical-migration-plan.md",
    "docs/devlog/postmortem-template.md"
)

foreach ($content in @($rootReadme, $templateMapping)) {
    foreach ($ref in $practiceTemplateRefs) {
        Assert-True ($content -match [regex]::Escape($ref)) "README and template-mapping should reference $ref."
    }
}

foreach ($ref in $practiceTemplateRefs) {
    $docsRelativeRef = $ref -replace "^docs/", ""
    Assert-True (
        ($docsReadme -match [regex]::Escape($ref)) -or
        ($docsReadme -match [regex]::Escape($docsRelativeRef))
    ) "docs README should reference $ref or $docsRelativeRef."
}

$onboarding = Get-Content -LiteralPath (Join-Path $repoRoot "docs\guides\onboarding.md") -Raw -Encoding UTF8
foreach ($term in @("能跑起来", "能读懂", "第一个 PR")) {
    Assert-True ($onboarding -match [regex]::Escape($term)) "onboarding.md should include practical onboarding term: $term."
}

$apiSpec = Get-Content -LiteralPath (Join-Path $repoRoot "docs\design\api-spec.md") -Raw -Encoding UTF8
foreach ($term in @("integration-guide-template.md", "契约权威源", "面向调用方")) {
    Assert-True ($apiSpec -match [regex]::Escape($term)) "api-spec.md should explain integration guide boundary term: $term."
}

foreach ($term in @("postmortem-template.md", "问题复盘", "普通 devlog")) {
    Assert-True ($devlogReadme -match [regex]::Escape($term)) "docs/devlog/README.md should explain postmortem boundary term: $term."
}

Write-Host "==> AI-first frontend collaboration templates cover page contracts, component APIs, and merge conflict handling"
$frontendCollaborationTemplates = @(
    @{
        Path = "docs\design\page-module-contract.md"
        Terms = @("页面模块顺序", "data-*", "模块对应组件", "允许修改文件", "集成负责人专属文件", "页面验收测试口径", "公共样式")
    },
    @{
        Path = "docs\design\component-api-contract.md"
        Terms = @("组件职责", "props", "emits", "slots", "CSS class 前缀", "mock 数据依赖", "测试要求", "禁止 AI 擅自改变")
    },
    @{
        Path = "docs\guides\merge-conflict-playbook.md"
        Terms = @("integration 分支", "只读模拟合并", "结构冲突", "契约冲突", "样式冲突", "测试冲突", "退回对应负责人", "集成负责人不负责", '未启用 `frontend` pack')
    }
)

foreach ($template in $frontendCollaborationTemplates) {
    $path = Join-Path $repoRoot $template.Path
    Assert-True (Test-Path -LiteralPath $path) "$($template.Path) should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in $template.Terms) {
        Assert-True ($content -match [regex]::Escape($term)) "$($template.Path) should include: $term."
    }
}

foreach ($term in @("文件所有权", "集成负责人职责", "模块负责人职责", "缺陷退回", "AI 编程边界")) {
    Assert-True ($teamCollaboration -match [regex]::Escape($term)) "team-collaboration.md should include AI-first team contract term: $term."
}

foreach ($term in @("AI 修改说明", "提示词", "是否越过文件边界", "是否新增命名", "是否修改公共样式", "是否修改组件 API", "截图", "type-check", "build")) {
    Assert-True ($prTemplate -match [regex]::Escape($term)) "pull_request_template.md should include AI/front-end PR checklist term: $term."
}

$frontendCollaborationRefs = @(
    "docs/design/page-module-contract.md",
    "docs/design/component-api-contract.md",
    "docs/guides/merge-conflict-playbook.md"
)

foreach ($content in @($rootReadme, $templateMapping)) {
    foreach ($ref in $frontendCollaborationRefs) {
        Assert-True ($content -match [regex]::Escape($ref)) "README and template-mapping should reference $ref."
    }
}

foreach ($ref in $frontendCollaborationRefs) {
    $docsRelativeRef = $ref -replace "^docs/", ""
    Assert-True (
        ($docsReadme -match [regex]::Escape($ref)) -or
        ($docsReadme -match [regex]::Escape($docsRelativeRef))
    ) "docs README should reference $ref or $docsRelativeRef."
}

Write-Host "==> large GitHub project documentation patterns cover contributors, RFCs, migrations, troubleshooting, and support"
$largeProjectTemplates = @(
    @{
        Path = "docs\guides\contributor-guide-template.md"
        Terms = @("贡献类型", "环境准备", "Issue", "PR", "测试", "变更记录", "Review 期望")
    },
    @{
        Path = "docs\design\rfc-template.md"
        Terms = @("动机", "目标", "非目标", "详细设计", "替代方案", "迁移影响", "开放问题", "决策状态")
    },
    @{
        Path = "docs\guides\migration-guide-template.md"
        Terms = @("版本迁移", "旧版本", "新版本", "破坏性变更", "迁移步骤", "回滚", "验证清单", "technical-migration-plan.md")
    },
    @{
        Path = "docs\guides\troubleshooting.md"
        Terms = @("现象", "可能原因", "检查命令", "解决步骤", "升级路径", "收集信息")
    },
    @{
        Path = "docs\guides\support-policy.md"
        Terms = @("支持渠道", "响应级别", "不支持事项", "安全问题", "维护版本", "升级路径")
    }
)

foreach ($template in $largeProjectTemplates) {
    $path = Join-Path $repoRoot $template.Path
    Assert-True (Test-Path -LiteralPath $path) "$($template.Path) should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in $template.Terms) {
        Assert-True ($content -match [regex]::Escape($term)) "$($template.Path) should include: $term."
    }
}

$largeProjectRefs = @(
    "docs/guides/contributor-guide-template.md",
    "docs/design/rfc-template.md",
    "docs/guides/migration-guide-template.md",
    "docs/guides/troubleshooting.md",
    "docs/guides/support-policy.md"
)

foreach ($content in @($rootReadme, $templateMapping)) {
    foreach ($ref in $largeProjectRefs) {
        Assert-True ($content -match [regex]::Escape($ref)) "README and template-mapping should reference $ref."
    }
}

foreach ($ref in $largeProjectRefs) {
    $docsRelativeRef = $ref -replace "^docs/", ""
    Assert-True (
        ($docsReadme -match [regex]::Escape($ref)) -or
        ($docsReadme -match [regex]::Escape($docsRelativeRef))
    ) "docs README should reference $ref or $docsRelativeRef."
}

foreach ($term in @("contributor-guide-template.md", "贡献规范详情")) {
    Assert-True ($contributing -match [regex]::Escape($term)) "CONTRIBUTING.md should reference contributor guide template term: $term."
}

Write-Host "==> GitHub issue templates provide structured intake for bugs, features, and documentation"
$issueTemplateDir = Join-Path $repoRoot ".github\ISSUE_TEMPLATE"
Assert-True (Test-Path -LiteralPath $issueTemplateDir) ".github/ISSUE_TEMPLATE should exist."

$issueTemplateFiles = @(
    "bug_report.yml",
    "feature_request.yml",
    "documentation.yml"
)

foreach ($file in $issueTemplateFiles) {
    $path = Join-Path $issueTemplateDir $file
    Assert-True (Test-Path -LiteralPath $path) ".github/ISSUE_TEMPLATE/$file should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in @("name:", "description:", "labels:", "body:")) {
        Assert-True ($content -match [regex]::Escape($term)) ".github/ISSUE_TEMPLATE/$file should include: $term."
    }
}

$issueConfigPath = Join-Path $issueTemplateDir "config.yml"
Assert-True (Test-Path -LiteralPath $issueConfigPath) ".github/ISSUE_TEMPLATE/config.yml should exist."
$issueConfig = Get-Content -LiteralPath $issueConfigPath -Raw -Encoding UTF8
foreach ($term in @("blank_issues_enabled:", "Add contact_links only after real")) {
    Assert-True ($issueConfig -match [regex]::Escape($term)) ".github/ISSUE_TEMPLATE/config.yml should include: $term."
}
Assert-True ($issueConfig -notmatch "contact_links:\s*(?:\r?\n)[^#]") ".github/ISSUE_TEMPLATE/config.yml should not enable contact links before real URLs are confirmed."
Assert-True ($issueConfig -notmatch '\{\{(?:SECURITY_REPORT_URL|SUPPORT_CHANNEL_URL)\}\}') ".github/ISSUE_TEMPLATE/config.yml should not ship placeholder URLs."
Assert-True ($issueConfig -notmatch "https://example\.com/(security|support)") ".github/ISSUE_TEMPLATE/config.yml should not ship non-actionable example.com contact links."

Write-Host "==> commercial profile templates cover confirmation, change control, delivery, and acceptance"
$commercialTemplates = @(
    @{
        Path = "docs\business\customer-confirmation.md"
        Terms = @("已确认", "客户待提供", "待决策", "确认记录", "不是合同")
    },
    @{
        Path = "docs\business\change-request-template.md"
        Terms = @("变更请求", "影响评估", "费用", "验收", "双方确认")
    },
    @{
        Path = "docs\business\delivery-acceptance.md"
        Terms = @("交付物", "验收证据", "已知限制", "资产", "交接")
    }
)

foreach ($template in $commercialTemplates) {
    $path = Join-Path $repoRoot $template.Path
    Assert-True (Test-Path -LiteralPath $path) "$($template.Path) should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in $template.Terms) {
        Assert-True ($content -match [regex]::Escape($term)) "$($template.Path) should include: $term."
    }
}

Write-Host "==> open-source profile templates cover licensing, governance, conduct, contribution, and security"
$openSourceTemplates = @(
    @{
        Path = "docs\guides\license-selection.md"
        Terms = @("SPDX", "OSI", "LICENSE", "不提供法律意见", "第三方")
    },
    @{
        Path = "docs\guides\open-source-governance.md"
        Terms = @("维护者", "决策", "发布", "安全", "继任")
    },
    @{
        Path = "scaffold\templates\CODE_OF_CONDUCT.md"
        Terms = @("行为准则", "报告", "执行", "复核")
    },
    @{
        Path = "scaffold\templates\CONTRIBUTING.md"
        Terms = @("贡献指南", "Pull Request", "测试", "文档同步", "安全漏洞")
    }
)

foreach ($template in $openSourceTemplates) {
    $path = Join-Path $repoRoot $template.Path
    Assert-True (Test-Path -LiteralPath $path) "$($template.Path) should exist."
    $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($term in $template.Terms) {
        Assert-True ($content -match [regex]::Escape($term)) "$($template.Path) should include: $term."
    }
}

$licenseGuide = Get-Content -LiteralPath (Join-Path $repoRoot "docs\guides\license-selection.md") -Raw -Encoding UTF8
foreach ($officialUrl in @("https://opensource.org/licenses", "https://spdx.org/licenses/", "https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository")) {
    Assert-True ($licenseGuide -match [regex]::Escape($officialUrl)) "license-selection.md should link to official guidance: $officialUrl."
}
Assert-True ($rootReadme -match '不会伪造 `LICENSE`') "README.md should state that the open-source profile does not fabricate a license."

Write-Host "==> template repository CI and Consumer CI remain separate"
$consumerWorkflow = Get-Content -LiteralPath (Join-Path $repoRoot "scaffold\templates\docs-checks.yml") -Raw -Encoding UTF8
foreach ($term in @("permissions:", "contents: read", "check-placeholders.ps1", "check-doc-links.ps1", ".docs-template/strict-ci")) {
    Assert-True ($consumerWorkflow -match [regex]::Escape($term)) "Consumer CI should include: $term."
}
foreach ($forbidden in @("TemplateRepository", "test-init-docs.ps1", "test-docs-template-checks.ps1")) {
    Assert-True ($consumerWorkflow -notmatch [regex]::Escape($forbidden)) "Consumer CI must not include template repository operation: $forbidden."
}

$templateWorkflow = Get-Content -LiteralPath (Join-Path $repoRoot ".github\workflows\docs-template-checks.yml") -Raw -Encoding UTF8
foreach ($term in @("permissions:", "contents: read", "test-docs-template-checks.ps1", "test-init-docs.ps1", "test-doc-links.ps1", "windows-latest", "TemplateRepository")) {
    Assert-True ($templateWorkflow -match [regex]::Escape($term)) "Template repository CI should include: $term."
}

$fileManifest = @(Import-Csv -LiteralPath (Join-Path $repoRoot "scaffold\files.tsv") -Delimiter "`t" -Encoding UTF8)
foreach ($source in @("scripts/check-placeholders.ps1", "scripts/check-placeholders.sh", "scripts/check-doc-links.ps1", "scripts/check-doc-links.sh")) {
    $rows = @($fileManifest | Where-Object { $_.source -ceq $source -and ($_.packs -split ';') -ccontains "tooling" })
    Assert-True ($rows.Count -eq 1) "files.tsv should distribute exactly one tooling row for $source."
}
$consumerWorkflowRows = @($fileManifest | Where-Object { $_.source -ceq "scaffold/templates/docs-checks.yml" -and $_.destination -ceq ".github/workflows/docs-checks.yml" })
Assert-True ($consumerWorkflowRows.Count -eq 1) "files.tsv should distribute the Consumer workflow exactly once."
Assert-True ($consumerWorkflowRows[0].packs -ceq "github-ci") "Consumer CI must be an explicit github-ci asset, not part of a default tooling profile."
Assert-True (@($fileManifest | Where-Object { $_.source -ceq ".github/workflows/docs-template-checks.yml" }).Count -eq 0) "files.tsv must not distribute the template repository workflow."
foreach ($term in @("github-ci", "strict-ci", "不会自动安装托管平台 CI")) {
    Assert-True ($rootReadme -match [regex]::Escape($term)) "README.md should explain explicit Consumer CI activation: $term."
}

Write-Host "==> default profiles stay platform-neutral and capability-driven"
$profilesManifest = @(Import-Csv -LiteralPath (Join-Path $repoRoot "scaffold\profiles.tsv") -Delimiter "`t" -Encoding UTF8)
$profilesByName = @{}
foreach ($row in $profilesManifest) { $profilesByName[$row.profile] = @($row.packs -split ';') }
foreach ($profile in @("personal", "commercial", "open-source")) {
    Assert-True ($profilesByName.ContainsKey($profile)) "profiles.tsv is missing $profile."
}
Assert-True (($profilesByName.personal -join ';') -ceq "core") "Personal profile should remain the minimal core-only baseline."
foreach ($required in @("requirements", "commercial", "security", "tooling")) {
    Assert-True ($profilesByName.commercial -ccontains $required) "Commercial profile should include $required."
}
foreach ($required in @("open-source", "security", "tooling")) {
    Assert-True ($profilesByName.'open-source' -ccontains $required) "Open-source profile should include $required."
}
foreach ($profile in @("commercial", "open-source")) {
    foreach ($forbidden in @("architecture", "release-support", "team", "github", "github-ci")) {
        Assert-True ($profilesByName[$profile] -cnotcontains $forbidden) "$profile should not assume optional pack $forbidden."
    }
}

$securityRows = @($fileManifest | Where-Object { $_.destination -ceq "SECURITY.md" })
Assert-True ($securityRows.Count -eq 1 -and $securityRows[0].packs -ceq "open-source") "Public SECURITY.md should belong only to the open-source pack."
$workflowRows = @($fileManifest | Where-Object { $_.destination -ceq "docs/design/state-flow-and-acceptance.md" })
Assert-True ($workflowRows.Count -eq 1 -and $workflowRows[0].packs -ceq "workflow") "State-flow documentation should be an explicit workflow capability."
$frontendApiRows = @($fileManifest | Where-Object { $_.destination -ceq "docs/design/frontend-backend-contract-check.md" })
Assert-True ($frontendApiRows.Count -eq 1 -and $frontendApiRows[0].packs -ceq "frontend-api-contract") "Frontend/backend contract checks should require their dedicated composite pack."
foreach ($destination in @("docs/BACKLOG.md", "CHANGELOG.md")) {
    $rows = @($fileManifest | Where-Object { $_.destination -ceq $destination })
    Assert-True ($rows.Count -eq 1 -and $rows[0].mode -ceq "render" -and $rows[0].placeholder_policy -ceq "replace") "$destination should be an editable active document, not an immutable reusable template."
}

$profileSpecificRefs = @(
    "docs/business/customer-confirmation.md",
    "docs/business/change-request-template.md",
    "docs/business/delivery-acceptance.md",
    "docs/guides/license-selection.md",
    "docs/guides/open-source-governance.md"
)
foreach ($content in @($rootReadme, $templateMapping)) {
    foreach ($ref in $profileSpecificRefs) {
        Assert-True ($content -match [regex]::Escape($ref)) "README and template-mapping should reference $ref."
    }
}

Write-Host "==> examples remain illustrative and defer generated file sets to scaffold manifests"
$examplesReadme = Get-Content -LiteralPath (Join-Path $repoRoot "examples\README.md") -Raw -Encoding UTF8
foreach ($term in @("精简填写示例", "不代表任何 profile 的完整生成结果", "scaffold/")) {
    Assert-True ($examplesReadme -match [regex]::Escape($term)) "examples/README.md should include: $term."
}
Assert-True ($examplesReadme -notmatch "完整 8 份最低必填") "examples/README.md should not retain the obsolete eight-document baseline."

Write-Host "==> local assistant settings are not part of the distributable template"
$localClaudeSettings = Join-Path $repoRoot ".claude\settings.local.json"
Assert-True (-not (Test-Path -LiteralPath $localClaudeSettings)) ".claude/settings.local.json should not be kept in the distributable template."

$gitignorePath = Join-Path $repoRoot ".gitignore"
Assert-True (Test-Path -LiteralPath $gitignorePath) ".gitignore is required to keep local tool state out of the template."
$gitignore = Get-Content -LiteralPath $gitignorePath -Raw -Encoding UTF8
Assert-ContainsLine $gitignore ".claude/" ".gitignore should ignore .claude/."

Write-Host "OK docs-template checks passed."

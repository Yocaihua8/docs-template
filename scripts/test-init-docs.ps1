Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$pwsh = (Get-Command pwsh -ErrorAction Stop).Source
$powerShellScript = Join-Path $PSScriptRoot "init-docs.ps1"
$bashScript = Join-Path $PSScriptRoot "init-docs.sh"
$powerShellLinkChecker = Join-Path $PSScriptRoot "check-doc-links.ps1"
$bashLinkChecker = Join-Path $PSScriptRoot "check-doc-links.sh"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docs-template-init-tests-" + [guid]::NewGuid().ToString("N"))

function Invoke-CapturedProcess {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = $repoRoot
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) {
        $startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        Stdout = $stdoutTask.GetAwaiter().GetResult()
        Stderr = $stderrTask.GetAwaiter().GetResult()
        Output = $stdoutTask.GetAwaiter().GetResult() + $stderrTask.GetAwaiter().GetResult()
    }
}

function Invoke-InitializerPowerShell {
    param([string[]]$Arguments)
    return Invoke-CapturedProcess $pwsh (@("-NoProfile", "-File", $powerShellScript) + $Arguments)
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if (-not $Condition) { throw $Message }
}

function Get-RelativeFileHashes {
    param([string]$Root)

    $result = [ordered]@{}
    foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File | Sort-Object FullName) {
        $relative = [System.IO.Path]::GetRelativePath($Root, $file.FullName).Replace('\', '/')
        $result[$relative] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $result
}

function Get-BashPath {
    if ([System.OperatingSystem]::IsWindows()) {
        foreach ($candidate in @(
            "C:\Program Files\Git\bin\bash.exe",
            "C:\Program Files\Git\usr\bin\bash.exe"
        )) {
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    $command = Get-Command bash -ErrorAction SilentlyContinue
    if ($null -ne $command) { return $command.Source }
    return $null
}

function Convert-ToBashPathArgument {
    param([string]$Path)
    if ([System.OperatingSystem]::IsWindows()) { return $Path.Replace('\', '/') }
    return $Path
}

function Assert-PathInsideTestRoot {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$TestRoot
    )

    $pathFull = [System.IO.Path]::GetFullPath($Path).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $rootFull = [System.IO.Path]::GetFullPath($TestRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $comparison = if ([System.OperatingSystem]::IsWindows()) {
        [System.StringComparison]::OrdinalIgnoreCase
    } else {
        [System.StringComparison]::Ordinal
    }
    $rootPrefix = $rootFull + [System.IO.Path]::DirectorySeparatorChar
    Assert-True ($pathFull.StartsWith($rootPrefix, $comparison)) "Unsafe test fixture path outside the test root: $pathFull"
}

function New-TestDirectoryLink {
    param(
        [Parameter(Mandatory)]
        [string]$LinkPath,

        [Parameter(Mandatory)]
        [string]$TargetPath,

        [Parameter(Mandatory)]
        [string]$TestRoot
    )

    Assert-PathInsideTestRoot $LinkPath $TestRoot
    Assert-PathInsideTestRoot $TargetPath $TestRoot
    Assert-True (Test-Path -LiteralPath $TargetPath -PathType Container) "Link target does not exist: $TargetPath"
    New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($LinkPath)) -Force | Out-Null

    if ([System.OperatingSystem]::IsWindows()) {
        New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
    }
}

function Remove-TestDirectoryLink {
    param(
        [Parameter(Mandatory)]
        [string]$LinkPath,

        [Parameter(Mandatory)]
        [string]$TestRoot
    )

    Assert-PathInsideTestRoot $LinkPath $TestRoot
    $link = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
    if ($null -eq $link) { return }
    Assert-True (($link.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) "Refusing to remove a non-link test path: $LinkPath"
    Remove-Item -LiteralPath $LinkPath -Force
}

function Get-TestTreeSnapshot {
    param([string]$Root)

    $entries = [System.Collections.Generic.List[string]]::new()
    $pending = [System.Collections.Generic.Stack[string]]::new()
    $pending.Push([System.IO.Path]::GetFullPath($Root))
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        foreach ($item in Get-ChildItem -LiteralPath $directory -Force) {
            $relative = [System.IO.Path]::GetRelativePath($Root, $item.FullName).Replace('\', '/')
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                $entries.Add("L`t$relative`t$($item.Target -join ',')")
            } elseif ($item.PSIsContainer) {
                $entries.Add("D`t$relative")
                $pending.Push($item.FullName)
            } else {
                $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                $entries.Add("F`t$relative`t$hash")
            }
        }
    }

    return (($entries | Sort-Object) -join "`n")
}

function Invoke-LinkedParentSafetyCase {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("PowerShell", "Bash")]
        [string]$Runner,

        [Parameter(Mandatory)]
        [bool]$Nested,

        [AllowNull()]
        [string]$BashPath,

        [Parameter(Mandatory)]
        [string]$TestRoot
    )

    $shape = if ($Nested) { "nested" } else { "shallow" }
    $caseRoot = Join-Path $TestRoot ("linked-parent-{0}-{1}" -f $Runner.ToLowerInvariant(), $shape)
    $target = Join-Path $caseRoot "target"
    $outside = Join-Path $caseRoot "outside"
    Assert-PathInsideTestRoot $caseRoot $TestRoot
    New-Item -ItemType Directory -Path $target, $outside -Force | Out-Null

    if ($Nested) {
        New-Item -ItemType Directory -Path (Join-Path $target "docs") -Force | Out-Null
        $linkPath = Join-Path $target "docs\guides"
    } else {
        $linkPath = Join-Path $target "docs"
    }

    New-TestDirectoryLink $linkPath $outside $TestRoot
    $before = Get-TestTreeSnapshot $target
    try {
        if ($Runner -eq "PowerShell") {
            $result = Invoke-InitializerPowerShell @(
                "-Target", $target,
                "-ProjectName", "link-safety-demo",
                "-Owner", "maintainer",
                "-Profile", "personal",
                "-Date", "2026-07-10",
                "-SetValue", "PROJECT_DESCRIPTION=link safety regression"
            )
        } else {
            Assert-True ($null -ne $BashPath) "Bash path is required for the Bash safety case."
            $result = Invoke-CapturedProcess $BashPath @(
                (Convert-ToBashPathArgument $bashScript),
                "--target", (Convert-ToBashPathArgument $target),
                "--project-name", "link-safety-demo",
                "--owner", "maintainer",
                "--profile", "personal",
                "--date", "2026-07-10",
                "--set", "PROJECT_DESCRIPTION=link safety regression"
            )
        }

        Assert-True ($result.ExitCode -eq 2) "$Runner $shape linked-parent case returned $($result.ExitCode), expected 2.`n$($result.Output)"
        Assert-True ($result.Output -match "(?i)(symlink|reparse point|resolved target)") "$Runner $shape linked-parent case did not report a path-safety error.`n$($result.Output)"
        Assert-True (@(Get-ChildItem -LiteralPath $outside -Force).Count -eq 0) "$Runner $shape linked-parent case wrote outside the target."
        Assert-True ((Get-TestTreeSnapshot $target) -ceq $before) "$Runner $shape linked-parent case added or changed target entries."
    } finally {
        Remove-TestDirectoryLink $linkPath $TestRoot
        Assert-True (Test-Path -LiteralPath $outside -PathType Container) "$Runner $shape cleanup removed the external directory."
    }
}

function Invoke-LinkedAncestorSafetyCase {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("PowerShell", "Bash")]
        [string]$Runner,

        [AllowNull()]
        [string]$BashPath,

        [Parameter(Mandatory)]
        [string]$TestRoot
    )

    $caseRoot = Join-Path $TestRoot ("linked-ancestor-{0}" -f $Runner.ToLowerInvariant())
    $outside = Join-Path $caseRoot "outside"
    $linkPath = Join-Path $caseRoot "linked-parent"
    $target = Join-Path $linkPath "target"
    Assert-PathInsideTestRoot $caseRoot $TestRoot
    New-Item -ItemType Directory -Path $caseRoot, $outside -Force | Out-Null
    New-TestDirectoryLink $linkPath $outside $TestRoot
    $before = Get-TestTreeSnapshot $outside

    try {
        if ($Runner -eq "PowerShell") {
            $result = Invoke-InitializerPowerShell @(
                "-Target", $target,
                "-ProjectName", "ancestor-link-safety-demo",
                "-Owner", "maintainer",
                "-Profile", "personal",
                "-Date", "2026-07-10"
            )
        } else {
            Assert-True ($null -ne $BashPath) "Bash path is required for the Bash ancestor safety case."
            $result = Invoke-CapturedProcess $BashPath @(
                (Convert-ToBashPathArgument $bashScript),
                "--target", (Convert-ToBashPathArgument $target),
                "--project-name", "ancestor-link-safety-demo",
                "--owner", "maintainer",
                "--profile", "personal",
                "--date", "2026-07-10"
            )
        }

        Assert-True ($result.ExitCode -eq 2) "$Runner linked-ancestor case returned $($result.ExitCode), expected 2.`n$($result.Output)"
        Assert-True ($result.Output -match "(?i)(symlink|junction|reparse point)") "$Runner linked-ancestor case did not report a path-safety error.`n$($result.Output)"
        Assert-True ((Get-TestTreeSnapshot $outside) -ceq $before) "$Runner linked-ancestor case wrote through the linked ancestor."
        Assert-True (-not (Test-Path -LiteralPath $target)) "$Runner linked-ancestor case created the target through the linked ancestor."
    } finally {
        Remove-TestDirectoryLink $linkPath $TestRoot
        Assert-True (Test-Path -LiteralPath $outside -PathType Container) "$Runner linked-ancestor cleanup removed the external directory."
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $bash = Get-BashPath

    Write-Host "==> list profiles and packs"
    $profiles = Invoke-InitializerPowerShell @("-ListProfiles")
    Assert-True ($profiles.ExitCode -eq 0) $profiles.Output
    foreach ($name in @("personal", "commercial", "open-source")) {
        Assert-True ($profiles.Stdout -match "(?m)^$([regex]::Escape($name))`t") "Missing profile: $name"
    }
    $packs = Invoke-InitializerPowerShell @("-ListPacks")
    Assert-True ($packs.ExitCode -eq 0) $packs.Output
    foreach ($name in @("core", "tracking", "tooling", "api", "workflow", "github", "github-ci")) {
        Assert-True ($packs.Stdout -match "(?m)^$([regex]::Escape($name))`t") "Missing pack: $name"
    }

    Write-Host "==> dry-run writes nothing and all presets resolve"
    foreach ($profile in @("personal", "commercial", "open-source")) {
        $target = Join-Path $tempRoot "dry-$profile"
        $result = Invoke-InitializerPowerShell @(
            "-Target", $target,
            "-ProjectName", "示例项目",
            "-Owner", "张三",
            "-Profile", $profile,
            "-Date", "2026-07-10",
            "-DryRun"
        )
        Assert-True ($result.ExitCode -eq 0) $result.Output
        Assert-True (-not (Test-Path -LiteralPath $target)) "Dry-run created target: $target"
    }

    Write-Host "==> linked destination parents are rejected before all target writes"
    Invoke-LinkedParentSafetyCase -Runner PowerShell -Nested $false -BashPath $bash -TestRoot $tempRoot
    Invoke-LinkedParentSafetyCase -Runner PowerShell -Nested $true -BashPath $bash -TestRoot $tempRoot
    Invoke-LinkedAncestorSafetyCase -Runner PowerShell -BashPath $bash -TestRoot $tempRoot
    if ($null -ne $bash) {
        Invoke-LinkedParentSafetyCase -Runner Bash -Nested $false -BashPath $bash -TestRoot $tempRoot
        Invoke-LinkedParentSafetyCase -Runner Bash -Nested $true -BashPath $bash -TestRoot $tempRoot
        Invoke-LinkedAncestorSafetyCase -Runner Bash -BashPath $bash -TestRoot $tempRoot
    } else {
        Write-Host "SKIP Bash linked-parent safety: bash executable was not found."
    }

    Write-Host "==> invalid custom values and dependency exclusions fail before writes"
    $unknownTarget = Join-Path $tempRoot "unknown-set"
    $unknown = Invoke-InitializerPowerShell @(
        "-Target", $unknownTarget,
        "-ProjectName", "demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-Date", "2026-07-10",
        "-SetValue", "NOT_A_REAL_KEY=value"
    )
    Assert-True ($unknown.ExitCode -eq 2) $unknown.Output
    Assert-True (-not (Test-Path -LiteralPath $unknownTarget)) "Invalid --set wrote target files."

    foreach ($githubCase in @(
        @{ Name = "missing-github-owner"; SetValue = $null },
        @{ Name = "invalid-github-owner"; SetValue = "GITHUB_OWNER=maintainer" },
        @{ Name = "trailing-hyphen-github-owner"; SetValue = "GITHUB_OWNER=@bad-" },
        @{ Name = "double-hyphen-github-owner"; SetValue = "GITHUB_OWNER=@a--b" },
        @{ Name = "long-github-owner"; SetValue = ("GITHUB_OWNER=@" + ("a" * 40)) },
        @{ Name = "trailing-hyphen-github-team"; SetValue = "GITHUB_OWNER=@org/team-" }
    )) {
        $githubTarget = Join-Path $tempRoot $githubCase.Name
        $powerShellArguments = @(
            "-Target", $githubTarget,
            "-ProjectName", "github-demo",
            "-Owner", "maintainer",
            "-Profile", "personal",
            "-IncludePack", "github",
            "-Date", "2026-07-10"
        )
        if ($null -ne $githubCase.SetValue) { $powerShellArguments += @("-SetValue", $githubCase.SetValue) }
        $githubPowerShell = Invoke-InitializerPowerShell $powerShellArguments
        Assert-True ($githubPowerShell.ExitCode -eq 2) "$($githubCase.Name) PowerShell case should return 2.`n$($githubPowerShell.Output)"
        Assert-True (-not (Test-Path -LiteralPath $githubTarget)) "$($githubCase.Name) PowerShell case wrote target files."

        if ($null -ne $bash) {
            $bashArguments = @(
                (Convert-ToBashPathArgument $bashScript),
                "--target", (Convert-ToBashPathArgument $githubTarget),
                "--project-name", "github-demo",
                "--owner", "maintainer",
                "--profile", "personal",
                "--include-pack", "github",
                "--date", "2026-07-10"
            )
            if ($null -ne $githubCase.SetValue) { $bashArguments += @("--set", $githubCase.SetValue) }
            $githubBash = Invoke-CapturedProcess $bash $bashArguments
            Assert-True ($githubBash.ExitCode -eq 2) "$($githubCase.Name) Bash case should return 2.`n$($githubBash.Output)"
            Assert-True (-not (Test-Path -LiteralPath $githubTarget)) "$($githubCase.Name) Bash case wrote target files."
        }
    }

    $dependencyTarget = Join-Path $tempRoot "dependency-conflict"
    $dependency = Invoke-InitializerPowerShell @(
        "-Target", $dependencyTarget,
        "-ProjectName", "demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-IncludePack", "api",
        "-ExcludePack", "architecture",
        "-Date", "2026-07-10"
    )
    Assert-True ($dependency.ExitCode -eq 2) $dependency.Output
    Assert-True (-not (Test-Path -LiteralPath $dependencyTarget)) "Dependency failure wrote target files."

    Write-Host "==> require-complete rejects active-document placeholders"
    $completeTarget = Join-Path $tempRoot "require-complete"
    $complete = Invoke-InitializerPowerShell @(
        "-Target", $completeTarget,
        "-ProjectName", "demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-Date", "2026-07-10",
        "-RequireComplete"
    )
    Assert-True ($complete.ExitCode -eq 6) $complete.Output
    Assert-True (-not (Test-Path -LiteralPath $completeTarget)) "RequireComplete failure wrote target files."

    Write-Host "==> fail conflicts are zero-write"
    $conflictTarget = Join-Path $tempRoot "fail-conflict"
    $conflictDocs = Join-Path $conflictTarget "docs"
    $conflictReadme = Join-Path $conflictDocs "README.md"
    New-Item -ItemType Directory -Path $conflictDocs -Force | Out-Null
    Set-Content -LiteralPath $conflictReadme -Value "user-owned" -NoNewline -Encoding UTF8
    $conflict = Invoke-InitializerPowerShell @(
        "-Target", $conflictTarget,
        "-ProjectName", "demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-Date", "2026-07-10"
    )
    Assert-True ($conflict.ExitCode -eq 3) $conflict.Output
    $conflictFiles = @(Get-ChildItem -LiteralPath $conflictTarget -Recurse -File)
    Assert-True ($conflictFiles.Count -eq 1 -and $conflictFiles[0].FullName -ceq [System.IO.Path]::GetFullPath($conflictReadme)) "Conflict handling wrote additional files."
    Assert-True ((Get-Content -LiteralPath $conflictFiles[0].FullName -Raw) -eq "user-owned") "Conflict handling changed docs/README.md."

    Write-Host "==> preserve conflicts remain unmanaged and discoverable"
    $openSourceTarget = Join-Path $tempRoot "open-source"
    New-Item -ItemType Directory -Path $openSourceTarget | Out-Null
    Set-Content -LiteralPath (Join-Path $openSourceTarget ".gitignore") -Value "user-ignore" -NoNewline -Encoding UTF8
    $openSource = Invoke-InitializerPowerShell @(
        "-Target", $openSourceTarget,
        "-ProjectName", "community-demo",
        "-Owner", "maintainer",
        "-Profile", "open-source",
        "-Date", "2026-07-10",
        "-SetValue", "PROJECT_DESCRIPTION=社区示例项目"
    )
    Assert-True ($openSource.ExitCode -eq 0) $openSource.Output
    Assert-True ((Get-Content -LiteralPath (Join-Path $openSourceTarget ".gitignore") -Raw) -eq "user-ignore") "Preserve policy overwrote .gitignore."
    $state = Get-Content -LiteralPath (Join-Path $openSourceTarget ".docs-template\state.tsv") -Raw -Encoding UTF8
    $stateHeader = ($state -split "`r?`n", 2)[0]
    Assert-True ($stateHeader -ceq "schema_version`ttemplate_version`tdestination`tsource`tpacks`tplaceholder_policy`tsha256") "state.tsv does not use the required seven-column schema."
    Assert-True ($state -notmatch "(?m)^1`t1\.0\.0`t\.gitignore`t") "Preserved file must not appear in state.tsv."
    $rootReadme = Get-Content -LiteralPath (Join-Path $openSourceTarget "README.md") -Raw -Encoding UTF8
    Assert-True ($rootReadme -match "已启用项目入口") "Root README is missing its generated entry catalog."
    Assert-True ($rootReadme -match "CONTRIBUTING\.md") "Open-source entry catalog does not expose CONTRIBUTING.md."
    $docsReadme = Get-Content -LiteralPath (Join-Path $openSourceTarget "docs\README.md") -Raw -Encoding UTF8
    Assert-True ($docsReadme -match "已启用文档") "docs/README.md is missing its generated asset catalog."
    Assert-True ($docsReadme -match "可复用模板") "Generated asset catalog does not mark reusable templates."

    Write-Host "==> include-pack adds its assets"
    $includeTarget = Join-Path $tempRoot "include-api"
    $include = Invoke-InitializerPowerShell @(
        "-Target", $includeTarget,
        "-ProjectName", "api-demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-IncludePack", "api",
        "-Date", "2026-07-10"
    )
    Assert-True ($include.ExitCode -eq 0) $include.Output
    Assert-True (Test-Path -LiteralPath (Join-Path $includeTarget "docs\design\api-spec.md")) "api pack did not generate api-spec.md."

    Write-Host "==> tracking accepts and renders MILESTONE_DUE_DATE"
    $trackingTarget = Join-Path $tempRoot "tracking-milestone"
    $tracking = Invoke-InitializerPowerShell @(
        "-Target", $trackingTarget,
        "-ProjectName", "tracking-demo",
        "-Owner", "alice",
        "-Profile", "personal",
        "-IncludePack", "tracking",
        "-Date", "2026-07-10",
        "-SetValue", "MILESTONE_DUE_DATE=2026-12-31"
    )
    Assert-True ($tracking.ExitCode -eq 0) $tracking.Output
    $trackingBacklog = Get-Content -LiteralPath (Join-Path $trackingTarget "docs\BACKLOG.md") -Raw -Encoding UTF8
    Assert-True ($trackingBacklog -match [regex]::Escape("2026-12-31")) "Tracking pack did not accept and render MILESTONE_DUE_DATE in BACKLOG.md."

    Write-Host "==> identical rerun is unchanged"
    $parityPowerShellTarget = Join-Path $tempRoot "parity-composed-pwsh"
    $commonPowerShellArgs = @(
        "-Target", $parityPowerShellTarget,
        "-ProjectName", "跨平台示例",
        "-Owner", "维护者",
        "-Profile", "commercial,open-source",
        "-Date", "2026-07-10",
        "-SetValue", 'PROJECT_DESCRIPTION=R&D $5 \ demo'
    )
    $first = Invoke-InitializerPowerShell $commonPowerShellArgs
    Assert-True ($first.ExitCode -eq 0) $first.Output
    Assert-True (Test-Path -LiteralPath (Join-Path $parityPowerShellTarget "docs\business\delivery-acceptance.md")) "Combined profiles did not include commercial assets."
    Assert-True (Test-Path -LiteralPath (Join-Path $parityPowerShellTarget "CODE_OF_CONDUCT.md")) "Combined profiles did not include open-source assets."
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $parityPowerShellTarget "LICENSE"))) "Open-source profile must not fabricate a LICENSE file."
    $beforeRerun = Get-RelativeFileHashes $parityPowerShellTarget
    $second = Invoke-InitializerPowerShell $commonPowerShellArgs
    Assert-True ($second.ExitCode -eq 0) $second.Output
    Assert-True ($second.Stdout -match "\[UNCHANGED") "Identical rerun did not report UNCHANGED files."
    $afterRerun = Get-RelativeFileHashes $parityPowerShellTarget
    Assert-True (($beforeRerun | ConvertTo-Json -Compress) -ceq ($afterRerun | ConvertTo-Json -Compress)) "Identical rerun changed generated bytes."

    if ($null -ne $bash) {
        Write-Host "==> PowerShell and Bash generate identical bytes"
        $parityBashTarget = Join-Path $tempRoot "parity-composed-bash"
        $bashResult = Invoke-CapturedProcess $bash @(
            (Convert-ToBashPathArgument $bashScript),
            "--target", (Convert-ToBashPathArgument $parityBashTarget),
            "--project-name", "跨平台示例",
            "--owner", "维护者",
            "--profile", "commercial,open-source",
            "--date", "2026-07-10",
            "--set", 'PROJECT_DESCRIPTION=R&D $5 \ demo'
        )
        Assert-True ($bashResult.ExitCode -eq 0) $bashResult.Output
        $powerShellHashes = Get-RelativeFileHashes $parityPowerShellTarget
        $bashHashes = Get-RelativeFileHashes $parityBashTarget
        Assert-True (($powerShellHashes.Keys -join "`n") -ceq ($bashHashes.Keys -join "`n")) "PowerShell and Bash generated different file sets."
        foreach ($path in $powerShellHashes.Keys) {
            Assert-True ($powerShellHashes[$path] -ceq $bashHashes[$path]) "PowerShell and Bash bytes differ: $path"
        }
    } else {
        Write-Host "SKIP Bash parity: bash executable was not found."
    }

    Write-Host "==> generated personal, commercial, and open-source profiles have valid local links"
    $profileTargets = [ordered]@{
        personal = Join-Path $tempRoot "links-personal"
        commercial = Join-Path $tempRoot "links-commercial"
        "open-source" = $openSourceTarget
    }

    foreach ($profile in @("personal", "commercial")) {
        $profileResult = Invoke-InitializerPowerShell @(
            "-Target", $profileTargets[$profile],
            "-ProjectName", "$profile-link-demo",
            "-Owner", "maintainer",
            "-Profile", $profile,
            "-Date", "2026-07-10"
        )
        Assert-True ($profileResult.ExitCode -eq 0) $profileResult.Output
    }

    foreach ($profile in @("personal", "commercial", "open-source")) {
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $profileTargets[$profile] ".github\workflows\docs-checks.yml"))) "$profile profile should not install strict GitHub CI before active documents are complete."
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $profileTargets[$profile] ".github"))) "$profile profile should remain hosting-platform neutral by default."
    }
    foreach ($profile in @("commercial", "open-source")) {
        $target = $profileTargets[$profile]
        foreach ($relative in @("scripts\check-placeholders.ps1", "scripts\check-doc-links.ps1")) {
            Assert-True (Test-Path -LiteralPath (Join-Path $target $relative)) "$profile profile is missing Consumer tooling asset: $relative"
        }
    }

    Write-Host "==> github-ci is explicit and installs the strict Consumer workflow"
    $githubCiTarget = Join-Path $tempRoot "github-ci-opt-in"
    $githubCi = Invoke-InitializerPowerShell @(
        "-Target", $githubCiTarget,
        "-ProjectName", "github-demo",
        "-Owner", "maintainer",
        "-Profile", "personal",
        "-IncludePack", "github-ci",
        "-Date", "2026-07-10",
        "-SetValue", "GITHUB_OWNER=@maintainer"
    )
    Assert-True ($githubCi.ExitCode -eq 0) $githubCi.Output
    foreach ($relative in @(".github\pull_request_template.md", ".github\CODEOWNERS", ".github\ISSUE_TEMPLATE\bug_report.yml", ".github\workflows\docs-checks.yml")) {
        Assert-True (Test-Path -LiteralPath (Join-Path $githubCiTarget $relative)) "github-ci opt-in is missing: $relative"
    }
    $workflow = Get-Content -LiteralPath (Join-Path $githubCiTarget ".github\workflows\docs-checks.yml") -Raw -Encoding UTF8
    Assert-True ($workflow -match "check-placeholders\.ps1") "Opt-in Consumer CI does not run the placeholder gate."
    Assert-True ($workflow -match "check-doc-links\.ps1") "Opt-in Consumer CI does not run the local link gate."
    Assert-True ($workflow -match [regex]::Escape(".docs-template/strict-ci")) "Opt-in Consumer CI does not use staged strict placeholder activation."
    $profileTargets["github-ci"] = $githubCiTarget

    foreach ($entry in $profileTargets.GetEnumerator()) {
        $powerShellLinks = Invoke-CapturedProcess $pwsh @(
            "-NoProfile", "-File", $powerShellLinkChecker,
            "-Target", $entry.Value
        )
        Assert-True ($powerShellLinks.ExitCode -eq 0) "$($entry.Key) PowerShell link check failed.`n$($powerShellLinks.Output)"

        if ($null -ne $bash) {
            $bashLinks = Invoke-CapturedProcess $bash @(
                (Convert-ToBashPathArgument $bashLinkChecker),
                "--target", (Convert-ToBashPathArgument $entry.Value)
            )
            Assert-True ($bashLinks.ExitCode -eq 0) "$($entry.Key) Bash link check failed.`n$($bashLinks.Output)"
        }
    }

    Write-Host "OK init-docs regression and parity checks passed."
    exit 0
}
catch {
    [Console]::Error.WriteLine("FAIL $($_.Exception.Message)")
    exit 1
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

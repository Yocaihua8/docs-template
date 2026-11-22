[CmdletBinding()]
param(
    [string]$Target,
    [string]$ProjectName,
    [string]$Owner,
    [string]$Date,
    [string[]]$Profile = @(),
    [string[]]$IncludePack = @(),
    [string[]]$ExcludePack = @(),
    [string[]]$SetValue = @(),
    [switch]$DryRun,
    [switch]$RequireComplete,
    [switch]$ListProfiles,
    [switch]$ListPacks,
    [switch]$ListPlaceholders,
    [switch]$Tsv,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/template-hash.ps1")

function Stop-InitDocs {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 255)]
        [int]$ExitCode,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $exception = [System.Exception]::new($Message)
    $exception.Data["InitDocsExitCode"] = $ExitCode
    throw $exception
}

function Show-Usage {
    @"
项目文档脚手架初始化器（PowerShell）

核心概念：
  Profile   常见项目起点（personal / commercial / open-source）
  Pack      按需叠加的文档能力包（如 architecture / api / data / frontend / team / github）
  Preserve  目标目录已有 README/配置等文件时自动保留，不覆盖

常用命令：
  # 1. 查看可用起点、能力包和可填字段
  pwsh -NoProfile -File scripts/init-docs.ps1 -ListProfiles
  pwsh -NoProfile -File scripts/init-docs.ps1 -ListPacks
  pwsh -NoProfile -File scripts/init-docs.ps1 -ListPlaceholders [-Profile personal] [-IncludePack github]

  # 2. 先预览（不写入任何文件），确认后再去掉 -DryRun 正式生成
  pwsh -NoProfile -File scripts/init-docs.ps1 \
    -Target <directory> -ProjectName <name> -Owner <owner> \
    -Profile <personal|commercial|open-source>[,<profile>...] \
    [-IncludePack <pack>[,<pack>...]] [-ExcludePack <pack>[,<pack>...]] \
    [-Date YYYY-MM-DD] [-SetValue KEY=VALUE] [-DryRun] [-RequireComplete]

说明：
  -SetValue         传入项目元数据或所选活动文档中的正文字段；需传多项时可直接在 PowerShell 中运行
                    ./scripts/init-docs.ps1 -SetValue @('K1=V1','K2=V2')
  -RequireComplete  活动文档仍有未填占位符时返回退出码 6 且不写入任何文件
  -Tsv              配合 -List* 使用时输出原始 Tab 分隔文本，便于脚本解析

安全边界：
  初始化器绝不静默覆盖已有不同文件，也不提供 force 或原地升级模式。
  后续需追加 pack 时，请生成到新的临时目录再通过 Git diff 人工合并。

退出码：
  0  成功 / 预览通过          2  参数或路径安全错误      3  存在文件冲突（零写入）
  4  脚手架清单损坏           5  文件系统读写错误        6  -RequireComplete 检测到未填占位符
"@ | Write-Host
}

function Import-StrictTsv {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string[]]$ExpectedHeaders
    )

    if (-not [System.IO.File]::Exists($Path)) {
        Stop-InitDocs 4 "Manifest file does not exist: $Path"
    }

    $lines = [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)
    if ($lines.Count -lt 1) {
        Stop-InitDocs 4 "Manifest file is empty: $Path"
    }

    $headerLine = $lines[0].TrimStart([char]0xFEFF).TrimEnd("`r")
    $headers = $headerLine.Split([char]9)
    if ($headers.Count -ne $ExpectedHeaders.Count) {
        Stop-InitDocs 4 "Manifest header has the wrong number of columns: $Path"
    }

    for ($index = 0; $index -lt $ExpectedHeaders.Count; $index++) {
        if ($headers[$index] -cne $ExpectedHeaders[$index]) {
            Stop-InitDocs 4 "Manifest header mismatch in $Path. Expected '$($ExpectedHeaders -join "`t")'."
        }
    }

    $rows = [System.Collections.Generic.List[object]]::new()
    for ($lineNumber = 2; $lineNumber -le $lines.Count; $lineNumber++) {
        $line = $lines[$lineNumber - 1].TrimEnd("`r")
        if ([string]::IsNullOrWhiteSpace($line)) {
            Stop-InitDocs 4 "Blank manifest row in ${Path}:$lineNumber"
        }

        $fields = $line.Split([char]9)
        if ($fields.Count -ne $ExpectedHeaders.Count) {
            Stop-InitDocs 4 "Manifest row has $($fields.Count) columns instead of $($ExpectedHeaders.Count) in ${Path}:$lineNumber"
        }

        $row = [ordered]@{}
        for ($fieldIndex = 0; $fieldIndex -lt $headers.Count; $fieldIndex++) {
            $row[$headers[$fieldIndex]] = $fields[$fieldIndex]
        }
        $row["__line"] = $lineNumber
        $rows.Add([pscustomobject]$row)
    }

    return $rows.ToArray()
}

function Expand-ArgumentValues {
    param([string[]]$Values)

    $expanded = [System.Collections.Generic.List[string]]::new()
    foreach ($value in $Values) {
        if ($null -eq $value) { continue }
        foreach ($item in ($value -split "[;,]")) {
            $trimmed = $item.Trim()
            if ($trimmed.Length -gt 0) {
                $expanded.Add($trimmed.ToLowerInvariant())
            }
        }
    }
    return $expanded.ToArray()
}

function Split-ManifestList {
    param([string]$Value)

    if ([string]::IsNullOrEmpty($Value)) { return @() }
    return @($Value.Split([char]';') | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_.Length -gt 0 })
}

function Test-SetIntersects {
    param(
        [string[]]$Items,
        [System.Collections.Generic.HashSet[string]]$Set,
        [switch]$WildcardMatches
    )

    if ($Items.Count -eq 0) { return $true }
    foreach ($item in $Items) {
        if ($WildcardMatches -and $item -eq "*") { return $true }
        if ($Set.Contains($item)) { return $true }
    }
    return $false
}

function Test-SafeRelativePath {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value.Contains('\')) { return $false }
    if ($Value.StartsWith('/') -or $Value.EndsWith('/')) { return $false }
    if ($Value.Contains('//') -or $Value.Contains(':')) { return $false }
    if ([System.IO.Path]::IsPathRooted($Value)) { return $false }
    foreach ($segment in $Value.Split([char]'/')) {
        if ($segment -eq "" -or $segment -eq "." -or $segment -eq "..") { return $false }
    }
    return $true
}

function Get-ComparablePath {
    param([string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $rootPath = [System.IO.Path]::GetPathRoot($fullPath)
    $trimmed = $fullPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    if ([string]::IsNullOrEmpty($trimmed)) { return $rootPath }
    if (-not [string]::IsNullOrEmpty($rootPath) -and $trimmed -eq $rootPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)) {
        return $rootPath
    }
    return $trimmed
}

function Test-PathWithin {
    param(
        [string]$Candidate,
        [string]$Parent
    )

    $comparison = if ([System.OperatingSystem]::IsWindows()) {
        [System.StringComparison]::OrdinalIgnoreCase
    } else {
        [System.StringComparison]::Ordinal
    }
    $parentWithSeparator = $Parent + [System.IO.Path]::DirectorySeparatorChar
    return $Candidate.StartsWith($parentWithSeparator, $comparison)
}

function Assert-NoReparsePoint {
    param([string]$ExistingPath)

    $current = [System.IO.DirectoryInfo]::new($ExistingPath)
    while ($null -ne $current) {
        if (($current.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            Stop-InitDocs 2 "Target path contains a symlink or reparse point: $($current.FullName)"
        }
        $current = $current.Parent
    }
}

function Assert-SafeTargetDestination {
    param(
        [Parameter(Mandatory)]
        [string]$TargetRoot,

        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $targetRootFull = Get-ComparablePath $TargetRoot
    $destinationFull = Get-ComparablePath (Join-Path $targetRootFull ($RelativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar))
    if (-not (Test-PathWithin $destinationFull $targetRootFull)) {
        Stop-InitDocs 2 "Target destination escapes the target root: $RelativePath"
    }

    $comparison = if ([System.OperatingSystem]::IsWindows()) {
        [System.StringComparison]::OrdinalIgnoreCase
    } else {
        [System.StringComparison]::Ordinal
    }

    $current = $targetRootFull
    $segments = $RelativePath.Split([char]'/')
    for ($index = -1; $index -lt $segments.Count; $index++) {
        if ($index -ge 0) {
            $current = Join-Path $current $segments[$index]
        }

        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) {
            break
        }
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            Stop-InitDocs 2 "Target destination crosses a symlink or reparse point: $RelativePath ($current)"
        }

        $resolved = Get-ComparablePath $item.FullName
        if (-not $resolved.Equals($targetRootFull, $comparison) -and -not (Test-PathWithin $resolved $targetRootFull)) {
            Stop-InitDocs 2 "Resolved target destination escapes the target root: $RelativePath ($resolved)"
        }

        if ($index -lt ($segments.Count - 1) -and -not $item.PSIsContainer) {
            break
        }
    }
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Write-Utf8LfFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $normalized = $Content.Replace("`r`n", "`n").Replace("`r", "`n")
    if (-not $normalized.EndsWith("`n", [System.StringComparison]::Ordinal)) {
        $normalized += "`n"
    }
    [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($false))
}

function Render-Template {
    param(
        [string]$Content,
        [System.Collections.Generic.Dictionary[string, string]]$Replacements
    )

    return [System.Text.RegularExpressions.Regex]::Replace(
        $Content,
        '\{\{[^{}\r\n]+\}\}',
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            if ($Replacements.ContainsKey($match.Value)) {
                return $Replacements[$match.Value]
            }
            return $match.Value
        }
    )
}

function Add-UniqueValue {
    param(
        [System.Collections.Generic.HashSet[string]]$Set,
        [string]$Value
    )
    [void]$Set.Add($Value.ToLowerInvariant())
}

$temporaryRoot = $null
$createdTarget = $false
$createdFiles = [System.Collections.Generic.List[string]]::new()

try {
    $repoRoot = Get-ComparablePath (Join-Path $PSScriptRoot "..")
    $scaffoldRoot = Join-Path $repoRoot "scaffold"

    $profileRows = Import-StrictTsv (Join-Path $scaffoldRoot "profiles.tsv") @("profile", "packs", "description")
    $packRows = Import-StrictTsv (Join-Path $scaffoldRoot "packs.tsv") @("pack", "requires", "description")
    $fileRows = Import-StrictTsv (Join-Path $scaffoldRoot "files.tsv") @("source", "destination", "packs", "mode", "conflict", "placeholder_policy", "index_group", "description")
    $placeholderRows = Import-StrictTsv (Join-Path $scaffoldRoot "placeholders.tsv") @("token", "required", "packs", "profiles", "default", "tbd", "description")

    $profilesByName = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $profileRows) {
        $name = $row.profile.Trim().ToLowerInvariant()
        if ($name -notmatch '^[a-z0-9][a-z0-9-]*$' -or $profilesByName.ContainsKey($name)) {
            Stop-InitDocs 4 "Invalid or duplicate profile '$($row.profile)' in profiles.tsv:$($row.__line)"
        }
        $profilesByName.Add($name, $row)
    }

    $packsByName = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $packRows) {
        $name = $row.pack.Trim().ToLowerInvariant()
        if ($name -notmatch '^[a-z0-9][a-z0-9-]*$' -or $packsByName.ContainsKey($name)) {
            Stop-InitDocs 4 "Invalid or duplicate pack '$($row.pack)' in packs.tsv:$($row.__line)"
        }
        $packsByName.Add($name, $row)
    }

    if ($Help) {
        Show-Usage
        exit 0
    }
    if ($ListProfiles) {
        if ($Tsv) {
            foreach ($name in @($profilesByName.Keys | Sort-Object)) {
                $row = $profilesByName[$name]
                Write-Host "$name`t$($row.packs)`t$($row.description)"
            }
        } else {
            Write-Host ("{0,-14} {1,-58} {2}" -f "PROFILE", "DEFAULT PACKS", "DESCRIPTION")
            Write-Host ("{0,-14} {1,-58} {2}" -f ("-" * 14), ("-" * 58), ("-" * 20))
            foreach ($name in @($profilesByName.Keys | Sort-Object)) {
                $row = $profilesByName[$name]
                Write-Host ("{0,-14} {1,-58} {2}" -f $name, $row.packs, $row.description)
            }
        }
        exit 0
    }
    if ($ListPacks) {
        if ($Tsv) {
            foreach ($name in @($packsByName.Keys | Sort-Object)) {
                $row = $packsByName[$name]
                Write-Host "$name`t$($row.requires)`t$($row.description)"
            }
        } else {
            Write-Host ("{0,-24} {1,-26} {2}" -f "PACK", "REQUIRES", "DESCRIPTION")
            Write-Host ("{0,-24} {1,-26} {2}" -f ("-" * 24), ("-" * 26), ("-" * 20))
            foreach ($name in @($packsByName.Keys | Sort-Object)) {
                $row = $packsByName[$name]
                $req = if ([string]::IsNullOrWhiteSpace($row.requires)) { "-" } else { $row.requires }
                Write-Host ("{0,-24} {1,-26} {2}" -f $name, $req, $row.description)
            }
        }
        exit 0
    }
    if ($ListPlaceholders) {
        $filterPacks = $null
        $requestedProfiles = @(Expand-ArgumentValues $Profile)
        $requestedIncludes = @(Expand-ArgumentValues $IncludePack)
        $requestedExcludes = @(Expand-ArgumentValues $ExcludePack)
        if ($requestedProfiles.Count -gt 0 -or $requestedIncludes.Count -gt 0) {
            $filterPacks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            [void]$filterPacks.Add("core")
            foreach ($profileName in $requestedProfiles) {
                $key = $profileName.ToLowerInvariant()
                if (-not $profilesByName.ContainsKey($key)) { Stop-InitDocs 2 "Unknown profile: $profileName" }
                foreach ($packName in @(Split-ManifestList $profilesByName[$key].packs)) { [void]$filterPacks.Add($packName) }
            }
            foreach ($packName in $requestedIncludes) {
                $key = $packName.ToLowerInvariant()
                if (-not $packsByName.ContainsKey($key)) { Stop-InitDocs 2 "Unknown pack in -IncludePack: $packName" }
                [void]$filterPacks.Add($key)
            }
            $expanded = $true
            while ($expanded) {
                $expanded = $false
                foreach ($packName in @($filterPacks)) {
                    foreach ($requiredPack in @(Split-ManifestList $packsByName[$packName].requires)) {
                        if ($filterPacks.Add($requiredPack)) { $expanded = $true }
                    }
                }
            }
            foreach ($packName in $requestedExcludes) { [void]$filterPacks.Remove($packName.ToLowerInvariant()) }
        }
        $rowsToShow = @($placeholderRows | Where-Object {
            if ($null -eq $filterPacks) { return $true }
            $rowPacks = @(Split-ManifestList $_.packs)
            foreach ($p in $rowPacks) { if ($filterPacks.Contains($p)) { return $true } }
            return $false
        } | Sort-Object token)
        if ($Tsv) {
            foreach ($row in $rowsToShow) {
                Write-Host "$($row.token)`t$($row.required)`t$($row.packs)`t$($row.default)`t$($row.tbd)`t$($row.description)"
            }
        } else {
            Write-Host ("{0,-30} {1,-8} {2,-26} {3,-12} {4}" -f "TOKEN", "REQUIRED", "PACKS", "FALLBACK", "DESCRIPTION")
            Write-Host ("{0,-30} {1,-8} {2,-26} {3,-12} {4}" -f ("-" * 30), ("-" * 8), ("-" * 26), ("-" * 12), ("-" * 20))
            foreach ($row in $rowsToShow) {
                $fallback = if (-not [string]::IsNullOrWhiteSpace($row.default)) { $row.default } elseif (-not [string]::IsNullOrWhiteSpace($row.tbd)) { $row.tbd } else { "-" }
                Write-Host ("{0,-30} {1,-8} {2,-26} {3,-12} {4}" -f $row.token, $row.required, $row.packs, $fallback, $row.description)
            }
        }
        exit 0
    }

    if ([string]::IsNullOrWhiteSpace($Target)) { Stop-InitDocs 2 "-Target is required." }
    if ([string]::IsNullOrWhiteSpace($ProjectName)) { Stop-InitDocs 2 "-ProjectName is required." }
    if ([string]::IsNullOrWhiteSpace($Owner)) { Stop-InitDocs 2 "-Owner is required." }
    if ($ProjectName.IndexOfAny(@([char]0, [char]9, [char]10, [char]13)) -ge 0) { Stop-InitDocs 2 "ProjectName contains a forbidden control character." }
    if ($Owner.IndexOfAny(@([char]0, [char]9, [char]10, [char]13)) -ge 0) { Stop-InitDocs 2 "Owner contains a forbidden control character." }

    if ([string]::IsNullOrWhiteSpace($Date)) {
        $Date = [System.DateTimeOffset]::Now.ToString("yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
    }
    $parsedDate = [System.DateTime]::MinValue
    if (-not [System.DateTime]::TryParseExact($Date, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)) {
        Stop-InitDocs 2 "Date must be a real calendar date in YYYY-MM-DD format."
    }

    $selectedProfileNames = @(Expand-ArgumentValues $Profile)
    if ($selectedProfileNames.Count -eq 0) { Stop-InitDocs 2 "At least one -Profile is required." }
    $selectedProfiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $selectedProfileNames) {
        if (-not $profilesByName.ContainsKey($name)) { Stop-InitDocs 2 "Unknown profile: $name" }
        Add-UniqueValue $selectedProfiles $name
    }

    $includedPacks = @(Expand-ArgumentValues $IncludePack)
    $excludedPacks = @(Expand-ArgumentValues $ExcludePack)
    $excludedPackSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $excludedPacks) {
        if (-not $packsByName.ContainsKey($name)) { Stop-InitDocs 2 "Unknown excluded pack: $name" }
        Add-UniqueValue $excludedPackSet $name
    }
    if ($excludedPackSet.Contains("core")) { Stop-InitDocs 2 "The core pack cannot be excluded." }

    $selectedPacks = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($profileName in $selectedProfiles) {
        foreach ($packName in (Split-ManifestList $profilesByName[$profileName].packs)) {
            if (-not $packsByName.ContainsKey($packName)) { Stop-InitDocs 4 "Profile '$profileName' references unknown pack '$packName'." }
            Add-UniqueValue $selectedPacks $packName
        }
    }
    foreach ($packName in $includedPacks) {
        if (-not $packsByName.ContainsKey($packName)) { Stop-InitDocs 2 "Unknown included pack: $packName" }
        if ($excludedPackSet.Contains($packName)) { Stop-InitDocs 2 "Pack '$packName' is both included and excluded." }
        Add-UniqueValue $selectedPacks $packName
    }
    foreach ($packName in $excludedPackSet) { [void]$selectedPacks.Remove($packName) }
    Add-UniqueValue $selectedPacks "core"

    $changed = $true
    while ($changed) {
        $changed = $false
        foreach ($packName in @($selectedPacks)) {
            if (-not $packsByName.ContainsKey($packName)) { Stop-InitDocs 4 "Selected pack is missing from packs.tsv: $packName" }
            foreach ($requiredPack in (Split-ManifestList $packsByName[$packName].requires)) {
                if (-not $packsByName.ContainsKey($requiredPack)) { Stop-InitDocs 4 "Pack '$packName' requires unknown pack '$requiredPack'." }
                if ($excludedPackSet.Contains($requiredPack)) { Stop-InitDocs 2 "Pack '$packName' requires excluded pack '$requiredPack'." }
                if ($selectedPacks.Add($requiredPack)) { $changed = $true }
            }
        }
    }

    foreach ($row in $packRows) {
        foreach ($requiredPack in (Split-ManifestList $row.requires)) {
            if (-not $packsByName.ContainsKey($requiredPack)) { Stop-InitDocs 4 "Pack '$($row.pack)' requires unknown pack '$requiredPack'." }
        }
    }

    $customValues = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in $SetValue) {
        $separator = if ($null -eq $entry) { -1 } else { $entry.IndexOf('=') }
        if ($separator -le 0) { Stop-InitDocs 2 "-SetValue must use KEY=VALUE: $entry" }
        $key = $entry.Substring(0, $separator).Trim().ToUpperInvariant()
        $value = $entry.Substring($separator + 1)
        if ($key -notmatch '^[A-Z][A-Z0-9_]*$') { Stop-InitDocs 2 "Invalid -SetValue key: $key" }
        if ([string]::IsNullOrEmpty($value) -or $value.IndexOfAny(@([char]0, [char]9, [char]10, [char]13)) -ge 0) {
            Stop-InitDocs 2 "Value for '$key' is empty or contains a forbidden control character."
        }
        if ($key -in @("PROJECT_NAME", "OWNER", "CURRENT_DATE")) {
            Stop-InitDocs 2 "Use the dedicated parameter instead of -SetValue for $key."
        }
        if ($key -eq "GITHUB_OWNER") {
            $ownerParts = @(
                if ($value.StartsWith("@", [System.StringComparison]::Ordinal)) { $value.Substring(1).Split('/') }
            )
            $account = if ($ownerParts.Count -ge 1) { $ownerParts[0] } else { "" }
            $validAccount = $account.Length -ge 1 -and $account.Length -le 39 -and $account -cmatch '^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$'
            $validTeam = $ownerParts.Count -eq 1 -or (
                $ownerParts.Count -eq 2 -and
                $ownerParts[1] -cmatch '^[A-Za-z0-9](?:[A-Za-z0-9_.-]*[A-Za-z0-9])?$'
            )
            if (-not $validAccount -or -not $validTeam) {
                Stop-InitDocs 2 "GITHUB_OWNER must be @user or @organization/team; the account part must be 1-39 alphanumeric characters with single internal hyphens."
            }
        }
        if ($customValues.ContainsKey($key) -and $customValues[$key] -cne $value) {
            Stop-InitDocs 2 "Conflicting values were supplied for $key."
        }
        $customValues[$key] = $value
    }

    $replacements = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
    $applicableKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $placeholderRows) {
        if ($row.required -notin @("true", "false")) { Stop-InitDocs 4 "Invalid required value '$($row.required)' in placeholders.tsv:$($row.__line)" }
        $token = $row.token.Trim()
        if ($token -notmatch '^\{\{([A-Z][A-Z0-9_]*)\}\}$') { Stop-InitDocs 4 "Invalid placeholder token '$token' in placeholders.tsv:$($row.__line)" }
        $key = $Matches[1]

        $packFilter = Split-ManifestList $row.packs
        $profileFilter = Split-ManifestList $row.profiles
        if (-not (Test-SetIntersects $packFilter $selectedPacks -WildcardMatches)) { continue }
        if (-not (Test-SetIntersects $profileFilter $selectedProfiles -WildcardMatches)) { continue }
        if (-not $applicableKeys.Add($key)) { Stop-InitDocs 4 "Duplicate applicable placeholder token: $token" }

        $value = $null
        switch ($key) {
            "PROJECT_NAME" { $value = $ProjectName }
            "OWNER" { $value = $Owner }
            "CURRENT_DATE" { $value = $Date }
            default {
                if ($customValues.ContainsKey($key)) { $value = $customValues[$key] }
                elseif (-not [string]::IsNullOrEmpty($row.default)) { $value = $row.default }
                elseif (-not [string]::IsNullOrEmpty($row.tbd)) { $value = $row.tbd }
                elseif ($row.required -eq "true") { Stop-InitDocs 2 "Required placeholder has no value, default, or TBD fallback: $token" }
            }
        }

        if ($null -ne $value) {
            if ($value.IndexOfAny(@([char]0, [char]9, [char]10, [char]13)) -ge 0) { Stop-InitDocs 2 "Replacement for $token contains a forbidden control character." }
            $replacements.Add($token, $value)
        }
    }
    $targetFull = Get-ComparablePath $Target
    $targetRoot = [System.IO.Path]::GetPathRoot($targetFull)
    $targetComparable = $targetFull.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $rootComparable = $targetRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    if ($targetComparable -eq $rootComparable -or [string]::IsNullOrEmpty($targetComparable)) { Stop-InitDocs 2 "A filesystem root cannot be used as the target." }
    if ([System.IO.File]::Exists($targetFull)) { Stop-InitDocs 2 "Target exists and is not a directory: $targetFull" }
    $targetExists = [System.IO.Directory]::Exists($targetFull)
    $existingTargetAnchor = if ($targetExists) { $targetFull } else { [System.IO.Path]::GetDirectoryName($targetFull) }
    if (-not [System.IO.Directory]::Exists($existingTargetAnchor)) { Stop-InitDocs 2 "The target parent directory does not exist: $existingTargetAnchor" }
    Assert-NoReparsePoint $existingTargetAnchor

    $comparison = if ([System.OperatingSystem]::IsWindows()) { [System.StringComparison]::OrdinalIgnoreCase } else { [System.StringComparison]::Ordinal }
    if ($targetFull.Equals($repoRoot, $comparison) -or (Test-PathWithin $targetFull $repoRoot) -or (Test-PathWithin $repoRoot $targetFull)) {
        Stop-InitDocs 2 "Target must not be the template repository, a child of it, or its ancestor."
    }

    $selectedRowsByDestination = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $fileRows) {
        if ($row.mode -notin @("copy", "render")) { Stop-InitDocs 4 "Invalid mode '$($row.mode)' in files.tsv:$($row.__line)" }
        if ($row.conflict -notin @("fail", "preserve")) { Stop-InitDocs 4 "Invalid conflict policy '$($row.conflict)' in files.tsv:$($row.__line)" }
        if ($row.placeholder_policy -notin @("replace", "preserve-template", "none")) { Stop-InitDocs 4 "Invalid placeholder policy '$($row.placeholder_policy)' in files.tsv:$($row.__line)" }
        if (-not (Test-SafeRelativePath $row.source)) { Stop-InitDocs 4 "Unsafe source path '$($row.source)' in files.tsv:$($row.__line)" }
        if (-not (Test-SafeRelativePath $row.destination)) { Stop-InitDocs 4 "Unsafe destination path '$($row.destination)' in files.tsv:$($row.__line)" }

        $rowPacks = Split-ManifestList $row.packs
        foreach ($packName in $rowPacks) {
            if (-not $packsByName.ContainsKey($packName)) { Stop-InitDocs 4 "File '$($row.source)' references unknown pack '$packName'." }
        }
        if (-not (Test-SetIntersects $rowPacks $selectedPacks)) { continue }

        if ($selectedRowsByDestination.ContainsKey($row.destination)) { Stop-InitDocs 4 "Duplicate destination (case-insensitive): $($row.destination)" }
        if ($row.destination.Equals(".docs-template/state.tsv", [System.StringComparison]::OrdinalIgnoreCase)) { Stop-InitDocs 4 "files.tsv must not own .docs-template/state.tsv." }

        $sourceFull = Get-ComparablePath (Join-Path $repoRoot ($row.source -replace '/', [System.IO.Path]::DirectorySeparatorChar))
        if (-not (Test-PathWithin $sourceFull $repoRoot)) { Stop-InitDocs 4 "Source escapes the repository: $($row.source)" }
        if (-not [System.IO.File]::Exists($sourceFull)) { Stop-InitDocs 4 "Source file does not exist: $($row.source)" }
        if (((Get-Item -LiteralPath $sourceFull -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { Stop-InitDocs 4 "Source file is a symlink or reparse point: $($row.source)" }
        if ($row.mode -eq "copy" -and $row.placeholder_policy -eq "replace") { Stop-InitDocs 4 "A copy row cannot use placeholder_policy=replace: $($row.source)" }
        $selectedRowsByDestination.Add($row.destination, [pscustomobject]@{ Manifest = $row; SourceFull = $sourceFull })
    }
    if ($selectedRowsByDestination.Count -eq 0) { Stop-InitDocs 4 "The selected profiles and packs produced no files." }

    $bodyKeys = @($customValues.Keys | Where-Object { -not $applicableKeys.Contains($_) })
    if ($bodyKeys.Count -gt 0) {
        $bodyTokens = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($selected in $selectedRowsByDestination.Values) {
            if ($selected.Manifest.mode -ne "render" -or $selected.Manifest.placeholder_policy -ne "replace") { continue }
            $sourceText = [System.IO.File]::ReadAllText($selected.SourceFull)
            foreach ($match in [regex]::Matches($sourceText, '\{\{[A-Z][A-Z0-9_]*\}\}')) {
                [void]$bodyTokens.Add($match.Value)
            }
        }
        foreach ($key in $bodyKeys) {
            $token = "{{$key}}"
            if ($placeholderRows.token -ccontains $token -or -not $bodyTokens.Contains($token)) {
                Stop-InitDocs 2 "Unknown or inactive -SetValue key for the selected profiles and packs: $key"
            }
            $replacements.Add($token, $customValues[$key])
        }
    }

    $temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("docs-template-init-" + [guid]::NewGuid().ToString("N"))
    [System.IO.Directory]::CreateDirectory($temporaryRoot) | Out-Null
    $stagingRoot = Join-Path $temporaryRoot "stage"
    [System.IO.Directory]::CreateDirectory($stagingRoot) | Out-Null

    $destinations = [string[]]@($selectedRowsByDestination.Keys)
    [System.Array]::Sort($destinations, [System.StringComparer]::Ordinal)

    $catalogProfiles = [string[]]@($selectedProfiles)
    $catalogPacks = [string[]]@($selectedPacks)
    [System.Array]::Sort($catalogProfiles, [System.StringComparer]::Ordinal)
    [System.Array]::Sort($catalogPacks, [System.StringComparer]::Ordinal)
    $catalogBuilder = [System.Text.StringBuilder]::new()
    [void]$catalogBuilder.AppendLine("")
    [void]$catalogBuilder.AppendLine("## 5. 已启用文档")
    [void]$catalogBuilder.AppendLine("")
    [void]$catalogBuilder.AppendLine("- Profile：``$($catalogProfiles -join ', ')``")
    [void]$catalogBuilder.AppendLine("- Packs：``$($catalogPacks -join ', ')``")
    [void]$catalogBuilder.AppendLine("")
    [void]$catalogBuilder.AppendLine("| 分组 | 路径 | 类型 | 说明 |")
    [void]$catalogBuilder.AppendLine("|------|------|------|------|")
    foreach ($catalogDestination in $destinations) {
        $catalogRow = $selectedRowsByDestination[$catalogDestination].Manifest
        $catalogGroup = $catalogRow.index_group.Replace('|', '\|')
        $catalogPath = $catalogDestination.Replace('|', '\|')
        $catalogDescription = $catalogRow.description.Replace('|', '\|')
        $catalogType = switch ($catalogRow.placeholder_policy) {
            "preserve-template" { "可复用模板" }
            "none" { "工具或配置" }
            default { "活动文档" }
        }
        [void]$catalogBuilder.AppendLine("| ``$catalogGroup`` | ``$catalogPath`` | $catalogType | $catalogDescription |")
    }
    $catalogSection = $catalogBuilder.ToString().Replace("`r`n", "`n").Replace("`r", "`n")

    $rootCatalogBuilder = [System.Text.StringBuilder]::new()
    [void]$rootCatalogBuilder.AppendLine("")
    [void]$rootCatalogBuilder.AppendLine("## 已启用项目入口")
    [void]$rootCatalogBuilder.AppendLine("")
    [void]$rootCatalogBuilder.AppendLine("以下入口由本次 profile 与 pack 选择生成，以实际文件为准。")
    [void]$rootCatalogBuilder.AppendLine("")
    $rootCatalogRows = 0
    foreach ($catalogDestination in $destinations) {
        if ($catalogDestination -eq "README.md") { continue }
        if ($catalogDestination.Contains('/') -and -not $catalogDestination.StartsWith(".github/", [System.StringComparison]::Ordinal)) { continue }
        if ($rootCatalogRows -eq 0) {
            [void]$rootCatalogBuilder.AppendLine("| 入口 | 类型 | 说明 |")
            [void]$rootCatalogBuilder.AppendLine("|------|------|------|")
        }
        $catalogRow = $selectedRowsByDestination[$catalogDestination].Manifest
        $catalogDescription = $catalogRow.description.Replace('|', '\|')
        $catalogType = switch ($catalogRow.placeholder_policy) {
            "preserve-template" { "可复用模板" }
            "none" { "工具或配置" }
            default { "活动文档" }
        }
        [void]$rootCatalogBuilder.AppendLine("| [$catalogDestination]($catalogDestination) | $catalogType | $catalogDescription |")
        $rootCatalogRows++
    }
    if ($rootCatalogRows -eq 0) {
        [void]$rootCatalogBuilder.AppendLine("当前 profile 未启用额外的根目录或 GitHub 协作入口。")
    }
    $rootCatalogSection = $rootCatalogBuilder.ToString().Replace("`r`n", "`n").Replace("`r", "`n")

    $templateVersion = [System.IO.File]::ReadAllText((Join-Path $scaffoldRoot "VERSION"), [System.Text.Encoding]::UTF8).Trim()
    if ($templateVersion -notmatch '^\d+\.\d+\.\d+$') { Stop-InitDocs 4 "scaffold/VERSION must contain a semantic version." }
    $unresolved = [System.Collections.Generic.List[object]]::new()
    $stateEntries = [System.Collections.Generic.List[string]]::new()
    foreach ($destination in $destinations) {
        $selected = $selectedRowsByDestination[$destination]
        $row = $selected.Manifest
        $stagedPath = Join-Path $stagingRoot ($destination -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($stagedPath)) | Out-Null

        if ($row.mode -eq "copy") {
            [System.IO.File]::Copy($selected.SourceFull, $stagedPath, $false)
        } else {
            $sourceContent = [System.IO.File]::ReadAllText($selected.SourceFull, [System.Text.Encoding]::UTF8)
            $rendered = Render-Template $sourceContent $replacements
            if ($destination -eq "docs/README.md") {
                $rendered = $rendered.TrimEnd("`r", "`n") + "`n" + $catalogSection
            }
            if ($destination -eq "README.md") {
                $rendered = $rendered.TrimEnd("`r", "`n") + "`n" + $rootCatalogSection
            }
            Write-Utf8LfFile $stagedPath $rendered
        }

        if ($row.placeholder_policy -eq "replace") {
            $content = [System.IO.File]::ReadAllText($stagedPath, [System.Text.Encoding]::UTF8)
            $matches = [System.Text.RegularExpressions.Regex]::Matches($content, '\{\{[^{}\r\n]+\}\}')
            $counts = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
            foreach ($match in $matches) {
                if ($counts.ContainsKey($match.Value)) { $counts[$match.Value]++ } else { $counts.Add($match.Value, 1) }
            }
            if ($counts.Count -gt 0) {
                $unresolved.Add([pscustomobject]@{ Path = $destination; Counts = $counts; Total = $matches.Count })
            }
        }

        $stagedHash = Get-Sha256 $stagedPath
        $prospectiveTarget = Join-Path $targetFull ($destination -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        $isPreserved = $row.conflict -eq "preserve" -and [System.IO.File]::Exists($prospectiveTarget) -and (Get-Sha256 $prospectiveTarget) -ne $stagedHash
        if (-not $isPreserved) {
            if ($row.placeholder_policy -eq "preserve-template") {
                $stagedHash = Get-TemplateTextHash $stagedPath
            }
            $stateEntries.Add("1`t$templateVersion`t$destination`t$($row.source)`t$($row.packs)`t$($row.placeholder_policy)`t$stagedHash")
        }
    }

    $stateRelative = ".docs-template/state.tsv"
    $stateStagedPath = Join-Path $stagingRoot ".docs-template/state.tsv"
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($stateStagedPath)) | Out-Null
    $stateContent = "schema_version`ttemplate_version`tdestination`tsource`tpacks`tplaceholder_policy`tsha256`n" + ($stateEntries.ToArray() -join "`n") + "`n"
    Write-Utf8LfFile $stateStagedPath $stateContent

    if ($unresolved.Count -gt 0) {
        $totalUnresolved = ($unresolved | Measure-Object -Property Total -Sum).Sum
        Write-Host "UNRESOLVED $totalUnresolved placeholder occurrence(s) remain in active documents:"
        foreach ($item in $unresolved | Sort-Object Path) {
            $tokens = [string[]]@($item.Counts.Keys)
            [System.Array]::Sort($tokens, [System.StringComparer]::Ordinal)
            $preview = $tokens -join ", "
            Write-Host "  $($item.Path): $($item.Total) ($preview)"
        }
        if ($RequireComplete) { Stop-InitDocs 6 "RequireComplete rejected unresolved placeholders." }
    }

    $allOutputs = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($destination in $destinations) {
        $allOutputs.Add($destination, (Join-Path $stagingRoot ($destination -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
    }
    $allOutputs.Add($stateRelative, $stateStagedPath)
    $outputPaths = [string[]]@($allOutputs.Keys)
    [System.Array]::Sort($outputPaths, [System.StringComparer]::Ordinal)

    $actions = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $conflicts = [System.Collections.Generic.List[string]]::new()
    foreach ($relativePath in $outputPaths) {
        Assert-SafeTargetDestination $targetFull $relativePath
        $targetPath = Join-Path $targetFull ($relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        $targetParent = [System.IO.Path]::GetDirectoryName($targetPath)
        $ancestor = $targetParent
        while ($ancestor.Length -gt $targetFull.Length -and -not [System.IO.Directory]::Exists($ancestor)) {
            if ([System.IO.File]::Exists($ancestor)) { break }
            $ancestor = [System.IO.Path]::GetDirectoryName($ancestor)
        }
        if ([System.IO.File]::Exists($ancestor) -or [System.IO.Directory]::Exists($targetPath)) {
            $actions[$relativePath] = "CONFLICT"
            $conflicts.Add($relativePath)
        } elseif ([System.IO.File]::Exists($targetPath)) {
            if ((Get-Sha256 $targetPath) -eq (Get-Sha256 $allOutputs[$relativePath])) {
                $actions[$relativePath] = "UNCHANGED"
            } else {
                $conflictPolicy = if ($selectedRowsByDestination.ContainsKey($relativePath)) {
                    $selectedRowsByDestination[$relativePath].Manifest.conflict
                } else {
                    "fail"
                }
                if ($conflictPolicy -eq "preserve") {
                    $actions[$relativePath] = "PRESERVE"
                } else {
                    $actions[$relativePath] = "CONFLICT"
                    $conflicts.Add($relativePath)
                }
            }
        } else {
            $actions[$relativePath] = "CREATE"
        }
    }

    foreach ($relativePath in $outputPaths) {
        Write-Host ("[{0}] {1}" -f $actions[$relativePath].PadRight(9), $relativePath)
    }
    if ($conflicts.Count -gt 0) {
        Stop-InitDocs 3 "Different existing files or path collisions were found. No target files were written. Note: init-docs does not overwrite or upgrade in place; to add packs or update templates, generate into a new temporary directory and merge via git diff."
    }
    if ($DryRun) {
        Write-Host "DRY-RUN OK: no target files were written."
        exit 0
    }

    if (-not $targetExists) {
        if (-not [System.IO.Directory]::Exists($existingTargetAnchor)) {
            Stop-InitDocs 2 "The target parent changed after preflight: $existingTargetAnchor"
        }
        Assert-NoReparsePoint $existingTargetAnchor
        if ([System.IO.File]::Exists($targetFull) -or [System.IO.Directory]::Exists($targetFull)) {
            Stop-InitDocs 3 "Target changed after preflight: $targetFull"
        }
        [System.IO.Directory]::CreateDirectory($targetFull) | Out-Null
        $createdTarget = $true
        Assert-SafeTargetDestination $targetFull $stateRelative
    }
    $applyOrder = @($outputPaths | Where-Object { $_ -ne $stateRelative }) + @($stateRelative)
    foreach ($relativePath in $applyOrder) {
        if ($actions[$relativePath] -ne "CREATE") { continue }
        $targetPath = Join-Path $targetFull ($relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        Assert-SafeTargetDestination $targetFull $relativePath
        if ([System.IO.File]::Exists($targetPath) -or [System.IO.Directory]::Exists($targetPath)) {
            Stop-InitDocs 3 "Target changed after preflight: $relativePath"
        }
        [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($targetPath)) | Out-Null
        Assert-SafeTargetDestination $targetFull $relativePath
        if ([System.IO.File]::Exists($targetPath) -or [System.IO.Directory]::Exists($targetPath)) {
            Stop-InitDocs 3 "Target changed after parent creation: $relativePath"
        }
        Assert-SafeTargetDestination $targetFull $relativePath
        [System.IO.File]::Copy($allOutputs[$relativePath], $targetPath, $false)
        $createdFiles.Add($targetPath)
    }

    Write-Host "OK: initialized $($destinations.Count) scaffold file(s) plus state metadata."
    $preservedFiles = @($outputPaths | Where-Object { $actions[$_] -eq "PRESERVE" })
    if ($preservedFiles.Count -gt 0 -or $unresolved.Count -gt 0 -or $selectedPacks.Contains("tooling") -or $selectedPacks.Contains("github-ci")) {
        Write-Host "Next steps:"
        if ($preservedFiles.Count -gt 0) {
            Write-Host "  - Manually merge preserved file(s): $($preservedFiles -join ', ')"
        }
        if ($unresolved.Count -gt 0) {
            Write-Host "  - Fill remaining placeholders in active documents (use TBD for unknown facts, N/A for inapplicable items)."
        }
        if ($selectedPacks.Contains("tooling")) {
            Write-Host "  - Run local checks in target repo: pwsh scripts/check-placeholders.ps1 && pwsh scripts/check-doc-links.ps1"
        }
        if ($selectedPacks.Contains("github-ci")) {
            Write-Host "  - After check-placeholders passes (exit 0), create .docs-template/strict-ci to enable strict CI blocking."
        }
    }
    exit 0
}
catch {
    $exitCode = 1
    if ($_.Exception.Data.Contains("InitDocsExitCode")) {
        $exitCode = [int]$_.Exception.Data["InitDocsExitCode"]
    }

    if (-not $DryRun -and $createdFiles.Count -gt 0) {
        foreach ($createdFile in @($createdFiles.ToArray()) | Sort-Object -Descending) {
            if ([System.IO.File]::Exists($createdFile)) {
                try { [System.IO.File]::Delete($createdFile) } catch { $exitCode = 5 }
            }
        }
    }
    if (-not $DryRun -and $createdTarget -and [System.IO.Directory]::Exists($targetFull)) {
        try { [System.IO.Directory]::Delete($targetFull, $true) } catch { $exitCode = 5 }
    }

    [Console]::Error.WriteLine("ERROR[$exitCode] $($_.Exception.Message)")
    exit $exitCode
}
finally {
    if ($null -ne $temporaryRoot -and [System.IO.Directory]::Exists($temporaryRoot)) {
        try { [System.IO.Directory]::Delete($temporaryRoot, $true) } catch { }
    }
}

# check-doc-links.ps1
#
# Validate local links in downstream project Markdown documents.
#
# Usage:
#   pwsh scripts/check-doc-links.ps1
#   pwsh scripts/check-doc-links.ps1 -Target docs
#   pwsh scripts/check-doc-links.ps1 C:\path\to\project
#
# Exit codes:
#   0 = all local links are valid
#   1 = one or more invalid local links were found
#   2 = invalid target or the target could not be scanned

param(
    [Parameter(Position = 0)]
    [string]$Target = ".",

    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help -or $Target -in @("-h", "--help")) {
    Write-Host @"
用法：
  pwsh scripts/check-doc-links.ps1 [Target]
  pwsh scripts/check-doc-links.ps1 -Target docs

说明：
  检查下游项目 Markdown 文档中的本地文件、图片、标题锚点与路径大小写是否有效。
  在 Git 仓库中扫描已跟踪及未忽略的 Markdown；普通目录中递归扫描并跳过常见构建/依赖目录。

退出码：
  0  所有本地链接有效
  1  发现无效链接
  2  目标路径无效或无法扫描
"@
    exit 0
}

$linkPattern = [regex]::new('(?<image>!)?\[[^\]\r\n]*\]\(\s*(?<destination><[^>\r\n]+>|[^)\s\r\n]+)')
$referencePattern = [regex]::new('^\s*\[[^\]\r\n]+\]:\s*(?<destination><[^>\r\n]+>|\S+)')
$script:anchorCache = @{}

function Test-FenceLine {
    param(
        [string]$Line,
        [ref]$FenceCharacter,
        [ref]$FenceLength,
        [ref]$InFence
    )

    $match = [regex]::Match($Line, '^\s*(?<fence>`{3,}|~{3,})')
    if (-not $match.Success) {
        return $false
    }

    $marker = $match.Groups['fence'].Value
    $character = $marker.Substring(0, 1)

    if (-not $InFence.Value) {
        $FenceCharacter.Value = $character
        $FenceLength.Value = $marker.Length
        $InFence.Value = $true
        return $true
    }

    if ($character -eq $FenceCharacter.Value -and $marker.Length -ge $FenceLength.Value) {
        $InFence.Value = $false
        $FenceCharacter.Value = $null
        $FenceLength.Value = 0
    }

    return $true
}

function ConvertTo-AnchorSlug {
    param([string]$Heading)

    $text = [regex]::Replace($Heading, '<[^>]+>', '')
    $text = $text.Trim().ToLowerInvariant()
    $builder = [System.Text.StringBuilder]::new()

    foreach ($character in $text.ToCharArray()) {
        $codePoint = [int]$character
        if (
            ($codePoint -ge 48 -and $codePoint -le 57) -or
            ($codePoint -ge 97 -and $codePoint -le 122) -or
            $character -eq '-' -or
            $character -eq '_'
        ) {
            [void]$builder.Append($character)
        }
        elseif ([char]::IsWhiteSpace($character)) {
            [void]$builder.Append('-')
        }
        elseif ($codePoint -gt 127) {
            [void]$builder.Append($character)
        }
    }

    return $builder.ToString()
}

function Get-MarkdownAnchors {
    param([string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if ($script:anchorCache.ContainsKey($fullPath)) {
        return $script:anchorCache[$fullPath]
    }

    $anchors = [System.Collections.Generic.List[string]]::new()
    $slugCounts = @{}
    $inFence = $false
    $fenceCharacter = $null
    $fenceLength = 0

    foreach ($line in [System.IO.File]::ReadLines($fullPath)) {
        if (Test-FenceLine $line ([ref]$fenceCharacter) ([ref]$fenceLength) ([ref]$inFence)) {
            continue
        }
        if ($inFence) {
            continue
        }

        foreach ($idMatch in [regex]::Matches($line, '(?i)<[A-Za-z][^>]*\s(?:id|name)\s*=\s*["''](?<id>[^"'']+)["''][^>]*>')) {
            $anchors.Add($idMatch.Groups['id'].Value)
        }

        $headingMatch = [regex]::Match($line, '^\s{0,3}#{1,6}\s+(?<heading>.+?)\s*$')
        if (-not $headingMatch.Success) {
            continue
        }

        $heading = [regex]::Replace($headingMatch.Groups['heading'].Value, '\s+#+\s*$', '')
        $baseSlug = ConvertTo-AnchorSlug $heading
        if ([string]::IsNullOrEmpty($baseSlug)) {
            continue
        }

        if (-not $slugCounts.ContainsKey($baseSlug)) {
            $slugCounts[$baseSlug] = 0
            $anchors.Add($baseSlug)
        }
        else {
            $slugCounts[$baseSlug]++
            $anchors.Add("$baseSlug-$($slugCounts[$baseSlug])")
        }
    }

    $result = $anchors.ToArray()
    $script:anchorCache[$fullPath] = $result
    return $result
}

function Test-PathCaseExact {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetPathRoot($fullPath)
    if ([string]::IsNullOrEmpty($root)) {
        return $false
    }

    $relative = $fullPath.Substring($root.Length)
    $segments = $relative -split '[\\/]+' | Where-Object { $_.Length -gt 0 }
    $current = $root

    foreach ($segment in $segments) {
        $match = Get-ChildItem -LiteralPath $current -Force | Where-Object { $_.Name -ceq $segment } | Select-Object -First 1
        if ($null -eq $match) {
            return $false
        }
        $current = $match.FullName
    }

    return $true
}

function Get-DisplayPath {
    param(
        [string]$FilePath,
        [string]$ScanRoot,
        [bool]$TargetIsFile
    )

    if ($TargetIsFile) {
        return [System.IO.Path]::GetFileName($FilePath)
    }
    return [System.IO.Path]::GetRelativePath($ScanRoot, $FilePath).Replace('\', '/')
}

function Get-MarkdownSourceFiles {
    param([string]$Directory)

    $git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $git -or (& $git.Source -C $Directory rev-parse --is-inside-work-tree 2>$null) -ne 'true') {
        $ignoredDirs = @('.git', 'node_modules', 'dist', 'build', '.next', '.venv', 'vendor')
        Get-ChildItem -LiteralPath $Directory -Recurse -File -Filter '*.md' -Force | Where-Object {
            $rel = [System.IO.Path]::GetRelativePath($Directory, $_.FullName).Replace('\', '/')
            $segments = $rel.Split('/')
            $skip = $false
            for ($i = 0; $i -lt ($segments.Length - 1); $i++) {
                if ($ignoredDirs -contains $segments[$i]) { $skip = $true; break }
            }
            -not $skip
        }
        return
    }

    # Read NUL-delimited UTF-8 paths without PowerShell splitting filenames at newlines.
    $start = [System.Diagnostics.ProcessStartInfo]::new($git.Source)
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    foreach ($argument in @('-C', $Directory, 'ls-files', '-z', '--cached', '--others', '--exclude-standard', '--', ':(icase,glob)**/*.md')) {
        $start.ArgumentList.Add($argument)
    }
    $process = [System.Diagnostics.Process]::Start($start)
    try {
        $paths = $process.StandardOutput.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "git ls-files failed under $Directory" }
    } finally {
        $process.Dispose()
    }
    foreach ($relative in $paths.Split([char]0, [System.StringSplitOptions]::RemoveEmptyEntries)) {
        $file = [System.IO.FileInfo]::new((Join-Path $Directory $relative))
        if ($file.Exists) { $file }
    }
}

function Test-LinkDestination {
    param(
        [string]$RawDestination,
        [bool]$IsImage,
        [string]$SourceFile,
        [int]$LineNumber,
        [string]$DisplayPath,
        [string]$ScanRoot
    )

    $destination = $RawDestination.Trim()
    if ($destination.StartsWith('<') -and $destination.EndsWith('>')) {
        $destination = $destination.Substring(1, $destination.Length - 2)
    }

    if (
        $destination -match '^(?i:https?://|mailto:)' -or
        $destination.StartsWith('?')
    ) {
        return $true
    }

    $fragment = $null
    $hashIndex = $destination.IndexOf('#')
    if ($hashIndex -ge 0) {
        $fragment = $destination.Substring($hashIndex + 1)
        $pathPart = $destination.Substring(0, $hashIndex)
    }
    else {
        $pathPart = $destination
    }

    $queryIndex = $pathPart.IndexOf('?')
    if ($queryIndex -ge 0) {
        $pathPart = $pathPart.Substring(0, $queryIndex)
    }

    try {
        $pathPart = [System.Uri]::UnescapeDataString($pathPart).Replace('\', '/')
        if ($null -ne $fragment) {
            $fragment = [System.Uri]::UnescapeDataString($fragment)
        }
    }
    catch {
        Write-Host "  ${DisplayPath}:${LineNumber}: [invalid-destination] $RawDestination"
        return $false
    }

    try {
        if ([string]::IsNullOrEmpty($pathPart)) {
            $candidate = [System.IO.Path]::GetFullPath($SourceFile)
        }
        elseif ($pathPart.StartsWith('/')) {
            $candidate = [System.IO.Path]::GetFullPath((Join-Path $ScanRoot $pathPart.TrimStart('/')))
        }
        else {
            $candidate = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetDirectoryName($SourceFile)) $pathPart))
        }
    }
    catch {
        Write-Host "  ${DisplayPath}:${LineNumber}: [invalid-destination] $RawDestination"
        return $false
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        Write-Host "  ${DisplayPath}:${LineNumber}: [missing-target] $RawDestination"
        return $false
    }
    if (-not (Test-PathCaseExact $candidate)) {
        Write-Host "  ${DisplayPath}:${LineNumber}: [case-mismatch] $RawDestination"
        return $false
    }

    $item = Get-Item -LiteralPath $candidate -Force
    if ($IsImage -and $item.PSIsContainer) {
        Write-Host "  ${DisplayPath}:${LineNumber}: [image-target-not-file] $RawDestination"
        return $false
    }

    if ($null -ne $fragment -and $fragment.Length -gt 0) {
        if ($item.PSIsContainer -or $item.Extension -ine '.md') {
            Write-Host "  ${DisplayPath}:${LineNumber}: [anchor-target-not-markdown] $RawDestination"
            return $false
        }

        $anchors = @(Get-MarkdownAnchors $item.FullName)
        if (-not ($anchors -ccontains $fragment)) {
            Write-Host "  ${DisplayPath}:${LineNumber}: [missing-anchor] $RawDestination"
            return $false
        }
    }

    return $true
}

try {
    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Host "ERROR target does not exist: $Target"
        exit 2
    }

    $targetItem = Get-Item -LiteralPath $Target -Force
    $targetIsFile = -not $targetItem.PSIsContainer

    if ($targetIsFile) {
        if ($targetItem.Extension -ine '.md') {
            Write-Host "ERROR target must be a directory or a Markdown file: $Target"
            exit 2
        }
        $scanRoot = $targetItem.Directory.FullName
        $files = @($targetItem)
    }
    else {
        $scanRoot = $targetItem.FullName
        $files = @(Get-MarkdownSourceFiles $scanRoot)
    }

    Write-Host "==> checking local Markdown links under $($targetItem.FullName)"

    $invalidCount = 0
    foreach ($file in $files) {
        $displayPath = Get-DisplayPath $file.FullName $scanRoot $targetIsFile
        $lineNumber = 0
        $inFence = $false
        $fenceCharacter = $null
        $fenceLength = 0

        foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
            $lineNumber++
            if (Test-FenceLine $line ([ref]$fenceCharacter) ([ref]$fenceLength) ([ref]$inFence)) {
                continue
            }
            if ($inFence) {
                continue
            }

            foreach ($match in $linkPattern.Matches($line)) {
                $valid = Test-LinkDestination `
                    -RawDestination $match.Groups['destination'].Value `
                    -IsImage $match.Groups['image'].Success `
                    -SourceFile $file.FullName `
                    -LineNumber $lineNumber `
                    -DisplayPath $displayPath `
                    -ScanRoot $scanRoot
                if (-not $valid) {
                    $invalidCount++
                }
            }

            $referenceMatch = $referencePattern.Match($line)
            if ($referenceMatch.Success) {
                $valid = Test-LinkDestination `
                    -RawDestination $referenceMatch.Groups['destination'].Value `
                    -IsImage $false `
                    -SourceFile $file.FullName `
                    -LineNumber $lineNumber `
                    -DisplayPath $displayPath `
                    -ScanRoot $scanRoot
                if (-not $valid) {
                    $invalidCount++
                }
            }
        }
    }

    if ($invalidCount -eq 0) {
        Write-Host "OK no invalid local Markdown links."
        exit 0
    }

    Write-Host "FAIL found $invalidCount invalid local Markdown link(s)."
    exit 1
}
catch {
    Write-Host "ERROR unable to scan Markdown links: $($_.Exception.Message)"
    exit 2
}

# check-docs-consistency.ps1
#
# 三索引同步检查：确保 docs/ 下每个 .md 文件至少在以下两处被提及：
#   1. README.md（根目录推荐目录或可选扩展表）
#   2. template-mapping.md（归入位置清单）
#
# 也检查 docs/README.md § 2 是否覆盖所有一级子目录。
#
# 用法：
#   pwsh scripts/check-docs-consistency.ps1
#
# 退出码：0 = 一致；1 = 存在缺失引用

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$rootReadme  = Join-Path $repoRoot "README.md"
$docsReadme  = Join-Path $repoRoot "docs\README.md"
$mapping     = Join-Path $repoRoot "template-mapping.md"

$missing = 0

Write-Host "==> 检查 docs/ 下的所有 .md 是否在 README.md 和 template-mapping.md 中被提及"

$rootContent    = Get-Content $rootReadme    -Raw -Encoding UTF8
$mappingContent = Get-Content $mapping       -Raw -Encoding UTF8

$files = Get-ChildItem -Path (Join-Path $repoRoot "docs") -Recurse -Filter "*.md" -File
$baseNameCounts = @{}

foreach ($file in $files) {
    if (-not $baseNameCounts.ContainsKey($file.Name)) {
        $baseNameCounts[$file.Name] = 0
    }
    $baseNameCounts[$file.Name]++
}

function Test-DocReference {
    param(
        [string]$Content,
        [string]$RelForward,
        [string]$BaseName,
        [int]$BaseNameCount
    )

    $docsPath = "docs/$RelForward"
    if ($Content -match [regex]::Escape($docsPath)) { return $true }
    if ($Content -match [regex]::Escape($RelForward)) { return $true }

    # Filename-only matches are accepted only when the basename is unique under docs/.
    # Otherwise files such as docs/README.md and docs/features/README.md can mask
    # missing directory-specific references.
    if ($BaseNameCount -eq 1 -and $Content -match [regex]::Escape($BaseName)) {
        return $true
    }

    return $false
}

foreach ($file in $files) {
    $rel = $file.FullName.Substring((Join-Path $repoRoot "docs").Length).TrimStart('\', '/')
    $relForward = $rel -replace '\\', '/'
    $base = $file.Name

    # 跳过模板文件
    if ($base -match '-template\.md$' -or $base -eq 'ADR-000-template.md') { continue }

    if (-not (Test-DocReference $rootContent $relForward $base $baseNameCounts[$base])) {
        Write-Host "  [miss] docs/$relForward  未在 README.md 中出现"
        $missing++
    }
    if (-not (Test-DocReference $mappingContent $relForward $base $baseNameCounts[$base])) {
        Write-Host "  [miss] docs/$relForward  未在 template-mapping.md 中出现"
        $missing++
    }
}

Write-Host ""
Write-Host "==> 检查 docs/README.md § 2 是否提到所有一级子目录"

$docsReadmeContent = Get-Content $docsReadme -Raw -Encoding UTF8
$subDirs = Get-ChildItem -Path (Join-Path $repoRoot "docs") -Directory

foreach ($dir in $subDirs) {
    $name = $dir.Name
    if ($docsReadmeContent -notmatch [regex]::Escape("${name}/")) {
        Write-Host "  [miss] ${name}/  未在 docs/README.md § 2 目录说明中出现"
        $missing++
    }
}

Write-Host ""
if ($missing -eq 0) {
    Write-Host "OK 三索引一致，无缺失引用。"
    exit 0
} else {
    Write-Host "FAIL 共发现 $missing 处缺失。请同步更新对应索引。"
    exit 1
}

# check-placeholders.ps1
#
# 扫描文档中是否残留未替换的 {{XXX}} 占位符。
#
# 使用场景：
#   - 在**使用本模板的项目**中运行：复制模板后忘记替换的占位符会被发现
#   - 在本模板仓库中运行：使用 -Mode TemplateRepository，跳过模板源文件并检查 examples 等非模板文档
#
# 用法：
#   pwsh scripts/check-placeholders.ps1                            # 使用模板后的项目：扫全仓
#   pwsh scripts/check-placeholders.ps1 docs/features              # 使用模板后的项目：扫指定目录
#   pwsh scripts/check-placeholders.ps1 -Mode TemplateRepository   # 本模板仓库：跳过模板源文件，检查 examples 等非模板文档
#
# 退出码：0 = 无残留；1 = 存在残留
#
# Allowlist（这些文件允许保留占位符）：
#   *-template.md、ADR-000-template.md、docs/style-guide.md、
#   docs/README.md、CHANGELOG.md；TemplateRepository 模式会额外跳过模板源文件

param(
    [Parameter(Position = 0)]
    [string]$Target = ".",

    [ValidateSet("Consumer", "TemplateRepository")]
    [string]$Mode = "Consumer"
)

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$allowlistPatterns = @(
    '-template\.md$',
    'ADR-000-template\.md$',
    'docs[/\\]style-guide\.md$',
    'docs[/\\]README\.md$',
    'CHANGELOG\.md$',
    'scripts[/\\]check-placeholders\.ps1$'
)

if ($Mode -eq "TemplateRepository") {
    $allowlistPatterns += @(
        '^AGENTS\.md$',
        '^CONTRIBUTING\.md$',
        '^README\.md$',
        '^SECURITY\.md$',
        '^template-mapping\.md$',
        '^docs[/\\].*\.md$'
    )
}

$targetPath = Join-Path $repoRoot $Target
Write-Host "==> 扫描 $Target 中残留的 {{XXX}} 占位符"
if ($Mode -eq "TemplateRepository") {
    Write-Host "    Mode: TemplateRepository，模板源文件已跳过，仍检查 examples 等非模板文档。"
} else {
    Write-Host "    Mode: Consumer，允许残留的模板文件已跳过。"
}
Write-Host ""

$found = 0
$files = Get-ChildItem -Path $targetPath -Recurse -Filter "*.md" -File

foreach ($file in $files) {
    $rel = $file.FullName.Substring($repoRoot.Length).TrimStart('\', '/')
    $relForward = $rel -replace '\\', '/'

    $skip = $false
    foreach ($pattern in $allowlistPatterns) {
        if ($relForward -match $pattern) { $skip = $true; break }
    }
    if ($skip) { continue }

    $hits = Select-String -Path $file.FullName -Pattern '\{\{[A-Z][A-Z0-9_]*\}\}' -AllMatches
    foreach ($hit in $hits) {
        Write-Host "  ${relForward}:$($hit.LineNumber): $($hit.Line.Trim())"
        $found++
    }
}

Write-Host ""
if ($found -eq 0) {
    Write-Host "OK 无残留占位符。"
    exit 0
} else {
    Write-Host "FAIL 共发现 $found 处未替换的占位符。"
    Write-Host "     如果你正在用本模板开发项目，请先替换后再提交。"
    Write-Host "     如果这是本模板仓库自检，请使用 -Mode TemplateRepository。"
    exit 1
}

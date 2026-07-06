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

function Invoke-CapturedPwsh {
    param(
        [string[]]$Arguments,
        [string]$WorkingDirectory
    )

    $output = & pwsh @Arguments 2>&1
    [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output   = ($output | Out-String)
    }
}

Write-Host "==> placeholder check supports template repository mode"
$templatePlaceholder = Invoke-CapturedPwsh `
    -Arguments @("-NoProfile", "-File", (Join-Path $repoRoot "scripts\check-placeholders.ps1"), "-Mode", "TemplateRepository") `
    -WorkingDirectory $repoRoot
Assert-True ($templatePlaceholder.ExitCode -eq 0) $templatePlaceholder.Output

Write-Host "==> example project remains placeholder-clean in consumer mode"
$examplePlaceholder = Invoke-CapturedPwsh `
    -Arguments @("-NoProfile", "-File", (Join-Path $repoRoot "scripts\check-placeholders.ps1"), "-Target", "examples") `
    -WorkingDirectory $repoRoot
Assert-True ($examplePlaceholder.ExitCode -eq 0) $examplePlaceholder.Output

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

Write-Host "==> devlog entries are grouped by year and month"
$devlogReadme = Get-Content -LiteralPath (Join-Path $repoRoot "docs\devlog\README.md") -Raw -Encoding UTF8
$plansReadme = Get-Content -LiteralPath (Join-Path $repoRoot "docs\plans\README.md") -Raw -Encoding UTF8
Assert-True ($devlogReadme -notmatch "devlog/archive|archive/") "docs/devlog/README.md still references devlog/archive."
Assert-True ($devlogReadme -match "docs/devlog/YYYY/MM/") "docs/devlog/README.md should require year/month grouping for log entries."
Assert-True ($devlogReadme -match "根目录只保留") "docs/devlog/README.md should make root-directory boundaries explicit."
Assert-True ($plansReadme -match "../devlog/YYYY/MM/") "docs/plans/README.md should point process records to ../devlog/YYYY/MM/."

Write-Host "==> AGENTS template requires low coupling and boundary preservation"
$agents = Get-Content -LiteralPath (Join-Path $repoRoot "AGENTS.md") -Raw -Encoding UTF8
Assert-True ($agents -match "低耦合") "AGENTS.md should explicitly require low coupling."
Assert-True ($agents -match "跨层直接依赖|跨模块直接依赖") "AGENTS.md should prohibit cross-layer or cross-module direct dependencies."
Assert-True ($agents -match "模块边界") "AGENTS.md should require preserving module boundaries."

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
foreach ($term in @("必须通过 PR", "最少 Review", "CI 必须通过", "Merge / Squash / Rebase", "分支过期", "冲突处理")) {
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

Write-Host "==> local assistant settings are not part of the distributable template"
$localClaudeSettings = Join-Path $repoRoot ".claude\settings.local.json"
Assert-True (-not (Test-Path -LiteralPath $localClaudeSettings)) ".claude/settings.local.json should not be kept in the distributable template."

$gitignorePath = Join-Path $repoRoot ".gitignore"
Assert-True (Test-Path -LiteralPath $gitignorePath) ".gitignore is required to keep local tool state out of the template."
$gitignore = Get-Content -LiteralPath $gitignorePath -Raw -Encoding UTF8
Assert-True ($gitignore -match "(?m)^\.claude/$") ".gitignore should ignore .claude/."

Write-Host "OK docs-template checks passed."

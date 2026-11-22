# 项目文档模板包

这是一套可组合、可验证的项目文档脚手架，用于在项目启动阶段快速生成适合当前场景的文档骨架，并让后续文档在**目录结构、命名方式、写作风格、维护流程**上保持一致。

## 适用范围

适用于以下类型项目：

- Web / 后端 / 前端 / 全栈项目
- 桌面端项目
- AI / 数据处理 / OCR / Agent / RAG 项目
- 个人项目、校招项目、小团队协作项目
- 商业交付项目
- 开源项目与公共组件 / 库

“个人、商业、开源”不是互斥分类：独立开发者可以交付商业项目，商业项目也可以开源。初始化器使用 profile 提供常见起点，再通过 pack 叠加 API、数据、前端、团队、运维等实际能力。

## 快速开始（30 秒上手）

1. **查看可用起点、能力包和可填字段**（默认输出对齐表格，加 `-Tsv` / `--tsv` 输出原始 TSV）：

```powershell
pwsh -NoProfile -File scripts/init-docs.ps1 -ListProfiles
pwsh -NoProfile -File scripts/init-docs.ps1 -ListPacks
pwsh -NoProfile -File scripts/init-docs.ps1 -ListPlaceholders -Profile personal
```

2. **先预览（`-DryRun` 不写入任何文件）**，确认清单后再去掉 `-DryRun` 正式生成：

```powershell
pwsh -NoProfile -File scripts/init-docs.ps1 `
  -Target E:\Projects\my-project `
  -ProjectName my-project `
  -Owner "项目负责人" `
  -Profile personal `
  -Date 2026-07-10 `
  -DryRun
```

```bash
bash scripts/init-docs.sh \
  --target ../my-project \
  --project-name my-project \
  --owner '项目负责人' \
  --profile personal \
  --date 2026-07-10 \
  --dry-run
```

3. **三大起点（Profile）速览**（可按需叠加 pack，详细规则见下文 `## 使用方法`）：
   - `personal`：极简 7 个入口（不强制 BACKLOG、PR、CI 或 AI plan）
   - `commercial`：商业交付基线（报价、客户确认、变更、交付验收、支持与安全）
   - `open-source`：开源社区基线（贡献、安全、行为准则、治理、支持与许可证决策）

> 详细参数、按需 pack 列表、严校验模式与 CI 激活方式见下方 `## 使用方法`；想先看填好后的样子，直接浏览 `examples/order-service/`。

## 设计原则

1. **先总览，后细节**：先看 `docs/README.md`，再进入各专题文档。
2. **一文一事**：每个文档只负责一个主题，避免信息混杂。
3. **当前状态优先**：文档优先描述“当前已经实现/已经确定”的内容。
4. **规划与现状分离**：规划写入 `BACKLOG.md`，不要混入功能说明和设计定稿文档。
5. **模板先行**：新增文档时优先从模板复制，避免风格漂移。
6. **按事实组装**：API、数据库、UI、多人协作、商业交付和开源治理均按需启用，不把无关文档强加给所有项目。
7. **安全生成**：初始化器先完成路径、manifest、文件冲突和目标父链检查，拒绝会把写入导向目标外的 symlink / junction / ReparsePoint，不静默覆盖已有文件。

## 模板仓库维护边界

本仓库中的 `docs/BACKLOG.md`、`CHANGELOG.md`、`docs/plans/plan-template.md`、`AGENTS.md` 等文件是模板源文件。维护本模板仓库自身时，不要把这些模板源文件当作本仓库真实任务台账、真实变更日志或真实 plan；模板仓库维护规则见 `TEMPLATE_REPOSITORY_MAINTENANCE.md`。复制到具体项目后，再按项目实际情况启用 BACKLOG / CHANGELOG / plan 流程。

## 推荐目录

```text
project-docs-template/
├── AGENTS.md                   # AI 编码助手操作上下文（Claude Code、Cursor 等）
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md                 # 安全漏洞上报（区别于 docs/guides/security.md）
├── .gitignore
├── .editorconfig
├── .markdownlint.json
├── .github/
│   ├── CODEOWNERS
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   ├── documentation.yml
│   │   └── config.yml
│   ├── pull_request_template.md
│   └── workflows/
│       └── docs-template-checks.yml
├── scripts/
│   ├── .gitattributes               # Git 检出 Bash 脚本使用 LF
│   ├── lib/template-hash.ps1        # 初始化器和占位符检查共用的模板文本摘要
│   ├── lib/template-hash.sh
│   ├── init-docs.sh                # Bash 初始化器（macOS / Linux / WSL / Git Bash）
│   ├── init-docs.ps1               # PowerShell 初始化器（Windows / pwsh）
│   ├── check-docs-consistency.sh   # 三索引同步检查（bash / macOS / Linux / WSL）
│   ├── check-docs-consistency.ps1  # 三索引同步检查（PowerShell / Windows）
│   ├── check-placeholders.sh       # 占位符残留检查（bash / macOS / Linux / WSL）
│   ├── check-placeholders.ps1      # 占位符残留检查（PowerShell / Windows）
│   ├── check-doc-links.sh          # Consumer 本地 Markdown 链接检查（bash）
│   ├── check-doc-links.ps1         # Consumer 本地 Markdown 链接检查（PowerShell）
│   ├── test-docs-template-checks.ps1 # 模板内容与维护契约回归
│   ├── test-init-docs.ps1          # 三类 profile、冲突安全与跨脚本回归
│   └── test-doc-links.ps1          # 本地链接门禁正负 fixture 回归
├── scaffold/
│   ├── VERSION                     # 脚手架版本
│   ├── profiles.tsv                # personal / commercial / open-source 组合
│   ├── packs.tsv                   # 能力包、治理包与依赖
│   ├── files.tsv                   # 精确的源文件到目标文件映射
│   ├── placeholders.tsv            # 初始化阶段可替换的项目元数据
│   └── templates/                  # 下游专用 README、CI、CODEOWNERS 等
├── examples/
│   ├── README.md
│   └── order-service/          # 填好的示例项目（订单中心）
└── docs/
    ├── README.md
    ├── style-guide.md
    ├── BACKLOG.md
    ├── requirements/
    │   ├── project-background-and-scope.md
    │   ├── functional-modules.md
    │   ├── use-cases.md
    │   └── mvp-scope-freeze.md      # 阶段 / 版本范围冻结（MVP 可用）
    ├── design/
    │   ├── system-design-overview.md
    │   ├── architecture-overview.md   # 总体架构说明（支持三层 / 六边形架构）
    │   ├── rfc-template.md        # RFC / 设计提案模板
    │   ├── api-spec.md
    │   ├── database-design.md
    │   ├── permission-matrix.md
    │   ├── state-flow-and-acceptance.md
    │   ├── frontend-backend-contract-check.md # 前后端契约对照分析
    │   ├── page-module-contract.md # 页面模块顺序 / 文件边界 / 验收口径
    │   ├── component-api-contract.md # 组件 API / props / emits / 样式前缀契约
    │   ├── risk-register.md
    │   └── ui-wireframes.md      # 页面结构 / 线框图
    ├── features/
    │   ├── README.md
    │   └── feature-template.md
    ├── adr/
    │   ├── README.md
    │   └── ADR-000-template.md
    ├── devlog/
    │   ├── README.md
    │   ├── devlog-template.md
    │   ├── postmortem-template.md # 问题复盘模板
    │   └── YYYY/
    │       └── MM/
    │           └── YYYY-MM-DD.md
    ├── plans/                  # AI 任务计划（执行完即删除）
    │   ├── README.md
    │   └── plan-template.md
    ├── business/
    │   ├── quotation-estimate.md # 商业化项目报价与工期预估
    │   ├── customer-confirmation.md # 客户确认、依赖与待决策项
    │   ├── delivery-acceptance.md # 交付物、验收证据与项目交接
    │   └── change-request-template.md # 商业项目变更请求模板
    ├── glossary.md             # 可选：术语表
    └── guides/
        ├── setup.md
        ├── contributor-guide-template.md # 贡献者指南扩展模板
        ├── integration-guide-template.md # 接口 / 第三方服务接入手册
        ├── migration-guide-template.md # 版本 / 使用方迁移指南
        ├── technical-migration-plan.md # 技术迁移计划
        ├── project-failure-patterns-and-prevention.md # 项目常见失误与预防清单
        ├── troubleshooting.md    # 故障排查模板
        ├── support-policy.md     # 支持范围模板
        ├── license-selection.md  # 开源许可证选择与落地检查
        ├── open-source-governance.md # 开源维护者、决策与权限治理
        ├── branch-conventions.md
        ├── team-collaboration.md # 团队角色、RACI、协作流转
        ├── merge-conflict-playbook.md # 合并冲突分类与退回规则
        ├── testing.md
        ├── release-process.md
        ├── onboarding.md       # 可选：新人指南
        ├── security.md         # 可选：安全与合规
        └── runbook.md          # 可选：运维手册

# 可选扩展：
# docs/design/api-changes.md    API 破坏性变更与迁移指南
```

目录索引文件：

- `docs/features/README.md`
- `docs/adr/README.md`
- `docs/devlog/README.md`
- `docs/plans/README.md`

## 使用方法

### 0. 选择入口

| 你的情况 | 从这里开始 |
|----------|-----------|
| 全新项目，从 0 搭文档 | 本文件 § 1 初始化项目文档 |
| 想查看可用 profile / pack / 可填字段 | `pwsh scripts/init-docs.ps1 -ListProfiles` / `-ListPacks` / `-ListPlaceholders` |
| 想先预览生成文件且不写入 | 初始化命令加 `-DryRun` / `--dry-run` |
| 已有旧文档，想迁移到本规范 | `template-mapping.md`（旧文档 → 本模板的归类指南） |
| 只想查写作规范 / 占位符 / 版本号格式 | `docs/style-guide.md` |
| 想写系统架构 / 三层架构 / 六边形架构 | `docs/design/architecture-overview.md` + `docs/adr/` |
| 想写页面结构 / 线框图 | `docs/design/ui-wireframes.md` |
| 想冻结页面模块顺序 / 文件边界 | `docs/design/page-module-contract.md` |
| 想冻结组件 props / emits / slots / 样式前缀 | `docs/design/component-api-contract.md` |
| 想做前后端契约对照 / 联调缺口分析 | `docs/design/frontend-backend-contract-check.md` |
| 想写接口 / 第三方服务接入手册 | `docs/guides/integration-guide-template.md` |
| 想写技术迁移计划 | `docs/guides/technical-migration-plan.md` |
| 想沉淀问题复盘 | `docs/devlog/postmortem-template.md` |
| 想把多次问题提炼为通用防错门禁 | `docs/guides/project-failure-patterns-and-prevention.md` |
| 想扩展贡献者指南 / 外部参与流程 | `docs/guides/contributor-guide-template.md` |
| 想写 RFC / 设计提案 | `docs/design/rfc-template.md` |
| 想写版本迁移指南（面向使用方） | `docs/guides/migration-guide-template.md` |
| 想沉淀故障排查路径 | `docs/guides/troubleshooting.md` |
| 想定义支持渠道 / 响应级别 / 维护版本 | `docs/guides/support-policy.md` |
| 想选择并落地开源许可证 | `docs/guides/license-selection.md` |
| 想定义开源维护者、决策和继任规则 | `docs/guides/open-source-governance.md` |
| 想了解各目录职责与阅读顺序 | `docs/README.md` |
| 想配置 AI 编码助手的项目上下文 | `AGENTS.md` |
| 想建立团队角色 / RACI / Review 流程 | `docs/guides/team-collaboration.md` |
| 想处理多人页面冲突 / 集成分支冲突 | `docs/guides/merge-conflict-playbook.md` |
| 想启用 GitHub PR / Issue / CODEOWNERS | 加入 `github` pack，再按需阅读 `docs/guides/branch-conventions.md` |
| 想安装 GitHub 文档 CI | 加入 `github-ci` pack；填完活动文档并本地检查通过后创建 `.docs-template/strict-ci` 激活占位符阻断 |
| 想预估商业化报价 / 工期 / 成本 | `docs/business/quotation-estimate.md` |
| 想确认客户范围、依赖和待决策项 | `docs/business/customer-confirmation.md` |
| 想记录交付物、验收证据和交接结果 | `docs/business/delivery-acceptance.md` |
| 想评估已确认基线后的范围变更 | `docs/business/change-request-template.md` |
| 想看当前已填写的精简示例 | `examples/order-service/`（需求入口 + 1 个功能文档） |
| 想跑本模板仓库自检（bash） | `bash scripts/check-docs-consistency.sh && bash scripts/check-placeholders.sh --mode template` |
| 想跑本模板仓库完整自检（PowerShell / CI 同款） | 依次运行 `scripts/test-docs-template-checks.ps1`、`scripts/test-init-docs.ps1`、`scripts/test-doc-links.ps1` |
| 想单独检查索引 / 占位符（PowerShell） | `pwsh scripts/check-docs-consistency.ps1; pwsh scripts/check-placeholders.ps1 -Mode TemplateRepository` |
| 想检查生成项目的占位符与本地链接 | `pwsh scripts/check-placeholders.ps1; pwsh scripts/check-doc-links.ps1` |

### 1. 初始化项目文档

- 先选择一个 profile，再按项目事实叠加 pack；不要把整个模板仓库复制到目标项目。
- 初始化器只按 `scaffold/files.tsv` 的白名单复制文件，不会分发 `examples/`、模板仓库维护说明、仓库回归测试或模板仓库 CI。
- 初始化器绝不静默覆盖：核心活动文档冲突会让整次生成失败；README、贡献规范和仓库配置等标记为 `preserve` 的既有文件会保留，并在输出中列为人工合并事项。建议先使用 dry-run。

PowerShell：

```powershell
pwsh -NoProfile -File scripts/init-docs.ps1 `
  -Target E:\Projects\my-project `
  -ProjectName my-project `
  -Owner "项目负责人" `
  -Profile personal `
  -Date 2026-07-10 `
  -DryRun
```

Bash：

```bash
bash scripts/init-docs.sh \
  --target ../my-project \
  --project-name my-project \
  --owner '项目负责人' \
  --profile personal \
  --date 2026-07-10 \
  --dry-run
```

确认 dry-run 输出后去掉 `-DryRun` / `--dry-run` 正式生成。可通过
`-ListProfiles` / `--list-profiles`、`-ListPacks` / `--list-packs` 和 `-ListPlaceholders` / `--list-placeholders` 查看当前清单（加 `-Tsv` / `--tsv` 可输出原始 TSV）。

初始化器定位为**项目启动时的一次性安全生成器**，不是模板升级器：相同内容可重复执行并显示 `UNCHANGED`；一旦受管文件被人工修改，或需要在后期扩展 profile / pack，重新执行可能因文件或 state 冲突而整体停止。此时应先在新的临时目录 dry-run / 生成，再通过 Git diff 人工合并；当前版本不提供 `force` 或自动覆盖更新模式。

| profile | 适用起点 | 默认特点 |
|---------|----------|----------|
| `personal` | 个人项目、学习项目、单人维护工具 | 仅生成 7 个 core 入口；任务跟踪、PR、Reviewer、CI 和文件式 AI plan 均按需加入 |
| `commercial` | 对客户交付、需要报价与验收的项目 | 需求、客户确认、变更、报价、交付验收、支持与安全入口；架构、版本发布按需加入 |
| `open-source` | 公共仓库、库、SDK、CLI 或社区项目 | 平台无关的贡献、安全、行为准则、治理、支持和许可证决策入口；发布按需加入 |

常用按需 pack：

```text
tracking        BACKLOG 与 DevLog 轻量跟踪
requirements    功能模块、用例与阶段 / 版本范围冻结
architecture    系统设计、架构边界、风险与 ADR / RFC
api             API 契约、兼容性变化与接入模板
data            数据库设计
frontend        UI、页面模块和组件 API 契约
frontend-api-contract 前端行为与后端 API 契约对照（依赖 frontend + api）
team            平台无关的多人协作、Review、责任边界和 Onboarding
ai-planning     AGENTS 与文件式 AI plan
security        通用安全基线与事件响应
tooling         本地占位符 / 链接检查脚本与 Markdown 配置
operations      Runbook、排障与复盘
migration       版本与技术迁移
workflow        存在业务状态或生命周期时的流转与验收
release-support CHANGELOG、发布流程与版本支持
github          GitHub PR、Issue Forms 和 CODEOWNERS
github-ci       GitHub Actions 门禁（链接立即检查，占位符通过 strict-ci 标记激活）
```

例如个人开源 CLI 可以从 `personal` 开始，再加入 `open-source` 与需要的能力包；商业开源项目可以使用 `commercial` 并加入 `open-source`。GitHub、GitLab、Gitee 或纯本地仓库共用平台无关基线，只有明确使用 GitHub 时才加入 `github`。profile 和 pack 只决定文档集合，不会猜测项目是否存在 API、数据库或 UI。

加入 `github` / `github-ci` 时必须同时提供真实 Owner，例如 PowerShell 使用 `-SetValue 'GITHUB_OWNER=@maintainer'`，Bash 使用 `--set 'GITHUB_OWNER=@maintainer'`。Issue contact links 不会使用假 URL 自动生成；确认真实安全 / 支持地址后再手工加入 `.github/ISSUE_TEMPLATE/config.yml`。

> 开源 profile 不会伪造 `LICENSE`。必须先按 `docs/guides/license-selection.md` 明确选择真实许可证，再从 OSI / SPDX 等权威来源加入完整许可证文本。

### 2. 新项目最低必填文档

所有 profile 共用的 core 只有以下 7 个入口，不再强制 API、数据库、ADR 或多人协作文档：

- `README.md`
- `docs/README.md`
- `docs/style-guide.md`
- `docs/requirements/project-background-and-scope.md`
- `docs/features/README.md`
- `docs/features/feature-template.md`
- `docs/guides/setup.md`

初始化完成后按控制台中的 `UNRESOLVED` 清单补充项目事实。可复用的 `*-template.md` 保留占位符是正常的；活动文档中的未知事实写 `TBD`，不适用项写 `N/A`，不要编造内容。

需要一次生成可通过占位符检查的个人项目时，先用 `-DryRun` 查看所选活动文档的字段，再用 `-RequireComplete` 生成。`-SetValue` 接受已启用的项目元数据和活动文档中列出的正文字段。同名字段共用一个值。下面的 PowerShell 示例直接调用脚本，以数组传入多项。

```powershell
$fields = @(
  'SCOPE=文档维护', 'RELATED_DOCS=docs/README.md', 'TOOL=PowerShell', 'TOOL_VERSION=7',
  'DESCRIPTION=本地文档检查', 'ISSUE_TITLE=如何运行检查', 'USER_A=维护者', 'USER_B=贡献者',
  'NEED=检查文档', 'SCENARIO=提交改动', 'METRIC_NAME=检查耗时', 'TARGET=2 分钟'
)
./scripts/init-docs.ps1 -Target ../my-project -ProjectName my-project -Owner maintainer -Profile personal -SetValue $fields -RequireComplete
```

Bash 使用相同字段，每项传一个 `--set 'KEY=VALUE'`，并加 `--require-complete`。仍有未填标记时，两种初始化器都会列出文件和字段、返回退出码 6，并在写入目标目录前停止。`TBD` 和 `N/A` 的含义仍由项目负责人确认。

启用 `tooling` pack 时会生成本地占位符检查与 Markdown 文件、图片、anchor、路径大小写检查脚本，但不会自动安装托管平台 CI。显式加入 `github-ci` 后，Consumer workflow 会立即严格检查本地链接；占位符步骤在准备阶段只提示，直到本地 `check-placeholders` 返回 0 且维护者创建 `.docs-template/strict-ci`，才转为阻断。模板仓库自身使用独立 CI，不会被分发到目标项目。

激活前先确认本地占位符检查确实返回 0，再执行 `New-Item -ItemType File -Force .docs-template/strict-ci`（PowerShell）或 `touch .docs-template/strict-ci`（Bash），并将该空标记提交到仓库。

链接检查在 Git 工作区扫描已跟踪文档及尚未跟踪且未被忽略的 Markdown，指定单个文件时直接检查该文件。在普通目录中递归扫描。占位符检查识别 GitHub 工作流的表达式，同一行的模板字段仍会报告。可复用模板以统一换行计算 SHA-256，Git 在 LF 和 CRLF 之间转换时可以正常检出和校验。

### 3. 后续维护规则

| 场景 | 需要更新的文档 |
|------|----------------|
| 新增需求/调整范围 | `requirements/*` |
| 新增模块/改动功能 | `features/*` |
| 接口变更 | `design/api-spec.md` |
| 数据结构变更 | `design/database-design.md` + ADR（必要时） |
| 架构模式/边界变化 | `design/architecture-overview.md` + `adr/*`（必要时） |
| 页面模块顺序、`data-*` 标识、页面文件边界或页面验收口径变化 | `docs/design/page-module-contract.md` |
| 组件职责、props、emits、slots、CSS class 前缀或 mock 数据变化 | `docs/design/component-api-contract.md` |
| 已知问题/技术债 | `docs/BACKLOG.md` |
| 开发过程日志（日/周） | `docs/devlog/YYYY/MM/*.md` |
| 问题复盘 / 事故复盘 / 复杂排障总结 | `docs/devlog/postmortem-template.md` 或 `docs/devlog/YYYY/MM/*-postmortem.md` |
| 跨事件重复失误、证据误用或交付反模式 | `docs/guides/project-failure-patterns-and-prevention.md` |
| 团队角色 / RACI / 模块责任变化 | `docs/guides/team-collaboration.md` |
| 多人合并冲突处理规则、integration 分支或缺陷退回规则变化 | `docs/guides/merge-conflict-playbook.md` |
| 接口接入 / 第三方服务接入说明变化 | `docs/guides/integration-guide-template.md` |
| 前后端契约对照 / 联调缺口分析变化 | `docs/design/frontend-backend-contract-check.md` |
| 技术迁移方案 / 工时 / 风险变化 | `docs/guides/technical-migration-plan.md` |
| PR 模板 / CODEOWNERS / CI 门禁变化 | `.github/` + `docs/guides/branch-conventions.md` |
| Issue 模板 / 贡献者参与流程变化 | `.github/ISSUE_TEMPLATE/` + `docs/guides/contributor-guide-template.md` |
| RFC / 设计提案流程变化 | `docs/design/rfc-template.md` + `docs/adr/`（必要时） |
| 版本迁移指南变化 | `docs/guides/migration-guide-template.md` + `docs/design/api-changes.md`（必要时） |
| 故障排查 / 支持范围变化 | `docs/guides/troubleshooting.md` + `docs/guides/support-policy.md` |
| 商业化报价 / 工期 / 成本预估变化 | `docs/business/quotation-estimate.md` |
| 客户确认、外部依赖或待决策结论变化 | `docs/business/customer-confirmation.md` |
| 已确认基线后的范围、工期、费用或验收变化 | `docs/business/change-request-template.md` |
| 交付物、验收证据、遗留项或交接结果变化 | `docs/business/delivery-acceptance.md` |
| 开源许可证决策或第三方通知义务变化 | `docs/guides/license-selection.md` |
| 开源维护者、决策权、发布权或继任规则变化 | `docs/guides/open-source-governance.md` |
| 版本发布 | `CHANGELOG.md` |

## 命名建议

- 文件名统一使用 **英文 kebab-case**
- 标题正文可使用中文
- 目录分层不宜过深，通常不超过 3 层

## 组合与裁剪规则

不是所有项目都需要全部文档。初始化时遵守以下顺序：

1. 选择最接近的 profile。
2. 只加入项目事实明确需要的能力 pack。
3. API、数据库、UI、权限、运维、团队和 AI plan 均不得仅凭项目名称自动推断。
4. 个人项目可以叠加 `open-source` 或 `commercial`；商业项目也可以同时公开开源。
5. 多人协作时再加入 `team`；使用文件式 AI 任务计划时再加入 `ai-planning`。
6. 只有仓库托管在 GitHub 时才加入 `github` / `github-ci`；`github-ci` 可在初始化时选中，但必须等活动文档填完并本地检查通过后再创建 `.docs-template/strict-ci`。
7. 生成后以 `.docs-template/state.tsv` 和 `docs/README.md` 的实际文件清单为准。

## 可选扩展文档

在基础目录之外，下列模板按需启用：

| 模板 | 触发条件 | 典型受众 |
|------|----------|----------|
| `docs/glossary.md` | 业务术语/缩写易混淆，或跨团队协作 | 全员 |
| `docs/guides/onboarding.md` | 有新人入职需要快速上手 | 新成员 |
| `docs/guides/team-collaboration.md` | 多人协作、Code Review、模块责任需要统一 | 全员 |
| `docs/design/page-module-contract.md` | 多人并行开发同一页面，需要冻结模块顺序、文件边界和验收口径 | 前端 + Reviewer + AI 编程成员 |
| `docs/design/component-api-contract.md` | 同名组件职责、props、emits、slots 或样式前缀容易冲突 | 前端 + Reviewer + AI 编程成员 |
| `docs/guides/merge-conflict-playbook.md` | 多分支合并冲突频繁，需要轻量分类、模拟合并和退回规则 | 集成负责人 + 模块负责人 |
| `docs/guides/integration-guide-template.md` | 需要面向调用方说明接口、SDK 或第三方服务如何接入 | 前端 / 移动端 / 第三方调用方 |
| `docs/design/frontend-backend-contract-check.md` | 联调时需要对照页面行为、接口契约和缺口优先级 | 前端 + 后端 + QA |
| `docs/guides/technical-migration-plan.md` | 需要规划框架升级、UI 库替换、构建工具切换或模块迁移 | Tech Lead / 开发团队 |
| `docs/devlog/postmortem-template.md` | 需要沉淀异常、事故、复杂排障或失败方案复盘 | 团队 |
| `docs/guides/project-failure-patterns-and-prevention.md` | 需要把多次问题提炼为跨事件可复用的失误模式和预防门禁 | 团队 / Reviewer |
| `docs/business/quotation-estimate.md` | 商业化项目需要报价、工期、成本和风险缓冲预估 | Owner / 商务 / Tech Lead |
| `docs/business/customer-confirmation.md` | 商业项目需要固定范围、客户依赖、待决策项和确认证据 | 客户决策人 / Owner / Tech Lead |
| `docs/business/delivery-acceptance.md` | 商业项目需要记录交付物、验收证据、遗留项和资产交接 | 客户验收人 / 交付负责人 |
| `docs/business/change-request-template.md` | 已确认基线后出现范围、工期、费用或验收变化 | 客户决策人 / Owner / 商务 |
| `docs/guides/contributor-guide-template.md` | 需要面向贡献者说明 Issue、PR、测试、Review 和变更记录流程 | 维护者 / 贡献者 |
| `docs/design/rfc-template.md` | 变更影响多个模块、对外契约或协作边界，需要先评审设计提案 | Tech Lead / Reviewer |
| `docs/guides/migration-guide-template.md` | 需要指导使用方从旧版本迁移到新版本 | 使用方 / 支持团队 |
| `docs/guides/troubleshooting.md` | 需要沉淀常见故障现象、检查命令、解决步骤和升级路径 | 开发 / 支持 / 运维 |
| `docs/guides/support-policy.md` | 需要定义支持渠道、响应级别、不支持事项和维护版本 | Owner / 支持团队 |
| `docs/guides/license-selection.md` | 公开项目需要选择真实许可证并核对第三方义务 | 维护者 / 法务或组织负责人 |
| `docs/guides/open-source-governance.md` | 开源项目需要明确维护者、决策、权限、退出和继任规则 | 维护者 / 贡献者 |
| `docs/guides/security.md` | 涉及敏感数据、合规、对外接口 | 开发 + 安全负责人 |
| `docs/guides/runbook.md` | 存在线上部署 / 值班 / 告警 | 运维 / 值班 |
| `docs/design/api-changes.md` | 对外提供 API 且有外部调用方 | API 使用方 |

初始化器会按 manifest 复制选中的模板并生成实际文档清单。若后续人工新增文档，仍须同步 `docs/README.md`、根 README 和模板映射 / 检查契约。

## 开源协议

本模板仓库本身采用 [MIT License](LICENSE) 开源。初始化器不会将本仓库的 `LICENSE` 自动复制到下游项目；使用 `open-source` profile 生成新项目时，请仍按 `docs/guides/license-selection.md` 自行确认并添加目标项目的许可证文件。

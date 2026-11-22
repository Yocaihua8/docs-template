# 模板仓库维护说明

本文档只用于维护 `docs-template` 仓库自身，不属于下游项目文件。初始化器按 `scaffold/files.tsv` 精确分发，因此不会把本文件复制到目标项目。

## 1. 模板源文件边界

`scaffold/files.tsv` 是“哪些源文件可以进入下游项目”的唯一机器清单；`profiles.tsv` 与 `packs.tsv` 决定组合方式。未出现在清单中的仓库 README、示例、测试和维护 CI 不得进入生成产物。

初始化器只保证启动阶段的事务式生成、完全相同参数的幂等重跑和冲突零写入，不承担已修改项目的模板升级。后期增加 pack 时应生成到新的临时目录后人工合并；不要通过放宽 state 冲突或新增 force 覆盖既有项目文件。

所有 destination 在预检和实际复制前都必须逐段检查目标父链；Windows ReparsePoint / junction 与 Bash symlink 均不得出现在目标根或任何已存在父目录中。安全回归必须断言外部目录零写入，并覆盖浅层与嵌套父链。

以下文件虽然位于仓库根目录或 `docs/`，但仍是 manifest 引用的下游模板源；维护本仓库时不要写入本仓库真实执行记录：

- `docs/BACKLOG.md`：只保留待办和已知问题模板，不写本仓库真实任务条目。
- `CHANGELOG.md`：只保留变更记录模板，不写本仓库真实变更日志。
- `docs/plans/plan-template.md`：只保留 plan 格式模板，不写本仓库真实 plan。
- `AGENTS.md`：保留下游项目可复用的完整参考模板，不写“当前仓库是模板仓库”这类维护者专用规则；初始化器实际分发 `scaffold/templates/consumer-AGENTS.md` 的轻量基线。
- `CONTRIBUTING.md`、`.github/CODEOWNERS`、`.github/pull_request_template.md`：在仓库根目录保留作为完整参考模板与仓库自身维护校验对象；初始化器实际向消费项目分发的是 `scaffold/templates/` 下对应的轻量专用版本（`CONTRIBUTING.md`、`CODEOWNERS`、`pull_request_template.md`）。

下游专用、不能与仓库维护版本共用的入口放在 `scaffold/templates/`，包括轻量 AGENTS、项目 README、Consumer 文档索引、Consumer CI、CODEOWNERS、行为准则、贡献指南和 PR 模板。Consumer CI 属于显式 `github-ci` pack；默认 profile 只分发本地检查脚本，避免非 GitHub 项目收到 `.github/workflows/`。`github-ci` 的链接门禁立即生效，占位符门禁只有在使用方完成本地检查并创建 `.docs-template/strict-ci` 后才阻断。

新增、删除或重命名分发资产时必须同时检查：

1. `scaffold/files.tsv` 的 source、destination、pack、冲突和占位符策略。
2. `README.md`、`docs/README.md` 与 `template-mapping.md` 的人工入口。
3. profile 独立契约、初始化器回归以及 Consumer 占位符 / 本地链接门禁。

本仓库自身的真实维护过程通过提交信息、PR 描述或外部发布说明记录。

## 2. 本仓库维护检查

维护本模板仓库时至少运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\test-docs-template-checks.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\test-init-docs.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\test-doc-links.ps1
git diff --check
pwsh -NoProfile -File scripts\check-docs-consistency.ps1
pwsh -NoProfile -File scripts\check-placeholders.ps1 -Mode TemplateRepository
```

生成到具体项目后，使用 Consumer 模式检查活动文档。`.docs-template/state.tsv` 记录七列数据，检查器验证表头、路径、pack、policy 与 SHA-256。仅为清单允许的 `preserve-template` 路径豁免占位符。初始化器和检查器对这类 Markdown 的摘要统一按 LF 计算，保留 BOM、末行换行和其他字节差异。检查器也接受旧版记录的原始摘要或 CRLF 摘要。

```powershell
pwsh -NoProfile -File scripts\check-placeholders.ps1
pwsh -NoProfile -File scripts\check-doc-links.ps1
```

不要直接对模板仓库根目录运行 Consumer 链接门禁：`scaffold/templates/` 内的相对链接以生成后的 destination 为基准，在源目录中预期无法解析。`test-init-docs.ps1` 会分别生成 personal、commercial、open-source 到系统临时目录，再用 PowerShell / Bash 门禁检查真实 Consumer 布局。

链接门禁在 Git 工作区通过 `git ls-files` 选取已跟踪和未忽略的新文档。`scripts/.gitattributes` 固定 Bash 脚本的 LF 换行，便于在启用了自动换行转换的检出中直接运行回归。

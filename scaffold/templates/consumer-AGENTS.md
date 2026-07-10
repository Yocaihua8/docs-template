# AGENTS.md

> Project：{{PROJECT_NAME}}
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

本文件为 AI 编码助手提供当前项目的轻量操作上下文。它只定义通用协作边界，不假设项目使用特定平台、框架、数据库、界面形态或托管服务。

## 1. 项目速查

| 项 | 值 |
|----|----|
| 项目说明 | {{PROJECT_DESCRIPTION}} |
| 项目类型 | {{PROJECT_TYPE}} |
| 当前阶段 | {{PHASE}} |
| 主要用户 | {{TARGET_USERS}} |
| 生产内容根目录 | `{{SRC_DIR}}` |
| 包或依赖管理工具 | {{PACKAGE_MANAGER}} |

已声明的常用命令：

```text
安装依赖：{{INSTALL_COMMAND}}
本地运行：{{DEV_COMMAND}}
构建：{{BUILD_COMMAND}}
全量测试：{{TEST_ALL_COMMAND}}
```

若某项为 `TBD` 或 `N/A`，先从实际源码、配置和现有自动化中确认，不要自行编造命令或技术栈。

## 2. 开始任务前

1. 读取 `README.md` 与 `docs/README.md`，确认项目入口和已生成的文档集合。
2. 读取 `docs/requirements/project-background-and-scope.md`，确认目标、范围和非目标。
3. 读取 `docs/BACKLOG.md`，锁定任务、优先级与已知问题。
4. 读取 `docs/plans/README.md`，并检查 `docs/plans/` 中是否存在相关 Active / Interrupted plan。
5. 读取相关功能文档；新功能文档从 `docs/features/feature-template.md` 复制后填写。
6. 读取 `docs/guides/setup.md` 与当前仓库实际配置，确认可用命令和验证方式。
7. 检查工作区状态，保留用户已有改动，不覆盖无关文件。

若规则或文档之间冲突，先指出冲突和影响，不擅自选择方便实现的一方。

## 3. Plan 与 BACKLOG

- 代码或多文件行为变更开始前，按 `docs/plans/README.md` 关联 BACKLOG、扫描进行中的 plan，并创建或恢复本次 plan。
- plan 只记录本次执行方案；长期任务、已知问题和技术债回流到 `docs/BACKLOG.md`。
- 每完成一个可验证子任务，及时更新 plan 的任务勾选和状态快照。
- 任务完成后确认回流清单，更新 BACKLOG 状态，并按计划生命周期规则删除已完成 plan。
- 纯问答、只读查阅和单行文字修复可不创建 plan。

## 4. 实施边界

- 只修改与当前任务直接相关的文件，保持现有目录、命名和依赖方向。
- 不把其他项目的业务实体、接口路径、页面名称或技术方案套入本项目。
- 不做无关重构，不删除暂时不理解的行为，不用假数据或 mock 掩盖未完成能力。
- 不硬编码密钥、Token、密码或真实个人信息。
- 删除公共接口、修改持久化结构、变更认证权限或引入跨模块依赖前，先说明影响并取得确认。
- 未明确要求时，不自动提交、推送、合并或发布。

## 5. 可选能力文档

以下规则只在对应 pack 已启用且文件实际生成时适用；文件不存在时不得假定项目具备该能力：

| 能力 | 启用后优先读取 / 同步 |
|------|----------------------|
| 完整需求 | `docs/requirements/functional-modules.md`、`docs/requirements/use-cases.md`、`docs/requirements/mvp-scope-freeze.md` |
| 架构与决策 | `docs/design/architecture-overview.md`、`docs/adr/` |
| API | `docs/design/api-spec.md`、`docs/design/api-changes.md` |
| 数据或持久化 | `docs/design/database-design.md` |
| 团队协作 | `CONTRIBUTING.md`、`docs/guides/team-collaboration.md`、`docs/guides/branch-conventions.md` |
| 本地质量工具 | `docs/guides/testing.md` 与已生成的 `scripts/check-*.ps1` / `scripts/check-*.sh` |
| 版本发布 | `CHANGELOG.md`、`docs/guides/release-process.md` |
| 安全与运行 | 已生成的安全、运行手册、故障排查和复盘文档 |

## 6. 验证与文档回流

- 优先运行与改动最接近的现有测试，再按风险运行构建或全量测试。
- 无法运行验证时，记录原计划命令、失败原因、关键报错和人工验证方式；未运行不得声称通过。
- 功能行为变化同步相关 `docs/features/<name>.md`；没有对应文档时，从功能模板创建。
- 可选能力的接口、数据、架构、团队或发布行为变化，仅在对应文档已生成时同步到 § 5 所列文件。
- 新发现的问题写入 `docs/BACKLOG.md`，不要只留在代码注释或临时对话中。

## 7. 完成时输出

最终说明应包含：实际修改内容、修改文件、已运行的验证及结果、文档同步情况，以及与本任务直接相关的剩余风险。不要夸大未完成或未验证的内容。

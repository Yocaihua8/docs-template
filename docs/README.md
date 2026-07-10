# 文档总览

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

本文档列出模板仓库提供的完整文档能力。下游项目由初始化器根据 profile / pack 生成专用 `docs/README.md`，只展示实际复制的文件；不要把本页的完整清单直接当成所有项目的必填要求。

## 1. 阅读顺序

建议按以下顺序阅读：

**先读（理解项目是什么）**：

1. `requirements/project-background-and-scope.md`
2. `design/system-design-overview.md`
3. `design/architecture-overview.md`
4. `design/api-spec.md`
5. `design/database-design.md`
6. `design/risk-register.md`
7. `features/`

**再读（参与开发前）**：

8. `../CONTRIBUTING.md`
9. `guides/setup.md`
10. `guides/branch-conventions.md`
11. `guides/team-collaboration.md`
12. `guides/testing.md`
13. `design/page-module-contract.md`（多人并行开发同一页面时）
14. `design/component-api-contract.md`（多人复用或修改同一组件时）

**按需读**：

15. `adr/*.md`（关心"为什么这么定"时）
16. `devlog/`（关心"最近做到哪"时）
17. `BACKLOG.md`（关心"还有什么要做"时）
18. `../CHANGELOG.md`（关心"对外发布了什么"时）
19. 可选扩展文档（见 § 2.2），例如接入手册、契约对照、迁移计划、问题复盘、贡献者指南、RFC、版本迁移、故障排查、支持范围模板和合并冲突手册

## 2. 目录说明

### 2.1 目录与启用条件

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `requirements/` | 项目背景、范围、用例、阶段 / 版本范围冻结 | 背景与范围属于 core；其余由 `requirements` pack 启用 |
| `design/` | 架构、接口、数据库、权限、状态流转 | 按 `architecture`、`workflow`、`api`、`data`、`frontend`、`frontend-api-contract` 等能力 pack 启用 |
| `features/` | 功能规格索引与可复用模板 | core |
| `adr/` | 架构决策记录 | `architecture` pack |
| `devlog/` | 开发过程日志（日/周） | `tracking` pack |
| `plans/` | AI 任务计划（与 BACKLOG 联动，执行完删除） | `ai-planning` pack |
| `business/` | 报价、客户确认、变更、验收与交接 | `commercial` pack |
| `guides/` | 环境、测试、发布、安全、协作与运维说明 | setup 属于 core；其余按所选 pack 启用 |
| `BACKLOG.md` | 已知问题、技术债、待办 | `tracking` pack |
| `style-guide.md` | 文档书写规范 | core |

### 2.2 可选扩展

按需启用；启用后**必须**同步 `../README.md § 推荐目录` 与 `../template-mapping.md § 8 可选扩展类`。

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `glossary.md` | 术语表 | 术语易混淆、跨团队协作 |
| `guides/onboarding.md` | 新人 Onboarding | 有新人入职场景 |
| `guides/team-collaboration.md` | 团队角色、RACI、Review、模块责任 | 多人协作或模块责任需要统一 |
| `design/page-module-contract.md` | 页面模块顺序、文件边界、`data-*` 标识和页面验收测试口径 | 多人并行开发同一页面 |
| `design/component-api-contract.md` | 组件职责、props、emits、slots、CSS class 前缀和 mock 数据依赖 | 同名组件或复用组件容易冲突 |
| `guides/merge-conflict-playbook.md` | integration 分支、只读模拟合并、冲突分类和缺陷退回规则 | 多分支合并冲突频繁 |
| `guides/contributor-guide-template.md` | 贡献者指南扩展模板 | 需要面向贡献者说明 Issue、PR、测试、Review 和变更记录流程 |
| `guides/integration-guide-template.md` | 接口 / 第三方服务接入手册 | 需要面向调用方说明接入、联调、错误处理 |
| `design/rfc-template.md` | RFC / 设计提案模板 | 变更影响多个模块、对外契约或协作边界，需要先评审方案 |
| `guides/migration-guide-template.md` | 版本 / 使用方迁移指南 | 需要指导使用方从旧版本迁移到新版本 |
| `design/frontend-backend-contract-check.md` | 前后端契约对照分析 | 需要排查页面行为、接口契约和缺口优先级 |
| `guides/technical-migration-plan.md` | 技术迁移计划 | 需要规划框架升级、UI 库替换、构建工具切换或模块迁移 |
| `guides/troubleshooting.md` | 故障排查模板 | 需要沉淀常见故障现象、检查命令、解决步骤和升级路径 |
| `guides/support-policy.md` | 支持范围模板 | 需要定义支持渠道、响应级别、不支持事项、安全入口和维护版本 |
| `devlog/postmortem-template.md` | 问题复盘模板 | 需要沉淀异常、事故、复杂排障或失败方案 |
| `business/quotation-estimate.md` | 商业化项目报价、工期、成本和风险缓冲预估 | 项目需要对外报价或交付周期承诺 |
| `business/customer-confirmation.md` | 客户确认、外部依赖和待决策事项 | 商业项目需要固定双方已确认事实和等待项 |
| `business/delivery-acceptance.md` | 交付物、验收证据、遗留项和项目交接 | 商业项目进入交付或验收阶段 |
| `business/change-request-template.md` | 已确认基线后的变更请求模板 | 范围、工期、费用或验收口径发生变化 |
| `guides/license-selection.md` | 开源许可证选择与落地检查 | 项目准备公开授权或调整许可证 |
| `guides/open-source-governance.md` | 开源维护者、决策、权限和继任治理 | 项目接受外部使用或贡献 |
| `guides/security.md` | 安全与合规规范 | 涉及敏感数据或合规要求 |
| `guides/runbook.md` | 运维手册 | 存在线上部署或值班体系 |
| `design/api-changes.md` | API 破坏性变更与迁移指南 | 对外提供 API 且有外部调用方 |
| `design/ui-wireframes.md` | 页面结构与线框示意 | 含 UI 的项目 |

## 3. 维护规则

- 需求变更先改 `requirements/`
- 设计变更同步改 `design/`
- 架构模式、三层边界、端口与适配器关系变更同步改 `design/architecture-overview.md`
- 页面结构、导航入口或核心页面布局变更同步改 `design/ui-wireframes.md`
- 页面模块顺序、`data-*` 标识、页面文件边界或页面验收测试口径变化同步改 `design/page-module-contract.md`
- 组件职责、props、emits、slots、CSS class 前缀或 mock 数据依赖变化同步改 `design/component-api-contract.md`
- 单模块行为变更同步改 `features/`
- 重大方案变更补充 ADR（触发条件见 § 4）
- 开发过程性记录写入 `devlog/`，重大决策提升至 ADR
- 问题复盘使用 `devlog/postmortem-template.md`，结论和行动项回流到 BACKLOG / ADR / 正式文档
- 未落地规划不写入定稿文档
- 技术栈、目录结构、架构边界或关键命令变更同步改 `../AGENTS.md`
- 多人合并冲突处理规则、integration 分支或缺陷退回规则变化同步改 `guides/merge-conflict-playbook.md`
- 接口 / 第三方服务接入说明变化同步改 `guides/integration-guide-template.md`
- 前后端契约对照或联调缺口变化同步改 `design/frontend-backend-contract-check.md`
- 技术迁移阶段、工时、风险或回滚策略变化同步改 `guides/technical-migration-plan.md`
- PR 模板、CODEOWNERS、分支保护或 CI 门禁变化同步改 `../.github/`、`guides/branch-conventions.md` 和 `guides/team-collaboration.md`
- Issue 模板或贡献者参与流程变化同步改 `../.github/ISSUE_TEMPLATE/` 和 `guides/contributor-guide-template.md`
- RFC / 设计提案流程变化同步改 `design/rfc-template.md`，若形成正式决策再同步 `adr/`
- 面向使用方的版本迁移步骤变化同步改 `guides/migration-guide-template.md`，涉及对外 API 时同步改 `design/api-changes.md`
- 故障排查路径、升级路径或支持范围变化同步改 `guides/troubleshooting.md` 和 `guides/support-policy.md`
- 商业化报价、工期、成本或风险缓冲口径变化同步改 `business/quotation-estimate.md`
- 客户确认、外部依赖和待决策事项变化同步改 `business/customer-confirmation.md`
- 基线后的范围、工期、费用或验收变化使用 `business/change-request-template.md` 创建实例
- 交付物、验收证据、遗留项或资产交接变化同步改 `business/delivery-acceptance.md`
- 开源许可证决策和第三方通知义务变化同步改 `guides/license-selection.md`
- 开源维护者、决策权、发布权或继任规则变化同步改 `guides/open-source-governance.md`

## 4. 何时应新建 ADR

满足以下任一条件**必须**新建 ADR：

- 技术选型存在多个可行方案，且决策会影响至少 2 个模块
- 存储 / 权限模型 / 认证方式 / 状态机 发生变化
- 跨服务的数据契约发生破坏性变更
- 用新方案**替代**现有方案（需保留历史理由）
- 依赖变更带来新的安全、合规或成本风险

以下情况**不必**新建 ADR，写入 `devlog/` 即可：

- 可逆的局部重构
- 不影响对外契约的实现细节调整
- 个人偏好或风格微调

在功能文档 (`features/*.md`) 中，凡是触发了 ADR 的功能，**必须**在文档头部 `Related ADR` 字段填入对应 ADR 编号。

## 5. 文档状态约定

建议统一使用以下状态：

- `Draft`：草稿
- `In Review`：评审中
- `Active`：当前有效
- `Deprecated`：已废弃
- `Archived`：已归档

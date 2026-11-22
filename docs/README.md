# 文档总览

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

本文档列出模板仓库提供的完整文档能力。下游项目由初始化器根据 profile / pack 生成专用 `docs/README.md`，只展示实际复制的文件；不要把本页的完整清单直接当成所有项目的必填要求。

## 1. 阅读顺序

按本次任务选择对应入口和章节；下表不是每次修改前的通读清单。已读取且仍适用的内容无需重复加载。

| 当前任务 | 阅读入口 |
|---|---|
| 选择文档能力或生成项目 | [仓库 README](../README.md) 的 profile / pack 与 `../template-mapping.md` |
| 了解产品或确定范围 | `requirements/project-background-and-scope.md`；完整需求仅在对应 pack 启用时查阅 |
| 修改功能、架构、API 或数据 | 相关 `features/` 规格及已启用的 architecture / api / data 文档 |
| 环境、测试或团队协作 | 按需选择 `guides/setup.md`、`guides/testing.md`、`guides/team-collaboration.md` |
| 并行改页面或共享组件 | `design/page-module-contract.md` 或 `design/component-api-contract.md` |
| 恢复任务、查看决策或发布 | 按需选择 `plans/`、`BACKLOG.md`、`adr/`、`devlog/` 或 `../CHANGELOG.md` |

先以任务涉及的正式规格和当前源码核对事实；历史计划与验收记录只说明其对应范围和版本。

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

按需启用；启用后**必须**同步 `../README.md § 推荐目录` 与 `../template-mapping.md § 9 可选扩展类`。

#### 设计与契约

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `design/system-design-overview.md` | 系统边界、核心流程与非功能设计总览（代码分层见 `architecture-overview.md`） | 需要独立说明系统级流程与非功能指标 |
| `design/rfc-template.md` | RFC / 设计提案模板 | 变更影响多个模块、对外契约或协作边界，需要先评审方案 |
| `design/api-changes.md` | API 破坏性变更与迁移指南 | 对外提供 API 且有外部调用方 |
| `design/ui-wireframes.md` | 页面结构与线框示意 | 含 UI 的项目 |
| `design/page-module-contract.md` | 页面模块顺序、文件边界、`data-*` 标识和页面验收测试口径 | 多人并行开发同一页面 |
| `design/component-api-contract.md` | 组件职责、props、emits、slots、CSS class 前缀和 mock 数据依赖 | 同名组件或复用组件容易冲突 |
| `design/frontend-backend-contract-check.md` | 前后端契约对照分析 | 需要排查页面行为、接口契约和缺口优先级 |
| `glossary.md` | 术语表 | 术语易混淆、跨团队协作 |

#### 团队协作与上手

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `guides/onboarding.md` | 新人 Onboarding | 有新人入职场景 |
| `guides/team-collaboration.md` | 团队角色、RACI、Review、模块责任 | 多人协作或模块责任需要统一 |
| `guides/merge-conflict-playbook.md` | integration 分支、只读模拟合并、冲突分类和缺陷退回规则 | 多分支合并冲突频繁 |
| `guides/contributor-guide-template.md` | 贡献者指南扩展模板 | 需要面向贡献者说明 Issue、PR、测试、Review 和变更记录流程 |

#### 商业交付

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `business/quotation-estimate.md` | 商业化项目报价、工期、成本和风险缓冲预估 | 项目需要对外报价或交付周期承诺 |
| `business/customer-confirmation.md` | 客户确认、外部依赖和待决策事项 | 商业项目需要固定双方已确认事实和等待项 |
| `business/delivery-acceptance.md` | 交付物、验收证据、遗留项和项目交接 | 商业项目进入交付或验收阶段 |
| `business/change-request-template.md` | 已确认基线后的变更请求模板 | 范围、工期、费用或验收口径发生变化 |

#### 开源治理、安全与支持

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `guides/license-selection.md` | 开源许可证选择与落地检查 | 项目准备公开授权或调整许可证 |
| `guides/open-source-governance.md` | 开源维护者、决策、权限和继任治理 | 项目接受外部使用或贡献 |
| `guides/security.md` | 安全与合规规范 | 涉及敏感数据或合规要求 |
| `guides/support-policy.md` | 支持范围模板 | 需要定义支持渠道、响应级别、不支持事项、安全入口和维护版本 |

#### 运维、复盘与迁移

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `guides/runbook.md` | 运维手册 | 存在线上部署或值班体系 |
| `guides/troubleshooting.md` | 故障排查模板 | 需要沉淀常见故障现象、检查命令、解决步骤和升级路径 |
| `devlog/postmortem-template.md` | 问题复盘模板 | 需要沉淀异常、事故、复杂排障或失败方案 |
| `guides/project-failure-patterns-and-prevention.md` | 通用失误与预防清单 | 需要把多次问题提炼为跨事件可复用的控制规则 |
| `guides/integration-guide-template.md` | 接口 / 第三方服务接入手册 | 需要面向调用方说明接入、联调、错误处理 |
| `guides/migration-guide-template.md` | 版本 / 使用方迁移指南 | 需要指导使用方从旧版本迁移到新版本 |
| `guides/technical-migration-plan.md` | 技术迁移计划 | 需要规划框架升级、UI 库替换、构建工具切换或模块迁移 |

## 3. 维护规则

- 需求变更先改 `requirements/`
- 设计变更同步改 `design/`
- 架构模式、三层边界、端口与适配器关系变更同步改 `design/architecture-overview.md`
- 页面结构、导航入口或核心页面布局变更同步改 `design/ui-wireframes.md`
- 页面模块顺序、`data-*` 标识、页面文件边界或页面验收测试口径变化同步改 `design/page-module-contract.md`
- 组件职责、props、emits、slots、CSS class 前缀或 mock 数据依赖变化同步改 `design/component-api-contract.md`
- 单模块行为变更同步改 `features/`
- 重大方案变更按 [ADR 新建条件](adr/README.md#1-何时需要新增-adr)记录决策
- 开发过程性记录写入 `devlog/`，重大决策提升至 ADR
- 问题复盘使用 `devlog/postmortem-template.md`，结论和行动项回流到 BACKLOG / ADR / 正式文档
- 跨事件重复出现的失误模式和预防门禁同步改 `guides/project-failure-patterns-and-prevention.md`
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

[ADR 索引中的新建条件](adr/README.md#1-何时需要新增-adr)列出了必须记录的决策、可以直接记入变更说明的情况，以及功能文档关联 ADR 的方式。

## 5. 文档状态约定

建议统一使用以下状态：

- `Draft`：草稿
- `In Review`：评审中
- `Active`：当前有效
- `Deprecated`：已废弃
- `Archived`：已归档

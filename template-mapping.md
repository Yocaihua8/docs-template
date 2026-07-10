# 原始文档到模板结构的归类说明

这份说明用于帮助你把旧项目文档迁移到统一模板中。

> **维护同步要求**
> 本文件的目录清单必须与以下两处保持一致，任何一处变更需同步另外两处：
>
> - `README.md` § 推荐目录
> - `docs/README.md` § 2. 目录说明
> - `template-mapping.md`（本文件）各"归入位置"清单
>
> 建议作为 PR 检查项，或通过脚本比对目录树与以上三处的文件清单。

## 1. 工程协作类

### 来源
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- 原有分支/测试/协作相关说明

### 归入位置
- `AGENTS.md`（AI 编码助手操作上下文；下游文件由 `scaffold/templates/consumer-AGENTS.md` 生成，仓库根 `AGENTS.md` 保留为完整参考模板，不再由初始化器直接分发）
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/`
- `.github/CODEOWNERS`
- `.github/workflows/docs-template-checks.yml`
- `docs/style-guide.md`（写作规范 / 占位符约定）
- `docs/features/README.md`（功能文档目录索引）
- `docs/adr/README.md`（ADR 目录索引）
- `docs/devlog/README.md`（开发日志目录索引）
- `docs/plans/README.md`（AI 任务计划目录索引）
- `docs/guides/branch-conventions.md`
- `docs/guides/team-collaboration.md`
- `docs/guides/merge-conflict-playbook.md`
- `docs/guides/testing.md`
- `docs/guides/release-process.md`
- `docs/guides/setup.md`
- `docs/guides/contributor-guide-template.md`
- `docs/guides/integration-guide-template.md`
- `docs/guides/migration-guide-template.md`
- `docs/guides/technical-migration-plan.md`
- `docs/guides/troubleshooting.md`
- `docs/guides/support-policy.md`

## 2. 需求分析类

### 来源
- 软件工程前期设计文档
- 功能模块设计
- 用例图
- 阶段 / 版本范围冻结（包括 MVP、迁移、维护或交付批次）

### 归入位置
- `docs/requirements/project-background-and-scope.md`
- `docs/requirements/functional-modules.md`
- `docs/requirements/use-cases.md`
- `docs/requirements/mvp-scope-freeze.md`

## 3. 系统设计类

### 来源
- 系统设计总览
- 架构设计说明
- 接口设计文档 / API 文档
- 数据库详细设计
- 权限矩阵
- 状态流转与验收标准
- UI 线框图
- 页面模块契约
- 组件 API 契约
- 前后端契约对照分析
- 数据分析模型设计

### 归入位置
- `docs/design/system-design-overview.md`
- `docs/design/architecture-overview.md`
- `docs/design/api-spec.md`
- `docs/design/database-design.md`
- `docs/design/permission-matrix.md`
- `docs/design/state-flow-and-acceptance.md`
- `docs/design/ui-wireframes.md`
- `docs/design/page-module-contract.md`
- `docs/design/component-api-contract.md`
- `docs/design/frontend-backend-contract-check.md`

### 说明
- 若项目包含算法/模型设计，可在 `docs/design/` 下新增 `analysis-model-design.md`
- 若项目偏 AI / OCR / RAG，可新增 `ai-pipeline-design.md`
- 若需要描述页面结构或导航入口，统一归入 `docs/design/ui-wireframes.md`
- 若多人并行开发同一页面，需要冻结页面模块顺序、文件边界、`data-*` 标识和页面验收口径，归入 `docs/design/page-module-contract.md`
- 若同名组件职责、props、emits、slots、CSS class 前缀或 mock 数据容易冲突，归入 `docs/design/component-api-contract.md`
- 若需要描述总体架构模式（如三层架构、六边形架构），统一归入 `docs/design/architecture-overview.md`；若涉及重要取舍或迁移，需同步写入 `docs/adr/*.md`

## 4. 功能规格类

### 来源
- 某一个模块的详细说明
- 某个页面、某条业务链路的行为说明

### 归入位置
- `docs/features/*.md`
- 首次编写建议复制 `docs/features/feature-template.md`

## 5. 决策与风险类

### 来源
- 风险评估
- 技术选型说明
- 替代方案分析
- RFC / 设计提案

### 归入位置
- `docs/design/risk-register.md`
- `docs/design/rfc-template.md`
- `docs/adr/*.md`

## 6. 待办与规划类

### 来源
- 已知问题
- 技术债
- 尚未做的规划功能
- 后续路线图草案

### 归入位置
- `docs/BACKLOG.md`

## 7. 开发过程记录类

### 来源
- 开发日志 / 日报 / 周报
- 问题复盘 / 事故复盘 / 复杂排障总结
- 调试过程笔记
- 临时决策记录（未达到 ADR 等级）
- 迭代进展记录
- AI 编码助手生成的任务计划

### 归入位置
- `docs/devlog/YYYY/MM/YYYY-MM-DD.md`（日报）
- `docs/devlog/YYYY/MM/YYYY-Www.md`（周报，按记录创建日期所属月份归档）
- 首次编写建议复制 `docs/devlog/devlog-template.md`
- 问题复盘建议复制 `docs/devlog/postmortem-template.md`，实际文件放入 `docs/devlog/YYYY/MM/`
- `docs/plans/{{B_ID}}-{{SLUG}}.md`（AI 任务计划，与 BACKLOG 条目对应）
- 首次编写建议复制 `docs/plans/plan-template.md`

### 说明
- 重大决策须从 devlog / plan 提升到 `docs/adr/`
- 跨迭代的待办须从 devlog / plan 提升到 `docs/BACKLOG.md`
- devlog 仅保留过程记录，不承担定稿职责
- postmortem 用于沉淀一次问题的根因、失败方案、最终方案和防复发动作；行动项必须回流到 BACKLOG / ADR / 正式文档
- plan 文件在任务完成、回流清单全部勾选后删除

## 8. 商务 / 报价 / 工期 / 成本预估类

### 来源
- 商业报价单
- 工期预估表
- 成本拆分表
- SOW / Statement of Work
- 付款节点、变更计费与维护费用说明
- 客户确认单、待决策清单和外部依赖清单
- 交付物基线、验收证据和项目交接清单

### 归入位置
- `docs/business/quotation-estimate.md`
- `docs/business/customer-confirmation.md`
- `docs/business/delivery-acceptance.md`
- `docs/business/change-request-template.md`

### 说明
- 报价和工期应使用区间估算，避免单点结论被误读为固定承诺。
- 工期必须同时区分人日 / 人周与日历周期，并列出并行度、关键路径、外部依赖和等待时间。
- 变更计费、维护费用、税费和第三方服务费用应单独列出，不要混入功能文档。
- 客户确认单只记录双方已确认事实和待决策事项，不替代合同或法务文件。
- 基线变化使用独立变更请求评估，交付阶段用验收与交接文档记录实际证据。

## 9. 可选扩展类

以下文档**按需启用**，启用后需同步 `docs/README.md` § 目录说明。

| 来源 | 归入位置 | 启用条件 |
|------|----------|----------|
| 术语表、业务词汇、缩写定义 | `docs/glossary.md` | 术语易混淆、跨团队协作 |
| 新人上手清单、入职指南 | `docs/guides/onboarding.md` | 有新人入职场景 |
| 团队角色、RACI、模块责任、评审流转 | `docs/guides/team-collaboration.md` | 多人协作或模块责任需要统一 |
| 页面模块顺序、文件边界、`data-*` 标识、页面验收口径 | `docs/design/page-module-contract.md` | 多人并行开发同一页面、首页改版、页面复刻或活动页 |
| 组件职责、props、emits、slots、样式前缀、mock 数据依赖 | `docs/design/component-api-contract.md` | 同名组件职责不一致，或可复用组件被多人并行修改 |
| 合并冲突分类、integration 分支、只读模拟合并、缺陷退回规则 | `docs/guides/merge-conflict-playbook.md` | 多分支合并冲突频繁，集成负责人需要轻量处理手册 |
| 贡献者指南、Issue / PR 参与流程、Review 期望 | `docs/guides/contributor-guide-template.md`；使用 GitHub 时再加入 `github` pack 的 `.github/ISSUE_TEMPLATE/` | 需要面向贡献者统一参与入口、环境准备、Issue、PR、测试和变更记录 |
| 接口接入手册、第三方服务接入说明、SDK 接入说明 | `docs/guides/integration-guide-template.md` | 需要面向调用方说明环境、认证、请求响应、错误码、联调和故障排查 |
| RFC、设计提案、跨模块变更评审 | `docs/design/rfc-template.md` | 变更影响多个模块、对外契约、迁移成本或协作边界，需要先评审方案 |
| 版本迁移、使用方升级指南、破坏性变更迁移步骤 | `docs/guides/migration-guide-template.md` | 需要指导使用方从旧版本迁移到新版本，并提供回滚和验证清单 |
| 前后端接口对照、联调缺口分析、页面行为与接口契约核对 | `docs/design/frontend-backend-contract-check.md` | 需要对照页面行为、现有接口、缺失接口、优先级和修复建议 |
| 框架升级、UI 库替换、构建工具切换、模块迁移计划 | `docs/guides/technical-migration-plan.md` | 需要描述原系统盘点、目标方案、组件映射、阶段计划、工时、风险和回滚 |
| 故障排查、常见错误、升级路径 | `docs/guides/troubleshooting.md` | 需要沉淀现象、可能原因、检查命令、解决步骤和收集信息清单 |
| 支持渠道、响应级别、不支持事项、维护版本 | `docs/guides/support-policy.md` | 需要定义支持范围、安全问题入口、升级路径和维护版本 |
| 事故复盘、问题复盘、复杂排障总结 | `docs/devlog/postmortem-template.md` | 需要沉淀时间线、失败方案、最终方案、根因和防复发动作 |
| 商业报价、工期预估、成本拆分、付款节点 | `docs/business/quotation-estimate.md` | 商业化项目需要对外报价或承诺交付周期 |
| 客户范围、依赖、待决策项和确认记录 | `docs/business/customer-confirmation.md` | 商业项目启动前后需要固定双方已确认事实 |
| 交付物、验收证据、遗留项、环境与资产交接 | `docs/business/delivery-acceptance.md` | 商业项目进入交付、验收或质保交接阶段 |
| 已确认基线后的范围、工期、费用或验收变化 | `docs/business/change-request-template.md` | 变更需要先评估影响并取得双方结论 |
| 开源许可证选择、SPDX 标识、第三方通知义务 | `docs/guides/license-selection.md` | 公开项目需要真实授权且不能使用占位许可证 |
| 维护者、决策方式、发布安全权限、退出与继任 | `docs/guides/open-source-governance.md` | 开源项目接受外部使用或贡献，需要明确治理边界 |
| 安全要求、合规清单、事件响应 | `docs/guides/security.md` | 涉及敏感数据或合规要求 |
| 运维手册、告警响应、值班交接 | `docs/guides/runbook.md` | 存在线上部署或值班体系 |
| API 破坏性变更与迁移指南 | `docs/design/api-changes.md` | 对外提供 API 且有外部调用方 |

## 10. 不建议继续保留的写法

以下内容不建议在正式文档中继续混写：

- “当前已实现”和“未来想做”写在同一章节
- 系统设计文档中混入大量具体项目宣传式描述
- 接口文档中夹带需求背景和路线图
- 功能文档里混入技术债和待办事项
- 单个文档同时承担需求、设计、实现说明三种角色

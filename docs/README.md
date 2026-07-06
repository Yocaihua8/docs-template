# 文档总览

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}

本文档用于说明项目文档的目录结构、阅读顺序和维护边界。

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

**按需读**：

13. `adr/*.md`（关心"为什么这么定"时）
14. `devlog/`（关心"最近做到哪"时）
15. `BACKLOG.md`（关心"还有什么要做"时）
16. `../CHANGELOG.md`（关心"对外发布了什么"时）
17. 可选扩展文档（见 § 2.2）

## 2. 目录说明

### 2.1 核心目录

| 路径 | 用途 | 是否必需 |
|------|------|----------|
| `requirements/` | 需求背景、范围、用例、MVP | 是 |
| `design/` | 架构、接口、数据库、权限、状态流转 | 是 |
| `features/` | 各功能模块规格说明 | 建议 |
| `adr/` | 架构决策记录 | 建议 |
| `devlog/` | 开发过程日志（日/周） | 建议 |
| `plans/` | AI 任务计划（与 BACKLOG 联动，执行完删除） | 建议 |
| `business/` | 商业化项目报价、工期与成本预估 | 可选 |
| `guides/` | 开发/测试/发布/分支协作说明 | 建议 |
| `BACKLOG.md` | 已知问题、技术债、待办 | 是 |
| `style-guide.md` | 文档书写规范 | 是 |

### 2.2 可选扩展

按需启用；启用后**必须**同步 `../README.md § 推荐目录` 与 `../template-mapping.md § 8 可选扩展类`。

| 路径 | 用途 | 启用条件 |
|------|------|----------|
| `glossary.md` | 术语表 | 术语易混淆、跨团队协作 |
| `guides/onboarding.md` | 新人 Onboarding | 有新人入职场景 |
| `guides/team-collaboration.md` | 团队角色、RACI、Review、模块责任 | 多人协作或模块责任需要统一 |
| `business/quotation-estimate.md` | 商业化项目报价、工期、成本和风险缓冲预估 | 项目需要对外报价或交付周期承诺 |
| `guides/security.md` | 安全与合规规范 | 涉及敏感数据或合规要求 |
| `guides/runbook.md` | 运维手册 | 存在线上部署或值班体系 |
| `design/api-changes.md` | API 破坏性变更与迁移指南 | 对外提供 API 且有外部调用方 |
| `design/ui-wireframes.md` | 页面结构与线框示意 | 含 UI 的项目 |

## 3. 维护规则

- 需求变更先改 `requirements/`
- 设计变更同步改 `design/`
- 架构模式、三层边界、端口与适配器关系变更同步改 `design/architecture-overview.md`
- 页面结构、导航入口或核心页面布局变更同步改 `design/ui-wireframes.md`
- 单模块行为变更同步改 `features/`
- 重大方案变更补充 ADR（触发条件见 § 4）
- 开发过程性记录写入 `devlog/`，重大决策提升至 ADR
- 未落地规划不写入定稿文档
- 技术栈、目录结构、架构边界或关键命令变更同步改 `../AGENTS.md`
- PR 模板、CODEOWNERS、分支保护或 CI 门禁变化同步改 `../.github/`、`guides/branch-conventions.md` 和 `guides/team-collaboration.md`
- 商业化报价、工期、成本或风险缓冲口径变化同步改 `business/quotation-estimate.md`

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

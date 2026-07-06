# 团队协作规范

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

本文档定义团队化开发中的角色、责任边界、协作流转、沟通渠道与模块责任归属。它补充 `../../CONTRIBUTING.md` 与 `branch-conventions.md`，不替代具体项目的组织制度。

## 1. 角色定义

| 角色 | 职责 | 典型产出 |
|------|------|----------|
| Owner | 对业务目标、范围、优先级和最终验收负责 | BACKLOG 优先级、验收结论、发布取舍 |
| Tech Lead | 对技术方案、架构边界和关键风险负责 | 技术方案、ADR、模块边界裁决 |
| Reviewer | 对代码质量、测试覆盖和文档同步负责 | Review 结论、阻塞意见、改进建议 |
| Dev | 对具体实现、测试和文档回流负责 | 代码、测试、功能文档、devlog |
| QA | 对测试策略、验收场景和回归风险负责 | 测试计划、缺陷记录、验收报告 |
| Ops | 对部署、监控、回滚和运行风险负责 | 发布检查、监控项、回滚记录 |

## 2. RACI 责任矩阵

| 活动 | Owner | Tech Lead | Reviewer | Dev | QA | Ops |
|------|-------|-----------|----------|-----|----|-----|
| BACKLOG 优先级确认 | A | C | I | C | C | I |
| 需求可开发确认 | A | C | I | R | C | I |
| 技术方案与架构边界 | C | A/R | C | C | I | C |
| 功能实现 | I | C | C | A/R | I | I |
| Code Review | I | C | A/R | R | C | I |
| 测试与验收 | A | C | C | R | A/R | C |
| 发布与回滚 | A | C | I | C | C | A/R |

说明：

- R = Responsible：实际执行。
- A = Accountable：最终负责，只建议一人或一个角色。
- C = Consulted：需参与讨论并给出意见。
- I = Informed：需同步进展或结果。

## 3. 需求到发布流转

团队协作默认按以下流转推进：

```text
BACKLOG -> plan 冲突扫描 -> branch -> PR -> CODEOWNERS Review -> CI -> review -> merge -> devlog/release
```

| 阶段 | 入口条件 | 输出 |
|------|----------|------|
| BACKLOG | 条目有标题、类型、优先级、负责人和关联文档 | 状态为 `todo` 或 `doing` 的可执行事项 |
| plan 冲突扫描 | 已识别影响范围 | 与 Active / Interrupted plan 的重叠结果与解决方式 |
| branch | BACKLOG 条目已确认可做 | 符合 `branch-conventions.md` 的短期分支 |
| PR | 代码、测试、文档已完成自查 | 影响范围、文件/模块锁定、并行冲突扫描、关联文档 |
| CODEOWNERS Review | PR 命中 `.github/CODEOWNERS` 规则 | 模块 Owner 或默认 Reviewer 被自动请求评审 |
| CI | PR 已创建或更新 | 模板检查、项目测试和构建结果 |
| review | CI 通过且 Reviewer 已指派 | Review 结论、必要修改、风险说明 |
| merge | 阻塞评论已处理，必要文档已同步 | 合并到目标分支 |
| devlog/release | 发布检查通过，CHANGELOG 已更新 | 过程记录、版本发布、监控、回滚预案 |

## 4. 沟通渠道与升级路径

| 场景 | 首选渠道 | 升级路径 | 记录位置 |
|------|----------|----------|----------|
| 需求范围不清 | {{PRODUCT_CHANNEL}} | Owner | `docs/BACKLOG.md` 或需求文档 |
| 架构边界冲突 | {{TECH_CHANNEL}} | Tech Lead | `docs/adr/` 或 `docs/design/architecture-overview.md` |
| PR Review 阻塞 | PR 评论区 | Reviewer -> Tech Lead | PR 线程 |
| 测试验收阻塞 | {{QA_CHANNEL}} | QA -> Owner | 测试记录或 `docs/BACKLOG.md` |
| 发布 / 回滚风险 | {{OPS_CHANNEL}} | Ops -> Tech Lead -> Owner | `docs/guides/runbook.md` 或 release 记录 |

## 5. 模块责任表

每个长期维护模块都应该明确 Owner、备份负责人、评审人和关键风险。小型项目可直接维护在本节；大型项目可拆分到 `docs/design/ownership.md`，但必须在本节保留入口链接。

| 模块 / 目录 | 模块 Owner | 备份负责人 | 默认 Reviewer | 关键风险 | 关联文档 |
|-------------|------------|------------|----------------|----------|----------|
| {{MODULE_OR_PATH}} | {{OWNER}} | {{BACKUP_OWNER}} | {{REVIEWER}} | {{KEY_RISK}} | {{RELATED_DOC}} |

`.github/CODEOWNERS` 应与本表保持一致：本表说明责任边界，CODEOWNERS 负责在 PR 中触发默认评审。若两者冲突，以本表为责任源头，先更新本表，再同步 CODEOWNERS。

## 6. 多人并行开发规则

- 同一模块同时存在多个 PR 时，模块 Owner 必须确认合并顺序。
- 同一文件被多个任务修改时，优先按 BACKLOG 优先级与发布时间排序；无法兼容时由 Tech Lead 裁决。
- 影响公共接口、数据库、权限、状态机或模块边界的任务，必须在 PR 描述中列出影响范围。
- 若需要临时分区开发，必须在 plan 的冲突扫描或 PR 描述中写清各自负责的文件 / 模块边界。
- 每个 PR 必须填写并行冲突扫描结果；未扫描 Active / Interrupted plan 或同模块未合并 PR 的，不应进入 Review。
- `PR -> CODEOWNERS Review -> CI` 是合并前的最小门禁；CODEOWNERS Review 不替代人工判断，CI 通过也不代表可以绕过模块 Owner。
- 高风险变更（公共接口、数据库、权限、状态机、架构边界）至少需要模块 Owner 与 Tech Lead 之一参与 Review。

## 7. GitHub 门禁建议

若项目使用 GitHub，建议同时启用以下分支保护设置：

- Require pull request reviews before merging
- Require review from Code Owners
- Require status checks to pass before merging
- Restrict direct pushes to protected branches

这些设置不能只靠文档生效，必须由仓库管理员在 GitHub 分支保护规则中配置。`.github/workflows/docs-template-checks.yml` 只提供模板一致性检查；具体项目的业务测试、构建、部署检查需要在复制模板后追加。

---

## 附录：填写示例

下方为订单中心团队协作填写样例。**复制模板时请删除本附录**。

```markdown
## 1. 角色定义

| 角色 | 职责 | 典型产出 |
|------|------|----------|
| Owner | 运营后台范围与优先级 | v1.1 BACKLOG |
| Tech Lead | 订单域架构与导出链路设计 | ADR-005 |

## 5. 模块责任表

| 模块 / 目录 | 模块 Owner | 备份负责人 | 默认 Reviewer | 关键风险 | 关联文档 |
|-------------|------------|------------|----------------|----------|----------|
| `order/export` | 张三 | 李四 | 王五 | 大文件导出超时 | `../features/order-export.md` |
```

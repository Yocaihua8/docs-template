# {{PLAN_TITLE}}

> ⚠️ 创建此文件前，必须已完成以下操作（AI 自检）：
> - [ ] `docs/BACKLOG.md` 中已有或已新建对应 B-xxx 条目，状态为 `doing`
> - [ ] 该 BACKLOG 条目"说明"列已填入本文件路径
> - [ ] 下方"关联功能文档"和"关联设计文档"已按实际情况填写（不可留空占位符）

> 状态：Draft / Active / Interrupted / Done
> 创建时间：{{CURRENT_DATE}}
> 创建方：{{CREATOR}}（AI 助手名称 / 开发者姓名）
> 关联 BACKLOG：{{B_ID}}（必填；无对应条目时填 N/A 并说明原因）
> 关联功能文档：{{FEATURE_DOC}}（必填；若不存在则新建占位文件并填路径）
> 关联设计文档：{{DESIGN_DOC}}（按改动类型填写；不涉及则填 N/A）

## 1. 目标

说明本次任务要解决什么问题，以及完成后系统应处于什么状态。

## 2. 前置条件

完成本任务之前需要满足的条件或先读的文档：

- {{PREREQUISITE_1}}
- {{PREREQUISITE_2}}

## 3. 任务拆解

每完成一项，立即执行：① 勾选此处 ② `git commit` 保存进度 ③ 更新 § 8 状态快照。
未完成项不得删除。

- [ ] {{TASK_1}}
- [ ] {{TASK_2}}
- [ ] {{TASK_3}}

## 4. 影响范围

| 类型 | 路径 / 模块 | 变更方向 |
|------|------------|---------|
| 代码 | `{{FILE_OR_MODULE}}` | 新增 / 修改 / 删除 |
| 文档 | `{{DOC_PATH}}` | 新增 / 修改 |

## 5. 依赖与冲突

### 5.1 依赖的其他 plan

本 plan 开始前需要完成的 plan（否则会产生冲突）：

| plan 文件 | 依赖原因 |
|-----------|---------|
| {{PLAN_FILE_OR_NA}} | {{REASON}} |

### 5.2 与现有 plan 的重叠

创建本 plan 时扫描到的潜在冲突及解决方式：

| 冲突 plan | 重叠范围（文件 / 模块 / 接口） | 解决方式 |
|-----------|-------------------------------|---------|
| {{CONFLICTING_PLAN_OR_NA}} | {{OVERLAP}} | 等待 / 合并 / 本 plan 覆盖 / 分区 |

> 无冲突时两列均填 `N/A`。

## 6. 完成标准

全部勾选后方可删除本 plan 文件：

- [ ] 功能行为符合 `{{FEATURE_DOC}}` 的业务规则
- [ ] 测试通过（参照 `../guides/testing.md` 最低要求）
- [ ] 相关文档已同步（见下方"回流清单"）
- [ ] BACKLOG 条目 `{{B_ID}}` 状态已更新为 `done`

## 7. 回流清单

删除本文件前，确认以下内容已写入正式文档：

| 内容 | 目标文档 | 是否完成 |
|------|----------|----------|
| {{CONTENT_1}} | `{{TARGET_DOC_1}}` | [ ] |
| {{CONTENT_2}} | `{{TARGET_DOC_2}}` | [ ] |

若产生了重大技术决策，**必须**在删除 plan 前新建对应 ADR。

## 8. 执行记录

AI 在执行过程中记录关键决策、遇到的问题、与原计划的偏差。完成后有价值的内容提升至 devlog 或 ADR，其余随 plan 一起删除。

- {{NOTE_1}}

## 9. 状态快照

> **每完成 § 3 中的一个任务后立即更新**，不等到中断时才填。
> 目的：无论因额度耗尽、开发者中断还是主动结束，下一个 session 都能从此处冷启动。
> 正常完成后随 plan 一起删除。

- **最后更新**：{{CURRENT_LOCAL_DATETIME}}
- **进度**：已完成 {{COMPLETED_TASK_COUNT}} / {{TOTAL_TASK_COUNT}} 项（见 § 3 勾选状态）
- **最新 commit**：`{{COMMIT_HASH}}` — {{COMMIT_MESSAGE}}
- **代码状态**：{{CODE_STATE}}（分支名；是否有未提交改动；部分完成的模块）
- **下一步**：{{NEXT_TASK}}（§ 3 中下一个未勾选的任务）
- **续任务须知**：{{CONTEXT}}（环境前提、关键变量、踩过的坑；首次填写时可为空）

---

## 附录：填写示例

下方为订单批量导出任务的计划示例。**复制模板时请删除本附录**。

```markdown
# 订单批量导出（B-001）

> ⚠️ 创建此文件前，必须已完成以下操作（AI 自检）：
> - [x] `docs/BACKLOG.md` B-001 状态已改为 `doing`
> - [x] B-001 说明列已填入 `见 plans/B-001-order-export.md`
> - [x] 下方关联文档已按实际情况填写

> 状态：Active
> 创建时间：2026-05-10
> 创建方：Claude Code
> 关联 BACKLOG：B-001
> 关联功能文档：`../features/order-export.md`
> 关联设计文档：`../design/api-spec.md`、`../design/database-design.md`

## 1. 目标

实现运营同学将筛选后的订单导出为 CSV / Excel 的功能。
完成后：POST /v1/orders/export 接口可用，导出任务异步执行，结果通过站内信通知。

## 2. 前置条件

- 已读 `../features/order-export.md`（业务规则与异常流程）
- 已读 `../design/api-spec.md`（接口定义）
- 本地 Docker 可用（集成测试需要）

## 3. 任务拆解

- [x] 创建 ExportTask 数据库表及 Flyway 迁移脚本
- [x] 实现 ExportController（提交任务、查询状态）
- [ ] 实现 ExportTaskService（并发限流、任务创建、异步触发）
- [ ] 实现 ExportWorker（分批读取、写入对象存储）
- [ ] 单元测试：并发限流逻辑、50,000 行边界
- [ ] 集成测试：主流程 + 对象存储不可用场景

## 4. 影响范围

| 类型 | 路径 / 模块 | 变更方向 |
|------|------------|---------|
| 代码 | `src/main/java/order/export/` | 新增 |
| 代码 | `src/main/resources/db/migration/V5__export_task.sql` | 新增 |
| 文档 | `../design/database-design.md` | 修改（添加 export_tasks 表） |

## 5. 完成标准

- [ ] 功能行为符合 `../features/order-export.md` § 3 业务规则
- [ ] 测试通过（单元 + 集成）
- [ ] `../design/database-design.md` 已补充 export_tasks 表说明
- [ ] BACKLOG 条目 B-001 状态已更新为 `done`

## 6. 回流清单

| 内容 | 目标文档 | 是否完成 |
|------|----------|----------|
| export_tasks 表结构 | `../design/database-design.md` | [x] |
| 接口无变化（已定义） | `../design/api-spec.md` | [x] N/A |

## 7. 执行记录

- 2026-05-10：并发限流用 Redis INCR + TTL 实现，原方案（DB 行锁）在高并发下有性能问题，已在 ADR-008 记录。

## 8. 状态快照（示例：完成第 2 项后的正常更新）

- **最后更新**：2026-05-11 14:32
- **进度**：已完成 2 / 6 项
- **最新 commit**：`a3f9c12` — feat: add ExportController with task submit & status endpoints
- **代码状态**：分支 `feature/order-export`，无未提交改动
- **下一步**：实现 ExportTaskService（§ 3 第 3 项）
- **续任务须知**：Redis 客户端已注入 ExportTaskService，限流 key 格式 `export:user:{userId}`，TTL 60s；Worker 需从 `ObjectStorageConfig` 读 bucket 名
```

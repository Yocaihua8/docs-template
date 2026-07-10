# 团队协作规范

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

本文档定义团队化开发中的角色、责任边界、协作流转、沟通渠道与模块责任归属。它补充已生成的 `../../CONTRIBUTING.md` 与 `branch-conventions.md`，不替代具体项目的组织制度。PR、Merge Request 或其他变更评审入口下文统称“变更请求”。

## 1. 角色定义

| 角色 | 职责 | 典型产出 |
|------|------|----------|
| Owner | 对业务目标、范围、优先级和最终验收负责 | BACKLOG 优先级、验收结论、发布取舍 |
| Tech Lead | 对技术方案、模块边界和关键风险负责 | 技术方案、模块边界裁决；启用 `architecture` pack 时包含架构文档与 ADR |
| Reviewer | 对代码质量、测试覆盖和文档同步负责 | Review 结论、阻塞意见、改进建议 |
| Dev | 对具体实现、测试和文档回流负责 | 代码、测试、功能文档、devlog |
| QA | 对测试策略、验收场景和回归风险负责 | 测试计划、缺陷记录、验收报告 |
| Ops | 对部署、监控、回滚和运行风险负责 | 已启用发布 / 运维能力时的发布检查、监控项与回滚记录 |

小团队可合并角色；没有独立 QA、Ops 或 Tech Lead 时，在责任矩阵中写明由谁兼任或填 `N/A`，不要虚构岗位。

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

团队协作默认按以下平台无关流转推进；plan、托管平台评审、CODEOWNERS、自动 CI、发布和 DevLog 仅在对应能力启用时加入：

```text
任务入口 -> 影响范围 / 冲突扫描 -> 分支或变更集 -> 变更请求 -> 自动或人工验证 -> Review -> 合并 -> 实际记录入口
```

| 阶段 | 入口条件 | 输出 |
|------|----------|------|
| BACKLOG | 条目有标题、类型、优先级、负责人和关联文档 | 状态为 `todo` 或 `doing` 的可执行事项 |
| plan 冲突扫描（若启用 `ai-planning`） | 已识别影响范围 | 与 Active / Interrupted plan 的重叠结果与解决方式 |
| branch | BACKLOG 条目已确认可做 | 符合 `branch-conventions.md` 的短期分支 |
| 变更请求 | 代码、测试、文档已完成自查 | 影响范围、文件 / 模块锁定、并行冲突扫描、关联文档 |
| CODEOWNERS Review（若启用 `github`） | 变更命中 `.github/CODEOWNERS` 规则 | 模块 Owner 或默认 Reviewer 被自动请求评审 |
| 自动 / 人工验证 | 变更请求已创建或更新 | 已配置 CI 的结果，或可复核的人工验证记录 |
| review | 必需验证完成且 Reviewer 已指派 | Review 结论、必要修改、风险说明 |
| merge | 阻塞评论已处理，必要文档已同步 | 合并到目标分支 |
| 记录 / 发布（按需） | 已启用对应 tracking / release / operations 能力 | 过程记录、版本发布、监控或回滚预案 |

## 4. 沟通渠道与升级路径

| 场景 | 首选渠道 | 升级路径 | 记录位置 |
|------|----------|----------|----------|
| 需求范围不清 | {{PRODUCT_CHANNEL}} | Owner | `docs/BACKLOG.md` 或需求文档 |
| 架构边界冲突 | {{TECH_CHANNEL}} | Tech Lead | 启用 `architecture` pack 时记录到 `../adr/` 或 `../design/architecture-overview.md`；未启用时记录到实际变更请求或技术决策入口 |
| 变更 Review 阻塞 | 变更请求评论区 | Reviewer -> Tech Lead | 变更请求线程 |
| 测试验收阻塞 | {{QA_CHANNEL}} | QA -> Owner | 测试记录或 `docs/BACKLOG.md` |
| 发布 / 回滚风险 | {{OPS_CHANNEL}} | Ops -> Tech Lead -> Owner | 启用 `operations` pack 时记录到 `runbook.md`；未启用时使用项目实际发布或变更记录入口 |

## 5. 模块责任表

每个长期维护模块都应该明确 Owner、备份负责人、评审人和关键风险。默认直接维护在本节；大型项目如需拆分，可自行创建专门的责任归属文档，并在文件实际存在后于本节补充相对链接。

| 模块 / 目录 | 模块 Owner | 备份负责人 | 默认 Reviewer | 关键风险 | 关联文档 |
|-------------|------------|------------|----------------|----------|----------|
| {{MODULE_OR_PATH}} | {{OWNER}} | {{BACKUP_OWNER}} | {{REVIEWER}} | {{KEY_RISK}} | {{RELATED_DOC}} |

若启用了 `github` pack，`.github/CODEOWNERS` 应与本表保持一致：本表说明责任边界，CODEOWNERS 负责在 PR 中触发默认评审。未启用 GitHub / CODEOWNERS 时，由项目实际托管平台或人工流程落实默认 Reviewer。若两者冲突，以本表为责任源头。

## 6. AI 编程团队协作契约

当团队主要使用 AI 编程时，必须先把文件所有权、模块或公共接口边界和验收口径写清楚，再并行开发。仅在启用 `frontend` pack 且项目存在页面或组件时，才额外维护组件 API 与页面模块顺序。

### 6.1 文件所有权

| 文件 / 目录 | 所属模块 | 文件 Owner | 允许修改角色 | 修改前必须读取 | 说明 |
|-------------|----------|------------|--------------|----------------|------|
| `{{FILE_OR_DIR}}` | {{MODULE_NAME}} | {{OWNER}} | {{ROLE}} | `{{CONTRACT_DOC}}` | {{NOTE}} |

规则：

- 入口、公共配置、共享契约和跨模块装配文件默认由集成负责人或对应 Owner 维护。
- 模块负责人只修改自己负责的模块实现、模块测试和已约定的文档。
- 启用 `frontend` pack 时，页面编排文件、页面级测试和公共样式默认由集成负责人维护；模块负责人只修改契约允许的组件、模块样式和模块测试。

### 6.2 集成负责人职责

| 职责 | 具体动作 | 不负责 |
|------|----------|--------|
| 统一装配 | 维护入口、模块注册顺序和跨模块连接；启用 `frontend` pack 时包含页面编排 | 不替模块负责人写模块内部业务逻辑 |
| 冲突分类 | 按结构 / 契约 / 依赖 / 测试分类；启用 `frontend` pack 时再区分页面、组件和样式冲突 | 不直接覆盖他人方案 |
| 验收口径 | 维护集成级验收测试；启用 `frontend` pack 时可包含页面测试和截图口径 | 不把个人方案写成团队验收 |
| 退回问题 | 将越界修改、业务缺陷、契约不一致退回对应负责人 | 不作为缺陷兜底人 |

### 6.3 模块负责人职责

| 职责 | 具体动作 | 必须同步 |
|------|----------|----------|
| 模块实现 | 按功能、接口或模块契约实现约定行为；启用 `frontend` pack 时再落实 props、emits、slots 和样式前缀 | 项目实际启用的功能 / 接口文档；启用 `frontend` pack 时前端组件为 `../design/component-api-contract.md` |
| 模块资源 | 不污染公共配置或共享资源；启用 `frontend` pack 时使用模块私有 class 前缀 | 项目公共资源边界；启用 `frontend` pack 时前端页面为 `../design/page-module-contract.md` |
| 模块测试 | 覆盖模块主路径、边界状态和对外行为 | 对应模块测试文件 |
| 变更自查 | 说明 AI 修改范围、提示词、是否越界 | 已启用的 PR / MR 模板或变更说明 |

### 6.4 缺陷退回规则

| 问题类型 | 退回对象 | 退回条件 |
|----------|----------|----------|
| 越过文件边界 | PR 作者 | 修改了契约未允许的文件 |
| 公共契约不一致 | 模块负责人 | 模块行为、输入或输出与已启用的功能 / 接口契约不一致 |
| 页面或组件契约不一致 | 前端对应负责人 | 仅启用 `frontend` pack 时，页面顺序、props、emits、slots 或样式边界与契约不一致 |
| 公共资源污染 | 资源变更负责人 | 为单个模块修改公共配置、共享状态；前端项目还包括公共样式 |
| 测试口径冲突 | 验收负责人 | 测试只验证个人方案，不符合共同验收口径 |
| 业务缺陷 | 原模块负责人 | 模块行为不符合功能或已启用的接口契约 |

### 6.5 AI 编程边界

- AI 开始修改前必须读取项目实际存在的协作规则与相关功能文档；仅启用 `ai-planning` pack 时要求 `AGENTS.md`，仅启用 `frontend` pack 时要求页面模块契约和组件 API 契约。
- AI 提示词必须包含允许修改文件、禁止修改文件、模块或公共接口边界和验收命令；启用 `frontend` pack 时再加入页面与组件 API 边界。
- AI 不得擅自新增模块名或公共契约；启用 `frontend` pack 时，也不得擅自新增 CSS class 前缀、`data-*` 标识、props、emits 或 slots。
- AI 不得把 mock 数据当成真实功能，也不得用假数据掩盖未完成接口。
- AI 生成结果必须由负责人按实际变更模板或自查清单核对，不能把集成负责人当作兜底修复人。

## 7. 多人并行开发规则

- 同一模块同时存在多个 PR / MR / 变更请求时，模块 Owner 必须确认合并顺序。
- 同一文件被多个任务修改时，优先按 BACKLOG 优先级与发布时间排序；无法兼容时由 Tech Lead 裁决。
- 影响公共接口、数据库、权限、状态机或模块边界的任务，必须在变更请求描述中列出影响范围。
- 若需要临时分区开发，必须在已启用的 plan 冲突扫描或变更请求描述中写清各自负责的文件 / 模块边界。
- 启用 `frontend` pack 且存在前端并行开发时，先维护 `../design/page-module-contract.md` 与 `../design/component-api-contract.md`；无前端项目不要求。
- 发生结构、API、样式或测试冲突时，按 `merge-conflict-playbook.md` 退回对应负责人。
- 每个变更请求必须填写并行冲突扫描结果；仅在启用 `ai-planning` 时扫描 Active / Interrupted plan，同时检查同模块未合并变更。
- 合并前最小门禁是“影响范围明确、必要验证完成、阻塞 Review 已处理、模块 Owner 边界未被绕过”；未配置自动 CI 或 CODEOWNERS 时使用可审计的人工替代流程。
- 高风险变更（公共接口、数据库、权限、状态机、架构边界）至少需要模块 Owner 与 Tech Lead 之一参与 Review。

## 8. GitHub 门禁建议

若项目使用 GitHub 并加入 `github` pack，建议同时启用以下分支保护设置：

- Require pull request reviews before merging
- Require review from Code Owners
- Require status checks to pass before merging
- Restrict direct pushes to protected branches

这些设置不能只靠文档生效，必须由仓库管理员在 GitHub 分支保护规则中配置。若同时启用 `github-ci`，`PR -> CODEOWNERS Review -> CI` 可作为 GitHub 变体，但 `.github/workflows/docs-checks.yml` 只检查文档；项目业务测试、构建和部署仍需单独配置。未使用 GitHub 时，本节填 `N/A`，改用托管平台的等效规则。

---

## 附录：填写示例

下方为订单中心团队协作填写样例。**复制模板时请删除本附录**。

```markdown
## 1. 角色定义

| 角色 | 职责 | 典型产出 |
|------|------|----------|
| Owner | 运营后台范围与优先级 | v1.1 BACKLOG |
| Tech Lead | 订单域技术方案与导出链路设计 | 技术决策记录（启用 `architecture` pack 时可使用 ADR） |

## 5. 模块责任表

| 模块 / 目录 | 模块 Owner | 备份负责人 | 默认 Reviewer | 关键风险 | 关联文档 |
|-------------|------------|------------|----------------|----------|----------|
| `order/export` | 张三 | 李四 | 王五 | 大文件导出超时 | `../features/order-export.md` |
```

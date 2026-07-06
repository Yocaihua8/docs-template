# 分支与提交规范

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 分支模型

在这里写明项目采用哪种策略：

- 单主分支 + 短期分支
- GitFlow
- trunk-based development

## 2. 分支命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 功能开发 | `feature/<description>` | `feature/login-page` |
| 问题修复 | `fix/<description>` | `fix/token-expired` |
| 重构 | `refactor/<description>` | `refactor/order-service` |
| 文档 | `docs/<description>` | `docs/api-spec` |
| 维护 | `chore/<description>` | `chore/upgrade-deps` |

## 3. 提交信息规范

建议遵循 Conventional Commits：

```text
<type>(<scope>): <subject>
```

| type | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复 |
| refactor | 重构 |
| docs | 文档 |
| test | 测试 |
| chore | 配置/依赖 |
| perf | 性能优化 |

## 4. 合并规则

- 是否允许直接推送主分支：{{ALLOW_DIRECT_PUSH}}（建议：否）
- 是否要求 PR：必须通过 PR，除非是紧急生产止血且事后补 PR / 记录
- 最少 Review 人数：{{MIN_REVIEW_COUNT}}（建议：至少 1 人；高风险改动至少 2 人）
- 是否要求 CI 通过：CI 必须通过，禁止跳过校验合并
- 是否要求 Code Review：必须完成阻塞评论处理，非阻塞建议需给出处理结论
- 是否要求 CODEOWNERS：建议启用 Require review from Code Owners，确保模块 Owner 或默认 Reviewer 被请求评审
- 合并方式：Merge / Squash / Rebase 由项目统一选择，不在单个 PR 中临时切换

### 4.1 分支保护建议

若项目使用 GitHub，建议对主分支启用：

- Require pull request reviews before merging
- Require status checks to pass before merging
- Require review from Code Owners
- Restrict direct pushes

以上规则用于保证所有变更先经过 PR、Review、CODEOWNERS 和 CI。仓库文件只能提供模板和说明，实际保护规则需要在托管平台中配置。

## 5. 合并方式选择

| 策略 | 适用场景 | 约束 |
|------|----------|------|
| Merge | 需要保留完整分支提交历史 | 分支提交应保持可读，不提交临时噪声 |
| Squash | 任务型开发、希望主分支历史简洁 | PR 标题和描述必须能代表完整变更 |
| Rebase | 追求线性历史且团队熟悉变基流程 | 禁止在共享分支上强推覆盖他人提交 |

项目应在本节固定一种默认策略：

```text
默认合并方式：{{DEFAULT_MERGE_STRATEGY}}（Merge / Squash / Rebase）
```

## 6. 分支过期与清理

- 分支过期：超过 {{STALE_BRANCH_DAYS}} 天无提交、无 PR 更新或无负责人响应，视为过期分支。
- 过期处理：先在 PR 或沟通渠道提醒负责人；超过 {{STALE_BRANCH_GRACE_DAYS}} 天仍无响应，可关闭 PR 或删除远端分支。
- 长期开发分支必须定期同步目标分支，避免一次性大冲突。
- 已合并分支应及时删除；未合并但保留的分支必须在 BACKLOG 或 PR 中说明原因。

## 7. 冲突处理

- 发现冲突后，先判断是否为同一模块、同一文件或同一接口的并行改动。
- 同一模块冲突由模块 Owner 协调合并顺序。
- 架构边界、接口契约、数据库、权限或状态机冲突由 Tech Lead 裁决。
- 无法自动合并时，禁止用覆盖式提交吞掉他人改动；必须逐项确认冲突块来源。
- 冲突处理结论应记录在 PR 评论、plan § 5.2 或 `docs/devlog/YYYY/MM/` 中。
- PR 创建前应完成并行冲突扫描：检查 Active / Interrupted plan、同模块未合并 PR 和 CODEOWNERS 命中的默认 Reviewer。

# RFC / 设计提案模板

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Decision Status：Proposed / Accepted / Rejected / Superseded
> Related ADR：{{ADR_ID_OR_NA}}
> Related BACKLOG：{{B_ID_OR_NA}}

RFC 用于在实现前讨论影响较大的设计提案。小范围修复不必创建 RFC；涉及对外契约、架构边界、迁移成本或多个团队协作时，建议先写 RFC 再进入实施。

与 ADR 的分工：RFC 是实施前的完整讨论稿（允许记录开放问题和评审过程）；方案被 `Accepted` 后，由 ADR 精简提炼最终决策结论并反向链接到本 RFC，无需全文复制。

## 1. 摘要

用 3-5 句话说明本提案要解决什么问题、推荐什么方案、会影响谁。

## 2. 动机

| 问题 | 当前影响 | 证据 / 链接 |
|------|----------|-------------|
| {{PROBLEM_1}} | {{IMPACT_1}} | {{EVIDENCE_1}} |
| {{PROBLEM_2}} | {{IMPACT_2}} | {{EVIDENCE_2}} |

说明为什么现在需要处理，为什么现有方案不足。

## 3. 目标

- {{GOAL_1}}
- {{GOAL_2}}
- {{GOAL_3}}

## 4. 非目标

- {{NON_GOAL_1}}
- {{NON_GOAL_2}}

非目标用于防止评审范围无限扩大。若后续需要处理，写入 BACKLOG 或另开 RFC。

## 5. 背景与约束

| 约束 | 说明 |
|------|------|
| 技术约束 | {{TECH_CONSTRAINT}} |
| 业务约束 | {{BUSINESS_CONSTRAINT}} |
| 兼容性约束 | {{COMPATIBILITY_CONSTRAINT}} |
| 安全 / 合规约束 | {{SECURITY_CONSTRAINT}} |
| 时间 / 人力约束 | {{SCHEDULE_CONSTRAINT}} |

## 6. 详细设计

### 6.1 总体方案

说明推荐方案的核心机制、模块边界、数据流和调用关系。

```text
{{SYSTEM_OR_FLOW_SKETCH}}
```

### 6.2 接口 / 契约变化

| 契约 | 当前 | 变更后 | 兼容性 |
|------|------|--------|--------|
| {{API_OR_EVENT}} | {{CURRENT}} | {{PROPOSED}} | {{COMPATIBILITY}} |

### 6.3 数据 / 状态变化

| 对象 | 当前状态 | 目标状态 | 迁移方式 |
|------|----------|----------|----------|
| {{DATA_OR_STATE}} | {{CURRENT}} | {{TARGET}} | {{MIGRATION}} |

### 6.4 安全、权限与审计

- 权限变化：{{AUTH_CHANGE_OR_NA}}
- 审计要求：{{AUDIT_REQUIREMENT_OR_NA}}
- 敏感数据处理：{{SENSITIVE_DATA_RULE_OR_NA}}

## 7. 替代方案

| 方案 | 优点 | 缺点 | 结论 |
|------|------|------|------|
| {{ALTERNATIVE_1}} | {{PROS}} | {{CONS}} | {{DECISION}} |
| {{ALTERNATIVE_2}} | {{PROS}} | {{CONS}} | {{DECISION}} |

## 8. 迁移影响

| 影响对象 | 影响说明 | 迁移 / 兼容策略 |
|----------|----------|----------------|
| 使用方 | {{USER_IMPACT}} | {{USER_MIGRATION}} |
| 开发团队 | {{TEAM_IMPACT}} | {{TEAM_MIGRATION}} |
| 运维 / 部署 | {{OPS_IMPACT}} | {{OPS_MIGRATION}} |
| 数据 | {{DATA_IMPACT}} | {{DATA_MIGRATION}} |

若需要面向使用方提供版本迁移步骤，同步创建 `../guides/migration-guide-template.md` 的实际迁移文档。

## 9. 发布与回滚

| 阶段 | 动作 | 验证 | 回滚条件 |
|------|------|------|----------|
| 灰度 | {{ACTION}} | {{CHECK}} | {{ROLLBACK_CONDITION}} |
| 全量 | {{ACTION}} | {{CHECK}} | {{ROLLBACK_CONDITION}} |

## 10. 开放问题

| 问题 | Owner | 截止时间 | 处理方式 |
|------|-------|----------|----------|
| {{OPEN_QUESTION}} | {{OWNER}} | {{DATE}} | {{NEXT_STEP}} |

## 11. 决策状态

| 日期 | 状态 | 决策人 / 评审人 | 说明 |
|------|------|----------------|------|
| {{CURRENT_DATE}} | Proposed | {{REVIEWERS}} | 初稿提交 |

状态流转建议：

- `Proposed`：开放讨论
- `Accepted`：同意实施
- `Rejected`：拒绝并说明原因
- `Superseded`：被新 RFC / ADR 替代

## 12. 回流清单

- [ ] 若方案被接受，创建或更新 ADR
- [ ] 若影响对外 API，更新 `api-spec.md` 和 `api-changes.md`
- [ ] 若影响使用方升级，创建迁移指南
- [ ] 若产生后续事项，写入 `../BACKLOG.md`

---

## 附录：填写示例

下方为精简示例，**复制模板时请删除本附录**。

```markdown
# RFC-003 导出任务改用对象存储托管

> 状态：Active
> Owner：张三
> Last Updated：2026-04-17
> Decision Status：Accepted
> Related ADR：ADR-005
> Related BACKLOG：B-012

## 1. 摘要
将异步导出文件从应用本地磁盘迁移到对象存储，通过 24 小时预签名 URL 提供下载，解决多实例部署下文件丢失问题。

## 3. 目标
- 多实例任意节点均可下载导出结果
- 导出产物 7 天后由存储生命周期规则自动清理

## 11. 决策状态
| 日期 | 状态 | 决策人 / 评审人 | 说明 |
|------|------|----------------|------|
| 2026-04-17 | Accepted | 李四、王五 | 评审通过，已提炼为 ADR-005 |
```

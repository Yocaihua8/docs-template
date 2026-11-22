# 问题复盘 {{INCIDENT_TITLE}}

> 状态：Draft
> Author：{{AUTHOR}}
> Date：{{CURRENT_DATE}}
> Related：{{RELATED_DOCS_OR_ISSUES}}

本文档用于记录一次已经收敛的问题复盘。普通 devlog 记录日常进展；问题复盘记录一次异常、事故、
重大缺陷或复杂排障的背景、根因、最终方案和防复发动作。跨事件、跨项目可复用的失误模式应提升到
`../guides/project-failure-patterns-and-prevention.md`，不得把单个项目的业务值复制为通用结论。

## 1. 背景

| 项 | 内容 |
|----|------|
| 问题性质 | 已确认失误 / 正确失败关闭（按安全或校验规则主动拒绝，非故障）/ 外部阻塞 / 尚未完成 / 环境限制 / 待确认 |
| 现象 | {{SYMPTOM}} |
| 影响范围 | {{IMPACT}} |
| 首次发现时间 | {{CURRENT_LOCAL_DATETIME}} |
| 恢复时间 | {{CURRENT_LOCAL_DATETIME}} |
| 当前状态 | 已恢复 / 已缓解 / 观察中 / 待修复 |

## 2. 时间线

| 时间 | 事件 | 处理人 |
|------|------|--------|
| {{CURRENT_LOCAL_DATETIME}} | {{EVENT}} | {{OWNER}} |

## 3. 失败方案

| 方案 | 为什么失败 | 学到什么 |
|------|------------|----------|
| {{FAILED_ATTEMPT}} | {{FAIL_REASON}} | {{LESSON}} |

## 4. 最终方案

说明最终采用的修复或缓解方案，以及为什么它能解决问题。

- 方案摘要：{{FINAL_SOLUTION}}
- 关键约束：{{CONSTRAINTS}}
- 验证方式：{{VERIFICATION}}

## 5. 根因

| 类型 | 根因 |
|------|------|
| 直接原因 | {{DIRECT_CAUSE}} |
| 深层原因 | {{ROOT_CAUSE}} |
| 未提前发现的原因 | {{WHY_NOT_CAUGHT}} |

## 6. 证据与结论边界

- 已验证事实及权威源：{{VERIFIED_FACTS_AND_SOURCES}}
- 假设与未知项：{{ASSUMPTIONS_AND_UNKNOWNS}}
- 本次验证绑定的提交 / 制品 / 环境 / 数据版本：{{EVIDENCE_SCOPE}}
- 本次证据不能证明的结论：{{NOT_PROVEN}}

## 7. 防复发

| 动作 | 类型 | 负责人 | 截止日期 | 跟踪 |
|------|------|--------|----------|------|
| {{ACTION}} | 自动门禁 / 负向测试 / 监控 / 审批 / 演练 / 文档 / 架构 | {{OWNER}} | {{CURRENT_DATE}} | B-{{ID}} |

每个已确认失误至少形成一个可持续控制；仅写“以后注意”不能关闭行动项。

## 8. BACKLOG / ADR / 通用规则回流

- 需要进入 BACKLOG 的事项：{{BACKLOG_ITEMS_OR_NA}}
- 需要新增或更新 ADR 的决策：{{ADR_ITEMS_OR_NA}}
- 需要同步的正式文档：{{DOCS_TO_UPDATE_OR_NA}}
- 是否形成新的通用失误模式：{{REUSABLE_PATTERN_OR_NA}}
- 需要更新的通用控制：`../guides/project-failure-patterns-and-prevention.md` / N/A

## 9. 结论

- 已解决：{{RESOLVED}}
- 仍需跟进：{{FOLLOW_UP}}
- 不再采用的做法：{{DEPRECATED_APPROACH}}

---

## 附录：填写示例

下方为精简示例，**复制模板时请删除本附录**。

```markdown
# 问题复盘 订单导出大文件上传偶发 504

> 状态：Active
> Author：张三
> Date：2026-04-20
> Related：`../features/order-export.md`、B-045

## 1. 背景
| 项 | 内容 |
|----|------|
| 问题性质 | 已确认失误 |
| 现象 | 单次导出超过 200MB 时约 5% 任务返回 504 |
| 影响范围 | 运营后台大批量导出，持续 2 天 |

## 4. 最终方案
- 方案摘要：改为分片上传（每片 10MB）并加上传超时重试
- 验证方式：50,000 行压测连续 20 次全部成功

## 7. 防复发
| 动作 | 类型 | 负责人 | 截止日期 | 跟踪 |
|------|------|--------|----------|------|
| 新增 50,000 行导出集成测试 | 负向测试 | 张三 | 2026-04-25 | B-045 |
```

# 变更请求 {{CHANGE_REQUEST_ID}}

> 状态：Draft / In Review / Approved / Rejected / Implemented
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：`customer-confirmation.md`、`quotation-estimate.md`、`delivery-acceptance.md`

本文档用于评估已确认基线之后的商业项目变更。未完成影响评估和双方确认前，不应把变更直接并入原范围。

## 1. 变更摘要

| 项目 | 内容 |
|------|------|
| 客户 / 项目 | {{CLIENT_OR_PROJECT_NAME}} |
| 提出人 | {{REQUESTER}} |
| 提出日期 | {{CURRENT_DATE}} |
| 期望完成日期 | {{REQUESTED_DUE_DATE}} |
| 原基线 / 确认版本 | {{BASELINE_VERSION}} |
| 变更原因 | {{REASON}} |

## 2. 请求内容

- **当前行为 / 范围**：{{CURRENT_BEHAVIOR_OR_SCOPE}}
- **期望行为 / 范围**：{{REQUESTED_BEHAVIOR_OR_SCOPE}}
- **明确不包含**：{{OUT_OF_SCOPE_OR_NA}}
- **验收标准变化**：{{ACCEPTANCE_CHANGE_OR_NA}}

## 3. 影响评估

| 影响类型 | 结论 | 依据 / 说明 |
|----------|------|-------------|
| 功能与用户流程 | {{FEATURE_IMPACT}} | {{EVIDENCE_OR_LINK}} |
| 接口与数据 | {{DATA_OR_API_IMPACT}} | {{EVIDENCE_OR_LINK}} |
| 权限与安全 | {{SECURITY_OR_AUTH_IMPACT}} | {{EVIDENCE_OR_LINK}} |
| 测试与验收 | {{TEST_AND_ACCEPTANCE_IMPACT}} | {{EVIDENCE_OR_LINK}} |
| 文档与培训 | {{DOCS_AND_TRAINING_IMPACT}} | {{EVIDENCE_OR_LINK}} |
| 运维与支持 | {{OPS_AND_SUPPORT_IMPACT}} | {{EVIDENCE_OR_LINK}} |

## 4. 工时、工期与费用

| 项目 | 调整前 | 本次增量 | 调整后 | 假设与说明 |
|------|--------|----------|--------|------------|
| 工时 | {{EFFORT_BEFORE}} | {{EFFORT_DELTA}} | {{EFFORT_AFTER}} | {{ASSUMPTION}} |
| 日历工期 | {{DURATION_BEFORE}} | {{DURATION_DELTA}} | {{DURATION_AFTER}} | {{ASSUMPTION}} |
| 费用 | {{COST_BEFORE}} | {{COST_DELTA}} | {{COST_AFTER}} | {{ASSUMPTION}} |

费用、税务和付款安排以正式商务文件为准；本文档只记录技术与交付评估。

## 5. 方案与风险

| 方案 | 优点 | 缺点 / 风险 | 推荐结论 |
|------|------|-------------|----------|
| {{OPTION_A}} | {{PROS}} | {{CONS}} | {{RECOMMENDATION}} |
| {{OPTION_B}} | {{PROS}} | {{CONS}} | {{RECOMMENDATION}} |

## 6. 决策记录

| 决策 | 说明 | 客户决策人 | 项目负责人 | 证据 | 日期 |
|------|------|------------|------------|------|------|
| 批准 / 拒绝 / 延后 / 重新评估 | {{DECISION_SUMMARY}} | {{CLIENT_DECISION_OWNER}} | {{OWNER}} | {{EVIDENCE_OR_LINK}} | {{CURRENT_DATE}} |

## 7. 执行与回流

- 关联 BACKLOG / Issue：{{BACKLOG_ID_OR_LINK}}
- 关联功能 / 设计文档：{{RELATED_DOCS}}
- 新验收证据位置：{{EVIDENCE_OR_LINK}}
- 是否更新报价或交付基线：{{BASELINE_UPDATE_DECISION}}

## 8. 自查清单

- [ ] 原基线和请求内容可以对照。
- [ ] 功能、接口、数据、权限、测试、文档和运维影响均已评估。
- [ ] 工时与日历工期已分开估算。
- [ ] 决策人、结论和证据已经记录。
- [ ] 获批变更已回流到正式需求、设计、BACKLOG 和交付基线。

---

## 附录：填写示例

- **当前行为 / 范围**：仅支持按月导出 CSV。
- **期望行为 / 范围**：增加按周导出 Excel，并保留原 CSV 能力。
- **明确不包含**：历史数据清洗与第三方 BI 接入。
- **验收标准变化**：新增 10 万行 Excel 导出成功率和耗时验证。

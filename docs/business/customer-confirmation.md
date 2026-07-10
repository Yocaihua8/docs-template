# 客户确认与待决策清单

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：`quotation-estimate.md`、`delivery-acceptance.md`

本文档用于在商业项目启动和执行过程中记录双方已经确认的事实、客户待提供事项与待决策问题。它不是合同；正式合同、报价、税务和法务条款以双方签署文件为准。

## 1. 确认信息

| 项目 | 内容 |
|------|------|
| 客户 / 项目 | {{CLIENT_OR_PROJECT_NAME}} |
| 客户决策人 | {{CLIENT_DECISION_OWNER}} |
| 项目 Owner | {{OWNER}} |
| 技术负责人 | {{TECH_LEAD}} |
| 本轮确认截止日期 | {{CONFIRMATION_DUE_DATE}} |

## 2. 已确认基线

| 类型 | 已确认内容 | 依据 | 确认人 | 确认日期 |
|------|------------|------|--------|----------|
| 项目目标 | {{GOAL_SUMMARY}} | {{EVIDENCE_OR_LINK}} | {{CONFIRMED_BY}} | {{CONFIRMATION_DATE}} |
| 范围内 | {{IN_SCOPE_ITEM}} | {{EVIDENCE_OR_LINK}} | {{CONFIRMED_BY}} | {{CONFIRMATION_DATE}} |
| 范围外 | {{OUT_OF_SCOPE_ITEM}} | {{EVIDENCE_OR_LINK}} | {{CONFIRMED_BY}} | {{CONFIRMATION_DATE}} |
| 交付物 | {{DELIVERABLE}} | {{EVIDENCE_OR_LINK}} | {{CONFIRMED_BY}} | {{CONFIRMATION_DATE}} |
| 验收方式 | {{ACCEPTANCE_METHOD}} | {{EVIDENCE_OR_LINK}} | {{CONFIRMED_BY}} | {{CONFIRMATION_DATE}} |

## 3. 客户待提供事项

| ID | 事项 | 提供方 | 截止日期 | 完成证据 | 延期影响 | 状态 |
|----|------|--------|----------|----------|----------|------|
| DEP-001 | {{DEPENDENCY}} | {{PROVIDER}} | {{DUE_DATE}} | {{EVIDENCE_OR_LINK}} | {{DELAY_IMPACT}} | 待提供 / 已提供 / 阻塞 |

账号、密钥和真实业务数据不得直接写入本文档，只记录安全存放位置和授权负责人。

## 4. 待决策问题

| ID | 问题 | 可选方案 | 推荐方案与理由 | 决策人 | 截止日期 | 最终结论 | 状态 |
|----|------|----------|----------------|--------|----------|----------|------|
| DEC-001 | {{QUESTION}} | {{OPTIONS}} | {{RECOMMENDATION}} | {{CLIENT_DECISION_OWNER}} | {{DUE_DATE}} | {{DECISION_OR_TBD}} | 待确认 / 已确认 / 作废 |

未在截止日期前确认的事项，必须记录默认处理方式及其对范围、工期、成本或验收的影响；不得由开发方静默猜测。

## 5. 变更边界

出现以下任一情况时，应新建 `change-request-template.md` 的实例，而不是直接修改本确认单：

- 已确认的功能行为或范围发生变化。
- 交付物、验收标准或环境归属发生变化。
- 外部依赖延期导致工期、成本或交付顺序变化。
- 新增合同范围外的支持、迁移或数据处理工作。

## 6. 确认记录

| 版本 | 确认范围 | 确认方式 / 证据 | 客户确认人 | 项目确认人 | 日期 |
|------|----------|-----------------|------------|------------|------|
| {{CONFIRMATION_VERSION}} | {{CONFIRMED_SCOPE}} | {{EVIDENCE_OR_LINK}} | {{CLIENT_DECISION_OWNER}} | {{OWNER}} | {{CONFIRMATION_DATE}} |

## 7. 启动检查清单

- [ ] 项目目标、范围内和范围外事项已经写清。
- [ ] 交付物和验收方式可以验证。
- [ ] 客户待提供事项均有负责人和截止日期。
- [ ] 待决策问题均有决策人、默认处理方式和影响说明。
- [ ] 账号、密钥和真实敏感数据未写入文档。
- [ ] 需要计费或改期的变化已进入正式变更请求。

---

## 附录：填写示例

| ID | 问题 | 可选方案 | 推荐方案与理由 | 决策人 | 截止日期 | 最终结论 | 状态 |
|----|------|----------|----------------|--------|----------|----------|------|
| DEC-001 | 导出文件保留多久 | 7 天 / 30 天 | 7 天，满足下载窗口并降低存储成本 | 客户项目经理 | 2026-07-15 | 7 天 | 已确认 |

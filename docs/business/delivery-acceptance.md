# 交付验收与项目交接

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：`customer-confirmation.md`、`quotation-estimate.md`

本文档用于固定商业项目的实际交付物、验收证据、已知限制和交接结果。它记录执行事实，不替代合同、付款凭证或法务文件。

## 1. 交付批次

| 项目 | 内容 |
|------|------|
| 客户 / 项目 | {{CLIENT_OR_PROJECT_NAME}} |
| 交付批次 / 版本 | {{DELIVERY_VERSION}} |
| 计划交付日期 | {{PLANNED_DELIVERY_DATE}} |
| 实际交付日期 | {{ACTUAL_DELIVERY_DATE}} |
| 客户验收负责人 | {{ACCEPTANCE_OWNER}} |
| 项目交付负责人 | {{DELIVERY_OWNER}} |

## 2. 交付物基线

| ID | 交付物 | 版本 / Commit | 交付位置 | 负责人 | 验收方式 | 状态 |
|----|--------|---------------|----------|--------|----------|------|
| D-001 | {{DELIVERABLE}} | {{VERSION_OR_COMMIT}} | {{DELIVERY_LOCATION}} | {{OWNER}} | {{ACCEPTANCE_METHOD}} | 待交付 / 已交付 / 已验收 |

交付位置只记录受控入口，不在本文档写入密码、Token、私钥或生产数据。

## 3. 验收项与证据

| ID | 验收项 | 通过标准 | 验证步骤 | 证据位置 | 执行人 | 结果 |
|----|--------|----------|----------|----------|--------|------|
| A-001 | {{ACCEPTANCE_NAME}} | {{ACCEPTANCE_CRITERIA}} | {{VERIFICATION}} | {{EVIDENCE_OR_LINK}} | {{ACCEPTANCE_OWNER}} | 通过 / 不通过 / 有条件通过 |

“有条件通过”必须同时记录剩余问题、负责人、计划完成日期和是否影响付款或上线。

## 4. 已知限制与遗留项

| ID | 限制 / 遗留项 | 影响 | 临时方案 | 负责人 | 计划日期 | 处理方式 |
|----|---------------|------|----------|--------|----------|----------|
| R-001 | {{KNOWN_LIMITATION}} | {{IMPACT}} | {{WORKAROUND_OR_STATUS}} | {{OWNER}} | {{DUE_DATE}} | 本批修复 / 后续变更 / 接受风险 |

## 5. 环境、账号与资产交接

只列本次实际交付或移交的资产。源代码包、设计稿、数据文件、培训材料、离线安装包、仓库权限或云环境都可以作为资产；没有部署环境、域名、监控或账号交接时填 `N/A`，不要补造云资源。

| 资产 | 归属方 | 管理负责人 | 交接方式 | 验证结果 | 备注 |
|------|--------|------------|----------|----------|------|
| {{ASSET_OR_NA}} | {{ASSET_OWNER_OR_NA}} | {{ASSET_MANAGER_OR_NA}} | {{HANDOVER_METHOD_OR_NA}} | {{VERIFICATION_RESULT_OR_NA}} | {{NOTE}} |

## 6. 支持与质保入口

| 项目 | 内容 |
|------|------|
| 支持范围 | {{SUPPORT_SCOPE}} |
| 支持期限 | {{SUPPORT_PERIOD}} |
| 支持渠道 | {{SUPPORT_CHANNEL_URL}} |
| 响应口径 | {{RESPONSE_POLICY}} |
| 不包含事项 | {{OUT_OF_SUPPORT_SCOPE}} |

详细支持边界可引用 `../guides/support-policy.md`。若该文档未启用，应在本节直接写清实际口径。

## 7. 验收结论

| 结论 | 说明 | 客户确认人 | 项目确认人 | 证据 | 日期 |
|------|------|------------|------------|------|------|
| 通过 / 不通过 / 有条件通过 | {{ACCEPTANCE_CONCLUSION}} | {{ACCEPTANCE_OWNER}} | {{DELIVERY_OWNER}} | {{EVIDENCE_OR_LINK}} | {{ACCEPTANCE_DATE}} |

## 8. 交付检查清单

- [ ] 每个交付物都有版本、位置、负责人和验收方式。
- [ ] 每个验收结论都有可访问的证据。
- [ ] 已知限制和遗留项已有明确处理结论。
- [ ] 本次实际涉及的环境、账号和资产归属已经双方验证；不涉及项已标记 `N/A`。
- [ ] 支持范围、期限、渠道和不包含事项已经写清。
- [ ] 文档中未包含密码、Token、私钥或真实敏感数据。

---

## 附录：填写示例

| ID | 交付物 | 版本 / Commit | 交付位置 | 负责人 | 验收方式 | 状态 |
|----|--------|---------------|----------|--------|----------|------|
| D-001 | 订单后台 Web 应用 | v1.0.0 / a1b2c3d | 客户 GitHub 仓库 release/v1.0.0 | 张三 | 验收环境主流程回归 | 已验收 |

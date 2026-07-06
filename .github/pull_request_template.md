<!--
此模板来自 CONTRIBUTING.md § 7，任何修改需在两处同步。
-->

## 变更说明

简述本次改动的目的和范围。

## 影响范围

- BACKLOG 条目：
- 关联 plan：
- 代码 / 模块：
- 接口 / API：
- 数据库 / 迁移：
- 权限 / 状态机：
- 文档：

## 并行开发隔离

- 文件/模块锁定范围：
- 并行冲突扫描：
  - [ ] 已检查 Active / Interrupted plan
  - [ ] 已检查同模块未合并 PR
  - 结果：
- 模块 Owner：
- 默认 Reviewer：
- CODEOWNERS Review：
  - [ ] 已触发
  - [ ] N/A，原因：
- 高风险变更：
  - [ ] 否
  - [ ] 是，已安排至少 2 人 Review，说明：

## 测试验证

- [ ] 单元测试通过
- [ ] 主流程验证通过
- [ ] 关键边界场景已检查
- [ ] CI 通过，或已说明无法运行的原因

## 关联文档

- 需求文档：
- 功能文档：
- ADR：

## 已知限制

- 

## 自查清单

- [ ] 文档已同步更新（对照 `CONTRIBUTING.md § 6`）
- [ ] `CHANGELOG.md` 已更新到 `Unreleased`
- [ ] 若触发 `docs/README.md § 4` 的强制条件，已提交 ADR
- [ ] 若涉及对外 API 破坏性变更，已更新 `docs/design/api-changes.md`
- [ ] 未绕过模块边界、层边界或既有端口 / 适配器边界
- [ ] 阻塞 Review 评论已处理，非阻塞建议已有结论

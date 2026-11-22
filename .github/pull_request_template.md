<!--
本文件用于 docs-template 仓库自身维护，包含模板仓库专用检查项。
下游项目使用 scaffold/templates/pull_request_template.md；共享字段变化时同步核对两处。
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

## 模板仓库维护变更

- [ ] N/A，本 PR 是普通项目变更，按下方清单更新 BACKLOG / plan / CHANGELOG
- [ ] 是，本 PR 仅维护模板源文件；BACKLOG / plan / CHANGELOG 不写入本仓库真实记录，原因：

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

## AI 修改说明

- 是否使用 AI 编程：
  - [ ] 否
  - [ ] 是，主要提示词 / 指令摘要：
- 实际修改文件：
- 是否越过文件边界：
  - [ ] 否
  - [ ] 是，已说明原因并更新契约：
- 是否新增命名（模块名、CSS class、`data-*`、测试 ID）：
  - [ ] 否
  - [ ] 是，新增项：
- 是否修改公共样式：
  - [ ] 否
  - [ ] 是，文件与原因：
- 是否修改组件 API（props / emits / slots / payload）：
  - [ ] 否
  - [ ] 是，关联 `component-api-contract.md`：
- 截图：
  - [ ] 已提供关键页面截图
  - [ ] N/A，原因：

## 测试验证

- [ ] 单元测试通过
- [ ] 主流程验证通过
- [ ] 关键边界场景已检查
- [ ] type-check 通过，或已说明无法运行的原因
- [ ] build 通过，或已说明无法运行的原因
- [ ] CI 通过，或已说明无法运行的原因

## 关联文档

- 需求文档：
- 功能文档：
- 页面模块契约：
- 组件 API 契约：
- ADR：

## 已知限制

- 

## 自查清单

- [ ] 文档已同步更新（对照 `CONTRIBUTING.md § 6`）
- [ ] `CHANGELOG.md` 已更新到 `Unreleased`，或本 PR 为模板仓库维护变更且已在上方标记 N/A
- [ ] 若触发 [ADR 新建条件](../docs/adr/README.md#1-何时需要新增-adr)，已提交 ADR
- [ ] 若涉及对外 API 破坏性变更，已更新 `docs/design/api-changes.md`
- [ ] 未绕过模块边界、层边界或既有端口 / 适配器边界
- [ ] 阻塞 Review 评论已处理，非阻塞建议已有结论

# Changelog

所有版本变更记录建议遵循 [Keep a Changelog] 的结构，版本号建议遵循语义化版本（Semantic Versioning）。

---

## [Unreleased]

### Added
- {{ADDED_CHANGE}}

### Changed
- {{CHANGED_CHANGE}}

### Fixed
- {{FIXED_CHANGE}}

### Removed
- {{REMOVED_CHANGE}}

### Security
- {{SECURITY_CHANGE}}

---

## [{{RELEASE_VERSION}}] - {{CURRENT_DATE}}

### Added
- {{ADDED_CHANGE}}

### Changed
- {{CHANGED_CHANGE}}

### Fixed
- {{FIXED_CHANGE}}

### Removed
- {{REMOVED_CHANGE}}

### Security
- {{SECURITY_CHANGE}}

---

## 编写规则

1. 一次发布写一个版本块。
2. 未发布内容统一写到 `Unreleased`。
3. 只记录对使用者 / 维护者有意义的变更，不记录无意义微调。
4. 每条尽量写"结果"，不要只写"做了什么"。
5. 使用本模板时，将 `{{PLACEHOLDER_NAME}}` 占位符替换为真实发布信息；无内容的分类可以删除或保留为空。

## 预发布检查清单

**发布前的整体检查**以 `docs/guides/release-process.md § 1 发布前检查` 为权威源；本节只列出**与 CHANGELOG 自身相关**的补充项：

- [ ] `Unreleased` 段至少有一个真实条目（否则不应发版）
- [ ] 每条目属于正确的分类：Added / Changed / Fixed / Removed / Security
- [ ] 每条目是"结果"描述，不是"做了什么"（例：分页接口空数据响应结构统一）
- [ ] 破坏性变更（Breaking Change）已在条目开头用 **BREAKING** 标记
- [ ] 弃用项（Deprecated）已注明替代方案和下线时间
- [ ] Security 条目已评估是否需要同步发送安全公告
- [ ] 发版后将 `Unreleased` 整段迁移为新版本块，`Unreleased` 重置为空模板

## 建议示例

```markdown
## [1.2.0] - 2026-04-17

### Added
- 新增订单导出能力，支持 CSV 与 Excel

### Changed
- 重构认证模块，统一 Token 刷新逻辑

### Fixed
- 修复分页接口在空数据场景下返回结构不一致的问题
```

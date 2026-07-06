# 发布流程

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 发布前检查

本清单为发布前自查的**权威源**，`../../CHANGELOG.md § 预发布检查清单` 仅补充与 CHANGELOG 本身相关的额外项。

- [ ] 主流程可运行
- [ ] 测试通过（单元 / 接口 / 人工回归按 `testing.md` 要求）
- [ ] 文档同步完成（需求 / 设计 / 功能 / ADR 按 `../../CONTRIBUTING.md § 6` 要求）
- [ ] `../../CHANGELOG.md` 已整理，且满足 `../../CHANGELOG.md § 预发布检查清单`
- [ ] 风险项已评估（对照 `../design/risk-register.md`）
- [ ] 破坏性变更已写入 `../design/api-changes.md`（若有）
- [ ] 版本号与 Tag 规划确定（遵循 `style-guide.md § 13.1`）

## 2. 发布步骤

1. 从指定分支创建发布版本
2. 更新版本号
3. 更新 `../../CHANGELOG.md`
4. 打 Tag
5. 发布制品 / 部署
6. 验证发布结果

## 3. 回滚方案

- 回滚条件：
- 回滚步骤：
- 数据回滚说明：

## 4. 发布记录模板

| 版本 | 日期 | 发布人 | 说明 |
|------|------|--------|------|
| {{VERSION}} | {{YYYY-MM-DD}} | {{RELEASER}} | {{DESCRIPTION}} |

## 附录：填写示例

```markdown
# 发布流程

## 1. 发布前检查

- [x] 主流程可运行
- [x] 测试通过
- [x] 文档同步完成
- [x] `../../CHANGELOG.md` 已整理

## 4. 发布记录模板

| 版本 | 日期 | 发布人 | 说明 |
|------|------|--------|------|
| v1.2.0 | 2026-04-18 | 张三 | 新增订单导出能力 |
```

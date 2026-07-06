# Changelog

所有版本变更记录建议遵循 [Keep a Changelog] 的结构，版本号建议遵循语义化版本（Semantic Versioning）。

---

## [Unreleased]

### Added
- 新增 `docs/devlog/` 目录，提供开发日志的 README 与单条记录模板
- 在 `docs/style-guide.md` 新增 § 3 占位符规范（统一 `{{PLACEHOLDER_NAME}}` 格式）
- 在 `docs/style-guide.md` 新增 § 11 图表与链接规范、§ 12 数值与版本表达、§ 13 中英文与标点
- 在 `template-mapping.md` 新增 § 7 开发过程记录类，并在顶部增加三索引同步说明
- `docs/adr/ADR-000-template.md` § 6 扩展为实施计划 / 回滚策略 / 验证方式 / 待办项四小节（含实施期限、回滚触发条件、回滚责任人、数据回滚说明）
- `docs/features/feature-template.md` 头部加 `Related ADR` 字段，并新增 § 9 相关决策
- `docs/README.md` 新增 § 4 "何时应新建 ADR"，明确强制 / 非强制触发条件
- `CHANGELOG.md` 新增"预发布检查清单"，与 `release-process.md` 联动
- 新增 5 份可选扩展文档：`docs/glossary.md`、`docs/guides/onboarding.md`、`docs/guides/security.md`、`docs/guides/runbook.md`、`docs/design/api-changes.md`
- `README.md` 新增 § 可选扩展文档，`template-mapping.md` 新增 § 8 可选扩展类
- `README.md` 新增 § 0 选择入口，提供按使用场景的入口导航表
- 新增 `.github/CODEOWNERS` 与 `.github/workflows/docs-template-checks.yml`，为模板提供 CODEOWNERS Review 与 CI 检查示例
- 新增 `docs/business/quotation-estimate.md`，提供商业化项目报价、工期、成本、风险缓冲、付款节点与变更计费预估模板
- `docs/style-guide.md` 新增 § 3.4 模板填写示例约定，统一"附录：填写示例"章节规范
- `docs/features/feature-template.md`、`docs/adr/ADR-000-template.md`、`docs/devlog/devlog-template.md` 各自追加"附录：填写示例"章节
- `docs/design/architecture-overview.md` 新增 `三层架构`、`六边形架构` 的结构模板与填写示例
- `docs/design/architecture-overview.md` 新增端口 / 适配器映射表，支持六边形架构落地描述
- `docs/style-guide.md` 新增架构设计表达规范，统一三层架构与六边形架构的写法要求
- `docs/features/feature-template.md` 新增"架构落点"章节，支持记录功能涉及的三层职责与端口 / 适配器
- `docs/adr/ADR-000-template.md` 新增三层架构决策示例
- 为需求、设计、环境搭建、测试、发布、安全、运维等高频模板补充"附录：填写示例"
- 新增 `docs/guides/team-collaboration.md`，覆盖团队角色、RACI、沟通升级、需求到发布流转与模块责任表

### Changed
- `README.md`、`docs/README.md` 的目录清单与维护规则表同步加入 devlog
- `docs/style-guide.md` 统一头部模板改用 `{{...}}` 占位符格式
- **全量迁移**：所有模板文件（requirements / design / features / adr / guides / BACKLOG / CONTRIBUTING 等共 20+ 份）的 `[xxx]` 占位符统一替换为 `{{XXX}}` 格式
- `docs/style-guide.md` § 3.1 增加 ASCII 示意图例外说明（`text` 代码块中的 `[框体名]` 不视为占位符）
- ADR 触发条件收敛到单一权威源：`docs/README.md § 4` 为唯一完整来源，`CONTRIBUTING.md § 8`、`docs/adr/README.md § 1` 改为引用指针 + 精简速查
- `docs/README.md § 2 目录说明` 拆分为「核心目录」和「可选扩展」两张表，消除 `design/` 与其子文件同级并列的层级不对称
- `docs/style-guide.md § 2` 新增索引型 README 可省略 `Scope / Related` 的例外规则
- `docs/README.md § 1 阅读顺序` 扩充为"先读 / 再读 / 按需读"三段，覆盖 guides、adr、devlog、CHANGELOG 与可选扩展
- `docs/style-guide.md § 11` 重组：架构与页面表达规则拆出为独立 § 12「架构与页面表达约定」，原 § 11 只保留图表与链接形式规范，后续章节顺延（原 § 12-14 变为 § 13-15）
- `docs/style-guide.md § 15 维护建议` 补充 `Deprecated` 文档头部字段约定（`Deprecated since` / `Replaced by`）
- `docs/adr/ADR-000-template.md` 状态值补齐 `Proposed` 与 `Deprecated`，并在头部注释中标明状态生命周期
- `docs/BACKLOG.md § 1` 新增 § 1.1 「待办清单 vs 已知问题」边界说明与流转规则
- `docs/guides/release-process.md § 1` 成为发布前检查的单一权威源，`CHANGELOG.md § 预发布检查清单` 裁剪为 CHANGELOG 特有项
- `docs/design/api-changes.md § 4` 用写实示例版本块（`v1.0.0 — 2026-04-18`）替代 `{{VERSION}}` 占位头，避免被误读为必填占位
- `docs/design/api-spec.md` ↔ `docs/design/api-changes.md` 互引，明确"契约 = api-spec / 变更迁移 = api-changes"的职责切分
- 新增 `scripts/check-docs-consistency.sh`：自动比对 docs/ 与 `README.md`、`template-mapping.md` 的一致性
- 新增 `scripts/check-placeholders.sh`：扫描使用本模板后残留的 `{{XXX}}` 占位符
- 新增 `.editorconfig` 与 `.markdownlint.json`：统一编辑器与 lint 基线
- 新增 `.github/pull_request_template.md`：GitHub 创建 PR 时自动填充本模板（与 `CONTRIBUTING.md § 7` 对齐）
- 新增 `SECURITY.md`（根级）：面向外部的漏洞上报渠道与响应承诺，区别于 `docs/guides/security.md`（面向内部的安全基线）
- 新增 `examples/order-service/`：按模板填好的订单中心示例，覆盖需求背景与订单导出功能
- `README.md § 0 选择入口` 增补 `examples/` 与 `scripts/` 两个入口，§ 推荐目录同步新增根级文件与 `examples/` / `scripts/` / `.github/` 层级
- `docs/design/ui-wireframes.md` 回退为通用页面线框模板，移除将架构概念写成页面布局的内容
- `README.md`、`docs/README.md`、`template-mapping.md`、`CONTRIBUTING.md`、`docs/adr/README.md` 同步补充三层 / 六边形架构的入口说明、归类方式与维护规则
- `README.md`、`docs/README.md`、`docs/design/system-design-overview.md`、`docs/guides/onboarding.md` 进一步对齐架构文档的最低必填、阅读顺序、使用边界与引用路径
- `docs/features/README.md`、`docs/design/system-design-overview.md` 进一步补充功能文档与系统总览文档的架构填写约束
- `docs/` 子目录内部链接统一改为相对路径，减少根路径引用与错误跳转
- `CONTRIBUTING.md`、`docs/guides/testing.md` 对齐三层架构与六边形架构的开发、测试要求
- `docs/guides/branch-conventions.md` 补充分支合并、PR、Review、CI、合并策略、分支过期与冲突处理规则
- `CONTRIBUTING.md` 补充 Definition of Ready、Definition of Done、Code Review 标准与多人并行文件/模块锁定规则
- `.github/pull_request_template.md` 补充影响范围、文件/模块锁定、并行冲突扫描、模块 Owner、默认 Reviewer、CODEOWNERS Review、CI 与高风险变更声明
- `docs/guides/team-collaboration.md`、`docs/guides/branch-conventions.md`、`CONTRIBUTING.md` 补充 PR / CODEOWNERS / CI / 分支保护门禁，强化多人并行开发隔离
- `CONTRIBUTING.md`、`AGENTS.md`、`docs/style-guide.md` 补充代码注释规范，区分单行注释、多行注释与文档注释的使用边界

### Fixed
- 修复占位符检查在模板仓库根目录执行时误报合法模板占位符的问题，新增模板仓库自检模式。
- 修复三索引一致性检查对重复文件名（如多个 `README.md`）的假通过问题。
- 修正 devlog 生命周期说明，统一为日志按 `docs/devlog/YYYY/MM/` 年月目录保留。
- 移除本地助手配置文件，并新增 `.gitignore` 避免本地工具状态进入模板包。
- 补充 `AGENTS.md` 低耦合约束，要求 AI 保持模块边界和依赖方向，跨层 / 跨模块依赖需先确认。

### Removed
- `docs/devlog/archive/` 目录与 `docs/devlog/README.md § 4 归档策略`：devlog 不再按季度归档，实际日志按 `docs/devlog/YYYY/MM/` 年月目录保留

### Security
- 

---

## [{{VERSION}}] - {{YYYY-MM-DD}}

### Added
- 

### Changed
- 

### Fixed
- 

### Removed
- 

### Security
- 

---

## 编写规则

1. 一次发布写一个版本块。
2. 未发布内容统一写到 `Unreleased`。
3. 只记录对使用者/维护者有意义的变更，不记录无意义微调。
4. 每条尽量写“结果”，不要只写“做了什么”。

## 预发布检查清单

**发布前的整体检查**以 `docs/guides/release-process.md § 1 发布前检查` 为权威源；本节只列出**与 CHANGELOG 自身相关**的补充项：

- [ ] `Unreleased` 段至少有一个条目（否则不应发版）
- [ ] 每条目属于正确的分类：Added / Changed / Fixed / Removed / Security
- [ ] 每条目是"结果"描述，不是"做了什么"（例：✅ 分页接口空数据响应结构统一 / ❌ 修改了 pagination.ts）
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

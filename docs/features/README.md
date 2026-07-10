# 功能文档说明

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

本目录用于存放各个功能模块的详细说明。每个功能应尽量独立成文，避免把多个模块混写在一个文件里。

## 1. 适用场景

适合写入这里的内容：

- 单个功能模块的行为规则
- 用户操作、CLI 命令、公共 API、脚本入口、页面或服务之间的联动逻辑
- 状态变更规则（若项目存在状态流转）
- 边界条件与异常处理

不适合写入这里的内容：

- 长期规划
- 项目背景
- 全局架构决策（启用 `architecture` pack 时写入对应设计文档）
- 发布记录（启用 `release-support` pack 时写入 `CHANGELOG.md`）

## 2. 建议命名

- `user-auth.md`
- `order-management.md`
- `cli-export.md`
- `library-cache.md`

## 3. 推荐做法

新增功能文档时，优先复制 `feature-template.md`。

若项目启用了 `architecture` pack，且功能涉及既有架构边界、层职责、端口或适配器变化，**必须**填写 `feature-template.md` § 7，并按需关联 `../design/architecture-overview.md` 与对应 ADR。未启用该 pack，或功能不涉及架构边界时，填写实现落点即可，架构关联填 `N/A`，不需要为满足模板额外创建设计文档。

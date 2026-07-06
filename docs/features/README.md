# 功能文档说明

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}

本目录用于存放各个功能模块的详细说明。每个功能应尽量独立成文，避免把多个模块混写在一个文件里。

## 1. 适用场景

适合写入这里的内容：

- 单个功能模块的行为规则
- 页面与接口之间的联动逻辑
- 状态变更规则
- 边界条件与异常处理

不适合写入这里的内容：

- 长期规划
- 项目背景
- 全局架构决策
- 发布记录

## 2. 建议命名

- `user-auth.md`
- `order-management.md`
- `ai-recognition.md`
- `notification-center.md`

## 3. 推荐做法

新增功能文档时，优先复制 `feature-template.md`。

若功能涉及 `三层架构` 中的层职责变化，或 `六边形架构` 中的端口 / 适配器变化，**必须**填写 `feature-template.md` § 7 "架构落点"，并按需关联 `../design/architecture-overview.md` 与对应 ADR。

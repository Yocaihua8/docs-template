# BACKLOG

> 状态：Active
> Owner：张三
> Last Updated：2026-04-18
> Scope：订单中心后台
> Related：`requirements/project-background-and-scope.md`、`features/order-export.md`

## 1. 当前迭代目标

- 里程碑：`v1.0-MVP`（目标日期：2026-05-15）
- 目标摘要：上线订单查询、批量状态更新与异步导出主链路。

## 2. 待办清单

| ID | 标题 | 类型 | 优先级 | 状态 | 负责人 | 关联文档 | 说明 |
|----|------|------|--------|------|--------|----------|------|
| B-001 | 订单导出支持 CSV / Excel 异步下载 | feature | P0 | done | 张三 | `features/order-export.md` | 已接入对象存储与预签名 URL（见 `adr/ADR-005-export-storage-choice.md`） |
| B-002 | 导出大文件（> 200MB）分片上传优化 | tech-debt | P1 | doing | 张三 | `features/order-export.md` | 当前单次上传偶发 504，计划改为 10MB 分片上传并补齐 50,000 行压测 |
| B-003 | 支持订单项（商品明细）导出 | feature | P2 | todo | 李四 | `requirements/project-background-and-scope.md` | 纳入 v1.1 范围，不在本期 MVP 内 |

## 3. 已知问题

| ID | 现象 | 影响范围 | 临时规避 | 跟踪状态 |
|----|------|----------|----------|----------|
| I-001 | 单次导出超过 200MB 时约 5% 概率上传超时 | 运营大批量导出 | 临时调大上传超时至 60s，待 B-002 根治 | 处理中 |

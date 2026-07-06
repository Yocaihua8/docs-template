# 订单导出

> 状态：Active
> Owner：张三
> Last Updated：2026-04-18
> Scope：订单中心后台
> Related：`../design/api-spec.md`、`../design/database-design.md`
> Related ADR：ADR-005-export-storage-choice.md

## 1. 功能目标

支持运营同学将筛选后的订单一次性导出为 CSV 或 Excel，替代现有手工复制粘贴的工作方式。

## 2. 范围

### 2.1 包含内容

- 按筛选条件导出订单列表
- 支持 CSV、Excel 两种格式
- 导出任务异步生成，结果通过站内信通知下载
- 导出文件保留 7 天后自动清理

### 2.2 不包含内容

- 订单项（商品明细）导出，由单独功能承接
- 自动定时导出
- 按 API 直接拉取大批量订单（另有数据同步接口）

## 3. 业务规则

1. 单次导出上限 50,000 行，超过则前端引导拆分筛选条件
2. 导出任务产物 7 天后自动清理，下载链接在此之后失效
3. 导出仅限当前角色可见的数据范围（见 `../design/permission-matrix.md`）
4. 同一用户并发进行中的导出任务不超过 3 个，第 4 个提交时拒绝
5. 导出文件命名：`orders_{筛选摘要}_{YYYYMMDD_HHmmss}.{csv|xlsx}`

## 4. 关键流程

### 4.1 主流程

1. 运营同学在订单列表页设置筛选条件
2. 点击「导出」，前端提交 `POST /v1/orders/export`
3. 后端校验筛选条件与角色数据范围
4. 创建导出任务，状态 `pending`，返回 `task_id`
5. 异步 worker 分批读取订单写入临时文件
6. 上传到对象存储，生成 7 天有效期的预签名 URL
7. 任务状态置 `ready`，通过站内信通知用户
8. 用户点击通知跳转下载页，直接用预签名 URL 下载

### 4.2 异常流程

1. 筛选结果超过 50,000 行：立即返回 `400 ERR_EXPORT_TOO_LARGE`，不创建任务
2. 并发任务数达上限：返回 `429 ERR_EXPORT_CONCURRENCY_LIMIT`
3. 导出中断（worker 崩溃 / 存储不可用）：任务状态置 `failed` 并记录错误码，站内信通知失败原因
4. 文件已过期后下载：预签名 URL 返回 403，前端引导重新发起导出

## 5. 数据与状态

| 项目 | 说明 |
|------|------|
| 输入 | 筛选条件 JSON（状态、时间范围、渠道等）、导出格式（csv/xlsx） |
| 输出 | 对象存储中的导出文件 + 预签名下载 URL |
| 状态 | `pending` → `processing` → `ready` / `failed` / `expired` |

## 6. 接口关联

| 接口 | 说明 |
|------|------|
| `POST /v1/orders/export` | 提交导出任务 |
| `GET /v1/orders/export/{id}` | 查询导出任务状态 |
| `GET /v1/orders/export/{id}/download` | 获取预签名下载 URL（兼容方案，前端优先用 GET status 返回的 URL） |

## 7. 架构落点

### 7.1 三层架构落点

| 层 | 涉及内容 | 说明 |
|----|----------|------|
| 表现层 | `ExportController` | HTTP 请求接收、参数校验、响应封装 |
| 业务层 | `ExportTaskService`、`ExportWorker` | 任务创建、并发限流、异步执行、状态变更 |
| 数据层 | `ExportTaskRepository`、`ObjectStorageClient` | 任务持久化、文件上传、预签名 URL 生成 |

### 7.2 六边形架构落点

本项目采用三层架构，六边形架构落点填 `N/A`。

## 8. 边界与限制

- 不承担订单业务规则校验（状态更新等）
- 不直接把文件推给用户邮箱，仅提供下载链接
- 不支持自定义列，仅导出固定字段集（见 `../design/database-design.md` § 3 `orders` 表）

## 9. 测试关注点

- 50,000 行边界：49,999 行与 50,001 行两侧的行为差异
- 并发限流：第 3 个与第 4 个任务的不同响应
- 任务过期：第 6 天、第 7 天、第 8 天分别访问的结果
- 对象存储不可用：任务状态与用户侧提示是否符合设计
- 权限：A 角色导出后，B 角色拿到 URL 是否仍能下载（预签名 URL 本身是否应受权限约束 —— 见 `../adr/ADR-005-export-storage-choice.md` 的取舍）

## 10. 相关决策

- 相关 ADR：`ADR-005-export-storage-choice.md`
- 决策摘要：采用对象存储 + 预签名 URL，避免服务端长连接下载；取舍详见 ADR

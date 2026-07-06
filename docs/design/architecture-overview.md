# 架构设计说明

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 架构结论

一句话说明当前采用的总体架构，例如：前后端分离 / 单体应用 / 微服务 / 三层架构 / 六边形架构 / 本地优先 / AI 辅助链路等。

建议补充以下结论字段：

| 字段 | 内容 |
|------|------|
| 架构模式 | 三层架构 / 六边形架构 / 混合 |
| 核心边界 | {{CORE_BOUNDARY}} |
| 主要入口 | {{PRIMARY_ENTRY}} |
| 主要外部依赖 | {{PRIMARY_DEPENDENCIES}} |

## 2. 架构图（文字版）

### 2.1 三层架构示意

```text
[表现层：前端 / Controller / API]
    ↓
[业务层：Application Service / Domain Service]
    ↓
[数据层：Repository / Database / Third-party]
```

### 2.2 六边形架构示意

```text
        [输入适配器：HTTP / CLI / MQ Consumer]
                      ↓
                [输入端口]
                      ↓
                  [领域核心]
                      ↓
                [输出端口]
                      ↓
 [输出适配器：Repository / MQ Producer / Third-party Client]
```

## 3. 技术栈

| 层级 | 技术 | 用途 | 选择原因 |
|------|------|------|----------|
| 前端 | {{TECH}} | {{PURPOSE}} | {{REASON}} |
| 后端 | {{TECH}} | {{PURPOSE}} | {{REASON}} |
| 数据库 / 基础设施 | {{TECH}} | {{PURPOSE}} | {{REASON}} |
| 部署 | {{TECH}} | {{PURPOSE}} | {{REASON}} |

## 4. 结构职责

### 4.1 三层架构职责

#### 表现层

- 负责用户交互、请求接收、参数校验、响应组装
- 不承载核心业务规则

#### 业务层

- 负责核心业务规则、用例编排、事务边界
- 协调数据层完成持久化与外部调用

#### 数据层

- 负责持久化、缓存、第三方系统访问
- 向上提供稳定的数据访问能力

### 4.2 六边形架构职责

#### 领域核心

- 负责核心业务规则、领域对象、领域服务
- 不直接依赖 HTTP、数据库、消息中间件、第三方 SDK

#### 输入端口

- 定义系统对外暴露的用例接口
- 由输入适配器调用

#### 输出端口

- 定义领域核心需要的外部能力接口
- 由输出适配器实现

#### 输入适配器

- 负责把 HTTP / CLI / MQ / 定时任务请求转换为输入端口调用

#### 输出适配器

- 负责把输出端口落到数据库、缓存、消息队列、第三方 API 等基础设施

### 4.3 端口与适配器映射表

| 名称 | 类型 | 作用 | 由谁调用 / 实现 |
|------|------|------|-----------------|
| {{PORT_OR_ADAPTER_NAME}} | 输入端口 / 输出端口 / 输入适配器 / 输出适配器 | {{PURPOSE}} | {{OWNER_OR_IMPLEMENTATION}} |

## 5. 外部依赖

| 依赖项 | 类型 | 用途 | 风险 |
|--------|------|------|------|
| {{DEPENDENCY}} | 内部/外部 | {{PURPOSE}} | {{RISK}} |

## 6. 关键设计约束

- 三层架构下，上层只能依赖下层，下层不反向依赖上层
- 三层架构下，表现层不直接承载核心业务规则
- 六边形架构下，领域核心不依赖适配器实现
- 端口命名应体现业务语义，不使用基础设施语义命名
- {{CONSTRAINT}}

## 7. 备选方案与取舍

| 方案 | 是否采用 | 原因 |
|------|----------|------|
| {{ALTERNATIVE_A}} | 是/否 | {{REASON}} |
| {{ALTERNATIVE_B}} | 是/否 | {{REASON}} |

## 附录：填写示例

### 示例 1：三层架构

下方为一个简化的三层架构填写样例。**复制模板时请删除本附录**。

````markdown
# 架构设计说明

> 状态：Draft
> Owner：张三
> Last Updated：2026-04-18
> Scope：用户中心
> Related：`../features/user-profile.md`、`api-spec.md`

## 1. 架构结论

当前用户中心采用三层架构。表现层负责 HTTP 请求与参数校验，业务层负责资料修改、权限判断与事务控制，数据层负责用户数据持久化与外部系统访问。

| 字段 | 内容 |
|------|------|
| 架构模式 | 三层架构 |
| 核心边界 | 用户资料、账号状态、权限校验 |
| 主要入口 | 用户资料查询接口、资料修改接口 |
| 主要外部依赖 | MySQL、Redis |

## 2.1 三层架构示意

```text
[表现层：UserController]
          ↓
[业务层：UserService]
          ↓
[数据层：UserRepository / RedisCache]
```
````

### 示例 2：六边形架构

下方为一个简化的六边形架构填写样例。**复制模板时请删除本附录**。

````markdown
# 架构设计说明

> 状态：Draft
> Owner：张三
> Last Updated：2026-04-18
> Scope：订单履约模块
> Related：`../features/order-fulfillment.md`、`../adr/ADR-008-order-fulfillment-hexagonal.md`

## 1. 架构结论

当前订单履约模块采用六边形架构。HTTP 控制器、定时任务、数据库访问、消息发送均通过端口与适配器接入，核心履约规则放在领域核心中。

| 字段 | 内容 |
|------|------|
| 架构模式 | 六边形架构 |
| 核心边界 | 订单履约规则、状态变更、库存校验 |
| 主要入口 | HTTP 下单接口、超时取消定时任务 |
| 主要外部依赖 | MySQL、Redis、消息队列 |

## 2. 架构图（文字版）

```text
[输入适配器：OrderController / CancelTimeoutJob]
                  ↓
        [输入端口：PlaceOrderUseCase]
                  ↓
              [领域核心]
                  ↓
 [输出端口：OrderRepository / InventoryGateway / EventPublisher]
                  ↓
[输出适配器：MySQL Repository / HTTP Client / MQ Producer]
```

## 4.3 端口与适配器映射表

| 名称 | 类型 | 作用 | 由谁调用 / 实现 |
|------|------|------|-----------------|
| `PlaceOrderUseCase` | 输入端口 | 提交订单 | `OrderController` 调用 |
| `OrderRepository` | 输出端口 | 读写订单聚合 | `MySqlOrderRepository` 实现 |
| `InventoryGateway` | 输出端口 | 校验与扣减库存 | `InventoryHttpClient` 实现 |
````

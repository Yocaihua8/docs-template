# 架构设计说明

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 架构结论

一句话说明当前采用的总体架构。架构模式使用项目真实名称或自由文本，例如：单进程 CLI、库 / SDK、插件体系、事件驱动、本地优先、前后端分离、三层架构或六边形架构。

建议补充以下结论字段：

| 字段 | 内容 |
|------|------|
| 架构模式 | {{ARCHITECTURE_MODE}} |
| 核心边界 | {{CORE_BOUNDARY}} |
| 主要入口 | {{PRIMARY_ENTRY}} |
| 主要外部依赖 | {{PRIMARY_DEPENDENCIES}} |

## 2. 架构图（文字版）

### 2.1 当前项目架构

只画实际存在的入口、核心模块、状态 / 数据、外部依赖和输出；不存在的层或基础设施不要补齐。

```text
{{ARCHITECTURE_DIAGRAM}}
```

以下两种结构仅供采用对应模式的项目参考；不适用时删除，不要同时当作当前约束。

### 2.2 三层架构示意（采用三层架构时）

```text
[表现层：前端 / Controller / API]
    ↓
[业务层：Application Service / Domain Service]
    ↓
[数据层：Repository / Database / Third-party]
```

### 2.3 六边形架构示意（采用六边形架构时）

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

## 3. 技术组成

只列实际存在的能力或组件。纯库、CLI、脚本、桌面端或无持久化项目可删除不适用行。

| 能力 / 组件 | 技术或实现 | 用途 | 选择原因 | 是否适用 |
|-------------|------------|------|----------|------------|
| 运行入口 | {{PRIMARY_ENTRY_TECH}} | {{PURPOSE}} | {{REASON}} | 是 / N/A |
| 核心模块 | {{CORE_COMPONENT_TECH}} | {{PURPOSE}} | {{REASON}} | 是 / N/A |
| 状态 / 数据 | {{STATE_OR_DATA_TECH}} | {{PURPOSE}} | {{REASON}} | 是 / N/A |
| 外部集成 | {{INTEGRATION_TECH}} | {{PURPOSE}} | {{REASON}} | 是 / N/A |
| 交付 / 运行载体 | {{DELIVERY_OR_RUNTIME_TECH}} | {{PURPOSE}} | {{REASON}} | 是 / N/A |

## 4. 结构职责

先使用通用模块表描述当前项目，再仅保留与实际架构模式匹配的专属小节。

### 4.1 通用模块职责

| 模块 / 边界 | 职责 | 输入 | 输出 | 允许依赖 | 禁止依赖 |
|-------------|------|------|------|----------|----------|
| {{MODULE_OR_BOUNDARY}} | {{RESPONSIBILITY}} | {{INPUT}} | {{OUTPUT}} | {{ALLOWED_DEPENDENCIES}} | {{FORBIDDEN_DEPENDENCIES}} |

### 4.2 三层架构职责（采用时）

#### 表现层

- 负责用户交互、请求接收、参数校验、响应组装
- 不承载核心业务规则

#### 业务层

- 负责核心业务规则、用例编排、事务边界
- 协调数据层完成持久化与外部调用

#### 数据层

- 负责持久化、缓存、第三方系统访问
- 向上提供稳定的数据访问能力

### 4.3 六边形架构职责（采用时）

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

### 4.4 端口与适配器映射表（采用六边形架构时）

| 名称 | 类型 | 作用 | 由谁调用 / 实现 |
|------|------|------|-----------------|
| {{PORT_OR_ADAPTER_NAME}} | 输入端口 / 输出端口 / 输入适配器 / 输出适配器 | {{PURPOSE}} | {{OWNER_OR_IMPLEMENTATION}} |

## 5. 外部依赖

| 依赖项 | 类型 | 用途 | 风险 |
|--------|------|------|------|
| {{DEPENDENCY}} | 内部/外部 | {{PURPOSE}} | {{RISK}} |

## 6. 关键设计约束

- 所有项目：记录真实模块边界、依赖方向和禁止跨越的约束
- 采用三层架构时：上层只能依赖下层，表现层不直接承载核心业务规则
- 采用六边形架构时：领域核心不依赖适配器实现，端口命名体现业务语义
- 纯库、CLI、脚本或插件：记录公共 API、运行入口、扩展点和宿主边界；无数据库、网络或部署层时填 `N/A`
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

## 4.4 端口与适配器映射表

| 名称 | 类型 | 作用 | 由谁调用 / 实现 |
|------|------|------|-----------------|
| `PlaceOrderUseCase` | 输入端口 | 提交订单 | `OrderController` 调用 |
| `OrderRepository` | 输出端口 | 读写订单聚合 | `MySqlOrderRepository` 实现 |
| `InventoryGateway` | 输出端口 | 校验与扣减库存 | `InventoryHttpClient` 实现 |
````

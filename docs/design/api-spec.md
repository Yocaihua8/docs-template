# 接口设计文档

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 设计原则

- URL 风格统一
- 请求参数命名统一
- 响应结构统一
- 错误码可枚举、可追踪

## 1.1 与接入手册的边界

| 文档 | 面向 | 职责 |
|------|------|------|
| `api-spec.md` | API 实现方 + 调用方 | 接口契约权威源：路径、方法、字段、错误码、权限、响应结构 |
| `../guides/integration-guide-template.md` | 面向调用方 | 说明如何接入、配置环境、处理认证、联调、排错，不重复维护接口权威字段 |

如果两者冲突，以 `api-spec.md` 为准；接入手册应链接到本文件对应接口，而不是复制一份长期漂移的契约。

## 2. 认证与鉴权

- 认证方式：
- Token / Session 位置：
- 刷新机制：
- 权限校验原则：

## 3. 统一响应格式

### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

### 失败响应

```json
{
  "code": 40001,
  "message": "error message",
  "data": null
}
```

### 分页响应

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 0,
    "page": 1,
    "page_size": 20,
    "items": []
  }
}
```

## 4. 错误码规范

| 错误码 | 含义 | 处理建议 |
|--------|------|----------|
| 40001 | {{ERROR_MEANING}} | {{SUGGESTION}} |
| 40101 | {{ERROR_MEANING}} | {{SUGGESTION}} |
| 50001 | {{ERROR_MEANING}} | {{SUGGESTION}} |

## 5. 关键数据契约

### 5.1 {{ENTITY_NAME}}

| 字段 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | integer | 是 | - | 主键 |

## 6. 接口清单

| 模块 | 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|------|
| {{MODULE}} | GET | `/path` | {{DESCRIPTION}} | {{ROLE}} |

## 7. 接口详情模板

### {{API_NAME}}

**Method**: `GET/POST/PUT/DELETE`
**Path**: `/path`
**说明**: {{API_PURPOSE}}

#### Request Params

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| {{PARAM_NAME}} | {{PARAM_TYPE}} | 是/否 | {{DEFAULT_VALUE}} | {{DESCRIPTION}} |

#### Request Body

```json
{
  "field": "value"
}
```

#### Response 200

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

#### 失败场景

| 场景 | 错误码 | 说明 |
|------|--------|------|
| {{SCENARIO}} | {{ERROR_CODE}} | {{DESCRIPTION}} |

## 8. 接口变更规则

- 破坏性变更必须提前记录
- 新增字段应尽量保持向后兼容
- 废弃接口要注明替代接口和下线时间

**职责切分**：

- 本文件（`api-spec.md`）是接口**契约的权威源**：描述当前有效的接口形态、字段、错误码
- 破坏性变更的**迁移指南、弃用时间表、版本倒序变更清单**统一写入 `api-changes.md`，本文件只链接到对应条目，不重复写迁移细节

## 附录：填写示例

````markdown
# 接口设计文档

## 6. 接口清单

| 模块 | 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|------|
| 订单导出 | POST | `/v1/orders/export` | 提交导出任务 | 运营人员 |

## 7. 接口详情模板

### 提交导出任务

**Method**: `POST`
**Path**: `/v1/orders/export`
**说明**: 按筛选条件创建订单导出任务

#### Request Body

```json
{
  "status": "paid",
  "date_from": "2026-04-01",
  "date_to": "2026-04-18"
}
```

#### Response 200

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "task_id": "exp_001"
  }
}
```
````

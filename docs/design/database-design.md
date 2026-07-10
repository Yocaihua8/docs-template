# 数据库设计

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

## 1. 设计目标

说明数据库设计要解决的问题与建模边界。

## 2. 表清单

| 表名 | 用途 | 主键 | 说明 |
|------|------|------|------|
| {{TABLE_NAME}} | {{PURPOSE}} | {{PRIMARY_KEY}} | {{DESCRIPTION}} |

## 3. 表结构模板

### 3.1 `{{TABLE_NAME}}`

**用途**：  
**说明**：

| 字段 | 类型 | 允许空 | 默认值 | 索引 | 说明 |
|------|------|--------|--------|------|------|
| id | bigint | 否 | - | PK | 主键 |
| created_at | datetime | 否 | CURRENT_TIMESTAMP | IDX | 创建时间 |

## 4. 实体关系

### 4.1 关系说明

- {{ENTITY_A}} 与 {{ENTITY_B}}：一对多 / 多对多 / 一对一
- {{ENTITY_C}} 与 {{ENTITY_D}}：...

### 4.2 ER 图（文字版）

```text
[entity_a] 1 --- n [entity_b]
[entity_b] n --- 1 [entity_c]
```

## 5. 关键约束

- 唯一约束：
- 外键约束：
- 状态字段约束：
- 软删除策略：

## 6. 迁移规范

- 所有结构变更通过迁移脚本完成
- 禁止直接修改线上已执行的历史迁移
- 迁移文件命名规则：`V{number}__description.sql`

## 附录：填写示例

````markdown
# 数据库设计

## 2. 表清单

| 表名 | 用途 | 主键 | 说明 |
|------|------|------|------|
| `orders` | 存储订单主信息 | `id` | 订单中心主表 |

## 3. 表结构模板

### 3.1 `orders`

**用途**：存储订单主信息  
**说明**：包含订单号、状态、金额、创建时间等字段

| 字段 | 类型 | 允许空 | 默认值 | 索引 | 说明 |
|------|------|--------|--------|------|------|
| id | bigint | 否 | - | PK | 主键 |
| order_no | varchar(64) | 否 | - | UK | 订单号 |
| status | varchar(32) | 否 | `created` | IDX | 订单状态 |
| created_at | datetime | 否 | CURRENT_TIMESTAMP | IDX | 创建时间 |

## 4.2 ER 图（文字版）

```text
[orders] 1 --- n [order_items]
```
````

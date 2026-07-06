# {{FEATURE_NAME}}

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}
> Related ADR：{{ADR_ID}}（若涉及架构决策则必填，否则填 N/A）

## 1. 功能目标

说明这个功能解决什么问题，服务谁。

## 2. 范围

### 2.1 包含内容

- 

### 2.2 不包含内容

- 

## 3. 业务规则

1. 
2. 
3. 

## 4. 关键流程

### 4.1 主流程

1. 
2. 
3. 

### 4.2 异常流程

1. 
2. 

## 5. 数据与状态

| 项目 | 说明 |
|------|------|
| 输入 | {{DESCRIPTION}} |
| 输出 | {{DESCRIPTION}} |
| 状态 | {{DESCRIPTION}} |

## 6. 接口关联

| 接口 | 说明 |
|------|------|
| `GET /path` | {{DESCRIPTION}} |
| `POST /path` | {{DESCRIPTION}} |

## 7. 架构落点

### 7.1 三层架构落点

| 层 | 涉及内容 | 说明 |
|----|----------|------|
| 表现层 | {{PRESENTATION_LAYER_COMPONENT}} | {{DESCRIPTION_OR_NA}} |
| 业务层 | {{BUSINESS_LAYER_COMPONENT}} | {{DESCRIPTION_OR_NA}} |
| 数据层 | {{DATA_LAYER_COMPONENT}} | {{DESCRIPTION_OR_NA}} |

### 7.2 六边形架构落点

| 类型 | 名称 | 作用 | 说明 |
|------|------|------|------|
| 输入端口 | {{INPUT_PORT}} | {{PURPOSE_OR_NA}} | {{DESCRIPTION_OR_NA}} |
| 输出端口 | {{OUTPUT_PORT}} | {{PURPOSE_OR_NA}} | {{DESCRIPTION_OR_NA}} |
| 输入适配器 | {{INPUT_ADAPTER}} | {{PURPOSE_OR_NA}} | {{DESCRIPTION_OR_NA}} |
| 输出适配器 | {{OUTPUT_ADAPTER}} | {{PURPOSE_OR_NA}} | {{DESCRIPTION_OR_NA}} |

若项目未采用对应架构，或本功能不涉及该部分，填 `N/A`。

## 8. 边界与限制

- 

## 9. 测试关注点

- 边界值与非法输入（空值、超长、越界）
- 权限校验：不同角色访问、无权限拒绝
- 异常路径：外部依赖（DB、缓存、第三方服务）失败时的行为
- 幂等性与并发：重复提交、并发写是否安全
- 回归：与现有功能的交叉影响点

## 10. 相关决策

- 相关 ADR：`{{ADR_ID}}`（可选，如 `ADR-007-auth-token-rotation.md`）
- 决策摘要：{{DECISION_SUMMARY}}（可选）

若本功能实现过程中做出过重要技术选型或架构变更，在此列出对应 ADR；没有则填 N/A。

---

## 附录：填写示例

下方为一个简化的填写样例，展示各字段预期形态。**复制模板时请删除本附录**。

```markdown
# 订单导出

> 状态：Active
> Owner：张三
> Last Updated：2026-04-17
> Scope：订单中心后台
> Related：`../design/api-spec.md`
> Related ADR：ADR-005-export-storage-choice.md

## 1. 功能目标

支持运营同学将筛选后的订单一次性导出为 CSV 或 Excel，替代原有手工复制粘贴。

## 2. 范围

### 2.1 包含内容
- 按筛选条件导出订单列表
- 支持 CSV、Excel 两种格式
- 导出结果异步生成后通过站内信通知下载

### 2.2 不包含内容
- 明细行（订单项）导出，由单独功能承接
- 自动定时导出

## 3. 业务规则
1. 单次导出上限 50,000 行，超过则要求拆分筛选条件
2. 导出任务 7 天后自动清理
3. 导出仅限当前角色可见的数据范围

## 6. 接口关联
| 接口 | 说明 |
|------|------|
| `POST /v1/orders/export` | 提交导出任务 |
| `GET /v1/orders/export/{id}` | 查询导出任务状态 |

## 7. 架构落点

### 7.1 三层架构落点
| 层 | 涉及内容 | 说明 |
|----|----------|------|
| 表现层 | `ExportController` | 接收导出请求、返回任务状态 |
| 业务层 | `ExportService` | 校验导出条件、创建导出任务、触发异步执行 |
| 数据层 | `ExportTaskRepository`、对象存储客户端 | 持久化任务记录、写入导出文件 |

### 7.2 六边形架构落点
| 类型 | 名称 | 作用 | 说明 |
|------|------|------|------|
| 输入端口 | `CreateExportTaskUseCase` | 创建导出任务 | 若项目未采用六边形架构则填 `N/A` |
| 输出端口 | `ExportFileStorage` | 保存导出文件 | 若项目未采用六边形架构则填 `N/A` |
| 输入适配器 | `ExportController` | HTTP 请求转用例调用 | 若项目未采用六边形架构则填 `N/A` |
| 输出适配器 | `OssExportFileStorage` | 对接对象存储实现文件保存 | 若项目未采用六边形架构则填 `N/A` |

## 9. 测试关注点

- 50,000 行边界：49,999 行与 50,001 行两侧的行为差异
- 权限：A 角色导出后，B 角色拿到链接是否仍能下载
- 异常路径：对象存储不可用时任务状态与用户侧提示是否符合设计
- 并发限流：第 3 个与第 4 个任务的不同响应

## 10. 相关决策
- 相关 ADR：`ADR-005-export-storage-choice.md`
- 决策摘要：采用对象存储 + 预签名 URL，避免服务端长连接下载
```

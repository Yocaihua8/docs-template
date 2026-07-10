# 状态流转与验收标准

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

本文档只在项目存在业务状态、任务生命周期、审批流、发布状态或其他有限状态流转时启用。若只有无状态计算或简单 CRUD，应删除本文件或将状态部分明确标为 `N/A`，不要为了套模板虚构状态机。

## 0. 适用性

| 项目 | 内容 |
|------|------|
| 是否存在需要约束的状态 / 生命周期 | 是 / 否 |
| 状态对象 | {{OBJECT_NAME_OR_NA}} |
| 状态权威来源 | {{STATE_SOURCE_OF_TRUTH_OR_NA}} |
| 不适用说明 | {{NOT_APPLICABLE_REASON_OR_NA}} |

## 1. 状态流转

### 1.1 {{OBJECT_NAME}}

| 当前状态 | 事件 | 下一个状态 | 规则 |
|----------|------|------------|------|
| {{STATE_A}} | {{ACTION}} | {{STATE_B}} | {{DESCRIPTION}} |
| {{STATE_B}} | {{ACTION}} | {{STATE_C}} | {{DESCRIPTION}} |

### 1.2 状态说明

- `{{STATE_A}}`：
- `{{STATE_B}}`：
- `{{STATE_C}}`：

## 2. 验收标准

### AC-001 {{ACCEPTANCE_NAME}}

- **前置条件**：
- **操作步骤**：
  1. 
  2. 
  3. 
- **预期结果**：
  - 

### AC-002 {{ACCEPTANCE_NAME}}

- **前置条件**：
- **操作步骤**：
  1. 
  2. 
- **预期结果**：
  - 

## 3. 验收执行方式

- 人工验收：
- 自动化验证：
- 回归范围：
- 仅有验收标准而无状态流时：删除 § 1，仅保留与项目实际能力对应的验收项。

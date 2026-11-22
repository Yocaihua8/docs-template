# DevLog {{CURRENT_DATE}}

> Author：{{AUTHOR}}
> Iteration：{{ITERATION_OR_SPRINT}}（可选）
> Related：{{RELATED_DOCS_OR_ISSUES}}（可选）

## 1. Done（今日/本周完成）

- {{ITEM_1}}
- {{ITEM_2}}

## 2. Issues（遇到的问题）

记录阻塞、异常、临时规避。问题本身若需追踪，请同步进 `BACKLOG.md` 并在此仅留指针。

- **问题**：{{PROBLEM}}
  **影响**：{{IMPACT}}
  **当前处理**：{{WORKAROUND_OR_STATUS}}
  **跟踪**：{{BACKLOG_ID_OR_LINK}}（可选）

## 3. Decisions（临时决策）

记录本次开发中做出的小决策。**重大决策必须提升为 ADR**，此处仅放 ADR 编号。

- {{DECISION}} → 原因：{{REASON}}
- 关联 ADR：{{ADR_ID}}（可选）

## 4. Next（下一步）

- {{NEXT_ITEM_1}}
- {{NEXT_ITEM_2}}

## 5. Links（相关链接）

- Commit：{{COMMIT_HASH_OR_URL}}（可选）
- PR：{{PR_URL}}（可选）
- Issue：{{ISSUE_URL}}（可选）
- 关联文档：{{DOC_PATH}}（可选）

---

## 附录：填写示例

下方为一条简化的单日 devlog 填写样例。**复制模板时请删除本附录**。

```markdown
# DevLog 2026-04-17

> Author：张三
> Iteration：Sprint-12
> Related：`../features/order-export.md`、B-042

## 1. Done
- 完成订单导出任务的对象存储接入（上传 + 预签名 URL 生成）
- 补齐导出任务状态查询接口的单测

## 2. Issues
- **问题**：大文件上传偶发 504
  **影响**：单次导出 > 200MB 时约 5% 概率失败
  **当前处理**：临时将超时提高到 60s，观察中
  **跟踪**：B-045

## 3. Decisions
- 导出产物保留期改为 7 天 → 原因：与运营对齐的清理窗口
- 关联 ADR：ADR-005-export-storage-choice.md

## 4. Next
- 将 504 问题的定位结果同步到 B-045
- 联调前端下载链路

## 5. Links
- PR：https://github.com/example/repo/pull/321
- Issue：B-045
```

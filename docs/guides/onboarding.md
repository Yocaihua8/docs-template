# 新人 Onboarding

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

帮助新成员在**一周内**能独立完成一次小型开发任务。目标是降低上手成本，不替代 `../../CONTRIBUTING.md` 与 `setup.md`。

本指南按项目实际托管平台和运行形态裁剪。PR、Merge Request 或其他评审入口均可作为“第一个变更请求”；没有 CI、部署平台、数据库、线上环境或独立测试账号时填 `N/A`，不要为完成清单申请无用权限。

## 0. 实战上手目标

新人上手不是只读完文档，而是要完成三个可验证目标：

| 目标 | 验收方式 |
|------|----------|
| 能跑起来 | 按 `setup.md` 完成本地启动，并能访问核心入口或跑通主命令 |
| 能读懂 | 能说清项目入口、核心模块、接口契约和当前 BACKLOG 位置 |
| 能提第一个 PR / MR / 变更请求 | 选择一个小任务，完成修改、验证、文档同步和 Review 往返 |

## 1. Day 0 — 加入前准备

- [ ] 获得代码仓库权限
- [ ] 若项目存在 CI / 部署平台，已获得完成任务所需的最小权限；否则 N/A
- [ ] 加入对应沟通渠道（IM、邮件组）
- [ ] 若任务需要，已获得最小测试账号与脱敏测试数据入口；否则 N/A

## 2. Day 1 — 环境与文档

- [ ] 按 `setup.md` 搭好本地环境并跑通主流程
- [ ] 阅读 `../requirements/project-background-and-scope.md`
- [ ] 若启用 `architecture` pack，阅读 `../design/system-design-overview.md` 与 `../design/architecture-overview.md`
- [ ] 若启用 `api` pack，阅读 `../design/api-spec.md`，确认接口契约在哪里维护
- [ ] 若启用 `glossary` pack，浏览 `../glossary.md`，记下陌生术语

## 3. Day 2-3 — 代码通读

- [ ] 通读核心模块目录结构
- [ ] 找到一个功能从项目实际入口（CLI / API / UI / 脚本 / 库调用）到核心逻辑的完整链路
- [ ] 按项目现有测试策略跑通至少一组相关验证；没有对应测试层时记录 N/A 和替代验证
- [ ] 阅读若干近期合并变更，理解团队的评审口径（仓库历史不足时 N/A）
- [ ] 若启用 `architecture` pack 且存在 ADR，阅读若干近期决策

## 4. Day 4-5 — 动手实践

- [ ] 领取一个 `good-first-issue` 或小型 BACKLOG 条目
- [ ] 按 `../../CONTRIBUTING.md` 流程提交项目实际采用的变更请求
- [ ] 完成一次 Code Review 往返
- [ ] 将过程中发现的文档缺口回流到对应模板或 BACKLOG

## 5. 第一周末 — 自查表

- [ ] 能独立运行项目实际主入口或主验证命令
- [ ] 知道功能文档入口，以及已启用的接口、数据、架构文档在哪里查
- [ ] 知道遇到阻塞时该找谁、用什么渠道
- [ ] 知道如何在 `../devlog/` 记录开发日志
- [ ] 能说明第一个 PR / MR / 变更请求的影响范围、验证命令和文档同步情况

## 6. 常用链接与联系人

| 类型 | 链接 / 联系人 |
|------|---------------|
| 代码仓库 | {{REPO_URL}} |
| CI / 部署（如有） | {{CI_URL_OR_NA}} |
| 监控面板（如有） | {{MONITORING_URL_OR_NA}} |
| 文档入口 | `../README.md` |
| 值班联系人（如有） | {{ONCALL_CONTACT_OR_NA}} |
| 技术负责人 | {{TECH_LEAD}} |

---

## 附录：填写示例

下方为简化样例，展示各阶段清单与联系人表的预期形态。**复制模板时请删除本附录**。

```markdown
# 新人 Onboarding

## 1. Day 0 — 加入前准备

- [x] 获得代码仓库权限（张三已邀请）
- [x] 获得 CI / 部署平台访问权限
- [ ] 加入 #order-team Slack 频道
- [ ] 拿到测试账号（联系李四）

## 2. Day 1 — 环境与文档

- [x] 按 `setup.md` 搭好本地环境并跑通主流程
- [ ] 阅读 `../requirements/project-background-and-scope.md`
- [ ] 阅读 `../design/system-design-overview.md`

## 6. 常用链接与联系人

| 类型 | 链接 / 联系人 |
|------|---------------|
| 代码仓库 | https://github.com/example/order-service |
| CI / 部署 | https://ci.example.com/order-service |
| 监控面板 | https://grafana.example.com/d/order |
| 文档入口 | `../README.md` |
| 值班联系人 | 李四（工作日 09:00–18:00） |
| 技术负责人 | 张三 |
```

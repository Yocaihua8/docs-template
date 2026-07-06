# 新人 Onboarding

> 状态：Draft
> Owner：{{OWNER}}
> Last Updated：{{YYYY-MM-DD}}
> Scope：{{SCOPE}}
> Related：{{RELATED_DOCS}}

帮助新成员在**一周内**能独立完成一次小型开发任务。目标是降低上手成本，不替代 `../../CONTRIBUTING.md` 与 `setup.md`。

## 1. Day 0 — 加入前准备

- [ ] 获得代码仓库权限
- [ ] 获得 CI / 部署平台访问权限
- [ ] 加入对应沟通渠道（IM、邮件组）
- [ ] 拿到测试账号与测试数据入口

## 2. Day 1 — 环境与文档

- [ ] 按 `setup.md` 搭好本地环境并跑通主流程
- [ ] 阅读 `../requirements/project-background-and-scope.md`
- [ ] 阅读 `../design/system-design-overview.md` 与 `../design/architecture-overview.md`
- [ ] 浏览 `../glossary.md`，记下陌生术语

## 3. Day 2-3 — 代码通读

- [ ] 通读核心模块目录结构
- [ ] 跑通至少一组单元测试与一次集成测试
- [ ] 阅读最近 10 个合并的 PR，理解团队的评审口味
- [ ] 阅读最近 3 条 ADR，理解为什么目前这样设计

## 4. Day 4-5 — 动手实践

- [ ] 领取一个 `good-first-issue` 或小型 BACKLOG 条目
- [ ] 按 `../../CONTRIBUTING.md` 流程提交 PR
- [ ] 完成一次 Code Review 往返

## 5. 第一周末 — 自查表

- [ ] 能独立跑起本地服务
- [ ] 知道功能、接口、数据结构分别在哪个文档里查
- [ ] 知道遇到阻塞时该找谁、用什么渠道
- [ ] 知道如何在 `../devlog/` 记录开发日志

## 6. 常用链接与联系人

| 类型 | 链接 / 联系人 |
|------|---------------|
| 代码仓库 | {{REPO_URL}} |
| CI / 部署 | {{CI_URL}} |
| 监控面板 | {{MONITORING_URL}} |
| 文档入口 | `../README.md` |
| 值班联系人 | {{ONCALL_CONTACT}} |
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

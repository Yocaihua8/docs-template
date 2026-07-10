# 贡献指南

感谢参与 {{PROJECT_NAME}}。本文档说明如何提出问题、准备改动、验证结果并提交可评审的 Pull Request。

本文中的 Issue 可对应项目实际的事项 / 工单入口，Pull Request（PR）也包括 Merge Request 或其他受评审的变更请求；不要因为托管平台不同而新增一套重复流程。

## 1. 开始之前

1. 阅读项目 [`README.md`](README.md) 与 [`docs/README.md`](docs/README.md)。
2. 搜索现有 Issue 和 Pull Request，避免重复工作。
3. 非小型修复先通过 Issue 或讨论入口确认目标、范围和验收方式。
4. 安全漏洞不要提交公开 Issue；若项目启用了根目录 `SECURITY.md`，按其中私密渠道上报，否则联系项目 Owner 使用已确认的非公开渠道。

## 2. 本地环境

```bash
{{INSTALL_COMMAND}}
{{ENV_INIT_COMMAND}}
{{DEV_COMMAND}}
```

详细步骤和常见问题见 `docs/guides/setup.md`。命令不适用时填写 `N/A` 并给出项目实际入口。

## 3. 选择贡献范围

- 一个 Pull Request 聚焦一个可验证目标。
- 开始前写清允许修改和明确不修改的文件、模块或公共契约。
- 不做无关重构、大范围格式化或依赖升级。
- 公共接口、数据库、权限、状态机或兼容性变化必须先说明影响和迁移方式。
- 使用 AI 编程时，在 PR 中说明主要指令、实际修改范围和人工验证结果。

## 4. 分支与提交

推荐分支名称：

```text
feature/<description>
fix/<description>
docs/<description>
refactor/<description>
chore/<description>
```

提交信息使用清楚的类型和结果描述，例如：

```text
fix: 修复空数据导出返回 500
docs: 补充本地数据库初始化步骤
```

不要使用 `update`、`misc`、`继续` 等无法说明改动结果的标题。

## 5. 测试与验证

提交前运行与改动相关的最小充分验证：

```bash
{{TEST_ALL_COMMAND}}
```

PR 中必须如实列出：

- 已运行的命令与结果。
- 未运行项目及其原因。
- 需要人工验证的步骤和预期结果。
- 已知限制、未覆盖平台或后续事项。

不得把“没有观察到错误”写成“测试通过”。

## 6. 文档同步

行为发生变化时，同步项目实际启用的对应文档：

| 变化 | 文档 |
|------|------|
| 需求、范围、验收标准 | `docs/requirements/`、`docs/features/` |
| API、数据、权限、状态 | `docs/design/` 中已启用的对应文档 |
| 架构边界或重大取舍 | 架构文档与 ADR |
| 安装、测试、发布、支持 | `docs/guides/` 中已启用的对应文档 |
| 已知问题和技术债 | 项目实际采用的 BACKLOG / Issue 入口 |
| 对使用者可见的发布变化 | 启用 `release-support` 时写入 `CHANGELOG.md`；否则使用项目实际发布入口 |

不需要更新文档时，在 PR 中说明理由。

## 7. Pull Request

PR 至少包含：

- 问题与目标。
- 实际修改范围。
- 接口、数据、权限和兼容性影响。
- 测试与人工验证证据。
- 文档同步情况。
- 已知限制和后续事项。

维护者可能要求拆分过大的 PR，或先补充问题定义、测试和迁移说明。

## 8. Review 与合并

- 评审聚焦正确性、边界、兼容性、安全、测试和文档，不进行人身评价。
- 阻塞问题必须处理；非阻塞建议应有明确结论。
- 单维护者项目可由维护者自行合并，但仍应保留验证记录。
- 多维护者项目按实际启用的团队规范、CODEOWNERS 和分支规则执行。
- 合并后若发现新风险或已知问题，回流到 Issue / BACKLOG，而不是只留在评论中。

## 9. 联系方式

- 项目 Owner：{{OWNER}}
- 常规问题：使用项目公开 Issue / Discussion 或 README 指定渠道。
- 安全问题：使用已启用的 `SECURITY.md` 私密渠道；未启用时联系项目 Owner，不在公开 Issue 披露。

# 文档总览

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

本文档是 {{PROJECT_NAME}} 的文档入口。初始化器只复制已选择 profile 与 pack 对应的文件，因此目录和阅读顺序以实际生成结果为准。

## 1. 最小阅读顺序

1. [`requirements/project-background-and-scope.md`](requirements/project-background-and-scope.md)：理解项目目标、用户、范围和约束。
2. [`guides/setup.md`](guides/setup.md)：完成环境准备、启动与基础验证。
3. [`features/README.md`](features/README.md)：了解功能规格的组织方式。
4. [`style-guide.md`](style-guide.md)：统一文档格式、占位符和维护习惯。

## 2. 核心目录

| 路径 | 用途 |
|------|------|
| `requirements/` | 项目背景、范围以及按需启用的需求文档 |
| `features/` | 功能规格索引与可复用功能模板 |
| `guides/` | 环境搭建以及按需启用的测试、发布、安全和协作文档 |

`design/`、`adr/`、`devlog/`、`plans/`、`business/` 等目录仅在相应 pack 被选择时生成。

## 3. 维护规则

- 文档只描述已经确定或已经实现的事实；未落地事项写入实际启用的任务管理入口。
- 功能行为、接口、数据、权限、架构或运行方式变化时，同步更新对应已生成文档。
- 不存在的文档不应被强制引用；新增或删除 pack 后重新生成并核对本索引。
- 未知信息使用 `TBD`，明确不适用的信息使用 `N/A`，不要编造项目事实。
- 若已启用 `tooling` pack，提交前运行 `pwsh scripts/check-placeholders.ps1` 与 `pwsh scripts/check-doc-links.ps1`；Bash 环境使用对应 `.sh` 脚本。
- 若已启用 `github-ci`，链接检查会立即阻断；活动文档全部填写且本地占位符检查返回 0 后，再创建空文件 `.docs-template/strict-ci` 激活 CI 的占位符阻断。不得为了变绿而提前创建或删除该标记。

## 4. 文档状态

- `Draft`：草稿
- `In Review`：评审中
- `Active`：当前有效
- `Deprecated`：已废弃
- `Archived`：已归档

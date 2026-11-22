# DevLog 开发日志

> 状态：Active
> Owner：{{OWNER}}
> Last Updated：{{CURRENT_DATE}}

用于记录**开发过程中的日常进展、遇到的问题、临时决策与下一步动作**。是面向开发者自己和同伴的"过程记录"，不是面向用户的版本说明。

## 1. 定位与边界

| 文档 | 面向 | 内容 | 节奏 | 适用条件 |
|------|------|------|------|----------|
| `../BACKLOG.md` | 开发者 / 维护者 | 待办、已知问题、技术债 | 随时更新 | 始终可用 |
| `./YYYY/MM/*.md` | 开发者自己 | 当天/当周做了什么、卡在哪、下一步 | 日 / 周 | 始终可用 |
| `../../CHANGELOG.md` | 使用者 / 维护者 | 已发布版本的对外变更 | 按版本 | 启用 `release-support` pack 时 |
| `../adr/*.md` | 开发者 / 维护者 | 重大且定稿的架构决策 | 按决策点 | 启用 `architecture` pack 时 |
| `postmortem-template.md` | 开发者 / 维护者 | 异常、事故或复杂排障的根因与防复发动作 | 按事件 | 启用 `operations` pack 时 |
| `../guides/project-failure-patterns-and-prevention.md` | 开发者 / 维护者 | 跨事件可复用的失误模式与预防门禁 | 按模式 | 启用 `operations` pack 时 |

**一句话区分**：BACKLOG 是“要做什么”，普通 devlog 是“今天 / 这周做到哪里了”，postmortem 复盘一次问题；
通用失误指南只保留跨事件仍成立的模式和控制，不保存项目专属结论。

## 2. 使用规则

- 必须：每条 devlog 只写**过程性事实**，不写长篇设计；定稿结论应提升到项目已有的对应正式文档
- 条件必填：若启用了 `architecture` pack，跨越 devlog 的架构决策必须提升到 ADR，并在 devlog 里引用 ADR 编号
- 应该：发现的**问题**同步进 `BACKLOG.md`，devlog 只留指针
- 应该：日志长度控制在 150 行以内，太长说明应拆分或提升到正式文档
- 可选：个人项目可用日报；团队项目推荐周报
- 可选：若启用了 `operations` pack，且一次问题跨越多个尝试、涉及运行影响或形成可复用教训，
  可复制 `postmortem-template.md` 新建问题复盘，并把行动项回流到 BACKLOG；涉及架构决策时再关联 ADR
- 条件必填：若启用了 `operations` pack，同一已确认失误模式跨事件重复出现或形成可跨项目复用的控制时，
  更新 `../guides/project-failure-patterns-and-prevention.md`；未启用时先回流 BACKLOG 或现有正式文档

## 3. 文件命名

- 根目录只保留 `README.md`、`devlog-template.md` 与启用 `operations` pack 时的 `postmortem-template.md`，不直接写入日 / 周日志
- 启用 `operations` pack 时，问题复盘模板保留为 `postmortem-template.md`；
  实际复盘文件建议放入对应年月目录，例如 `docs/devlog/YYYY/MM/YYYY-MM-DD-incident-slug-postmortem.md`
- 日报：`docs/devlog/YYYY/MM/YYYY-MM-DD.md`，例如 `docs/devlog/2026/04/2026-04-17.md`
- 周报：`docs/devlog/YYYY/MM/YYYY-Www.md`，例如 `docs/devlog/2026/04/2026-W16.md`
- 周报按记录创建日期所属月份归档；跨月周报可在正文标明覆盖日期范围
- 同一天多条：追加到当天文件末尾，不新建文件

## 4. 写作建议

- 先写"做了什么"，再写"卡在哪"，最后写"下一步"
- 用最短的句子，不要写成散文
- 贴链接优先于重复描述：按项目实际能力引用 commit、PR、issue 或 BACKLOG 条目 ID
- 不要把 devlog 当作调试草稿纸 —— 最终结论请回流到正式文档

## 5. 保留策略

- devlog 文件默认全部保留在 `docs/devlog/YYYY/MM/` 年月目录下，便于按时间范围检索和跨版本追溯
- 不再创建历史归档子目录；需要降低噪声时，优先通过年月目录、文件名或搜索过滤
- 过长日志应该拆分为日 / 周记录，定稿结论提升到正式文档，而不是移动到其他目录

## 6. 模板

新建条目时复制 `devlog-template.md`，按模板字段填写。

# 项目文档模板包

这是一套可直接复用的项目文档骨架，目标是让不同项目在**目录结构、命名方式、写作风格、维护流程**上保持统一。

## 适用范围

适用于以下类型项目：

- Web / 后端 / 前端 / 全栈项目
- 桌面端项目
- AI / 数据处理 / OCR / Agent / RAG 项目
- 个人项目、校招项目、小团队协作项目

## 设计原则

1. **先总览，后细节**：先看 `docs/README.md`，再进入各专题文档。
2. **一文一事**：每个文档只负责一个主题，避免信息混杂。
3. **当前状态优先**：文档优先描述“当前已经实现/已经确定”的内容。
4. **规划与现状分离**：规划写入 `BACKLOG.md`，不要混入功能说明和设计定稿文档。
5. **模板先行**：新增文档时优先从模板复制，避免风格漂移。

## 推荐目录

```text
project-docs-template/
├── AGENTS.md                   # AI 编码助手操作上下文（Claude Code、Cursor 等）
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md                 # 安全漏洞上报（区别于 docs/guides/security.md）
├── .gitignore
├── .editorconfig
├── .markdownlint.json
├── .github/
│   ├── CODEOWNERS
│   ├── pull_request_template.md
│   └── workflows/
│       └── docs-template-checks.yml
├── scripts/
│   ├── check-docs-consistency.sh   # 三索引同步检查（bash / macOS / Linux / WSL）
│   ├── check-docs-consistency.ps1  # 三索引同步检查（PowerShell / Windows）
│   ├── check-placeholders.sh       # 占位符残留检查（bash / macOS / Linux / WSL）
│   └── check-placeholders.ps1      # 占位符残留检查（PowerShell / Windows）
├── examples/
│   ├── README.md
│   └── order-service/          # 填好的示例项目（订单中心）
└── docs/
    ├── README.md
    ├── style-guide.md
    ├── BACKLOG.md
    ├── requirements/
    │   ├── project-background-and-scope.md
    │   ├── functional-modules.md
    │   ├── use-cases.md
    │   └── mvp-scope-freeze.md
    ├── design/
    │   ├── system-design-overview.md
    │   ├── architecture-overview.md   # 总体架构说明（支持三层 / 六边形架构）
    │   ├── api-spec.md
    │   ├── database-design.md
    │   ├── permission-matrix.md
    │   ├── state-flow-and-acceptance.md
    │   ├── risk-register.md
    │   └── ui-wireframes.md      # 页面结构 / 线框图
    ├── features/
    │   ├── README.md
    │   └── feature-template.md
    ├── adr/
    │   ├── README.md
    │   └── ADR-000-template.md
    ├── devlog/
    │   ├── README.md
    │   ├── devlog-template.md
    │   └── YYYY/
    │       └── MM/
    │           └── YYYY-MM-DD.md
    ├── plans/                  # AI 任务计划（执行完即删除）
    │   ├── README.md
    │   └── plan-template.md
    ├── business/
    │   └── quotation-estimate.md # 商业化项目报价与工期预估
    ├── glossary.md             # 可选：术语表
    └── guides/
        ├── setup.md
        ├── branch-conventions.md
        ├── team-collaboration.md # 团队角色、RACI、协作流转
        ├── testing.md
        ├── release-process.md
        ├── onboarding.md       # 可选：新人指南
        ├── security.md         # 可选：安全与合规
        └── runbook.md          # 可选：运维手册

# 可选扩展：
# docs/design/api-changes.md    API 破坏性变更与迁移指南
```

目录索引文件：

- `docs/features/README.md`
- `docs/adr/README.md`
- `docs/devlog/README.md`
- `docs/plans/README.md`

## 使用方法

### 0. 选择入口

| 你的情况 | 从这里开始 |
|----------|-----------|
| 全新项目，从 0 搭文档 | 本文件 § 1 初始化项目文档 |
| 已有旧文档，想迁移到本规范 | `template-mapping.md`（旧文档 → 本模板的归类指南） |
| 只想查写作规范 / 占位符 / 版本号格式 | `docs/style-guide.md` |
| 想写系统架构 / 三层架构 / 六边形架构 | `docs/design/architecture-overview.md` + `docs/adr/` |
| 想写页面结构 / 线框图 | `docs/design/ui-wireframes.md` |
| 想了解各目录职责与阅读顺序 | `docs/README.md` |
| 想配置 AI 编码助手的项目上下文 | `AGENTS.md` |
| 想建立团队角色 / RACI / Review 流程 | `docs/guides/team-collaboration.md` |
| 想启用 PR / CODEOWNERS / CI 门禁 | `.github/` + `docs/guides/branch-conventions.md` |
| 想预估商业化报价 / 工期 / 成本 | `docs/business/quotation-estimate.md` |
| 想看"填好长啥样"的完整示例 | `examples/order-service/` |
| 想跑本模板仓库自检（bash） | `bash scripts/check-docs-consistency.sh && bash scripts/check-placeholders.sh --mode template` |
| 想跑本模板仓库自检（PowerShell） | `pwsh scripts/check-docs-consistency.ps1; pwsh scripts/check-placeholders.ps1 -Mode TemplateRepository` |
| 想检查使用模板后的项目占位符 | `pwsh scripts/check-placeholders.ps1` |

### 1. 初始化项目文档

- 复制本模板包到你的项目根目录
- 将占位符统一替换（格式见 `docs/style-guide.md` § 3）：
  - `{{PROJECT_NAME}}`
  - `{{MODULE_NAME}}`
  - `{{OWNER}}`
  - `{{YYYY-MM-DD}}`
  - `{{VERSION}}`

### 2. 新项目最低必填文档

建议至少先完成以下 10 份：

- `AGENTS.md`
- `docs/README.md`
- `docs/style-guide.md`
- `docs/requirements/project-background-and-scope.md`
- `docs/design/system-design-overview.md`
- `docs/design/architecture-overview.md`
- `docs/design/api-spec.md`
- `docs/design/database-design.md`
- `docs/BACKLOG.md`
- `CHANGELOG.md`

### 3. 后续维护规则

| 场景 | 需要更新的文档 |
|------|----------------|
| 新增需求/调整范围 | `requirements/*` |
| 新增模块/改动功能 | `features/*` |
| 接口变更 | `design/api-spec.md` |
| 数据结构变更 | `design/database-design.md` + ADR（必要时） |
| 架构模式/边界变化 | `design/architecture-overview.md` + `adr/*`（必要时） |
| 已知问题/技术债 | `docs/BACKLOG.md` |
| 开发过程日志（日/周） | `docs/devlog/YYYY/MM/*.md` |
| 团队角色 / RACI / 模块责任变化 | `docs/guides/team-collaboration.md` |
| PR 模板 / CODEOWNERS / CI 门禁变化 | `.github/` + `docs/guides/branch-conventions.md` |
| 商业化报价 / 工期 / 成本预估变化 | `docs/business/quotation-estimate.md` |
| 版本发布 | `CHANGELOG.md` |

## 命名建议

- 文件名统一使用 **英文 kebab-case**
- 标题正文可使用中文
- 目录分层不宜过深，通常不超过 3 层

## 可裁剪建议

不是所有项目都需要全部文档：

- 小型个人项目：可只保留 `requirements`、`design`、`BACKLOG`、`CHANGELOG`
- 团队项目：建议保留全部
- 演示型项目：可弱化 `permission-matrix`、`release-process`

## 可选扩展文档

在基础目录之外，下列模板按需启用：

| 模板 | 触发条件 | 典型受众 |
|------|----------|----------|
| `docs/glossary.md` | 业务术语/缩写易混淆，或跨团队协作 | 全员 |
| `docs/guides/onboarding.md` | 有新人入职需要快速上手 | 新成员 |
| `docs/guides/team-collaboration.md` | 多人协作、Code Review、模块责任需要统一 | 全员 |
| `docs/business/quotation-estimate.md` | 商业化项目需要报价、工期、成本和风险缓冲预估 | Owner / 商务 / Tech Lead |
| `docs/guides/security.md` | 涉及敏感数据、合规、对外接口 | 开发 + 安全负责人 |
| `docs/guides/runbook.md` | 存在线上部署 / 值班 / 告警 | 运维 / 值班 |
| `docs/design/api-changes.md` | 对外提供 API 且有外部调用方 | API 使用方 |

启用时从模板复制即可，无需启用可不创建，但如创建则必须同步 `docs/README.md` 的目录说明。

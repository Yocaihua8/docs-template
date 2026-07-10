# AGENTS.md

> 本文件为 AI 编码助手（Claude Code、Cursor、Copilot 等）提供项目操作上下文。
> 代码结构或团队约定发生实质性变化时同步更新。不替代 `CONTRIBUTING.md`，后者为人工贡献规范。

## 1. 项目概述

{{PROJECT_DESCRIPTION}}

| 项 | 值 |
|----|----|
| 项目类型 | {{PROJECT_TYPE}}（Web 后端 / 前后端全栈 / CLI / AI 服务 / 桌面端等） |
| 当前阶段 | {{PHASE}}（原型 / MVP / 生产 / 维护） |
| 主要用户 | {{TARGET_USERS}} |
| 文档入口 | `docs/README.md` |

## 2. 技术栈

| 类型 | 名称 | 版本 | 说明 |
|------|------|------|------|
| 语言 | {{LANGUAGE}} | {{LANGUAGE_VERSION}} | - |
| 框架 | {{FRAMEWORK}} | {{FRAMEWORK_VERSION}} | - |
| 数据库 | {{DATABASE}} | {{DATABASE_VERSION}} | - |
| 构建工具 | {{BUILD_TOOL}} | {{BUILD_TOOL_VERSION}} | - |
| 测试框架 | {{TEST_FRAMEWORK}} | {{TEST_FRAMEWORK_VERSION}} | - |
| 包管理器 | {{PACKAGE_MANAGER}} | {{PACKAGE_MANAGER_VERSION}} | - |

## 3. 目录速查

| 路径 | 用途 |
|------|------|
| `{{SRC_DIR}}/` | 生产代码根目录 |
| `{{TEST_DIR}}/` | 测试代码根目录 |
| `docs/requirements/` | 需求背景、功能范围、阶段 / 版本范围冻结 |
| `docs/design/` | 架构、接口、数据库、权限、状态流 |
| `docs/features/` | 各功能模块规格（每个功能一份） |
| `docs/adr/` | 架构决策记录 |
| `docs/BACKLOG.md` | 待办、已知问题、技术债 |
| `CHANGELOG.md` | 对外发布变更 |

> 完整目录结构见 `docs/README.md § 2`。

## 4. 开发环境与常用命令

### 4.1 启动本地环境

```bash
{{INSTALL_COMMAND}}     # 安装依赖
{{ENV_INIT_COMMAND}}    # 初始化环境变量（如：cp .env.example .env）
{{DEV_COMMAND}}         # 启动开发服务
```

### 4.2 日常操作

```bash
{{BUILD_COMMAND}}               # 构建
{{TEST_ALL_COMMAND}}            # 全量测试
{{TEST_UNIT_COMMAND}}           # 仅单元测试
{{LINT_COMMAND}}                # 代码检查
{{FORMAT_COMMAND}}              # 代码格式化
{{MIGRATE_COMMAND}}             # 运行数据库迁移（若有）
```

> 详细搭建步骤见 `docs/guides/setup.md`。

## 5. 架构概要

本项目采用 **{{ARCH_PATTERN}}**（三层架构 / 六边形架构 / 其他）。

{{ARCH_SUMMARY}}

**关键边界**：

- {{BOUNDARY_1}}（如：业务层不得直接访问数据库，必须经过数据层接口）
- {{BOUNDARY_2}}（如：表现层只负责请求接收与响应封装，不放业务规则）

> 完整说明见 `docs/design/architecture-overview.md`。接口契约见 `docs/design/api-spec.md`。

## 6. 代码约定（速查）

### 6.1 命名

- {{NAMING_RULE_1}}（如：类名 PascalCase，文件名 kebab-case，数据库字段 snake_case）
- {{NAMING_RULE_2}}（如：接口以 `I` 前缀 / 无前缀，端口以业务语义命名）

### 6.2 文件组织

- {{FILE_ORG_RULE_1}}（如：每个模块放独立目录，目录下 index 作为唯一入口）
- {{FILE_ORG_RULE_2}}（如：测试文件与源文件同目录 / 放在镜像测试目录）

### 6.3 明确禁用的模式

- {{ANTI_PATTERN_1}}（如：禁止 Controller 直接注入 Repository）
- {{ANTI_PATTERN_2}}（如：禁止在页面组件内发起裸 HTTP 请求）

### 6.4 低耦合约束

- AI 修改代码时必须优先保持低耦合，遵守既有模块边界、层边界和依赖方向。
- 禁止为快速实现而新增跨层直接依赖、跨模块直接依赖或绕过既有端口 / 服务接口。
- 若任务确实需要打破现有边界，必须先说明原因、影响范围和替代方案，并按 `docs/README.md § 4` 判断是否需要 ADR。

> 完整规范见 `CONTRIBUTING.md § 4`。

### 6.5 代码注释边界

- AI 添加注释时必须先判断是否能降低理解成本；不要为显而易见的代码补空泛注释。
- 注释优先解释 why、constraint、invariant、兼容性原因、失败后果或跨层边界，不解释明显的 what。
- 单行注释用于局部非显然意图；多行注释用于复杂算法、状态机、协议流程、并发 / 事务 / 安全约束；文档注释用于公共模块、公共类、公共函数、对外接口和脚本入口参数。
- 技术债、已知问题和后续规划写入 `docs/BACKLOG.md`，不要长期塞进代码注释或 TODO 中。

## 7. 测试约定

| 类型 | 路径模式 | 运行命令 |
|------|----------|----------|
| 单元测试 | `{{UNIT_TEST_PATTERN}}` | `{{TEST_UNIT_COMMAND}}` |
| 集成测试 | `{{INTEGRATION_TEST_PATTERN}}` | `{{TEST_INTEGRATION_COMMAND}}` |
| E2E | `{{E2E_TEST_PATTERN}}` | `{{TEST_E2E_COMMAND}}` |

测试优先级：核心业务规则 > 接口契约 > 数据层集成 > UI 流程。

> 测试策略与最低覆盖要求见 `docs/guides/testing.md`。

## 8. 文档联动规则

AI 修改代码后**必须**同步更新对应文档，否则视为未完成：

| 代码变更 | 需同步更新的文档 |
|----------|----------------|
| 新增 / 修改功能行为 | `docs/features/<name>.md` |
| 接口签名变更 | `docs/design/api-spec.md` |
| 数据库表结构变更 | `docs/design/database-design.md` |
| 架构模式 / 模块边界变更 | `docs/design/architecture-overview.md` + `docs/adr/`（若触发 ADR 条件） |
| 新增 ADR | `docs/adr/README.md` 索引表追加一行 |
| 版本发布 | `CHANGELOG.md` |

已知问题或技术债直接写入 `docs/BACKLOG.md`，不写在代码注释里。

> ADR 触发条件见 `docs/README.md § 4`。

## 9. Plan 文件使用规则

### 9.1 两种 plan 产生方式

| 方式 | 典型场景 | plan 位置 | 命名格式 |
|------|----------|-----------|---------|
| **主动创建**（推荐） | AI 接到明确任务，按流程先建 plan 再动手 | `docs/plans/` | `{B-ID}-{slug}.md` |
| **工具自动生成** | Claude Code、superpowers 等工具自行生成 | 工具指定目录（如 `docs/superpowers/plans/`） | `{YYYY-MM-DD}-{slug}.md` |

**两种方式都必须触发 BACKLOG 同步**，区别只是同步的时机：主动创建时在动手前完成，工具自动生成时在文件落地后立即补做。

### 9.2 主动创建流程（任务启动三步）

凡涉及**代码改动**的任务，无论用户是否提供 BACKLOG ID，均先走这三步再动手。
纯问答、只读查阅、单行拼写修复可免。

**Step 1 — 锁定 BACKLOG 条目**

打开 `docs/BACKLOG.md` § 6，按以下逻辑处理：

| 情况 | 操作 |
|------|------|
| 找到匹配的 `B-xxx` 条目 | 记录 ID，状态改为 `doing` |
| 无匹配条目 | 末尾新增一行，分配下一个 ID，状态置 `doing`，优先级与规模由 AI 估算填入 |

**Step 2 — 冲突扫描（创建 plan 前）**

扫描所有状态为 `Active` 或 `Interrupted` 的 plan 文件（含工具目录），对比其 § 4 影响范围与本次任务的预期改动范围：

| 扫描结果 | 处理方式 |
|---------|---------|
| 无重叠 | 继续 Step 3 |
| 有重叠，冲突 plan 尚未完成 | 告知用户，选择下方四种解决策略之一，确认后再继续 |
| 有重叠，冲突 plan 已完成但未删除 | 视为无冲突，提醒清理残留 plan 文件 |

**四种解决策略**：

- **等待**：本任务暂缓，等冲突 plan 完成后再开始（适合强依赖场景）
- **合并**：将两个任务合并为一个 plan，统一执行
- **本 plan 覆盖**：本 plan 的设计优先，冲突 plan 的对应部分作废（在两个 plan 的 § 5.2 中互相注明）
- **分区**：明确划定各自负责的文件/模块边界，互不干涉（在各自 § 5.2 中记录边界）

将扫描结果填入新 plan 的 § 5.2。

**Step 3 — 创建 plan 文件并完成文档关联**

在 `docs/plans/` 新建 `{B-ID}-{slug}.md`，**同一步骤内**完成：

1. 头部"关联 BACKLOG"填入 Step 1 的 B-ID
2. 头部"关联功能文档"：去 `docs/features/` 找对应文档；无则新建占位文件
3. 头部"关联设计文档"：按改动类型填（接口变更 → `design/api-spec.md`；DB 变更 → `design/database-design.md`；架构变更 → `design/architecture-overview.md`）
4. § 4"影响范围"填写将被修改的代码路径和文档路径
5. § 5.2 填入 Step 2 的冲突扫描结果
6. § 7"回流清单"逐行列出"改了什么 → 更新哪个文档"

**Step 4 — plan 路径写回 BACKLOG**

在该条目"说明"列追加 plan 文件的相对路径。

### 9.3 工具自动生成后的补同步（superpowers / Claude Code 等）

工具在 `docs/superpowers/plans/`（或其他目录）落地 plan 文件后，**在同一次对话中立即执行**：

1. **读取 plan 文件**，提取任务主题
2. **检索 `docs/BACKLOG.md` § 6**：
   - 找到语义匹配的条目 → 状态改 `doing`，说明列追加 plan 路径（相对于项目根目录）
   - 未找到 → 新建条目，填写标题/类型/优先级/规模，状态置 `doing`，说明列填入 plan 路径
3. **识别影响范围**，在 plan 文件中补写（若工具生成的内容缺失）：
   - 将变更的功能追加到 `docs/features/` 对应文档的路径
   - 将变更的接口/DB 结构追加到 `docs/design/` 对应文档的路径
4. **将以上关联信息写入 plan 文件头部**（若工具生成时未填）

> 若当前对话无法确定语义匹配的 BACKLOG 条目，**禁止跳过**，应新建条目后再关联。

### 9.4 执行节奏（每个子任务的固定动作）

每完成 § 3 中的**一个任务**后，立即按顺序执行以下三步，不可跳过：

1. **勾选 § 3 对应条目**
2. **`git commit`**，message 简述本次完成的内容
3. **更新 plan § 8 状态快照**：填写最后更新时间、最新 commit hash、下一步任务

> 这三步的目的：在任意时刻被打断（额度耗尽、开发者中断、网络断开），
> 损失的进度最多只有"当前子任务"，而非整个 session。

遇到偏差、关键决策时，记入 plan § 8 执行记录。

**执行中发现冲突**（代码状态与 plan 预期不一致）：

1. **停止当前任务**，不要强行继续
2. 检查其他 Active/Interrupted plan 的 § 4，找到修改了同一位置的 plan
3. 确认冲突类型：
   - **时序冲突**：另一个 plan 先修改了此处，当前 plan 的前提失效 → 重新评估当前任务的影响范围，更新 § 4 和 § 5.2
   - **设计冲突**：两个 plan 对同一模块有不兼容的设计意图 → 告知用户，由用户决定哪个 plan 优先
4. 在当前 plan § 8 执行记录中记录冲突详情和解决结论

### 9.5 任务中断处理

**主动中断**（有时间收尾）：

1. 将 plan 头部状态改为 `Interrupted`
2. 确认 § 8 状态快照已更新到最新（若刚完成一个子任务，§ 8 应已是最新）
3. 补充 § 8 的"续任务须知"字段（当前子任务的中间状态、注意事项）
4. 更新 BACKLOG：有外部阻塞 → `blocked`；仅未完成 → 保持 `doing`

**被动中断**（额度耗尽 / 开发者强制停止，无收尾机会）：

- 无需任何操作——§ 8 快照已在上一个子任务完成时更新
- 损失仅为当前正在进行的子任务（尚未 commit 的改动）
- 恢复时：读 § 8 快照，检查 git log 确认最新 commit，从"下一步"字段指向的任务继续

**禁止在中断时删除 plan 文件**。

### 9.6 恢复未完成的 plan

新 session 开始时，若发现 `docs/plans/`（或工具目录）下存在 `状态：Interrupted` 的 plan 文件：

1. **读取 plan § 8 中断记录**，了解当前状态和剩余任务
2. **读取 plan § 3**，确认哪些任务已勾选、哪些待做
3. **检查代码状态**（§ 8 中记录的分支/改动）是否与实际一致
4. 将 plan 头部状态改回 `Active`，继续执行剩余任务
5. 恢复完成后，走正常的 § 9.5 完成流程

### 9.7 完成流程

1. 确认回流清单全部勾选（每项已写入对应文档）
2. 重大技术决策 → 新建 ADR，更新 `docs/adr/README.md` 索引
3. 新发现的问题 → 写入 `docs/BACKLOG.md § 7`
4. BACKLOG 条目状态改为 `done`
5. **删除 plan 文件**（工具自动生成的文件同样需要删除）

> Plan 文件格式见 `docs/plans/plan-template.md`，生命周期规则见 `docs/plans/README.md`。

## 10. AI 操作边界

**可以自主执行**：

- 修改 `{{SRC_DIR}}/` 下的业务代码与测试
- 按上方"文档联动规则"同步文档
- 在 `docs/BACKLOG.md` 追加待办或已知问题条目
- 创建、更新、删除 `docs/plans/` 下的 plan 文件
- 在不破坏低耦合和模块边界的前提下，做任务直接相关的局部调整

**需先确认再执行**：

- 删除或重命名已有公共接口 / 导出模块
- 修改数据库 Schema 或迁移脚本
- 变更认证 / 权限逻辑
- 引入新的跨模块依赖、跨层调用或全局共享状态
- 新增 ADR（需和用户确认决策内容）
- 向主分支直接推送

**禁止**：

- 硬编码密钥、Token、数据库密码
- 跳过 lint / 格式化检查（如 `--no-verify`）
- 修改 `{{GENERATED_DIR}}/` 内的自动生成文件（若项目有此目录）
- 在正式文档中混写当前已实现内容与未来规划（规划放 `BACKLOG.md`）
- 为了图省事把业务逻辑、数据访问、HTTP / UI 细节直接耦合在同一层或同一模块

---

## 附录：填写示例

下方为订单中心示例项目的填写样例。**复制模板时请删除本附录**。

````markdown
# AGENTS.md

## 1. 项目概述

为电商平台运营团队提供订单管理后台，支持订单查询、状态流转与批量导出。

| 项 | 值 |
|----|----|
| 项目类型 | Web 后端（REST API）+ 管理后台前端 |
| 当前阶段 | MVP |
| 主要用户 | 运营同学、财务同学 |
| 文档入口 | `docs/README.md` |

## 2. 技术栈

| 类型 | 名称 | 版本 | 说明 |
|------|------|------|------|
| 语言 | Java | 21 | - |
| 框架 | Spring Boot | 3.2 | - |
| 数据库 | PostgreSQL | 16 | - |
| 构建工具 | Gradle | 8.5 | - |
| 测试框架 | JUnit 5 + Testcontainers | - | 集成测试依赖 Docker |
| 包管理器 | Gradle | 8.5 | - |

## 3. 目录速查

| 路径 | 用途 |
|------|------|
| `src/main/java/` | 生产代码根目录 |
| `src/test/java/` | 测试代码根目录 |
| `src/main/resources/db/migration/` | Flyway 迁移脚本 |

## 4. 常用命令

```bash
./gradlew bootRun                   # 启动开发服务（需本地 PostgreSQL）
./gradlew test                      # 全量测试（含集成测试，需 Docker）
./gradlew test --tests "*UnitTest"  # 仅单元测试
./gradlew checkstyleMain            # 代码检查
./gradlew flywayMigrate             # 运行数据库迁移
```

## 5. 架构概要

本项目采用**三层架构**。

Controller 层只负责 HTTP 接收与响应封装；Service 层持有核心业务规则与事务边界；
Repository 层负责持久化与缓存。

**关键边界**：
- 禁止 Controller 直接注入 Repository
- Service 层不依赖 HttpServletRequest 等 Web 对象

## 6. 代码约定（速查）

- 类名 PascalCase，文件名与类名一致，数据库字段 snake_case
- 每个模块放独立包（`order`、`payment`、`user`），模块间通过 Service 接口通信
- 禁止 Controller 直接访问数据库；禁止在 Entity 上写业务逻辑
- 保持低耦合：禁止跨层直接依赖、跨模块直接依赖；新增依赖必须通过既有 Service / Port / Adapter 边界接入

## 7. 测试约定

| 类型 | 路径模式 | 运行命令 |
|------|----------|----------|
| 单元测试 | `**/*UnitTest.java` | `./gradlew test --tests "*UnitTest"` |
| 集成测试 | `**/*IntegrationTest.java` | `./gradlew test --tests "*IntegrationTest"` |

## 8. 文档联动规则

| 代码变更 | 需同步更新的文档 |
|----------|----------------|
| 新增 / 修改功能行为 | `docs/features/<name>.md` |
| 接口签名变更 | `docs/design/api-spec.md` |
| 数据库表结构变更 | `docs/design/database-design.md` |

## 9. AI 操作边界

**可以自主执行**：修改 `src/` 下业务代码、新增测试、同步文档、写 BACKLOG 条目。

**需先确认**：删除公共接口、改 Schema、变更权限逻辑、新增跨模块依赖、新增 ADR。

**禁止**：硬编码密码或 Token、跳过 Checkstyle、修改 `build/`（生成目录）、把业务逻辑与数据访问或 HTTP 细节直接耦合。
````

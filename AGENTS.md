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

> 按任务选择阅读入口见 `docs/README.md § 1`，完整目录见 § 2；不要求每次任务读取所有架构、数据和部署文档。

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
- 若任务确实需要打破现有边界，必须先说明原因、影响范围和替代方案，并按 [ADR 新建条件](docs/adr/README.md#1-何时需要新增-adr)判断是否需要记录决策。

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

> 测试策略与最低覆盖要求见 `docs/guides/testing.md`。只执行本次影响范围对应的检查；完成相关验证和必要文档回流后交付，不在首次实现后提前停止。

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

> ADR 触发条件见 [ADR 索引](docs/adr/README.md#1-何时需要新增-adr)。

## 9. Plan 文件使用规则

仅在任务需要跨模块协调、多步恢复或较复杂的多文件变更时创建 plan；局部修复、纯文案和只读任务可直接执行并说明验证结果。

创建、恢复与回流统一按 `docs/plans/README.md`，格式使用 `docs/plans/plan-template.md`。创建时关联 BACKLOG，检查涉及范围内的 Active / Interrupted 计划与已有改动；文件相同但章节独立时可明确分区，不自动判为冲突。

在可验证阶段结束、关键决策或中断时更新进度、未提交状态和下一步。Git 提交独立遵循用户授权与项目规则，不要求每个勾选项提交一次。未完成的计划保留；完成约定验证和正式文档回流后按计划生命周期收口。

## 10. AI 操作边界

用户明确要求直接执行或已确认方案后，在授权范围内连续完成实施、相关验证、本次引入问题的修复和文档同步；普通局部选择说明假设后继续。只有扩大范围、改变已确认方案、缺少影响结果的关键决策或触及尚未授权的操作时再询问。

技能只在其明确工作流与当前任务匹配时加载，按需读取支持文件；不得把技能建议推断为额外审批要求。需要因规则暂停时，指出具体文件、条款和未决事项。

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

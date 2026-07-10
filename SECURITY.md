# Security Policy

本文件说明**如何向本项目上报安全漏洞**。它与 `docs/guides/security.md` 职责不同：

| 文件 | 面向 | 内容 |
|------|------|------|
| `SECURITY.md`（本文件） | 外部安全研究者 / 用户 | 上报漏洞的渠道、响应承诺 |
| `docs/guides/security.md`（若启用 security pack） | 项目开发者 | 项目自身的安全基线、条件要求和事件响应流程 |

## 上报渠道

- **优先**：通过私密上报入口 `{{SECURITY_REPORT_URL}}`
- 若项目使用安全邮箱，可发送至 `{{SECURITY_CONTACT_EMAIL}}`
- 不要在公开 Issue 里描述漏洞细节，以免被利用

## 响应承诺

| 阶段 | 时效 |
|------|------|
| 确认收到 | {{SECURITY_ACK_TARGET}} |
| 初步评估与反馈 | {{SECURITY_ASSESSMENT_TARGET}} |
| 高危问题修复 / 缓解目标 | {{HIGH_SEVERITY_FIX_TARGET}} |

## 支持版本

{{SUPPORTED_VERSIONS_POLICY}}

## 披露

在修复或缓解措施发布前，请不要公开漏洞细节。若项目已启用 `CHANGELOG.md`，可在其 `Security` 分类下发布致谢；未启用时通过实际发布说明致谢，且仅在研究者同意署名时公开身份。

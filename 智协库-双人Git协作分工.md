# 智协库双人 Git 协作分工方案

## 0. 先共同确定的公共契约

这部分建议两人一起在第一个提交里完成，避免后面反复冲突。

- 项目骨架：HarmonyOS ArkTS / ArkUI 工程结构、底部导航、路由命名、主题样式、通用组件目录。
- 模拟数据层：统一放在 `mock/` 或 `common/data/`，禁止页面里各自硬编码大段数据。
- 公共类型：`User`、`Role`、`KnowledgeArticle`、`WorkflowTemplate`、`WorkflowInstance`、`ApprovalRecord`、`Notification`、`AuditLog`。
- 公共服务接口：登录、当前用户、知识列表、流程模板、流程实例、消息、审计日志。
- Git 分支：`main` 只放稳定版本，`dev` 做集成分支，两人各自从 `dev` 拉功能分支。

## 1. 成员 A：知识库与工作台体验线

目标：完成“查资料、看知识、智能问答、消息入口、首页展示”这条用户体验闭环。

负责模块：

- 登录后的工作台：首页用户信息、待办数量、快捷流程入口、最近知识、收藏知识、消息提醒、智能问答入口。
- 企业知识库：分类浏览、搜索、搜索结果、知识详情、收藏、有用反馈、纠错建议。
- 智能知识助手：自然语言输入、关键词匹配、返回答案摘要、推荐知识、推荐流程入口、最近问答记录。
- 消息页面：消息列表、已读标记、跳转知识详情或流程详情。
- “我的”页面中的个人信息、收藏知识、基础设置展示。
- HarmonyOS 展示点：互动卡片样式、可变字体阅读体验、知识详情沉浸式卡片。

建议目录边界：

- `features/dashboard/`
- `features/knowledge/`
- `features/assistant/`
- `features/messages/`
- `features/profile/`
- `common/components/KnowledgeCard.ets`
- `common/services/knowledgeService.ts`
- `common/services/assistantService.ts`
- `common/services/messageService.ts`

主要验收项：

- AC-001：不同角色登录后进入工作台。
- AC-002：知识库能完成分类、搜索、详情、收藏。
- AC-003：智能问答能返回相关知识和推荐流程。
- AC-007：能看到通知消息并跳转。
- AC-HM-001：工作台有待办或流程进度卡片效果。
- AC-HM-002：智能助手体现 Agent / Skill 的模拟效果。

优先级建议：

1. 工作台 + 底部导航入口。
2. 知识分类 / 搜索 / 详情。
3. 收藏、反馈、纠错。
4. 智能问答。
5. 消息和我的页面补齐。

## 2. 成员 B：流程协作与权限治理线

目标：完成“发起流程、审批流程、状态流转、关联知识、安全确认、管理配置”这条业务闭环。

负责模块：

- 流程模板：请假、报销、采购、权限申请四类模板。
- 流程发起：表单填写、附件模拟、表单校验、提交生成流程实例。
- 流程详情：申请内容、状态、审批记录、关联知识、时间线。
- 审批处理：待办列表、通过、驳回、审批意见、状态流转。
- 权限控制：普通员工、审批人、知识管理员、系统管理员的入口和操作限制。
- 管理页面：知识分类管理、知识发布 / 下架入口、用户 / 部门 / 角色展示、流程模板维护、操作日志。
- 安全能力：高金额报销 / 采购二次确认、关键操作审计日志、风险检测模拟。
- HarmonyOS 展示点：闪控窗 / 悬浮状态模拟、安全确认弹窗、数字身份 / 数字盾规划展示。

建议目录边界：

- `features/workflow/`
- `features/approval/`
- `features/admin/`
- `features/security/`
- `common/components/WorkflowCard.ets`
- `common/components/Timeline.ets`
- `common/services/workflowService.ts`
- `common/services/authService.ts`
- `common/services/auditService.ts`

主要验收项：

- AC-004：能成功提交请假或报销申请。
- AC-005：审批人能查看待办并通过或驳回。
- AC-006：流程时间线能展示申请、审批、完成节点。
- AC-008：普通员工不能访问管理功能。
- AC-HM-003：高风险操作有二次确认并记录日志。
- AC-HM-004：流程页面能展示关联制度。

优先级建议：

1. 流程模板列表 + 流程表单。
2. 流程提交和状态流转。
3. 审批待办、通过、驳回。
4. 流程详情和时间线。
5. 权限、管理、安全确认、审计日志。

## 3. 两人之间的接口约定

成员 A 需要调用成员 B 提供：

- 获取流程模板：用于工作台快捷入口、智能问答推荐流程。
- 跳转流程发起页：智能问答结果中的“立即发起”。
- 获取流程待办数量：工作台待办统计。
- 获取流程状态消息：消息页面跳转流程详情。

成员 B 需要调用成员 A 提供：

- 获取关联知识：流程发起页、审批页、流程详情页展示制度说明。
- 跳转知识详情：流程页面点击关联制度。
- 搜索知识：管理员维护流程模板时选择关联知识。

推荐先定义这些函数签名，再各自实现：

```ts
getKnowledgeByWorkflowType(type: string): KnowledgeArticle[]
searchKnowledge(keyword: string): KnowledgeArticle[]
getWorkflowTemplates(): WorkflowTemplate[]
createWorkflow(templateId: string, formData: object): WorkflowInstance
getTodoCount(userId: string): number
createNotification(notification: Notification): void
writeAuditLog(log: AuditLog): void
```

## 4. Git 协作流程

推荐分支：

- `main`：答辩稳定版本，只接受从 `dev` 合并。
- `dev`：日常集成分支。
- `feature/a-knowledge-dashboard`：成员 A 主分支。
- `feature/b-workflow-admin`：成员 B 主分支。
- `fix/*`：集成后的修复分支。

日常流程：

```bash
git checkout dev
git pull origin dev
git checkout -b feature/a-knowledge-dashboard

# 开发完成后
git add .
git commit -m "feat: add knowledge search and detail pages"
git push origin feature/a-knowledge-dashboard
```

合并建议：

1. 每天至少向 `dev` 提一次可运行版本。
2. 合并前先从 `dev` 更新自己的分支。
3. 冲突优先按目录归属处理，公共类型和 mock 数据两人一起确认。
4. 每次合并到 `dev` 后至少跑一遍登录、知识搜索、流程提交、审批四条主流程。
5. 答辩前从 `dev` 合并到 `main`，打标签 `v1.0-demo`。

## 5. 推荐里程碑

第 1 阶段：公共骨架

- 两人共同完成路由、底部导航、mock 数据、公共类型、登录模拟。

第 2 阶段：各自核心闭环

- 成员 A：工作台、知识列表、知识详情、搜索。
- 成员 B：流程模板、流程表单、流程提交、待办。

第 3 阶段：联动集成

- 成员 A：智能问答推荐流程。
- 成员 B：流程页展示关联知识。
- 两人共同完成消息通知和页面跳转。

第 4 阶段：特色与答辩完善

- 成员 A：互动卡片、智能助手演示、知识阅读体验。
- 成员 B：安全确认、审计日志、权限限制、管理页面。
- 两人共同完成测试、截图、演示脚本和课程报告材料。

## 6. 最小可演示闭环

如果时间紧，优先保证下面这条链路完整：

1. employee01 登录进入工作台。
2. 在智能问答里输入“报销打车费需要什么材料”。
3. 系统返回《差旅报销制度》摘要，并推荐“报销申请”流程。
4. 用户点击立即发起，填写报销表单并提交。
5. manager01 登录后看到待办，查看关联制度，通过审批。
6. employee01 收到流程通过消息，流程详情展示时间线。

这条链路能同时覆盖知识库、智能问答、流程协作、消息通知、权限角色、知识流程联动和 HarmonyOS 特色展示，是双人开发时最值得优先打通的主线。

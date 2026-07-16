# 2026-07-16 后端接口交接文档

## 1. 本次前端已完成

- 底部导航已将 `流程` 调整为 `协作`
- 工作台未读统计改为 `待处理 / 等待中 / 未读 / 邮件`
- `待处理` 仅代表需要本人立刻处理的事项
- `等待中` 仅代表本人发起后、正在等他人回复的事项
- `我的` 页已展示 HR 与知识管理员权限提示

## 2. 通用约定

- 所有受保护接口使用 `Authorization: Bearer <token>`
- 返回体默认直接是 JSON 对象或数组，不额外包一层 `data`
- 员工删除优先做软删除，状态置为 `inactive`
- `approver` 仍然只表示流程审批角色，不代表组织直属上级
- 组织关系使用 `managerId` 表达，流程审批继续沿用现有审批角色

## 3. Auth

### `POST /api/auth/login`

请求体:

```json
{ "account": "employee01", "password": "123456" }
```

返回体:

```json
{
  "token": "jwt-token",
  "user": {
    "id": "u1",
    "name": "张晓宇",
    "account": "employee01",
    "department": "产品研发部",
    "role": "employee",
    "roleLabel": "普通员工"
  }
}
```

### `GET /api/auth/me`

返回当前登录用户信息。

### `POST /api/auth/logout`

登出并失效 token。

## 4. 组织与 HR

### `GET /api/organization/me`

返回当前用户的组织视图:

```json
{
  "employee": { "id": "u1", "name": "张晓宇", "departmentName": "产品研发部" },
  "manager": { "id": "u2", "name": "李清远" },
  "directReports": [],
  "departmentMembers": []
}
```

### `GET /api/organization/departments/tree`

返回部门树，用于人员归属和管理范围选择。

### `GET /api/organization/users?scope=department|team|all&departmentId=&keyword=&activeOnly=true`

返回人员目录列表。

### `POST /api/organization/users`

HR 新增员工。

请求体建议包含:

```json
{
  "name": "新员工",
  "account": "new01",
  "departmentId": "d-sales",
  "managerId": "u2",
  "jobTitle": "销售专员",
  "role": "employee"
}
```

### `PATCH /api/organization/users/:id/organization`

用于调整员工部门、直属主管、岗位、角色、在职状态。

### `DELETE /api/organization/users/:id`

建议语义为软删除/停用:

```json
{ "employmentStatus": "inactive" }
```

权限要求:

- HR
- `systemAdmin`

## 5. 知识库管理

### `GET /api/knowledge/categories`
### `GET /api/knowledge/articles`

供知识库列表、详情、收藏和关联流程展示使用。

### `POST /api/knowledge/categories`
### `PATCH /api/knowledge/categories/:id`

知识分类新增与编辑。

### `POST /api/knowledge/articles`
### `PATCH /api/knowledge/articles/:id`
### `DELETE /api/knowledge/articles/:id`

知识文章新增、编辑、删除、下架。

文章建议字段:

```json
{
  "title": "系统权限申请规范",
  "summary": "说明系统权限申请的流程与审批要求",
  "content": "正文",
  "categoryId": "cat-1",
  "tags": ["权限", "申请"],
  "status": "published"
}
```

### `POST /api/knowledge/articles/:id/favorite`
### `DELETE /api/knowledge/articles/:id/favorite`
### `POST /api/knowledge/articles/:id/corrections`

收藏、取消收藏、纠错建议。

权限要求:

- `knowledgeAdmin`
- `systemAdmin`

## 6. 协作

### `GET /api/collaboration/summary?focus=all|action|waiting`

返回工作台协作统计，前端会据此展示:

- `actionCount`
- `waitingCount`
- `meetingCount`
- `groupCount`
- `meetingItems`
- `taskItems`
- `groupItems`
- `chainItems`
- 每个条目建议补充 `threadId`
- 每个条目建议补充 `lastMessageText`
- 每个条目建议补充 `lastMessageTime`
- 每个条目建议补充 `unreadCount`

### `GET /api/collaboration/meetings`
### `POST /api/collaboration/meetings`

会议时间地点声明。

建议请求体:

```json
{
  "title": "产品周会",
  "timeText": "7月18日 09:30",
  "placeText": "A 栋 3 层会议室",
  "summary": "同步本周进度"
}
```

### `GET /api/collaboration/tasks`
### `POST /api/collaboration/tasks`
### `POST /api/collaboration/tasks/:id/reply`

短期工作对接与回复确认。

建议请求体:

```json
{
  "title": "接口联调",
  "targetText": "李清远 / 项目协同组",
  "timeText": "今天 18:00 前",
  "summary": "请确认联调边界与对接人"
}
```

### `GET /api/collaboration/groups`
### `POST /api/collaboration/groups`

工作组创建与查询。

### `GET /api/collaboration/chains`

返回直属上级与直接下属关系，用于长期上下级直接对接。

### 文本通讯接口

协作页中的 `工作对接`、`工作组`、`工作汇报` 都需要文本通讯能力。

建议新增以下接口:

- `GET /api/collaboration/threads?targetType=task|group|chain&targetId=`
- `GET /api/collaboration/threads/:id/messages`
- `POST /api/collaboration/threads/:id/messages`

建议消息体:

```json
{ "content": "我已经看过，请继续推进。" }
```

建议返回消息结构:

- `id`
- `threadId`
- `senderName`
- `senderRoleLabel`
- `content`
- `timeText`
- `direction`

## 7. 消息

### `GET /api/notifications`
### `POST /api/notifications/:id/read`

用于系统通知、流程提醒、知识更新等消息。

### `GET /api/messages/feed`
### `POST /api/messages/:id/read`

用于其他员工发来的具体消息或对接消息线程。

## 8. 流程

### `GET /api/workflow/templates`
### `GET /api/workflow/instances/my`
### `GET /api/workflow/instances/todo`
### `GET /api/workflow/instances/:id`
### `POST /api/workflow/instances`
### `POST /api/workflow/instances/:id/approve`
### `POST /api/workflow/instances/:id/reject`
### `POST /api/workflow/instances/:id/security-confirm`

状态仍沿用:

- `待审批`
- `审批中`
- `待二次确认`
- `已通过`
- `已驳回`

## 9. 前端联动假设

- 工作台未读数当前按 `通知 + 邮件` 计算
- 协作页当前已经支持本地文本通讯与新建会议/对接
- 后端接入后，协作页可直接切到真实线程和持久化数据
- 后续若要把 `messages/feed` 也并入未读数，可在 summary 中补一个统一未读字段

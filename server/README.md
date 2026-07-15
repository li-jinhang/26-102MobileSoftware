# MobileSoftwareBackend

智协库配套后端骨架，当前采用：

- NestJS
- Prisma
- SQLite
- 内存数据版控制器实现

## 当前已覆盖接口

- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `GET /api/knowledge/categories`
- `GET /api/knowledge/articles`
- `POST /api/knowledge/articles/:id/favorite`
- `DELETE /api/knowledge/articles/:id/favorite`
- `POST /api/knowledge/articles/:id/corrections`
- `GET /api/workflow/templates`
- `GET /api/workflow/instances/my`
- `GET /api/workflow/instances/todo`
- `GET /api/workflow/instances/:id`
- `POST /api/workflow/instances`
- `POST /api/workflow/instances/:id/approve`
- `POST /api/workflow/instances/:id/reject`
- `POST /api/workflow/instances/:id/security-confirm`
- `GET /api/notifications`
- `POST /api/notifications/:id/read`
- `POST /api/assistant/ask`
- `GET /api/attendance/today`
- `GET /api/attendance/records/my`
- `POST /api/attendance/check-in`
- `POST /api/attendance/check-out`
- `GET /api/mail/inbox`
- `GET /api/mail/sent`
- `GET /api/mail/:id`
- `POST /api/mail/send`
- `POST /api/mail/:id/read`
- `DELETE /api/mail/:id`

## 说明

当前版本有两个目的：

1. 让鸿蒙前端现有接口有一个统一的后端落点。
2. 为后续从内存数据迁移到 Prisma + SQLite 持久化保留表结构。

也就是说：

- `prisma/schema.prisma` 已经给出首版数据表设计。
- `src/data/mock-db.ts` 目前仍作为演示期数据源。
- 下一步可以把控制器里的读写逐步替换为 Prisma 查询。

## 启动方式

```bash
cd server
npm install
npm run start:dev
```

默认地址：

```text
http://127.0.0.1:26102/api
```

## 后续建议

建议按下面顺序继续推进：

1. 把 `mock-db.ts` 中的用户、知识、流程、通知、考勤、邮件整理成 Prisma seed。
2. 新增 `PrismaService`，逐个替换控制器中的内存读写。
3. 给登录态加真正的 token 校验和守卫。
4. 把流程审批、邮件发送、考勤异常提醒补上更完整的业务规则。

# harmony_team17_defense - Design Spec

## I. Project Information

| Item | Value |
| ---- | ----- |
| **Project Name** | TEAM17 白泽课程设计答辩 |
| **Canvas Format** | PPT 16:9 (1280x720) |
| **Page Count** | 15 |
| **Design Style** | Academic defense + restrained HarmonyOS-inspired technology |
| **Target Audience** | 移动软件开发课程答辩教师 |
| **Use Case** | 2025-2026 学年第二学期课程设计答辩 |
| **Created Date** | 2026-07-17 |

---

## II. Canvas Specification

| Property | Value |
| -------- | ----- |
| **Format** | PPT 16:9 |
| **Dimensions** | 1280x720 |
| **viewBox** | `0 0 1280 720` |
| **Margins** | left/right 56px; top/bottom 44px |
| **Content Area** | 1168x632px |

---

## III. Visual Theme

### Theme Style

- **Style**: Academic defense + restrained HarmonyOS-inspired technology
- **Theme**: Light theme
- **Tone**: 清晰、可信、克制，以深蓝结构线和鸿蒙红强调关键交互。

### Color Scheme

| Role | HEX | Purpose |
| ---- | --- | ------- |
| **Background** | `#F7F9FC` | 页面背景 |
| **Secondary bg** | `#EAF0F7` | 分区和截图底板 |
| **Primary** | `#123B63` | 标题、流程线、主要结构 |
| **Accent** | `#E63B46` | 鸿蒙能力、关键动作与高亮 |
| **Secondary accent** | `#18A38A` | 成功状态、闭环完成 |
| **Body text** | `#16212E` | 正文 |
| **Secondary text** | `#536273` | 说明文字 |
| **Tertiary text** | `#7C8997` | 页脚与辅助信息 |
| **Border/divider** | `#D7E0EA` | 分隔线、截图框 |
| **Success** | `#18A38A` | 正向状态 |
| **Warning** | `#E63B46` | 风险/待处理状态 |

---

## IV. Typography System

### Font Plan

**Typography direction**: CJK-first 的技术答辩排版；标题、正文同族以确保投影可读，代码使用等宽字体。

| Role | Chinese | English | Fallback tail |
| ---- | ------- | ------- | ------------- |
| **Title** | `Microsoft YaHei` | `Arial` | `sans-serif` |
| **Body** | `Microsoft YaHei` | `Arial` | `sans-serif` |
| **Emphasis** | `Microsoft YaHei` | `Arial` | `sans-serif` |
| **Code** | - | `Consolas` | `monospace` |

**Per-role font stacks**:

- Title: `"Microsoft YaHei", Arial, sans-serif`
- Body: `"Microsoft YaHei", Arial, sans-serif`
- Emphasis: `"Microsoft YaHei", Arial, sans-serif`
- Code: `Consolas, "Courier New", monospace`

### Font Size Hierarchy

**Baseline**: Body font size = 22px.

| Purpose | Ratio to body | Project range | Weight |
| ------- | ------------- | ------------- | ------ |
| Cover title | 2.5-5x | 68-84px | Bold |
| Chapter/page title | 1.5-2x | 36-42px | Bold |
| Subtitle | 1.2-1.5x | 26-30px | SemiBold |
| **Body content** | **1x** | **22px** | Regular |
| Annotation/caption | 0.7-0.85x | 16-18px | Regular |
| Page number/footer | 0.5-0.65x | 12-14px | Regular |

Formula policy: `text-only` (本项目无公式内容)。

---

## V. Layout Principles

### Page Structure

- **Header area**: 44-104px；页码、章节标签和标题。
- **Content area**: 104-650px；核心叙事、截图和原生图形。
- **Footer area**: 650-690px；功能归属/简短结论。

### Layout Pattern Library

- `anchor` 页面以单一大标题或结构图为锚点；`dense` 页面以截图、要点和流程组成；`breathing` 页面以一条主张和大尺度视觉收束。
- 截图按原始纵横比 `meet` 放置，统一使用 2px 边框与 8px 圆角；截图不是卡片套卡片。
- 多图页面使用同尺寸小样本或非对称拼贴；架构页以原生节点和连线保持可编辑。

### Spacing Specification

| Element | Current Project |
| ------- | --------------- |
| Safe margin | 56px |
| Content block gap | 24px |
| Icon-text gap | 12px |
| Screenshot gap | 20px |
| Screenshot frame radius | 8px |

---

## VI. Icon Usage Specification

### Source

- **Built-in icon library**: `phosphor-duotone`
- **Usage method**: SVG placeholder `<use data-icon="phosphor-duotone/icon-name" .../>`

### Recommended Icon List

| Purpose | Icon Path | Page |
| ------- | --------- | ---- |
| 产品入口/工作台 | `phosphor-duotone/app-window` | P01, P12 |
| 知识检索 | `phosphor-duotone/book-open` | P02, P11 |
| 智能助手 | `phosphor-duotone/robot` | P02, P10, P13 |
| 邮件 | `phosphor-duotone/envelope` | P05 |
| 考勤 | `phosphor-duotone/calendar-check` | P06 |
| 收藏 | `phosphor-duotone/star` | P07 |
| 服务与数据 | `phosphor-duotone/database` | P03, P08 |
| 协作 | `phosphor-duotone/users-three` | P09 |
| 模板/流程 | `phosphor-duotone/files` | P11 |
| 任务/待办 | `phosphor-duotone/list-checks` | P12 |
| 连接/闭环 | `phosphor-duotone/git-branch` | P13 |
| 安全 | `phosphor-duotone/shield-check` | P03, P08 |

---

## VII. Visualization Reference List

本答辩不使用数据型图表模板。P03、P08、P13 的技术结构与业务闭环均使用原生 SVG 节点、连线、图标和可编辑文本绘制，避免虚构统计数据。

---

## VIII. Image Resource List

| Filename | Dimensions | Ratio | Purpose | Type | Layout pattern | Acquire Via | Status | Reference | text_policy | page_role |
| -------- | ---------- | ----- | ------- | ---- | -------------- | ----------- | ------ | --------- | ----------- | --------- |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_001.png` | 2546x1370 | 1.86 | 后端 Swagger 接口总览 | Screenshot | #19 Image floating in whitespace with thin frame and caption + #70 Image with thin colored matte frame | user | Existing | 后端模块接口总览 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_003.png` | 574x1198 | 0.48 | 工作台 | Screenshot | #19 Image floating in whitespace with thin frame and caption + #70 Image with thin colored matte frame | user | Existing | 员工工作台、待办和快捷入口 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_004.png` | 574x1198 | 0.48 | 知识列表 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 知识分类与文章浏览 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_005.png` | 574x1198 | 0.48 | 知识详情 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 详情、收藏与关联流程 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_006.png` | 570x1234 | 0.46 | 助手初始态 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 文本/图片输入入口 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_007.png` | 570x1234 | 0.46 | 助手问答 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 制度摘要与关联知识 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_009.png` | 570x1234 | 0.46 | 智能预填 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 推荐流程与预填入口 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_010.png` | 574x1198 | 0.48 | 流程模板 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 请假、报销、采购和权限模板 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_015.png` | 574x1198 | 0.48 | 考勤签到 | Screenshot | #19 Image floating in whitespace with thin frame and caption + #70 Image with thin colored matte frame | user | Existing | 今日状态、时间、地点、历史记录 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_016.png` | 574x1198 | 0.48 | 邮件收件箱 | Screenshot | #48 Side-by-side comparison + #70 Image with thin colored matte frame | user | Existing | 内部收件箱 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_017.png` | 574x1198 | 0.48 | 写邮件 | Screenshot | #48 Side-by-side comparison + #70 Image with thin colored matte frame | user | Existing | 编辑邮件及关联知识/流程 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_018.png` | 574x1198 | 0.48 | 组织关系 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 部门、上级、下属和成员 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_019.png` | 574x1198 | 0.48 | 协作对象 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 任务、会议和参与人 | | |
| `“移动软件开发”课设报告-TEAM17-李金航-李承岩-邢思琦__image_020.png` | 574x1198 | 0.48 | 协作详情 | Screenshot | #47 Small multiples + #70 Image with thin colored matte frame | user | Existing | 截止时间、状态和处理事项 | | |

---

## IX. Content Outline

### Part 1: 项目全貌与鸿蒙实现

#### Slide 01 - 白泽：企业知识与流程协作
- **Layout**: breathing；产品名为主视觉，右侧工作台手机截图与原生图标构成入口感。
- **Core message**: 白泽把“查制度、问助手、办流程、跟结果”收束到一个鸿蒙移动入口。
- **Content**: 2025-2026 学年第二学期；课程名称：移动软件开发；组别：TEAM17；24080212 邢思琦、24080218 李金航、24080217 李承岩。

#### Slide 02 - 从知识查询到流程办理的移动闭环
- **Layout**: dense；四段原生闭环线叠加工作台、知识、助手、流程截图。
- **Core message**: 产品价值不在单点功能，而在知识理解驱动业务办理的连续路径。
- **Content**: 查制度 → 问助手 → 智能预填 → 提交与跟踪；四类角色按权限获得不同工作台与待办。

#### Slide 03 - 鸿蒙端分层：ArkTS + ArkUI + Repository
- **Layout**: anchor；端侧、适配层、后端、数据层的可编辑架构图，辅以 Swagger 总览。
- **Core message**: 组件化 ArkUI 页面通过 UseCase、Repository 与 HTTP Adapter 解耦，便于 Mock 到 HTTP 的平滑切换。
- **Content**: HarmonyOS / ArkTS / ArkUI；NestJS / Prisma / SQLite；Token 鉴权与统一 `code-message-data` 响应。

### Part 2: 邢思琦负责模块

#### Slide 04 - 邢思琦：名称与图标设计
- **Layout**: breathing；“白泽”字标、知识识别意象与命名逻辑形成单一主张。
- **Core message**: 白泽的命名将中国文化意象转译为“识别知识、提示风险、辅助决策”的产品定位。
- **Content**: 中国文化命名；知识理解；流程推荐；风险提示；统一图标语义降低企业功能的理解成本。

#### Slide 05 - 内部邮件：从消息接收到业务关联
- **Layout**: dense；收件箱与写邮件双屏对照。
- **Core message**: 邮件不仅传递内容，也能把知识和流程上下文一起带入沟通。
- **Content**: 收件箱、已发邮件、详情；收件人、主题、正文；关联流程与知识；可继续编辑助手生成的邮件草稿。

#### Slide 06 - 考勤签到签退：让状态、地点与记录可追溯
- **Layout**: dense；大尺寸签到截图，旁侧三个可编辑状态节点。
- **Core message**: 考勤在移动端清楚呈现今日状态、操作信息和近期记录，降低核对成本。
- **Content**: 签到/签退状态；时间与地点；备注；近期记录。

#### Slide 07 - 收藏知识：让制度阅读成为可回访的入口
- **Layout**: dense；知识详情和个人中心小样本，原生收藏路径标注。
- **Core message**: 收藏将高频制度沉淀到个人中心，并保留从知识到关联流程的下一步入口。
- **Content**: 文章详情；标签、版本、更新时间；收藏与纠错；关联流程。

### Part 3: 李金航负责模块

#### Slide 08 - 后端开发：模块化服务支撑业务闭环
- **Layout**: anchor；后端模块矩阵与 Swagger 全景截图。
- **Core message**: NestJS 按业务模块拆分认证、知识、流程、通知、考勤、邮件、助手与协作服务。
- **Content**: Controller / Service / Prisma；SQLite 本地演示数据；Token 鉴权；统一响应；前后端接口映射。

#### Slide 09 - 协作功能：组织、会议、任务放进同一工作对象
- **Layout**: dense；三张组织/协作手机截图并列。
- **Core message**: 员工可先确认协作关系，再围绕任务与会议持续跟进状态和参与人。
- **Content**: 组织关系；工作对象；会议与任务；截止时间；处理状态；参与人。

### Part 4: 李承岩负责模块

#### Slide 10 - 智能助手：问答、图片识别与流程推荐
- **Layout**: dense；三屏连续演示输入、回答、推荐流程。
- **Core message**: 助手把自然语言或图片中的问题连接到制度知识和可执行流程。
- **Content**: 文本提问；相册图片输入；制度摘要；关联知识；推荐流程；缺失字段提示。

#### Slide 11 - 模板与知识库：标准入口承接不同业务场景
- **Layout**: dense；知识列表、详情、流程模板三屏对照。
- **Core message**: 分类知识和流程模板共同提供清晰的标准入口，降低员工查找与发起成本。
- **Content**: 分类/详情/收藏/纠错；请假/报销/采购/权限模板；发起、审批、状态查询。

#### Slide 12 - 工作栏：角色、待办、快捷入口集中呈现
- **Layout**: breathing；放大工作台截图，辅以三项短标注。
- **Core message**: 工作栏以当前身份、待办数量和快捷入口组织高频工作，按角色呈现不同信息。
- **Content**: 用户与部门；待办与消息；知识、助手、流程快捷入口；底部导航。

### Part 5: 总结与验证

#### Slide 13 - 新颖特点：智能理解驱动业务执行
- **Layout**: anchor；以“问题 → 知识 → 表单草稿 → 审批通知”原生闭环图为中心。
- **Core message**: 智能预填不是普通跳转，而是将识别出的标题、日期、金额、事由和附件写入后续流程表单。
- **Content**: 知识问答；图片识别；流程推荐；智能预填；审批通知；结果回流工作台。

#### Slide 14 - 测试与演示环境
- **Layout**: dense；测试环境清单、核心用户路径、边界关注点。
- **Core message**: 在 HarmonyOS 模拟器和 Node.js 服务环境中，主路径能够完成从登录到流程办理的端到端联动。
- **Content**: DevEco Studio；HarmonyOS 模拟器；NestJS `26102` 端口；SQLite 初始数据；图片清晰度、Token 有效性、缺失字段等边界。

#### Slide 15 - 答辩总结
- **Layout**: breathing；一句结论与三项成果收束。
- **Core message**: 白泽以鸿蒙组件化移动端为入口，完成知识、智能与协作的可演示业务闭环。
- **Content**: ArkTS / ArkUI 实践；前后端分层协作；从知识查询到业务执行的连续体验。谢谢老师。

---

## X. Speaker Notes Requirements

每页生成对应讲稿文件，命名与 SVG 文件一致；每页控制在 25-45 秒，P02、P03、P10、P13 为核心讲解页。

---

## XI. Technical Constraints Reminder

1. viewBox: `0 0 1280 720`。
2. 背景使用 `<rect>`；文字以 `<text>` 和 `<tspan>` 排版。
3. 仅使用本规范锁定的颜色、字体、图标和图片。
4. 禁止 `rgba()`、`<style>`、`class`、`foreignObject`、`textPath`、`animate*`、`script`、`mask`。
5. 图片不裁剪，使用 `preserveAspectRatio="xMidYMid meet"`；透明度使用 `fill-opacity` / `stop-opacity`。

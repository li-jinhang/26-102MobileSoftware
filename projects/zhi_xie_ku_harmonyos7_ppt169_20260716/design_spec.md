# 智协库 HarmonyOS 7 课程答辩 - Design Spec

> Human-readable design narrative. The execution contract is recorded in spec_lock.md.

## I. Project Information

| Item | Value |
| ---- | ----- |
| **Project Name** | 智协库 HarmonyOS 7 课程答辩 |
| **Canvas Format** | PPT 16:9 (1280x720) |
| **Page Count** | 20 |
| **Design Style** | General Consulting + 极简科技答辩风 |
| **Target Audience** | 课程答辩教师与同学 |
| **Use Case** | 展示企业知识库与流程协作鸿蒙应用的业务价值、工程实现与平台特色 |
| **Created Date** | 2026-07-16 |

---

## II. Canvas Specification

| Property | Value |
| -------- | ----- |
| **Format** | PPT 16:9 |
| **Dimensions** | 1280x720 |
| **viewBox** | 0 0 1280 720 |
| **Margins** | 左右 48px，上下 40px |
| **Content Area** | 1184x640px；标题区 88px，内容区 510px，页脚区 28px |

---

## III. Visual Theme

### Theme Style

- **Style**: General Consulting + 极简科技答辩风
- **Theme**: Light theme
- **Tone**: 克制、清晰、可验证；以结构图和项目事实支撑结论

### Color Scheme

| Role | HEX | Purpose |
| ---- | --- | ------- |
| **Background** | #FFFFFF | 页面底色 |
| **Secondary bg** | #F5F8FC | 分区和浅色信息容器 |
| **Primary** | #0B1F3A | 章节锚点、主标题和结构线 |
| **Accent** | #1677FF | 核心能力、连接和可点击状态 |
| **Secondary accent** | #14B8A6 | 已实现/正向状态 |
| **Body text** | #1F2937 | 正文 |
| **Secondary text** | #64748B | 注释、说明 |
| **Tertiary text** | #94A3B8 | 页脚、辅助信息 |
| **Border/divider** | #D8E1EE | 边框与分隔线 |
| **Success** | #0F9F6E | 已实现标记 |
| **Warning** | #F59E0B | 风险、限制与待规划标记 |

### Gradient Scheme

仅在封面与少量沉浸光感示意中使用深蓝到科技蓝的极弱线性过渡；常规内容页保持纯色底和实线分隔。

---

## IV. Typography System

### Font Plan

**Typography direction**: 现代中文无衬线，优先保障投影环境中的可读性。

| Role | Chinese | English | Fallback tail |
| ---- | ------- | ------- | ------------- |
| **Title** | Microsoft YaHei | Arial | sans-serif |
| **Body** | Microsoft YaHei | Arial | sans-serif |
| **Emphasis** | Microsoft YaHei | Arial | sans-serif |
| **Code** | — | Consolas, Courier New | monospace |

**Per-role font stacks**:

- Title: "Microsoft YaHei", Arial, sans-serif
- Body: "Microsoft YaHei", Arial, sans-serif
- Emphasis: "Microsoft YaHei", Arial, sans-serif
- Code: Consolas, "Courier New", monospace

**Baseline**: Body font size = 22px.

| Purpose | Ratio to body | Recommended size | Weight |
| ------- | ------------- | ---------------- | ------ |
| Cover title | 2.5-3.5x | 72px | Bold |
| Chapter/page title | 1.6-2x | 36-40px | Bold |
| Subtitle | 1.2-1.5x | 26-30px | SemiBold |
| Body content | 1x | 22px | Regular |
| Annotation | 0.7-0.85x | 15-18px | Regular |
| Page number | 0.55x | 12px | Regular |

**Formula policy**: text-only. 本项目不含需要保持数学结构的公式。

---

## V. Layout Principles

### Page Structure

- **Header area**: 88px，页码、章节标签、主标题。
- **Content area**: 510px，按信息权重选择图解、流程、对比或产品界面区域。
- **Footer area**: 28px，项目名与轻量页码。

### Layout Direction

- 封面、关键结论使用单一强锚点与大留白。
- 痛点、优势、模块、能力分层使用两列或四列结构，避免层叠卡片。
- 架构、流程、路线图使用原生 SVG 线条和箭头，保证 PowerPoint 内仍可编辑。
- 组件圆角不超过 8px，阴影极弱或不用阴影；不使用装饰性光球或大面积渐变。

### Spacing Specification

| Element | Current Project |
| ------- | --------------- |
| Safe margin from canvas edge | 48px |
| Content block gap | 24px |
| Icon-text gap | 10px |
| Card gap | 20px |
| Card padding | 22px |
| Card border radius | 8px |
| Line-height | 1.45x body |

---

## VI. Icon Usage Specification

### Source

- **Built-in icon library**: tabler-outline
- **Usage method**: SVG placeholder use data-icon="tabler-outline/icon-name"
- **Stroke width**: 2

### Approved Icon Inventory

| Purpose | Icon Path | Page |
| ------- | --------- | ---- |
| 主页与工作台 | tabler-outline/home | P05, P06 |
| 知识与检索 | tabler-outline/book-2, tabler-outline/search | P05, P12 |
| 流程与审批 | tabler-outline/git-branch, tabler-outline/clipboard-check | P05, P11 |
| 用户与权限 | tabler-outline/users, tabler-outline/key | P07, P14 |
| 后端与数据库 | tabler-outline/server, tabler-outline/database | P09, P10 |
| 智能助手 | tabler-outline/sparkles, tabler-outline/message-chatbot | P13, P18 |
| 安全治理 | tabler-outline/shield-check, tabler-outline/alert-triangle | P14, P15 |
| 鸿蒙能力 | tabler-outline/widgets, tabler-outline/scan, tabler-outline/device-mobile | P16-P18 |
| 结论 | tabler-outline/target-arrow, tabler-outline/rocket | P19, P20 |

---

## VII. Visualization Reference List

Catalog read: 71 templates

| Page | Template | Path | Summary-quote (verbatim) | Usage |
| ---- | -------- | ---- | ------------------------ | ----- |
| P02 | agenda_list | templates/charts/agenda_list.svg | "Pick for table of contents, meeting agendas, or presentation roadmap — numbered items + brief description + duration / owner per row. Skip for substantive content lists (use vertical_list) or single-page section dividers (use a cover layout)." | 答辩叙事总览 |
| P03 | fishbone_diagram | templates/charts/fishbone_diagram.svg | "Pick for cause-and-effect root cause analysis with 4-6 cause branches (Ishikawa, 6M). Skip for sequential flow (use process_flow)." | 传统系统痛点的成因归类 |
| P05 | hub_spoke | templates/charts/hub_spoke.svg | "Pick for 1 core capability + 4-8 surrounding capabilities (platform/ecosystem); each spoke = title or title + 1-2 line description. Skip if center is a system containing parts with their own descriptions (use module_composition), or surroundings exert inward pressure on the center (use hub_inward_arrows)." | 智协库统一入口与四类业务能力 |
| P07 | top_down_tree | templates/charts/top_down_tree.svg | "Pick for hierarchical top-down tree 2-4 levels deep with parent→children reporting/decomposition lines — org charts (CEO → VPs → Directors), OKR cascades (Objective → Key Results → Initiatives), WBS decomposition. Skip for non-hierarchical brainstorm (use mind_map) or flat team showcase (use team_roster)." | 四种角色与权限边界 |
| P08 | module_composition | templates/charts/module_composition.svg | "Pick for one parent container wrapping 3-N child module cards, each = title + 2-3 bullets — fits 'Feature X contains 3 parts, each with its own description'. Skip if source has only labels without descriptions (use numbered_steps or icon_grid)." | 前端模块组成 |
| P09 | client_server_flow | templates/charts/client_server_flow.svg | "Pick for left-side clients + right-side servers with labeled bidirectional arrows for key interactions (request/response/push). Each module = name + 1-line description; each arrow must have an action label. Skip for non-distributed flows (use process_flow)." | ArkTS/ArkUI、NestJS、Prisma/SQLite 的交互 |
| P11 | process_flow | templates/charts/process_flow.svg | "Pick for 3-8 sequential steps connected by simple arrows — approval workflows, customer onboarding, request handling, lifecycle stages. Skip if cyclical (use circular_stages) or stages produce named outputs (use pipeline_with_stages)." | 从发起到安全确认与通知的流程闭环 |
| P12 | chevron_chain_with_tail | templates/charts/chevron_chain_with_tail.svg | "Pick for 4-6 sequential chevron blocks plus a final wedge representing aggregate outcome — Porter's value chain (primary + support activities mapped to margin), process leading to a summary deliverable, contribution chain to a result. Skip for plain chevron flow without summary tail (use chevron_process) or non-chevron pipeline (use pipeline_with_stages)." | 知识查询到流程发起的转化链路 |
| P15 | layered_architecture | templates/charts/layered_architecture.svg | "Pick for 3-4 horizontal architecture layers (presentation/service/data), 2-4 module cards per layer, each card = title + 1-line description (description required, even if source brief). Skip if no per-module descriptions (use icon_grid) or no horizontal layering (use module_composition)." | 鸿蒙能力的已实现、可演示、预留三层边界 |
| P19 | vertical_pillars | templates/charts/vertical_pillars.svg | "Pick for 1×3 / 1×4 / 1×5 vertical column layout where each pillar = one independent category with title + bullets — PEST (Political/Economic/Social/Technological), four-pillar strategy overview, side-by-side independent categories. Skip for 2×2 quadrant (use quadrant_text_bullets), pricing tiers (use comparison_columns), or 2×2 parallel aspects (use labeled_card)." | 软件新颖性的四项支柱 |

**Runners-up considered**:

- icon_grid | rejected for P05：能力之间存在“统一入口—功能模块”的中心关系，辐射结构比平行卡片更准确。
- comparison_table | rejected for P03：本页要解释痛点原因，不是按功能逐行比较产品。
- pipeline_with_stages | rejected for P11：审批链主要表现顺序状态流转，未为每一步定义独立产物。

---

## VIII. Image Resource List

本演示不引入外部 AI 或网络图片。产品界面以项目运行截图为优先素材；若当前环境不能获得截图，使用原生 SVG 界面示意和可编辑结构图替代。因此本节不包含需要在 Step 5 获取的资源。

---

## IX. Content Outline

### Part 1: 问题与定位

#### Slide 01 - 封面：智协库

- **Layout**: 深蓝标题锚点 + 右侧简化的知识、流程、智能三节点示意。
- **Title**: 智协库
- **Core message**: 面向企业内部的知识库与流程协作鸿蒙应用。
- **Content**: 副标题“让查知识、办流程、控风险在一个移动入口完成”；标注 HarmonyOS、ArkTS、ArkUI、NestJS、Prisma、SQLite。

#### Slide 02 - 答辩路线

- **Layout**: agenda_list。
- **Title**: 从问题出发，证明方案价值与工程落地。
- **Core message**: 本次展示依次回答痛点、方案、实现、鸿蒙能力与创新性五个问题。
- **Visualization**: agenda_list。
- **Content**: 业务痛点 / 产品方案 / 前后端实现 / HarmonyOS 7 能力 / 新颖性与总结。

#### Slide 03 - 旧式协作系统的结构性痛点

- **Layout**: fishbone_diagram，右端为“低效且难追溯的内部协作”。
- **Title**: 知识、流程与待办分散，造成协作摩擦。
- **Core message**: 问题并非单个功能缺失，而是入口、依据、状态和责任链同时割裂。
- **Visualization**: fishbone_diagram。
- **Content**: 信息孤岛：制度分散难检索；流程脱节：填单前缺少依据；待办滞后：状态与通知不同步；权限模糊：角色边界不清；风控缺位：高风险操作难留痕。

#### Slide 04 - 从“找得到”到“办得对”的效率断点

- **Layout**: 左右对比，左侧为传统路径，右侧为期望路径。
- **Title**: 传统路径链路长、容易漏项，且审批依据不可见。
- **Core message**: 员工完成一次报销或权限申请，要在多个入口间反复切换。
- **Content**: 传统方式：找制度 → 询问同事 → 填表 → 等待 → 追问进度；核心代价：查找成本高、字段易错、审批难判断、责任难追溯。目标方式：问一句、看依据、直接发起、全程可追踪。

#### Slide 05 - 产品定位：一个统一的企业协作入口

- **Layout**: hub_spoke。
- **Title**: 智协库将四类高频能力收敛为一个移动闭环。
- **Core message**: 系统以工作台为入口，将知识、流程、消息和安全治理组织为可联动的能力网络。
- **Visualization**: hub_spoke。
- **Content**: 中心“智协库工作台”；辐射：知识库、流程协作、智能助手、消息与个人中心；底部说明“先有知识依据，再发起业务流程”。

### Part 2: 方案与工程实现

#### Slide 06 - 软件优势：更短的业务路径

- **Layout**: 四项横向能力区 + 一条从查询到完成的路径线。
- **Title**: 优势不止于功能齐全，而是将业务链路缩短。
- **Core message**: 同一应用内完成查询、推荐、发起、审批、通知和留痕。
- **Content**: 集中入口减少切换；知识联动减少填单错误；流程状态可视化减少催办；高风险二次确认强化可审计性。

#### Slide 07 - 角色与权限：按职责开放能力

- **Layout**: top_down_tree。
- **Title**: 四类角色覆盖使用、审批、维护与治理边界。
- **Core message**: 权限不是页面隐藏，而是围绕业务职责形成可解释的访问边界。
- **Visualization**: top_down_tree。
- **Content**: 普通员工：查知识、发起流程；审批人：处理待办、查看关联制度；知识管理员：维护和发布知识；系统管理员：用户角色、模板、安全确认与日志。

#### Slide 08 - 鸿蒙前端：模块化体验层

- **Layout**: module_composition。
- **Title**: ArkTS 与 ArkUI 将业务拆为独立、可演示的功能模块。
- **Core message**: 前端以工作台为主入口，功能模块通过公共模型和服务层协作。
- **Visualization**: module_composition。
- **Content**: Dashboard、Knowledge、Assistant、Workflow、Messages、Profile；公共层包含 components、services、models、mock；突出页面与业务逻辑分离。

#### Slide 09 - 前后端架构：从原型走向可扩展服务

- **Layout**: client_server_flow。
- **Title**: 移动端、REST API 与数据层职责清晰。
- **Core message**: 前端负责体验与交互，NestJS 负责业务边界，Prisma 统一数据访问，SQLite 支撑课程演示持久化。
- **Visualization**: client_server_flow。
- **Content**: 左侧 ArkTS/ArkUI；中间 Bearer Token + REST；右侧 NestJS modules、Prisma ORM、SQLite；接口统一返回 code/message/data。

#### Slide 10 - 数据与接口：用统一模型承载协作状态

- **Layout**: 顶部数据对象带，底部接口域分组。
- **Title**: 用户、知识、流程、通知和审计日志形成统一数据闭环。
- **Core message**: 数据模型使知识与流程关系可追溯，也为后续替换数据库或接入真实服务保留边界。
- **Content**: 核心对象：User、Role、KnowledgeArticle、WorkflowTemplate、WorkflowInstance、ApprovalRecord、Notification、AuditLog；接口域：认证、知识、流程、通知、考勤、邮件、助手。

#### Slide 11 - 流程协作闭环

- **Layout**: process_flow。
- **Title**: 流程从发起到通知形成可追踪的状态机。
- **Core message**: 请假、报销、采购、权限申请共享统一的提交、审批、驳回与留痕机制。
- **Visualization**: process_flow。
- **Content**: 选择模板 → 填写校验 → 提交实例 → 审批/驳回 → 高风险二次确认 → 状态通知与审计记录。

#### Slide 12 - 知识驱动流程，而不是把知识当附件

- **Layout**: chevron_chain_with_tail。
- **Title**: 查询结果可直接转化为可执行的流程入口。
- **Core message**: 智协库把“制度说明”放进业务办理的关键时刻，降低理解与填写成本。
- **Visualization**: chevron_chain_with_tail。
- **Content**: 自然语言提问 → 关键词/标签匹配 → 返回知识摘要 → 推荐对应流程 → 预填或发起申请 → 合规办理结果。

#### Slide 13 - 智能助手：面向实际业务语句的辅助入口

- **Layout**: 问答对话区与推荐行动区的非对称分栏。
- **Title**: 将自然语言问题转化为知识答案与下一步操作。
- **Core message**: 当前版本提供可演示的知识问答与流程推荐，并为多模态分析能力预留服务边界。
- **Content**: 输入示例“报销打车费需要什么材料？”；输出制度摘要、关联知识、报销申请入口；明确当前已实现规则匹配/服务接口，真实大模型与连续 Agent 作为后续扩展。

#### Slide 14 - 安全治理：让高风险操作有确认、有记录

- **Layout**: 左侧阈值规则，右侧安全确认与审计链。
- **Title**: 关键审批不只追求快，更要求可控与可追溯。
- **Core message**: 高金额报销和采购会触发二次安全确认，并与权限和审计日志联动。
- **Content**: 报销超过 5000 元；采购超过 10000 元；系统管理员可处理确认；审批、驳回、确认和通知均写入业务记录或审计日志。

### Part 3: HarmonyOS 7 能力与新颖性

#### Slide 15 - HarmonyOS 7 能力边界：真实能力、可演示能力、预留能力

- **Layout**: layered_architecture。
- **Title**: 平台特色需要真实说明，而不是将规划写成已交付。
- **Core message**: 智协库采用“真实 API 接入 + 稳定演示降级 + 系统级能力预留”的三层策略。
- **Visualization**: layered_architecture。
- **Content**: 已实现：FormKit 服务卡片、CoreVisionKit OCR、MediaLibraryKit/ImageKit、Preferences、ArkUI 体验组件；可演示：OCR 失败降级、沉浸光感、可变字号、模拟智能问答；预留：Agent、Skill、闪控窗、碰一碰、数字身份、数字盾。

#### Slide 16 - 已实现：服务卡片让待办信息走出应用

- **Layout**: 左侧服务卡片原型，右侧数据同步路径。
- **Title**: FormExtensionAbility 将工作台摘要同步到桌面服务卡片。
- **Core message**: 待办数、未读消息和最近知识可以由应用摘要驱动，并从卡片直接进入目标页面。
- **Content**: 使用 FormKit 的 FormExtensionAbility、formProvider、formBindingData；使用 Preferences 保存摘要；卡片点击通过 postCardAction 回到 EntryAbility；只同步摘要，不复制流程状态机。

#### Slide 17 - 已实现：OCR 与沉浸式阅读增强移动端知识体验

- **Layout**: 上下分区，顶部为 OCR 输入输出，底部为阅读体验能力。
- **Title**: 从图片信息提取到知识阅读，体验能力服务于真实办公任务。
- **Core message**: OCR 识别结果被转化为关键词与关联知识，阅读页再提供字号调节和沉浸光感。
- **Content**: CoreVisionKit 文本识别；MediaLibraryKit 选图与 ImageKit 处理；系统 OCR、云端 OCR、演示结果三级降级；KnowledgeDetailPage 使用字号档位和 EdgeLightPanel 强化层次。

#### Slide 18 - 预留：从应用内助手到系统级 Agent/Skill

- **Layout**: 左右分层路线图。
- **Title**: 先做可控的业务助手，再逐步开放系统级能力。
- **Core message**: 当前以明确输入、固定流程和可解释推荐保证演示稳定；未来可把“查制度、发起流程、查看待办”封装为系统级 Skill。
- **Content**: 当前：文本/图片输入、知识匹配、流程意图、表单草稿；下一步：接入大模型与多模态分析；平台预留：Agent 编排、Skill 暴露、闪控窗、碰一碰精准分享、数字身份与数字盾。所有预留能力均标注为规划，不宣称已发布。

#### Slide 19 - 软件新颖性：把企业协作从“功能集合”变为“业务闭环”

- **Layout**: vertical_pillars。
- **Title**: 四项创新共同支撑可用、可控、可扩展的协作体验。
- **Core message**: 新颖性来自知识、流程、智能、安全和平台能力的组合关系。
- **Visualization**: vertical_pillars。
- **Content**: 知识-流程联动；对话/图片驱动的智能辅助；阈值化安全确认与审计；HarmonyOS 原生服务卡片、OCR 和沉浸式交互；前后端解耦的工程扩展性。

#### Slide 20 - 总结：让每一次协作都有依据、有进度、有留痕

- **Layout**: 单列结论页，三条结论与右下角技术栈标签。
- **Title**: 智协库完成了从课程原型到可扩展协作系统的关键一步。
- **Core message**: 项目以真实业务闭环验证软件价值，以明确能力边界呈现 HarmonyOS 平台特色。
- **Content**: 解决“查知识难、办流程慢、审批依据不统一”；前后端架构已形成可运行的业务服务；HarmonyOS 原生能力已落地并为系统级智能能力预留演进路径。

---

## X. Speaker Notes Requirements

- **Filename**: 与 SVG 文件同名，例如 01_cover.md。
- **Duration**: 12-15 分钟，平均每页 35-45 秒，P16-P18 的鸿蒙能力说明合计约 3 分钟。
- **Style**: 正式、简洁、以项目证据为主。
- **Purpose**: 说明问题、展示可运行功能、解释技术选择、明确已实现与预留边界。

---

## XI. Technical Constraints Reminder

- SVG viewBox 固定为 0 0 1280 720，背景使用 rect。
- 文本换行使用 tspan；禁止 foreignObject、style、class、textPath、script、animate。
- 透明度使用 fill-opacity 或 stroke-opacity，禁止 rgba 和 g opacity。
- 仅使用 spec_lock.md 已锁定的颜色、字体、图标和页面图表模板。
- 图标统一使用 tabler-outline，stroke-width 固定为 2。

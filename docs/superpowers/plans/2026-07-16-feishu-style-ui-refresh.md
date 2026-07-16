# 飞书式企业协作界面改造 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在保留现有业务逻辑和导航行为的前提下，统一改造鸿蒙应用的主导航页面与常用子页面，使其具备飞书式企业协作产品的信息密度和视觉层级。

**Architecture:** 以语义化主题令牌为单一视觉来源，先收敛公共组件，再逐层改造应用外壳、四个主导航页面和高频子页面。所有数据与事件回调保持原签名，不修改 use case、repository、service 或模型。

**Tech Stack:** HarmonyOS ArkUI、ArkTS、Hvigor、现有原生组件

---

### Task 1: 建立视觉令牌

**Files:**
- Create: `entry/src/main/ets/common/theme/AppTheme.ets`
- Modify: `entry/src/main/ets/common/theme/Typography.ets`

- [ ] 定义背景、表面、边框、主色、文字、状态色、圆角、间距和控件高度常量。
- [ ] 调整页面、分区、正文和辅助文字规格，保持动态阅读字号逻辑不变。
- [ ] 运行主模块构建，确认 ArkTS 常量类型与现有 SDK 兼容。

Run: `hvigorw.bat --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap`

Expected: `BUILD SUCCESSFUL`

### Task 2: 收敛公共内容组件

**Files:**
- Modify: `entry/src/main/ets/common/components/SectionBlock.ets`
- Modify: `entry/src/main/ets/common/components/KnowledgeCard.ets`
- Modify: `entry/src/main/ets/common/components/EmptyState.ets`
- Create: `entry/src/main/ets/common/components/AppTopBar.ets`

- [ ] 让分区组件使用白色无阴影内容面、8vp 圆角和统一边框。
- [ ] 将知识卡改成紧凑列表单元，保留文章点击和收藏提示。
- [ ] 将空状态改为低装饰的文本状态，移除不稳定字符图标。
- [ ] 新增统一返回标题栏，暴露 `title`、`subtitle` 和 `onBack`。
- [ ] 构建主模块，确认所有公共组件通过 ArkTS 检查。

### Task 3: 改造应用外壳

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] 保留登录、状态初始化和页面路由，只替换登录后外壳的背景、顶部栏和内容间距。
- [ ] 将底部导航改成四个稳定的线性几何标识与文字，固定点击区域尺寸并增加选中态。
- [ ] 将流程入口改成紧凑分段与列表表达，保留对话框、表单和审批回调。
- [ ] 构建并检查四个 tab 可切换、消息入口可打开、流程弹层可关闭。

### Task 4: 改造工作台与知识库

**Files:**
- Modify: `entry/src/main/ets/features/dashboard/DashboardPage.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgePage.ets`
- Modify: `entry/src/main/ets/common/components/EdgeLightPanel.ets`

- [ ] 将工作台问候区压缩为轻量状态横幅，保留模拟器可见的流光。
- [ ] 将待办、消息、考勤、邮件改成紧凑数据栏，高频入口改成规则网格。
- [ ] 将知识推荐与收藏改成列表式内容，减少大圆角卡片。
- [ ] 保留知识分类浏览，确认搜索框和图片按钮仍只存在于智能助手。
- [ ] 构建并检查所有入口回调未变。

### Task 5: 改造智能助手与个人页

**Files:**
- Modify: `entry/src/main/ets/features/assistant/AssistantPage.ets`
- Modify: `entry/src/main/ets/features/profile/ProfilePage.ets`

- [ ] 将助手输入区、图片附件、结果和历史记录改成紧凑消息/列表结构。
- [ ] 保留文字和相册图片提交、知识打开、表单跳转及自动填充回调。
- [ ] 将个人资料改为单一头部，将组织、消息、邮件和设置改成带分隔线的标准列表。
- [ ] 将退出登录与普通入口视觉分离。
- [ ] 构建并检查助手和个人页交互。

### Task 6: 统一高频子页面

**Files:**
- Modify: `entry/src/main/ets/features/messages/MessagesPage.ets`
- Modify: `entry/src/main/ets/features/attendance/AttendancePage.ets`
- Modify: `entry/src/main/ets/features/knowledge/KnowledgeDetailPage.ets`
- Modify: `entry/src/main/ets/features/knowledge/OcrResultPage.ets`
- Modify: `entry/src/main/ets/features/mail/MailPage.ets`
- Modify: `entry/src/main/ets/features/mail/MailDetailPage.ets`
- Modify: `entry/src/main/ets/features/mail/MailComposerPage.ets`
- Modify: `entry/src/main/ets/features/organization/OrganizationPage.ets`

- [ ] 使用统一返回标题栏替换各页面自定义返回字符。
- [ ] 统一背景、分隔线、输入框、按钮、状态标签与列表单元样式。
- [ ] 保持签到、邮件、知识反馈、组织查看等事件回调和数据属性不变。
- [ ] 构建主 HAP，修复所有 ArkTS 编译问题。

### Task 7: 回归与交付

**Files:**
- Review: `entry/src/main/ets/**/*.ets`

- [ ] 搜索旧的大圆角和分散主色，确认高频页面已切换到主题令牌。
- [ ] 运行主 HAP 构建并记录产物路径。
- [ ] 检查 `git diff --check` 和 `git status -sb`，不纳入图标方案等无关文件。
- [ ] 交付模拟器测试清单：登录、四 tab、助手文字/图片、知识详情、流程表单、签到、消息、邮件、我的。

Run: `hvigorw.bat --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap`

Expected: `BUILD SUCCESSFUL`

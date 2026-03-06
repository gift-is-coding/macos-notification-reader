# macOS Notification Reader

> 让 OpenClaw 读取你的 macOS 通知，自动生成每日工作摘要

**这是一个为 OpenClaw 打造的技能（Skill），可以读取 macOS 通知中心的内容，帮助 AI 助手更好地了解你的工作动态。**

---

## 🎯 这是什么？

简单说：这个工具会把你的 macOS 通知导出成 Markdown 文件，让 OpenClaw 能够：

- 📬 知道谁在找你（Teams、Outlook、WeChat、Slack...）
- 📅 了解你的日程提醒
- ✅ 提取待办事项（会议、审批、deadline...）
- 🧠 记住你最近在忙什么

---

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/gift-is-coding/macos-notification-reader.git
cd macos-notification-reader
```

### 2. 首次运行（需要授权）

```bash
# 导出当天所有通知
./scripts/export-notification.sh
```

首次运行时，macOS 会弹窗请求「通知访问权限」，点击允许即可。

### 3. 查看输出

通知会导出到 `output/` 目录：
```
output/2026-03-06/notifications-20260306-114500.md
```

格式如下：
```markdown
# macOS Notifications Export
- Date: 2026-03-06
- Timestamp: 20260306-114500
- Total: 45 items

## 通知内容

| 时间 | 应用 | 内容 |
|------|------|------|
| 2026-03-06 11:24:03 | Microsoft Teams | Shuo Zhou: 9号的讨论... |
| 2026-03-06 10:30:00 | Outlook | 会议提醒：Q4 财报评审 |
```

---

## 💼 工作摘要模式（推荐）

如果你只想看**工作相关**的通知（Teams / Outlook / WeChat），使用：

```bash
# 默认提取过去 3 小时的工作通知
./scripts/work-summary.sh
```

输出示例：
```markdown
# Work Notification Summary
- Date: 2026-03-06
- Time Range: 10:30 - 13:30
- Total: 12 items

## 📬 未读消息

### Microsoft Teams
- **Shuo Zhou** (10:24): "9号的讨论，你们起了一个新的Deck吧，麻烦分享我一个"

### WeChat (工作)
- **Vivian DT Brad 团队**: "你们结束了吗"

## ✅ 待处理事项

- [ ] 向 Shuo Zhou 分享新 Deck（9号讨论前）
```

---

## 🔧 定时自动运行（可选）

如果你希望 OpenClaw 自动定期抓取，可以配置 cron：

```bash
# 每 30 分钟运行一次
*/30 * * * * cd /path/to/macos-notification-reader && ./scripts/export-notification.sh
```

---

## 🔐 隐私说明

- ✅ 数据保存在本地，不上传任何服务器
- ✅ 只读取通知标题和内容，不读取附件
- ✅ 支持一键清理：`rm -rf output/`

---

## 🤖 与 OpenClaw 集成

这个项目本身就是为 OpenClaw 设计的！

在 OpenClaw 中配置后，每次对话时 AI 会自动读取 `output/` 目录的记忆文件，了解你最近的工作动态。

### 集成步骤：

1. 把项目放到 OpenClaw 的 skills 目录：
   ```bash
   cp -r macos-notification-reader ~/.openclaw/workspace/skills/
   ```

2. 在 OpenClaw 配置中添加 cron job 定时抓取

3. 开始对话，OpenClaw 就会"知道"谁在找你了 🎉

---

## 🛠️ 故障排查

### Q: 显示 0 条通知？

**常见原因**：macOS 通知数据库使用 SQLite WAL 模式，可能需要同时读取 wal 文件。

当前脚本已自动处理。若仍有问题，检查权限：
```bash
# 快速调试
python3 ./scripts/read_notifications.py --minutes 35 --output /tmp/debug.txt
cat /tmp/debug.txt
```

### Q: 微信通知没被识别？

确保在「系统设置 → 通知」中允许微信通知。脚本已兼容 `WeChat` 和 `xinwechat` 两种 app id。

---

## 📁 文件结构

```
macos-notification-reader/
├── scripts/
│   ├── export-notification.sh    # 导出所有通知
│   ├── work-summary.sh           # 工作摘要（推荐）
│   ├── read_notifications.py     # 核心读取脚本
│   └── read_notifications_visual.py  # 可视化版本
├── output/                       # 导出目录
├── README.md
└── LICENSE
```

---

## 📞 支持

- 问题反馈：https://github.com/gift-is-coding/macos-notification-reader/issues
- 了解更多 OpenClaw：https://docs.openclaw.ai

---

**Made with ❤️ for OpenClaw**

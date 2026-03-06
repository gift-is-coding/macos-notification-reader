# macOS Notification Reader

> 让 OpenClaw 读取你的 macOS 通知，自动生成每日工作摘要

> Read your macOS notifications and generate daily work summaries for OpenClaw

**这是一个为 OpenClaw 打造的技能（Skill），可以读取 macOS 通知中心的内容，帮助 AI 助手更好地了解你的工作动态。**

---

## 🎯 这是什么？ / What is this?

### 中文
简单说：这个工具会把你的 macOS 通知导出成 Markdown 文件，让 OpenClaw 能够：
- 📬 知道谁在找你（Teams、Outlook、WeChat...）
- 📅 了解你的日程提醒
- ✅ 提取待办事项（会议、审批、deadline...）
- 🧠 记住你最近在忙什么

### English
Simply put: This tool exports your macOS notifications to Markdown files, allowing OpenClaw to:
- 📬 Know who's reaching out (Teams, Outlook, WeChat...)
- 📅 Understand your calendar reminders
- ✅ Extract action items (meetings, approvals, deadlines...)
- 🧠 Remember what you've been working on

---

## 🚀 快速开始 / Quick Start

### 前置要求 / Prerequisites

- macOS 系统 / macOS system
- Python 3.8+ (`python3 --version` 检查)
- OpenClaw 已安装

### 1. 克隆项目 / Clone the project

```bash
git clone https://github.com/gift-is-coding/macos-notification-reader.git
cd macos-notification-reader
```

### 2. 给脚本执行权限 / Make scripts executable

```bash
chmod +x scripts/*.sh
```

### 3. 首次运行（需要授权）/ First run (requires authorization)

```bash
# 导出当天所有通知 / Export all notifications for the day
./scripts/export-notification.sh
```

首次运行时，macOS 会弹窗请求「通知访问权限」，点击允许即可。/ On first run, macOS will prompt for notification access permission - click Allow.

### 4. 查看输出 / Check output

通知会导出到 `output/` 目录：/ Notifications are exported to the `output/` directory:

```
output/2026-03-06/notifications-20260306-114500.md
```

---

## ⚙️ OpenClaw 集成配置 / OpenClaw Integration Setup

### 方式一：配置定时任务（推荐）/ Method 1: Setup Cron Job (Recommended)

在 OpenClaw 中配置定时自动抓取通知：

1. 编辑 OpenClaw 配置，添加 cron 任务：

```bash
# 方式 A：通过 OpenClaw 命令行（如果支持）
openclaw cron add "*/30 * * * *" "./scripts/export-notification.sh"

# 方式 B：手动添加 crontab
crontab -e
```

2. 添加以下行（每 30 分钟抓取一次）：

```cron
*/30 * * * * cd /path/to/macos-notification-reader && ./scripts/export-notification.sh >> /tmp/notif_cron.log 2>&1
```

### 方式二：放入 OpenClaw Skills 目录 / Method 2: Put in OpenClaw Skills Directory

```bash
cp -r macos-notification-reader ~/.openclaw/workspace/skills/macos-notification-reader
```

然后在 OpenClaw 配置中设置定时调用。

---

## 💼 工作摘要模式（推荐）/ Work Summary Mode (Recommended)

如果你只想看**工作相关**的通知，使用：/ If you only want to see **work-related** notifications:

```bash
# 默认提取过去 3 小时的工作通知 / Default: extract work notifications from last 3 hours
./scripts/work-summary.sh

# 自定义时间范围 / Custom time range
WORK_LOOKBACK_MINUTES=60 ./scripts/work-summary.sh
```

---

## 🔧 环境变量 / Environment Variables

| 变量 / Variable | 默认值 / Default | 说明 / Description |
|-----------------|------------------|-------------------|
| `OUTPUT_DIR` | `./output` | 输出目录（建议设为 OpenClaw 的 memory 目录）/ Output directory (recommend setting to OpenClaw's memory directory) |
| `NOTIF_LOOKBACK_MINUTES` | `40` | 导出通知的时间窗口（分钟）/ Notification time window (minutes) |
| `WORK_LOOKBACK_MINUTES` | `180` | 工作摘要时间窗口（分钟）/ Work summary time window (minutes) |

### 高级：输出到 OpenClaw Memory 目录 / Advanced: Output to OpenClaw Memory

如果想让 OpenClaw 自动读取通知，可以直接输出到 memory 目录：

```bash
OUTPUT_DIR=~/.openclaw/workspace/memory/$(date +%Y-%m-%d)/computer_io/notification ./scripts/work-summary.sh
```

---

## 🔐 隐私说明 / Privacy

- ✅ 数据保存在本地，不上传任何服务器 / Data stored locally, not uploaded to any server
- ✅ 只读取通知标题和内容，不读取附件 / Only reads notification titles and content, not attachments
- ✅ 支持一键清理：`rm -rf output/` / One-click cleanup: `rm -rf output/`

---

## 📁 文件结构 / File Structure

```
macos-notification-reader/
├── scripts/
│   ├── export-notification.sh    # 导出所有通知 / Export all notifications
│   ├── work-summary.sh           # 工作摘要（推荐）/ Work summary (recommended)
│   ├── daily-summary.sh          # 每日摘要 / Daily summary
│   └── read_notifications.py    # 核心读取脚本 / Core reading script
├── output/                       # 导出目录 / Export directory
├── SKILL.json                    # OpenClaw Skill 元数据 / OpenClaw Skill metadata
├── README.md
└── LICENSE
```

---

## 🛠️ 故障排查 / Troubleshooting

### Q: 显示 0 条通知？/ Q: Shows 0 notifications?

**常见原因**：macOS 通知数据库使用 SQLite WAL 模式。/ **Common cause**: macOS notification database uses SQLite WAL mode.

当前脚本已自动处理。若仍有问题，检查权限：/ Current script handles this automatically. If issues persist, check permissions:

```bash
# 快速调试 / Quick debug
python3 ./scripts/read_notifications.py --minutes 5 --output /tmp/debug.txt
cat /tmp/debug.txt
```

### Q: 权限被拒绝？/ Q: Permission denied?

```bash
# 确保脚本有执行权限 / Make sure scripts are executable
chmod +x scripts/*.sh
```

---

## 📞 支持 / Support

- 问题反馈 / Issues: https://github.com/gift-is-coding/macos-notification-reader/issues
- 了解更多 OpenClaw / Learn more about OpenClaw: https://docs.openclaw.ai

---

**Made with ❤️ for OpenClaw**

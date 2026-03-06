#!/bin/bash
# Export macOS notifications to date-based folder

NOTIF_SCRIPT="/Users/wutianfu/.openclaw/workspace/skills/macos-notification-reader/scripts/read_notifications.py"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

OUTPUT_DIR="/Users/wutianfu/.openclaw/workspace/memory/$TODAY/computer_io/notification"
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/$TIMESTAMP.md"

# 读取最近一段时间的通知（默认 40 分钟，可通过环境变量覆盖）
LOOKBACK_MINUTES="${NOTIF_LOOKBACK_MINUTES:-40}"
python3 "$NOTIF_SCRIPT" --minutes "$LOOKBACK_MINUTES" --output "/tmp/notif_$TIMESTAMP.txt" 2>/dev/null

# 转换为 markdown 格式
python3 - "$OUTPUT_FILE" "$TODAY" "$TIMESTAMP" << 'PYEOF'
import sys
import os

output_file = sys.argv[1]
today = sys.argv[2]
timestamp = sys.argv[3]

temp_file = f"/tmp/notif_{timestamp}.txt"

if not os.path.exists(temp_file) or os.path.getsize(temp_file) == 0:
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# macOS Notifications\n- Date: {today}\n- Timestamp: {timestamp}\n\n今日无通知记录\n")
    print(f"Exported to {output_file} (no notifications)")
    exit(0)

with open(temp_file, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')[1:]  # Skip header

# Write markdown
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(f"# macOS Notifications Export\n")
    f.write(f"- Date: {today}\n")
    f.write(f"- Timestamp: {timestamp}\n")
    f.write(f"- Total: {len([l for l in lines if '|' in l])} items\n\n")
    f.write(f"## 通知内容\n\n")
    f.write(f"| 时间 | 应用 | 内容 |\n")
    f.write(f"|------|------|------|\n")
    
    for line in lines:
        if '|' in line:
            parts = line.split('|', 2)
            if len(parts) >= 3:
                time = parts[0].strip()
                app = parts[1].strip()
                content = parts[2].strip().replace('|', '\\|')[:100]
                f.write(f"| {time} | {app} | {content} |\n")

# Clean up temp file
os.remove(temp_file)

print(f"Exported to {output_file}")

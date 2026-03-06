#!/bin/bash
# Daily Notification Summary - 每天 23:05 执行，将当日通知摘要写入 daily memory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIF_SCRIPT="$SCRIPT_DIR/read_notifications.py"
MEMORY_DIR="/Users/wutianfu/.openclaw/workspace/memory"
TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="/tmp/notif_summary_$TODAY.txt"

# 读取今日通知（最近 24 小时）
python3 $NOTIF_SCRIPT --hours 24 > "$OUTPUT_FILE" 2>/dev/null

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "今日无通知记录"
    exit 0
fi

# 统计各应用通知数量
python3 << EOF
import re
from collections import Counter

with open("$OUTPUT_FILE", 'r') as f:
    content = f.read()

# 解析通知
apps = []
messages = []
for line in content.strip().split('\n'):
    if '|' in line:
        parts = line.split('|')
        if len(parts) >= 3:
            app = parts[1].strip().split('[')[0].strip()
            msg = parts[2].strip()
            apps.append(app)
            messages.append(msg)

if not apps:
    print("无有效通知")
    exit(0)

# 统计
app_count = Counter(apps)

# 写入每日 memory
memory_file = "$MEMORY_DIR/$TODAY.md"

existing = ""
try:
    with open(memory_file, 'r') as f:
        existing = f.read()
except:
    pass

if "## 今日通知" in existing:
    import re
    pattern = r"## 今日通知[\s\S]*?(?=\n## |\Z)"
    new_section = f"""## 今日通知

- 条数：{len(apps)}
- 应用分布：{', '.join([f'{k}({v})' for k,v in app_count.most_common(10)])}"""
    existing = re.sub(pattern, new_section, existing)
else:
    new_section = f"""

## 今日通知

- 条数：{len(apps)}
- 应用分布：{', '.join([f'{k}({v})' for k,v in app_count.most_common(10)])}

### 重要通知

"""
    # 取前5条非系统通知
    important = [m for m in messages if len(m) > 10][:5]
    new_section += '\n'.join([f"- {m[:100]}" for m in important])
    existing += f"\n{new_section}"

with open(memory_file, 'w') as f:
    f.write(existing)

print(f"已更新 {memory_file}")
print(f"今日通知: {len(apps)} 条")
EOF

rm -f "$OUTPUT_FILE"

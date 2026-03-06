#!/bin/bash
# Work Notification Summary
# 用法：WORK_LOOKBACK_MINUTES=180 ./work-summary.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIF_SCRIPT="$SCRIPT_DIR/read_notifications.py"
WORKSPACE="/Users/wutianfu/.openclaw/workspace"
TODAY=$(date +%Y-%m-%d)
TS=$(date +%Y%m%d-%H%M%S)
LOOKBACK_MINUTES="${WORK_LOOKBACK_MINUTES:-180}"

TMP_RAW="/tmp/work_notif_raw_$TS.txt"
OUT_DIR="$WORKSPACE/memory/$TODAY/computer_io/notification"
OUT_MD="$OUT_DIR/work-summary-$TS.md"

mkdir -p "$OUT_DIR"
python3 "$NOTIF_SCRIPT" --minutes "$LOOKBACK_MINUTES" --output "$TMP_RAW" 2>/dev/null

python3 - "$TMP_RAW" "$OUT_MD" "$LOOKBACK_MINUTES" << 'PYEOF'
import re
import sys
from collections import defaultdict
from pathlib import Path

raw_file = Path(sys.argv[1])
out_file = Path(sys.argv[2])
lookback = sys.argv[3]

work_apps = {
    'Teams': 'teams',
    'Outlook': 'outlook',
    'WeChat': 'wechat',
    'xinwechat': 'wechat',
}

action_kw = [
    '待办', 'todo', 'action item', 'follow up', 'follow-up', '请', '截止', 'deadline',
    'review', '审批', 'approve', '确认', '提醒', '会议', 'meeting', 'sync', 'blocker',
]

lines = []
if raw_file.exists():
    txt = raw_file.read_text(encoding='utf-8', errors='ignore')
    for ln in txt.splitlines():
        if '|' in ln and not ln.startswith('==='):
            lines.append(ln)

by_app = defaultdict(list)
all_work = []
for ln in lines:
    parts = [x.strip() for x in ln.split('|', 2)]
    if len(parts) < 3:
        continue
    t, app, msg = parts
    app_norm = app.lower()

    selected = None
    for k, v in work_apps.items():
        if k.lower() in app_norm:
            selected = v
            break

    # 微信只收工作群/工作关键词的通知
    if selected == 'wechat':
        if not re.search(r'联想|Lenovo|项目|会议|CTO|Anwar|Amu|审批|财务|预算|研发|架构', msg, re.I):
            continue

    if selected:
        by_app[selected].append((t, msg))
        all_work.append((t, selected, msg))

# 去重（同 app + msg）
seen = set()
uniq = []
for t, a, m in all_work:
    key = (a, m)
    if key in seen:
        continue
    seen.add(key)
    uniq.append((t, a, m))

# 待处理项识别
pending = []
for t, a, m in uniq:
    mm = m.lower()
    if any(k in mm for k in action_kw):
        pending.append((t, a, m))

out = []
out.append('# 工作通知摘要')
out.append(f'- Lookback: 过去 {lookback} 分钟')
out.append(f'- 总工作通知: {len(uniq)} 条')
out.append('')
out.append('## 渠道分布')
out.append(f"- Teams: {len(by_app.get('teams', []))}")
out.append(f"- Outlook: {len(by_app.get('outlook', []))}")
out.append(f"- WeChat(疑似工作相关): {len(by_app.get('wechat', []))}")
out.append('')
out.append('## 待处理事项（自动提取）')
if pending:
    for t, a, m in pending[:20]:
        out.append(f"- [{t}] ({a}) {m[:180]}")
else:
    out.append('- 暂未识别到明确待处理项')

out.append('')
out.append('## 最近工作通知（去重后）')
if uniq:
    for t, a, m in uniq[:30]:
        out.append(f"- [{t}] ({a}) {m[:180]}")
else:
    out.append('- 无')

out_file.write_text('\n'.join(out) + '\n', encoding='utf-8')
print(str(out_file))
PYEOF

rm -f "$TMP_RAW"
echo "Saved: $OUT_MD"

#!/bin/bash
set -x

# Telegram设置
        TELEGRAM_BOT_TOKEN="8191759378:AAFmzAqPETS3c4zALwC9X3k4H1SfZCX7v6o"
        #TELEGRAM_CHAT_ID="7948679745"
        TELEGRAM_CHAT_ID="-4695443980"

# 时区换算
        indian_time=$(date +'%Y-%m-%d %H:%M:%S')
        timestamp=$(date -d "$indian_time" +%s)
        new_timestamp=$((timestamp + 2*3600 + 30*60))
        cn_time=$(date -d @$new_timestamp +'%Y-%m-%d %H:%M:%S')


# 检查所有挂载点
while read line; do
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//g')
    mount_point=$(echo "$line" | awk '{print $6}')

    if [ "$usage" -ge 85 ]; then
        alert_message="*挂载点*: $mount_point *使用率*: ${usage}%"
    fi
done  <<< "$(df -hP | grep '^/')"

echo "$alert_message"
        echo "tg告警通知"
        message="
        ✅ 【‌磁盘空间不足告警】‌
✔️ 告警信息：$alert_message
🕒 告警时间：${cn_time}
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
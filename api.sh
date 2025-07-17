#!/bin/bash
set -x

base_port=9000
max_port=9999
step=10

# Telegram设置
        TELEGRAM_BOT_TOKEN="8191759378:AAFmzAqPETS3c4zALwC9X3k4H1SfZCX7v6o"
        TELEGRAM_CHAT_ID="7948679745"
        #TELEGRAM_CHAT_ID="-4695443980"

# 时区换算
        indian_time=$(date +'%Y-%m-%d %H:%M:%S')
        timestamp=$(date -d "$indian_time" +%s)
        new_timestamp=$((timestamp + 2*3600 + 30*60))
        cn_time=$(date -d @$new_timestamp +'%Y-%m-%d %H:%M:%S')

# 查找当前所有正在监听的端口（用于我们API）
get_listen_ports() {
    ss -lntp | awk -v base=$base_port -v max=$max_port '
    /LISTEN/ && $4 ~ /:([0-9]+)$/ {
        split($4, a, ":")
        port = a[length(a)]
        if (port >= base && port <= max) print port
    }' | sort -n
}

# 获取当前活跃端口（有 ESTABLISHED 连接的）
get_active_ports() {
    ss -ant | awk -v base=$base_port -v max=$max_port '
    /ESTAB/ && $4 ~ /:([0-9]+)$/ {
        split($4, a, ":")
        port = a[length(a)]
        if (port >= base && port <= max) print port
    }' | sort -n | uniq
}

# 启动一个新进程监听指定端口
start_process() {
    port=$1
    echo "🔼 启动端口 $port"
    cd /www/python/789pay/server/api/
    export RUN_ENV='PRODUTION' && nohup python3 /www/python/789pay/server/api/main.py --port=$port --logfile=api_$port.log >/dev/null 2>&1 &
}

# 停止监听指定端口的进程
stop_process() {
    port=$1
    echo "🔽 停止端口 $port"
    pid=$(lsof -iTCP:$port -sTCP:LISTEN -t 2>/dev/null)
    if [ -n "$pid" ]; then
        kill "$pid"
    fi
}

# === 主逻辑 ===

listen_ports=($(get_listen_ports))
active_ports=($(get_active_ports))

total=${#listen_ports[@]}
used=0

# 统计 active_ports 中有多少是当前 listen_ports 中的
for port in "${listen_ports[@]}"; do
    if [[ " ${active_ports[*]} " =~ " $port " ]]; then
        ((used++))
    fi
done

if [ "$total" -eq 0 ]; then
    echo "⚠️ 当前无进程运行，默认启动第一个 $step 个端口"
    for i in $(seq 0 $((step - 1))); do
        start_process $((base_port + i))
    done
    exit 0
fi

percent=$((100 * used / total))
name="📊 当前使用率: $percent% ($used/$total)"
echo "$name"

# 扩容判断
if [ "$percent" -ge 80 ]; then
    echo "⚠️ 使用率过高，准备扩容 +$step"
    last_port=${listen_ports[-1]}
    for i in $(seq 1 $step); do
        new_port=$((last_port + i))
        if [ "$new_port" -gt "$max_port" ]; then
            echo "⛔ 已达最大端口限制 $max_port，停止扩容"
            break
        fi
        start_process $new_port
    done
message="
✅ 【‌api进程扩容告警】‌
✔️ 端口占用数：$active_ports / $listen_ports
$name
⚠️ 告警信息：使用率过高，准备扩容 +$step
🕒 告警时间：${cn_time}
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
# 缩容判断
elif [ "$percent" -le 20 ] && [ "$total" -gt "$step" ]; then
    echo "🧊 使用率过低，准备缩容 -$step"
    for i in $(seq 1 $step); do
        last_index=$((total - i))
        stop_process ${listen_ports[$last_index]}
    done
message="
✅ 【‌api进程缩容告警】‌
✔️ 端口占用数：$active_ports / $listen_ports
$name
🧊 告警信息：使用率过低，准备缩容 -$step
🕒 告警时间：${cn_time}
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
else
    echo "✅ 使用率正常，无需扩/缩容"
fi

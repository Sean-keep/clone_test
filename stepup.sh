#！/bin/bash
set -x
# Telegram设置
TELEGRAM_BOT_TOKEN="8191759378:AAFmzAqPETS3c4zALwC9X3k4H1SfZCX7v6o"
TELEGRAM_CHAT_ID="-46954439800"

# 时区换算
indian_time=$(date +'%Y-%m-%d %H:%M:%S')
timestamp=$(date -d "$indian_time" +%s)
new_timestamp=$((timestamp + 2*3600 + 30*60))
cn_time=$(date -d @$new_timestamp +'%Y-%m-%d %H:%M:%S')


cd /www/python/dev/api
if git branch -a | grep -q "remotes/origin/$1"; then
  echo "Branch '$1' already exists. Checking out..."
  git checkout "$1"
  git pull > /www/python/dev/api/gitlog1 2>&1
  cat  /www/python/dev/api/gitlog1
else
  echo "Branch '$1' does not exist. Creating and checking out..."
  git checkout testing
  git pull > /www/python/dev/api/gitlog1 2>&1
  cat  /www/python/dev/api/gitlog1
fi
if grep -q "Already" /www/python/dev/api/gitlog1; then
    echo "代码已是最新，无需更新"
else 
        pid=$(ps -ef|grep api/main.py|grep -v grep | awk '{print $2}')
        timeout 10s /www/python/dev/api/venv/bin/python3 -u /www/python/dev/api/main.py > /www/python/dev/api/runlog1 2>&1
        if grep -q "already" /www/python/dev/api/runlog1 || grep -q "password" /www/python/dev/api/runlog1 ||grep -q "服务启动" /www/python/dev/api/runlog1 ; then
                kill $pid
        else
        message="
        🛑  【dev_api构建信息】
        ❌  构建状态：更新成功，但是重启失败
        🕒  构建时间：${cn_time}
        🔗  失败原因：$(sed 's/"/\\"/g' ./runlog1)
                        "
                                        curl -s -X POST \
                                                        -H "Content-Type: application/json" \
                                                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                                                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
        fi
fi

cd /www/python/dev/admin
if git branch -a | grep -q "remotes/origin/$1"; then
  echo "Branch '$1' already exists. Checking out..."
  git checkout "$1"
  git pull > gitlog2 2>&1
else
  echo "Branch '$1' does not exist. Creating and checking out..."
  git checkout testing
  git pull > gitlog2 2>&1
fi
if grep -q "Already" ./gitlog2; then
    echo "代码已是最新，无需更新"
else 
        pid=$(ps -ef|grep admin|grep main.py|grep -v grep | awk '{print $2}')
        timeout 10s /www/python/dev/api/venv/bin/python3 -u /www/python/dev/admin/main.py > runlog2 2>&1
        if grep -q "already" ./runlog2 || grep -q "password" ./runlog2 ||grep -q "服务启动" ./runlog2 ; then
                kill $pid
        else
        message="
        🛑  【dev_api构建信息】
        ❌  构建状态：更新成功，但是重启失败
        🕒  构建时间：${cn_time}
        🔗  失败原因：$(sed 's/"/\\"/g' ./runlog2)
                        "
                                        curl -s -X POST \
                                                        -H "Content-Type: application/json" \
                                                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                                                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
        fi
fi

cd /www/python/dev/merchant
if git branch -a | grep -q "remotes/origin/$1"; then
  echo "Branch '$1' already exists. Checking out..."
  git checkout "$1"
  git pull > gitlog3 2>&1
else
  echo "Branch '$1' does not exist. Creating and checking out..."
  git checkout testing
  git pull > gitlog3 2>&1
fi
if grep -q "Already" ./gitlog3; then
    echo "代码已是最新，无需更新"
else 
        pid=$(ps -ef|grep merchant|grep main.py| awk '{print $2}')
        timeout 10s /www/python/dev/api/venv/bin/python3 -u /www/python/dev/merchant/main.py > ./runlog3 2>&1
        if grep -q "already" ./runlog3 || grep -q "password" ./runlog3 ||grep -q "服务启动" ./runlog3 ; then
                kill $pid
        else
        message="
        🛑  【dev_api构建信息】
        ❌  构建状态：更新成功，但是重启失败
        🕒  构建时间：${cn_time}
        🔗  失败原因：$(sed 's/"/\\"/g' ./runlog1)
                        "
                                        curl -s -X POST \
                                                        -H "Content-Type: application/json" \
                                                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                                                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
        fi
fi
cd /www/python/dev/ospay_frontend/
# 保存当前提交
        OLD_COMMIT=$(git rev-parse HEAD)
        echo -e "当前提交: $OLD_COMMIT"

# 拉取远程
        git fetch origin
        git reset --hard $1

# 最新提交
    NEW_COMMIT=$(git rev-parse HEAD)
    echo -e "最新提交: $NEW_COMMIT"

# 查看变更文件
        echo "变更文件:"
        code=$(git diff --name-only $OLD_COMMIT HEAD)

# code内容判断
        if [ -z "$code" ]; then
                echo "无变更，脚本退出"
                exit 0
        fi

# 前端更新
        if echo "$code" | grep -q "admin"; then
                echo "admin前端需要更新"
                echo "开始构建admin前端"
                cd /www/python/dev/ospay_frontend/admin
                node ./scripts/build.js 789pay prod
                echo "tg告警通知"
                message="
        ✅ 【‌dev_admin前端构建信息】‌
        ✔️ 构建状态：成功
        🕒 构建时间：${cn_time}
        🔢 ‌COMMIT：$NEW_COMMIT
        🔗 修改文件: $code
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
        elif  echo "$code" | grep -q "merchant" ; then
                echo "merchant前端需要更新"
                echo "开始构建merchant前端"
                cd //www/python/dev/ospay_frontend/merchant
                node ./scripts/build.js 789pay prod

                echo "tg告警通知"
                message="
        ✅ 【‌测试环境dev_merchant前端构建信息】‌_merchant前端构建信息】‌
        ✔️ 构建状态：成功
                🔢 ‌COMMIT：$NEW_COMMIT
        🔗 修改文件: $code
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
        fi

exit

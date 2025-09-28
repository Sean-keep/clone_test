#！/bin/bash
set -x

# 时区换算
indian_time=$(date +'%Y-%m-%d %H:%M:%S')
timestamp=$(date -d "$indian_time" +%s)
new_timestamp=$((timestamp + 2*3600 + 30*60))
cn_time=$(date -d @$new_timestamp +'%Y-%m-%d %H:%M:%S')

pid=$(ps -ef|grep $1|grep -v grep |grep -v "process.sh"|awk '{print $2}')
echo $pid
if [ -z "$pid" ]; then
    echo "进程未运行，启动中"
        cd /www/python/dev/api/jobs/
        export RUN_ENV='PRODUTION' 
	nohup /www/python/dev/api/venv/bin/python3 /www/python/dev/api/jobs/$1 > /dev/null 2>&1 &
else
    echo "进程已启动，重启中"
    echo "关闭进程：$pid"
        kill $pid
        export RUN_ENV='PRODUTION' 
	nohup /www/python/dev/api/venv/bin/python3 /www/python/dev/api/jobs/$1 & 
fi

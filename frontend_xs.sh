#!/bin/bash

# Telegram设置
TELEGRAM_BOT_TOKEN="8191759378:AAFmzAqPETS3c4zALwC9X3k4H1SfZCX7v6o"
TELEGRAM_CHAT_ID="-4695443980"

# 时区换算
indian_time=$(date +'%Y-%m-%d %H:%M:%S')
timestamp=$(date -d "$indian_time" +%s)
new_timestamp=$((timestamp + 2*3600 + 30*60))
cn_time=$(date -d @$new_timestamp +'%Y-%m-%d %H:%M:%S')

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 路径设置
SCRIPTS_DIR="/www/cicd/"
REPO_DIR="/www/cicd/"
LOGS_DIR="/www/cicd/logs"
CLIENT_DIR="/www/wwwroot/"


# 日志记录
mkdir -p $LOGS_DIR
LOG_FILE="$LOGS_DIR/789pay-$(date +%Y%m%d).log"

echo "===========================================" 
echo "开始部署前端项目 - $(date)" 
echo "===========================================" 

# 配置信息
ADMIN_PATH="$CLIENT_DIR/admin"
MERCHANT_PATH="$CLIENT_DIR/merchant"
REPO_PATH="$REPO_DIR"  # 代码仓库本地路径
ADMIN_REPO="git@35.241.87.36:root/ospay_frontend.git"  # 替换为实际仓库
BRANCH="master"

    
# 更新代码并记录更改
    echo -e "${GREEN}拉取最新代码...${NC}"
    git fetch --all
    git checkout -f $BRANCH
    git reset --hard origin/$BRANCH
    git pull origin $BRANCH --force
    
# 当前HEAD提交
    CURRENT_COMMIT=$(git rev-parse HEAD)
    echo -e "${GREEN}当前提交: $CURRENT_COMMIT${NC}"
    
# 获取最近的提交记录
    echo -e "${GREEN}最近提交:${NC}"
    git log -3 --pretty=format:"%h - %an, %ar : %s"


# 检查是否有文件变更
CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD 2>/dev/null || echo "admin/ merchant/")
echo -e "${GREEN}变更的文件:${NC}"
echo "$CHANGED_FILES"

# Admin 前端部署
if echo "$CHANGED_FILES" | grep -q "admin/" || [ "$1" = "--force" ]; then
    echo -e "${GREEN}开始构建 Admin 前端...${NC}"
    cd $REPO_PATH/admin
    
    # 构建前端
    echo -e "${GREEN}执行构建...${NC}"
    node ./scripts/build.js 789pay prod

    # 检查构建是否成功
    if [ ! -d "dist" ]; then
        echo -e "${RED}Admin 前端构建失败!${NC}"
        exit 1
    fi
    
    # 备份当前版本
    if [ -d "$ADMIN_PATH" ] && [ "$(ls -A $ADMIN_PATH 2>/dev/null)" ]; then
        echo -e "${GREEN}备份当前 Admin 前端...${NC}"
        BACKUP_FILE="$CLIENT_DIR/admin_backup_$(date +%Y%m%d%H%M%S).tar.gz"
        tar -czf "$BACKUP_FILE" -C $(dirname $ADMIN_PATH) admin || true
        echo -e "${GREEN}备份已保存到 $BACKUP_FILE${NC}"
    fi
    
    # 部署新版本
    echo -e "${GREEN}部署 Admin 前端...${NC}"
    mkdir -p $ADMIN_PATH
    
    # 保存特殊文件（如果存在）
    if [ -f "$ADMIN_PATH/.user.ini" ]; then
        cp "$ADMIN_PATH/.user.ini" /tmp/user.ini.backup
    fi
    
    # 删除旧文件但保留特殊文件
    find $ADMIN_PATH -type f -not -name ".user.ini" -delete
    
    # 复制新文件
    \cp -rf dist/789pay/* $ADMIN_PATH/
    
    # 恢复特殊文件（如果之前存在）
    if [ -f "/tmp/user.ini.backup" ]; then
        cp /tmp/user.ini.backup "$ADMIN_PATH/.user.ini"
        rm /tmp/user.ini.backup
    fi
    
    # 设置权限（排除.user.ini文件）
    find $ADMIN_PATH -type f -not -name ".user.ini" -exec chown www:www {} \;
    find $ADMIN_PATH -type d -exec chown www:www {} \;
    
    echo -e "${GREEN}Admin 前端部署完成!${NC}"
		message="
        ✅ 【‌789pay_admin前端构建信息】‌
        ✔️ 构建状态：成功
        🕒 构建时间：${cn_time}
        🔗 变更记录:$CURRENT_COMMIT 
		$CHANGED_FILES
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" 
                exit 0
	
fi

# Merchant 前端部署
if echo "$CHANGED_FILES" | grep -q "merchant/" || [ "$1" = "--force" ]; then
    echo -e "${GREEN}开始构建 Merchant 前端...${NC}"
    cd $REPO_PATH/merchant
    
    
    # 构建前端
    echo -e "${GREEN}执行构建...${NC}"
    node ./scripts/build.js 789pay prod
    
    # 检查构建是否成功
    if [ ! -d "dist" ]; then
        echo -e "${RED}Merchant 前端构建失败!${NC}"
        exit 1
    fi
    
    # 备份当前版本
    if [ -d "$MERCHANT_PATH" ] && [ "$(ls -A $MERCHANT_PATH 2>/dev/null)" ]; then
        echo -e "${GREEN}备份当前 Merchant 前端...${NC}"
        BACKUP_FILE="$CLIENT_DIR/merchant_backup_$(date +%Y%m%d%H%M%S).tar.gz"
        tar -czf "$BACKUP_FILE" -C $(dirname $MERCHANT_PATH) merchant || true
        echo -e "${GREEN}备份已保存到 $BACKUP_FILE${NC}"
    fi
    
    # 部署新版本
    echo -e "${GREEN}部署 Merchant 前端...${NC}"
    mkdir -p $MERCHANT_PATH
    
    # 保存特殊文件（如果存在）
    if [ -f "$MERCHANT_PATH/.user.ini" ]; then
        cp "$MERCHANT_PATH/.user.ini" /tmp/merchant_user.ini.backup
    fi
    
    # 删除旧文件但保留特殊文件
    find $MERCHANT_PATH -type f -not -name ".user.ini" -delete
    
    # 复制新文件
    \cp -rf dist/789pay/* $MERCHANT_PATH/
    
    # 恢复特殊文件（如果之前存在）
    if [ -f "/tmp/merchant_user.ini.backup" ]; then
        cp /tmp/merchant_user.ini.backup "$MERCHANT_PATH/.user.ini"
        rm /tmp/merchant_user.ini.backup
    fi
    
    # 设置权限（排除.user.ini文件）
    find $MERCHANT_PATH -type f -not -name ".user.ini" -exec chown www:www {} \;
    find $MERCHANT_PATH -type d -exec chown www:www {} \;
    
    echo -e "${GREEN}Merchant 前端部署完成!${NC}"
	message="
        ✅ 【‌789pay_merchant前端构建信息】‌
        ✔️ 构建状态：成功
        🕒 构建时间：${cn_time}
        🔗 变更记录:$CURRENT_COMMIT 
		$CHANGED_FILES
        "
                curl -s -X POST \
                        -H "Content-Type: application/json" \
                        -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${message}\"}" \
                        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" 
                exit 0
fi



echo "===========================================" 
echo "部署流程完成 - $(date)" 
echo "===========================================" 
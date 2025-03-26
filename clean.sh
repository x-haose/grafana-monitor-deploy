#!/bin/bash

# 检查是否存在 .env 文件
if [ ! -f .env ]; then
    echo "❌ 错误：未找到 .env 文件！"
    exit 1
fi

# 加载.env文件
set -a
source .env
set +a

# 检查必需的环境变量
required_vars=(
    "MINIO_ROOT_USER"
    "MINIO_ROOT_PASSWORD"
    "GF_AUTH_ANONYMOUS_ENABLED"
    "GF_AUTH_ANONYMOUS_ORG_ROLE"
    "GF_SECURITY_ADMIN_USER"
    "GF_SECURITY_ADMIN_PASSWORD"
    "GF_USERS_DEFAULT_LANGUAGE"
    "LOKI_READ_PORT"
    "LOKI_WRITE_PORT"
    "LOKI_GATEWAY_PORT"
    "GRAFANA_PORT"
    "ALLOY_PORT"
)

# 检查环境变量是否设置
missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

# 如果有缺失的环境变量，显示错误信息并退出
if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ 错误：以下必需的环境变量未设置："
    printf '%s\n' "${missing_vars[@]}"
    echo "请检查 .env 文件中是否包含这些变量"
    exit 1
fi

echo "⚠️ 警告：此操作将删除所有数据！"
echo "包括："
echo "- Docker 容器和网络"
echo "- Docker 卷数据"
echo "- data 目录中的所有数据"
read -p "是否确定要继续？(y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在停止服务并清理数据..."
    docker compose down -v
    
    if [ $? -eq 0 ]; then
        echo "✅ 服务已停止，Docker资源已清理"
        
        echo "正在清理 data 目录..."
        rm -rf ./data/*
        
        if [ $? -eq 0 ]; then
            echo "✅ data 目录已清理"
            echo "🎉 所有清理工作完成！"
        else
            echo "❌ data 目录清理失败"
            exit 1
        fi
    else
        echo "❌ 服务停止过程中出现错误"
        exit 1
    fi
else
    echo "操作已取消"
fi
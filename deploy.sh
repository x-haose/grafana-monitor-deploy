#!/bin/bash

# 检查是否存在 .env 文件，如果不存在则从示例文件复制
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "正在从 .env.example 创建 .env 文件..."
        cp .env.example .env
        echo "请检查并根据需要修改 .env 文件"
        exit 1
    else
        echo "未找到 .env.example 文件！"
        exit 1
    fi
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

# 创建目录（如果不存在）
mkdir -p config/grafana/dashboards/providers
mkdir -p data

# 将环境变量字符串转换为数组
IFS=',' read -ra DASHBOARD_ARRAY <<< "$DASHBOARD_IDS"

# 下载每个 dashboard
for id in "${DASHBOARD_ARRAY[@]}"; do
    # 去除可能存在的空格
    id=$(echo $id | tr -d ' ')
    echo "正在下载仪表盘 ${id}..."
    wget "https://grafana.com/api/dashboards/${id}/revisions/latest/download" -O "config/grafana/dashboards/providers/${id}.json"
    
    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "仪表盘 ${id} 下载成功"
    else
        echo "仪表盘 ${id} 下载失败"
        exit 1
    fi
done

# 启动 docker compose
echo "正在启动 docker compose..."
docker compose up -d

# 检查服务是否成功启动
if [ $? -eq 0 ]; then
    echo -e "\n========== 服务信息 ==========\n"
    
    echo "🌟 服务已成功启动！以下是访问地址："

    # 函数：检查端口格式并生成访问URL提示
    check_port_and_print() {
        local service_name=$1
        local port_var=$2
        local port_value=${!port_var}
        local emoji=$3

        echo -e "\n$emoji $service_name:"
        if [[ $port_value == *"127.0.0.1"* ]] || [[ $port_value == *"localhost"* ]]; then
            echo "   http://${port_value}"
            echo "   ⚠️ 注意：此服务仅配置为本地访问"
            echo "   如需外部访问，请配置域名和反向代理"
        else
            echo "   http://127.0.0.1:${port_value}"
            echo "   http://localhost:${port_value}"
        fi
    }

    # Grafana
    check_port_and_print "Grafana 仪表盘" "GRAFANA_PORT" "📊"
    echo "   用户名：${GF_SECURITY_ADMIN_USER}"
    echo "   密码：${GF_SECURITY_ADMIN_PASSWORD}"
    
    # Loki Gateway
    check_port_and_print "Loki 网关" "LOKI_GATEWAY_PORT" "📝"
    
    # Loki Read API
    check_port_and_print "Loki 读取接口" "LOKI_READ_PORT" "📡"
    
    # Loki Write API
    check_port_and_print "Loki 写入接口" "LOKI_WRITE_PORT" "📤"
    
    # Alloy Metrics
    check_port_and_print "Alloy 指标" "ALLOY_PORT" "🔍"
    
    echo -e "\n💡 使用提示："
    echo "- Grafana 仪表盘已自动导入"
    echo "- 查看日志请使用：docker compose logs -f"
    echo "- 监控容器状态：docker compose ps"
    echo "- 启动服务：./start.sh"
    echo "- 停止服务：./stop.sh"
    echo "- 完全清理：./clean.sh"
        
    echo -e "\n========================================"
else
    echo "❌ 错误：服务启动失败"
    echo "请使用以下命令查看日志：docker compose logs"
    exit 1
fi
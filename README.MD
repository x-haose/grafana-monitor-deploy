# Grafana Loki 监控系统

一个基于 Grafana、Loki、Prometheus 的完整日志和监控解决方案。

## 功能特点

- 📊 Grafana 仪表盘可视化
- 📝 Loki 日志聚合
- 📈 Prometheus 指标监控
- 🔍 容器和主机监控
- 🚀 一键部署和管理

## 系统架构

- **Grafana**: 数据可视化平台
- **Loki**: 日志聚合系统
  - Read Node: 日志读取节点
  - Write Node: 日志写入节点
  - Backend: 后端处理节点
  - Gateway: 网关节点
- **Prometheus**: 指标监控系统
- **Node Exporter**: 主机指标收集
- **cAdvisor**: 容器指标收集
- **Alloy**: Grafana 日志收集器
- **MinIO**: 对象存储后端

## 快速开始

### 前置要求

- Docker Engine
- Docker Compose
- wget

### 安装步骤

1. 克隆仓库：
```bash
git clone https://github.com/x-haose/grafana-monitor-deploy.git
cd grafana-monitor-deploy
```

2. 配置环境变量：
```bash
cp .env.example .env
# 根据需要修改 .env 文件中的配置
```

3. 首次部署：
```bash
chmod +x *.sh        # 添加执行权限
./deploy.sh          # 部署服务
```

### 日常操作

```bash
./start.sh          # 启动服务
./stop.sh           # 停止服务
./clean.sh          # 清理所有数据（谨慎使用）
```

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Grafana | 40020 | 仪表盘界面 |
| Loki Gateway | 40010 | 日志网关 |
| Loki Read | 40011 | 日志读取接口 |
| Loki Write | 40012 | 日志写入接口 |
| Alloy UI | 40030 | 日志收集器界面 |

## 预配置仪表盘

系统预置了以下 Grafana 仪表盘：

| 仪表盘 | ID | 说明 |
|--------|-----|------|
| Node Exporter Full | 1860 | 主机监控指标 |
| Cadvisor Exporter | 14282 | 容器监控指标 |
| PostgreSQL Exporter | 14114 | PostgreSQL 监控 |
| Redis Dashboard | 11835 | Redis 监控 |

## 访问地址

- Grafana: http://127.0.0.1:40020
  - 默认用户名：admin
  - 默认密码：admin
- Loki Gateway: http://127.0.0.1:40010
- Loki Read: http://127.0.0.1:40011/ready
- Loki Write: http://127.0.0.1:40012/ready
- Alloy UI: http://127.0.0.1:40030

## 配置说明

### 环境变量配置

主要配置项（在 .env 文件中）：
- `DASHBOARD_IDS`: Grafana 仪表盘 ID
- 各服务端口配置
- Grafana 和 MinIO 的访问凭据

### 数据持久化

所有数据存储在 `./data` 目录下：
- `./data/grafana`: Grafana 数据
- `./data/minio`: MinIO 数据（Loki 存储）
- `./data/prometheus`: Prometheus 数据

## 注意事项

1. 默认配置为本地访问模式（127.0.0.1），如需外部访问：
   - 修改 .env 中的端口配置
   - 配置适当的域名和反向代理
   - 注意设置安全的访问控制

2. 数据备份：
   - 定期备份 `./data` 目录
   - 使用 `clean.sh` 前确保数据已备份

## 故障排查

常见问题处理：
```bash
# 查看服务状态
docker compose ps

# 查看服务日志
docker compose logs -f [服务名]

# 重启特定服务
docker compose restart [服务名]
```

## 相关文档

- [Grafana 文档](https://grafana.org.cn/docs/grafana/latest/)
- [Loki 文档](https://grafana.org.cn/docs/loki/latest/get-started/quick-start)
- [Grafana Alloy 文档](https://grafana.org.cn/docs/alloy/latest/)

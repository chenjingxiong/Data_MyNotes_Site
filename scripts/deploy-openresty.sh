#!/bin/bash

# 部署到 OpenResty 服务器的脚本
# 用法: ./scripts/deploy-openresty.sh [环境]
# 环境参数: dev, staging, prod (默认: prod)

set -e

# 配置变量（可以从环境变量或配置文件读取）
SERVER_HOST="${SERVER_HOST:-}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_USER="${SERVER_USER:-root}"
DEPLOY_PATH="${DEPLOY_PATH:-/usr/local/openresty/nginx/html/mynotes}"
BACKUP_PATH="${BACKUP_PATH:-/var/backups/mynotes}"
SITE_NAME="${SITE_NAME:-mynotes}"
NGINX_USER="${NGINX_USER:-nginx}"
NGINX_RELOAD_CMD="${NGINX_RELOAD_CMD:-/usr/local/openresty/nginx/sbin/nginx -s reload}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必需的变量
check_required_vars() {
    if [ -z "$SERVER_HOST" ]; then
        log_error "SERVER_HOST 环境变量未设置"
        exit 1
    fi

    log_info "配置信息:"
    log_info "  服务器: $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    log_info "  部署路径: $DEPLOY_PATH"
    log_info "  备份路径: $BACKUP_PATH"
}

# 构建
build() {
    log_info "开始构建..."
    pnpm run docs:build
    log_info "构建完成"
}

# 部署
deploy() {
    log_info "开始部署到服务器..."

    # 压缩构建产物
    log_info "压缩构建产物..."
    cd .vitepress/dist
    tar -czf ../../dist.tar.gz *
    cd ../..

    # 上传到服务器
    log_info "上传文件到服务器..."
    scp -P $SERVER_PORT dist.tar.gz $SERVER_USER@$SERVER_HOST:/tmp/

    # 在服务器上执行部署
    log_info "在服务器上执行部署..."
    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST << ENDSSH
        # 创建备份目录
        mkdir -p $BACKUP_PATH

        # 备份当前版本
        if [ -d "$DEPLOY_PATH" ]; then
            BACKUP_NAME="$SITE_NAME-\$(date +%Y%m%d_%H%M%S)"
            echo "备份当前版本到 \$BACKUP_PATH/\$BACKUP_NAME"
            cp -r $DEPLOY_PATH \$BACKUP_PATH/\$BACKUP_NAME

            # 只保留最近 10 个备份
            cd $BACKUP_PATH
            ls -t $SITE_NAME-* | tail -n +11 | xargs -r rm -rf
        fi

        # 创建部署目录
        mkdir -p $DEPLOY_PATH

        # 解压新版本
        echo "解压新版本..."
        tar -xzf /tmp/dist.tar.gz -C $DEPLOY_PATH

        # 清理临时文件
        rm /tmp/dist.tar.gz

        # 设置权限
        chown -R $NGINX_USER:$NGINX_USER $DEPLOY_PATH
        chmod -R 755 $DEPLOY_PATH

        echo "部署完成!"
ENDSSH

    # 清理本地临时文件
    rm -f dist.tar.gz

    log_info "部署成功!"
}

# 回滚
rollback() {
    log_info "开始回滚..."

    BACKUP_VERSION=${1:-""}

    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST << ENDSSH
        cd $BACKUP_PATH

        if [ -z "$BACKUP_VERSION" ]; then
            # 列出可用备份
            echo "可用备份:"
            ls -lt $SITE_NAME-* | head -10
            echo ""
            echo "请使用: ./scripts/deploy-openresty.sh rollback <备份名称>"
            exit 0
        fi

        if [ ! -d "$BACKUP_VERSION" ]; then
            echo "备份不存在: $BACKUP_VERSION"
            exit 1
        fi

        echo "回滚到备份: $BACKUP_VERSION"
        rm -rf $DEPLOY_PATH/*
        cp -r $BACKUP_VERSION/* $DEPLOY_PATH/

        # 重载 Nginx
        $NGINX_RELOAD_CMD

        echo "回滚完成!"
ENDSSH

    log_info "回滚完成!"
}

# 主函数
main() {
    check_required_vars

    case "${1:-deploy}" in
        deploy)
            build
            deploy
            ;;
        rollback)
            rollback $2
            ;;
        build-only)
            build
            log_info "构建完成，跳过部署"
            ;;
        *)
            echo "用法: $0 {deploy|rollback|build-only} [备份名称]"
            echo ""
            echo "命令:"
            echo "  deploy       - 构建并部署到服务器 (默认)"
            echo "  rollback     - 回滚到指定备份"
            echo "  build-only   - 仅构建，不部署"
            echo ""
            echo "环境变量:"
            echo "  SERVER_HOST  - 服务器地址 (必需)"
            echo "  SERVER_PORT  - SSH 端口 (默认: 22)"
            echo "  SERVER_USER  - SSH 用户 (默认: root)"
            echo "  DEPLOY_PATH  - 部署路径"
            echo "  BACKUP_PATH  - 备份路径"
            exit 1
            ;;
    esac
}

main "$@"

# 部署说明文档

本文档介绍如何配置和使用自动部署功能。

## 目录

- [GitHub Pages 部署](#github-pages-部署)
- [OpenResty 服务器部署](#openresty-服务器部署)
- [本地部署](#本地部署)
- [故障排查](#故障排查)

---

## GitHub Pages 部署

### 1. 启用 GitHub Pages

1. 进入 GitHub 仓库设置页面
2. 导航到 **Settings** > **Pages**
3. 在 **Source** 下选择 **GitHub Actions**

### 2. 配置工作流

工作流文件位于 [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml)

**触发条件:**
- 推送到 `main` 分支
- 手动触发 (workflow_dispatch)

### 3. 部署流程

1. 检出代码和 submodule
2. 安装依赖 (pnpm)
3. 构建 VitePress
4. 部署到 GitHub Pages

### 4. 访问网站

部署完成后，网站可通过以下地址访问:
```
https://<username>.github.io/<repository>/
```

---

## OpenResty 服务器部署

### 1. 配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets (**Settings** > **Secrets and variables** > **Actions**):

| Secret 名称 | 说明 | 示例值 |
|-----------|------|--------|
| `SSH_PRIVATE_KEY` | SSH 私钥 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `SSH_PORT` | SSH 端口 | `22` |
| `SSH_USER` | SSH 用户名 | `root` |
| `SERVER_HOST` | 服务器地址 | `example.com` |
| `DEPLOY_PATH` | 部署路径 | `/usr/local/openresty/nginx/html/mynotes` |
| `BACKUP_PATH` | 备份路径 | `/var/backups/mynotes` |
| `SITE_NAME` | 网站名称 | `mynotes` |
| `NGINX_USER` | Nginx 运行用户 | `nginx` |
| `NGINX_TEST_CMD` | Nginx 测试命令 | `/usr/local/openresty/nginx/sbin/nginx -t` |
| `NGINX_RELOAD_CMD` | Nginx 重载命令 | `/usr/local/openresty/nginx/sbin/nginx -s reload` |

### 2. 生成 SSH 密钥

在本地机器上生成 SSH 密钥对:

```bash
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions
```

将公钥添加到服务器的 `authorized_keys`:

```bash
ssh-copy-id -i ~/.ssh/github_actions.pub user@your-server.com
```

将私钥内容添加到 GitHub Secrets `SSH_PRIVATE_KEY`:

```bash
cat ~/.ssh/github_actions
```

### 3. 配置 Nginx

参考 [nginx.conf.example](nginx.conf.example) 配置 Nginx:

```bash
# 复制配置文件
sudo cp nginx.conf.example /usr/local/openresty/nginx/conf/conf.d/mynotes.conf

# 修改配置文件
sudo nano /usr/local/openresty/nginx/conf/conf.d/mynotes.conf

# 测试配置
sudo /usr/local/openresty/nginx/sbin/nginx -t

# 重载 Nginx
sudo /usr/local/openresty/nginx/sbin/nginx -s reload
```

### 4. 工作流程

1. 推送到 `main` 分支自动触发部署
2. 检出代码和 submodule
3. 安装依赖并构建
4. 备份当前版本
5. 部署新版本
6. 重载 Nginx

---

## 本地部署

### 1. 配置环境变量

复制 `.env.example` 为 `.env` 并填写实际值:

```bash
cp .env.example .env
nano .env
```

### 2. 部署命令

```bash
# 完整部署 (构建 + 部署)
npm run deploy:openresty

# 仅构建
npm run deploy:openresty:build

# 回滚到上一个备份
npm run rollback:openresty
```

### 3. 直接使用脚本

```bash
# 部署
bash scripts/deploy-openresty.sh deploy

# 回滚
bash scripts/deploy-openresty.sh rollback mynotes-20250210_120000

# 仅构建
bash scripts/deploy-openresty.sh build-only
```

---

## 故障排查

### GitHub Pages 部署失败

1. **检查 Pages 设置**: 确保在仓库设置中启用了 GitHub Actions 作为 Source
2. **检查 Actions 权限**: 确保 workflow 有正确的权限设置
3. **查看构建日志**: 在 Actions 页面查看详细的错误信息

### OpenResty 部署失败

1. **SSH 连接问题**
   ```bash
   # 测试 SSH 连接
   ssh -p <PORT> <USER>@<HOST>
   ```

2. **权限问题**
   ```bash
   # 确保 Nginx 用户有权限访问部署目录
   sudo chown -R nginx:nginx /usr/local/openresty/nginx/html/mynotes
   sudo chmod -R 755 /usr/local/openresty/nginx/html/mynotes
   ```

3. **Nginx 配置错误**
   ```bash
   # 测试 Nginx 配置
   sudo /usr/local/openresty/nginx/sbin/nginx -t

   # 查看 Nginx 错误日志
   sudo tail -f /var/log/nginx/error.log
   ```

4. **Submodule 初始化问题**
   ```bash
   # 确保 submodule 已初始化
   git submodule update --init --recursive
   ```

### 本地部署问题

1. **脚本权限问题**
   ```bash
   chmod +x scripts/deploy-openresty.sh
   ```

2. **环境变量未加载**
   ```bash
   # 使用 source 加载环境变量
   source .env
   npm run deploy:openresty
   ```

---

## 常见问题

### Q: 如何同时部署到 GitHub Pages 和 OpenResty?

A: 两个工作流都会在推送到 `main` 分支时触发，自动同时部署。

### Q: 如何禁用自动部署?

A: 删除或重命名对应的工作流文件，或在工作流文件中移除触发条件。

### Q: 如何回滚部署?

A: 本地回滚使用 `npm run rollback:openresty`，服务器上可以手动恢复备份。

### Q: 备份保留多久?

A: 脚本默认保留最近 10 个备份，可在 `scripts/deploy-openresty.sh` 中修改。

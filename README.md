# Cloudflare 多线程测速脚本

这是一个基于 `bash` 的轻量测速工具，使用 Cloudflare 官方测速文件进行 **单线程** 和 **多线程** 下载速度测试。多线程模式使用 `aria2c` 实现高速并发下载。

📦 仓库地址：https://github.com/csznet/speedtest

## ✨ 功能特点

- ✅ 使用 Cloudflare 1GB 文件测速，真实可靠
- ✅ 支持单线程（`wget`）与多线程（`aria2c`）测速
- ✅ 自动检测并安装所需依赖（`wget`、`bc`、`aria2c`）
- ✅ 测试结束后自动清理下载文件
- ✅ 输出美观，单位清晰（MB/s）

## ⚙️ 所需依赖

- `wget`
- `bc`
- `aria2c`

脚本会自动检查并安装以上依赖，支持以下 Linux 发行版：

- Debian / Ubuntu / Proxmox
- CentOS / RHEL / Rocky
- Alpine

> 如果你不是 root 用户，请手动安装依赖后执行脚本。

## 🚀 一键运行测速

使用以下命令一键运行测速（无需手动 clone）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/csznet/speedtest/main/run.sh)
```

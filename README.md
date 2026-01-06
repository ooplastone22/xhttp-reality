README.md（示例）
# xHTTP + REALITY Auto Installer

> 一个用于快速部署 **xHTTP（上行，经 Cloudflare CDN） + REALITY（下行，直连）**
> 的 Xray 自动化脚本，适合需要兼顾 **隐匿性与性能** 的场景。

---

## ✨ 特性

- 🚀 一键部署 Xray（Debian / Ubuntu）
- 🔀 同时启用：
  - xHTTP inbound（适合走 CDN，上行伪装）
  - REALITY inbound（直连，低延迟高吞吐）
- 📦 自动生成客户端分享链接（v2rayN / sing-box）
- 🧹 支持一键卸载
- 🛠 适合自用 / 进阶用户二次修改


---

## 📦 支持系统

- Debian 10+
- Ubuntu 20.04 / 22.04
- 需要 `root` 权限

---

## 🚀 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/ooplastone22/xhttp-reality/refs/heads/main/xhttp-reality.sh | bash -s install your.domain.com


参数说明：

install：安装并启动

your.domain.com：用于客户端配置的域名（Cloudflare 为vps解析过的域名）

安装完成后，客户端链接会输出到终端，并保存在：

/usr/local/etc/xray/client-link.txt

🧹 卸载
```bash
curl -fsSL https://raw.githubusercontent.com/ooplastone22/xhttp-reality/refs/heads/main/xhttp-reality.sh | bash -s uninstall

📁 文件结构
xhttp-reality.sh   # 主安装脚本
README.md

🔐 安全说明

本项目不会上传任何信息

所有配置仅生成并保存在本地

建议自行检查脚本内容后使用

📜 License

MIT License

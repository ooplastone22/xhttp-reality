# Xray xhttp + Reality + Cloudflare 一键脚本

## 特性
- xhttp 上行走 Cloudflare CDN
- Reality 下行直连
- 支持 Debian / Ubuntu
- 支持 amd64 / arm64
- 自动生成分享链接与订阅
- 支持一键卸载

## 架构
客户端
  ├─ 上行：xhttp → Cloudflare → VPS:80
  └─ 下行：reality → VPS:443

# 安装

bash xray-xhttp-reality.sh install <CF_DOMAIN>

# 示例：

bash xray-xhttp-reality.sh install xh.example.com

# 卸载
bash xray-xhttp-reality.sh uninstall

# 客户端

v2rayN：导入 vless:// 或 Base64 订阅

sing-box：使用 client-singbox.json

Clash Meta：使用 client-clash.yaml

# 注意事项（Cloudflare）

代理仅回源 80 / 443

xhttp 监听必须是 80 或通过 443 fallback




---

# ④ 增加 `--print-link / --status`（运维级增强）

## 1️⃣ print-link

print_link() {
  cat "$XRAY_DIR/client-link.txt"
  exit 0
}

2️⃣ status
status_xray() {
  systemctl status xray --no-pager
  exit 0
}

3️⃣ 接入到 case
case "$ACTION" in
  install)
    install_xray
    ;;
  uninstall)
    uninstall_xray
    ;;
  print-link)
    print_link
    ;;
  status)
    status_xray
    ;;
  *)
    echo "用法:"
    echo "  install <CF_DOMAIN>"
    echo "  uninstall"
    echo "  print-link"
    echo "  status"
    exit 1
    ;;
esac

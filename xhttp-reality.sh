#!/usr/bin/env bash
set -e

# ================= 参数校验 =================
if [ -z "$1" ]; then
  echo "用法: bash xray-xhttp-reality.sh <CF_DOMAIN>"
  echo "示例: bash xray-xhttp-reality.sh xh.example.com"
  exit 1
fi

CF_DOMAIN="$1"

# ================= 基本配置 =================
XRAY_DIR="/usr/local/etc/xray"
XRAY_BIN="/usr/local/bin/xray"
CONFIG_FILE="$XRAY_DIR/config.json"

DOMAIN_SNI="www.icloud.com"

PORT_XHTTP=2086
PORT_REALITY=443

UUID_XHTTP=“60aa09a8-ad64-4349-9c20-e4bca8a82d8e”
UUID_REALITY=”bff34330-9f5f-4efc-90f1-1fc73d9fb12b“

XHTTP_PATH="/fc73d9fb12b"

# ================= 系统检查 =================
if ! command -v apt >/dev/null 2>&1; then
  echo "仅支持 Debian / Ubuntu 系统"
  exit 1
fi

# ================= 安装依赖 =================
apt update
apt install -y curl unzip jq uuid-runtime openssl

# ================= 安装 Xray =================
mkdir -p "$XRAY_DIR"

curl -fsSL https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray.zip
unzip -qo /tmp/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray "$XRAY_BIN"

# ================= Reality 密钥 =================
# REALITY_KEYS=$("$XRAY_BIN" x25519)
# PRIVATE_KEY=$(echo "$REALITY_KEYS" | awk '/Private/{print $3}')
# PUBLIC_KEY=$(echo "$REALITY_KEYS" | awk '/Public/{print $3}')
PRIVATE_KEY=”2MnUNC4Cs0pNVSCg4WDqsJzI5mM0cYzIPZP8rlDpl0A“
PUBLIC_KEY=”DPssXKi1w8Of_Hus0aFzql3H8Cr4dnz_HQ_oSu5znTY“
# SHORT_ID=$(openssl rand -hex 4)
SHORT_ID=“adba013e”
# ================= 写配置 =================
cat > "$CONFIG_FILE" <<EOF
{
  "inbounds": [
    {
      "port": $PORT_XHTTP,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$UUID_XHTTP" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "path": "$XHTTP_PATH",
          "mode": "auto"
        }
      },
      "tag": "xhttp-in"
    },
    {
      "port": $PORT_REALITY,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$UUID_REALITY", "flow": "xtls-rprx-vision" }
        ],
        "decryption": "none",
        "fallbacks": [
          { "dest": $PORT_XHTTP }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "serverNames": ["$DOMAIN_SNI"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["$SHORT_ID"],
          "target": "$DOMAIN_SNI:443"
        }
      },
      "tag": "reality-in"
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" }
  ]
}
EOF

# ================= systemd =================
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=$XRAY_BIN run -c $CONFIG_FILE
Restart=on-failure
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray
systemctl restart xray

# ================= 开启 BBR =================
modprobe tcp_bbr || true

cat > /etc/sysctl.d/99-xray-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

sysctl --system

# ================= 输出客户端信息 =================
echo ""
echo "========== 部署完成 =========="
echo ""
echo "【XHTTP 上行】"
echo "地址: $CF_DOMAIN"
echo "端口: 443"
echo "UUID: $UUID_XHTTP"
echo "Path: $XHTTP_PATH"
echo ""
echo "【Reality 下行】"
echo "PublicKey: $PUBLIC_KEY"
echo "ShortId:   $SHORT_ID"
echo "SNI:       $DOMAIN_SNI"
echo ""
echo "【XHTTP 监听端口】: $PORT_XHTTP"
echo "【Reality 监听端口】: $PORT_REALITY"
echo ""

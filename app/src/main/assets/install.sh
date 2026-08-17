#!/bin/bash
set -e
API_KEY="@@API_KEY@@"
BASE_URL="@@BASE_URL@@"
MODEL="@@MODEL@@"
PORT="@@PORT@@"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export DEBIAN_FRONTEND=noninteractive
if [ -z "$API_KEY" ]; then echo "!! 未配置 API key"; exit 1; fi
echo "==> [1/4] apt update" && apt-get update -y >/dev/null 2>&1 || true
echo "==> [2/4] 安装 Python" && apt-get install -y python3 python3-pip curl >/dev/null 2>&1
echo "==> [3/4] 安装 OpenSquilla"
pip3 install --no-deps opensquilla 2>/dev/null || true
pip3 install aiosqlite anyio httpx jinja2 pyyaml typer rich structlog uvicorn starlette click websockets pydantic-settings 2>/dev/null || true
echo "==> [4/4] 写入配置"
mkdir -p /root/.opensquilla
cat > /root/.opensquilla/config.toml << CFG
[llm]
provider = "openai"
model = "$MODEL"
api_key = "$API_KEY"
base_url = "$BASE_URL"
[squilla_router]
enabled = true
default_tier = "t1"
[squilla_router.tiers.t0] provider = "openai" model = "$MODEL"
[squilla_router.tiers.t1] provider = "openai" model = "$MODEL"
[squilla_router.tiers.t2] provider = "openai" model = "$MODEL"
[squilla_router.tiers.t3] provider = "openai" model = "$MODEL"
CFG
cat > /root/start.sh << 'GO'
#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export HOME="/root"
pkill -f 'opensquilla gateway' 2>/dev/null; sleep 1
cd /root && opensquilla gateway start --json
GO
chmod +x /root/start.sh
echo "完成！端口 18791 | 启动: bash /root/start.sh"

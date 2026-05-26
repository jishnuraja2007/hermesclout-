#!/bin/bash
# Hermes Cloud Agent - Auto-Start Script
# Runs on Render.com (or any Docker container)

set -e

echo "========================================="
echo "  🧠 Hermes Agent - Cloud Bootup"
echo "========================================="

# Ensure Hermes config directory exists
mkdir -p $HERMES_HOME

# Setup minimal Hermes config if missing
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    echo "Setting up Hermes config..."
    cat > $HERMES_HOME/config.yaml <<'CONFIG'
model:
  provider: openrouter
  default: openrouter/quasar-alpha

gagent:
  max_turns: 90

memory:
  memory_enabled: true
  user_profile_enabled: true

compression:
  enabled: true
  threshold: 0.50
  target_ratio: 0.20

display:
  tool_progress: true
  show_cost: false

tts:
  provider: edge

stt:
  enabled: true
  provider: local

security:
  approvals:
    mode: smart
CONFIG
fi

echo "🔑 API keys loaded from env vars"
echo "🤖 Starting Hermes Gateway..."

# Start Hermes gateway in background
$HOME/.local/bin/hermes gateway run &
GATEWAY_PID=$!

# Wait for gateway to init
sleep 8

echo "🌐 Starting health check server..."
python3 /home/hermes/web_health.py &
HEALTH_PID=$!

echo "========================================="
echo "✅ Hermes Agent is LIVE"
echo "========================================="
echo "Gateway PID: $GATEWAY_PID"
echo "Health  PID: $HEALTH_PID"
echo ""
echo "Health check: http://0.0.0.0:10000/health"
echo ""

# Wait for both processes
wait $GATEWAY_PID $HEALTH_PID

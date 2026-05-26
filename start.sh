#!/bin/bash
# Hermes Agent - Cloud Start Script
# Runs on Render.com

set -e

echo "========================================="
echo "  🧠 Hermes Agent - Starting"
echo "========================================="

# Ensure Hermes home directory exists
mkdir -p $HERMES_HOME

# Write a minimal config if none exists
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    echo "Writing config..."
    cat > $HERMES_HOME/config.yaml <<EOF
model:
  provider: ollama
  default: ${HERMES_MODEL:-llama3.2}
  api_key: ${OLLAMA_API_KEY:-}

agent:
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
EOF
fi

echo "🤖 Starting Hermes Gateway..."

# Start Hermes gateway in background
$HOME/.local/bin/hermes gateway run &
GATEWAY_PID=$!

# Wait for gateway to init
sleep 8

echo "🌐 Starting Health Server..."
python3 /home/hermes/web_health.py &
HEALTH_PID=$!

echo "========================================="
echo "✅ Hermes Agent is LIVE"
echo "========================================="
echo "Gateway PID: $GATEWAY_PID"
echo "Health  PID: $HEALTH_PID"
echo ""
echo "Health check: http://0.0.0.0:${PORT:-10000}/health"
echo ""

# Keep running
wait $GATEWAY_PID $HEALTH_PID

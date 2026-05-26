#!/bin/bash
# Hermes Cloud Agent - Auto-Start Script
# Runs on Render.com (or any Docker container)

set -e

echo "========================================="
echo "  🧠 Hermes Agent - Cloud Bootup"
echo "========================================="

# Ensure Hermes config directory exists
mkdir -p $HERMES_HOME

# Determine provider and settings
API_KEY=${OLLAMA_API_KEY:-$LLM_API_KEY}
OLLAMA_URL=${OLLAMA_HOST:-""}

echo "🔑 API Key loaded (provider: Ollama)"

# Setup minimal Hermes config if missing
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    echo "Setting up Hermes config..."
    
    cat > $HERMES_HOME/config.yaml <<CONFIG
model:
  provider: ollama
  default: ${HERMES_MODEL:-llama3.2}
  api_key: ${API_KEY}
  $(if [ -n "$OLLAMA_URL" ]; then echo "  base_url: ${OLLAMA_URL}"; fi)

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
CONFIG
fi

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

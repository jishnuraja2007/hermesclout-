#!/bin/bash
# Hermes Agent - Cloud Start Script for Render (Python Native)

set -e

echo "========================================="
echo "  🧠 Hermes Agent - Cloud Bootup"
echo "========================================="

# Install Hermes if not already installed
pip install hermes-agent[messaging] 2>/dev/null || true

# Ensure Hermes home directory exists
mkdir -p $HERMES_HOME

# Write minimal config if missing
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    echo "Writing config..."
    cat > $HERMES_HOME/config.yaml <<EOF
model:
  provider: ollama
  default: ${HERMES_MODEL:-llama3.2}
  api_key: ${OLLAMA_API_KEY:-}
  $(if [ -n "$OLLAMA_HOST" ]; then echo "  base_url: $OLLAMA_HOST"; fi)

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

# Start health check server in background
echo "🌐 Starting health server..."
python app.py &
HEALTH_PID=$!

# Wait a moment
sleep 3

# Start Hermes gateway
echo "🤖 Starting Hermes Gateway..."
hermes gateway run &
GATEWAY_PID=$!

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

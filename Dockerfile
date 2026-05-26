FROM python:3.11-slim

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl build-essential ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create hermes user
RUN useradd -m -s /bin/bash hermes
USER hermes
WORKDIR /home/hermes

# Install Hermes Agent
RUN pip install --user hermes-agent flask

# Copy app files
COPY start.sh /home/hermes/start.sh
COPY web_health.py /home/hermes/web_health.py

# Make executable
RUN chmod +x /home/hermes/start.sh

# Expose health check port
EXPOSE 10000

# Start
CMD ["/bin/bash", "/home/hermes/start.sh"]

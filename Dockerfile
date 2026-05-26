FROM python:3.11-slim

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl build-essential ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create hermes user
RUN useradd -m -s /bin/bash hermes
USER hermes
WORKDIR /home/hermes

# Install Hermes
RUN pip install --user hermes-agent

# Copy config
COPY .hermes/ /home/hermes/.hermes/
COPY start.sh /home/hermes/start.sh
COPY web_health.py /home/hermes/web_health.py
COPY render.yaml /home/hermes/render.yaml

# Make executable
RUN chmod +x /home/hermes/start.sh

# Install health check web server deps
RUN pip install --user flask

# Expose health check port
EXPOSE 10000

# Start both gateway and health check
CMD ["/bin/bash", "/home/hermes/start.sh"]

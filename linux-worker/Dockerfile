FROM debian:bookworm-slim

# Use distribution-matched Chromium, ChromeDriver and Selenium together.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    binutils build-essential ca-certificates chromium chromium-driver cmake curl \
    file fonts-dejavu fonts-liberation git jq less libimage-exiftool-perl \
    libreoffice-calc libreoffice-impress libreoffice-writer make ninja-build \
    nodejs npm pandoc pkg-config poppler-utils procps python3 python3-docx \
    python3-openpyxl python3-pil python3-pip python3-selenium python3-venv \
    ripgrep sqlite3 sudo unzip xauth xdotool xterm xvfb zip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash worker \
    && echo 'worker ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/worker \
    && chmod 0440 /etc/sudoers.d/worker \
    && visudo -cf /etc/sudoers.d/worker

USER worker
WORKDIR /home/worker

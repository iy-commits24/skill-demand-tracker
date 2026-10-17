# Base image 
FROM python:3.13-slim
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

ENV UV_INSTALL_DIR="/usr/local/bin"

ADD https://astral.sh/uv/0.13.0/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

COPY pyproject.toml . 
COPY uv.lock .
COPY .python-version .

RUN uv sync --locked --no-dev --no-install-project 

# Install project and run container
COPY . .
RUN uv sync --locked --no-dev

RUN useradd -m app
USER app

EXPOSE 8000
CMD ["uv", "run", "--no-sync", "fastapi", "run", "src/tracker/main.py", "--host", "0.0.0.0", "--port", "8000"]

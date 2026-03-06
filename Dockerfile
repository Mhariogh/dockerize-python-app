# ============================================
# Dockerize Python App Challenge
# ============================================
#
# YOUR TASK: Create a production-ready Dockerfile
#
# Requirements:
# 1. Use multi-stage build (builder + final stages)
# 2. Final image must be under 200MB
# 3. Run as non-root user (security)
# 4. Include a health check
# 5. Use python:3.11-slim for the final image
#
# Hints:
# - Stage 1 (builder): Install dependencies
# - Stage 2 (final): Copy only what's needed
# - Use --prefix=/install with pip to control where packages go
# - Create a user with: RUN useradd --create-home appuser
# - Health check can use Python urllib (curl not in slim image)
#
# ============================================

# TODO: Implement your Dockerfile here!
#
# Delete everything below and write your own.
# See README.md for step-by-step hints.

# This is a BROKEN starter - it works but has problems:
# - Image is too big (~1GB)
# - Runs as root (insecure)
# - No health check
# - No multi-stage build

# FROM python:3.11

# WORKDIR /app

# COPY requirements.txt .
# RUN pip install -r requirements.txt

# COPY src/ ./src/

# EXPOSE 5000

# CMD ["python", "src/app.py"]


# # Stage 1: Builder
# FROM python:3.11 AS builder
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --user -r requirements.txt

# # Stage 2: Final
# FROM python:3.11-slim
# WORKDIR /app

# # Copy installed packages from builder
# COPY --from=builder /root/.local /root/.local

# # Copy application code
# COPY src/ ./src/

# # ... rest of your Dockerfile

# # Create non-root user
# RUN useradd --create-home appuser
# USER appuser

# # # In builder stage:
# # RUN pip install --prefix=/install -r requirements.txt

# # # In final stage:
# # COPY --from=builder /install /usr/local

# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
# CMD curl -f http://localhost:5000/health || exit 1
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
# CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# ENV FLASK_APP=src/app.py
# ENV FLASK_RUN_HOST=0.0.0.0
# ENV FLASK_RUN_PORT=5000

# # Document the port
# EXPOSE 5000

# # Run the application
# CMD ["python", "src/app.py"]


# Stage 1: Builder
FROM python:3.11-alpine AS builder
WORKDIR /app

COPY requirements.txt .
# RUN pip install --prefix=/install -r requirements.txt
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final
FROM python:3.11-alpine
WORKDIR /app

# Copy installed packages
COPY --from=builder /install /usr/local

# Copy app code
COPY src/ ./src/

# Create non-root user
RUN adduser -D appuser
USER appuser

ENV FLASK_APP=src/app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000

EXPOSE 5000

CMD ["python", "src/app.py"]


# Changing from Slim to Alpine
# Alpine uses adduser instead of useradd. Change line 111 in your Dockerfile:
    # Replace this:
# RUN useradd --create-home appuser

# # With this:
# RUN adduser -D appuser
# The -D flag means "no password" (Alpine's equivalent of --create-home — it creates the home directory by default).
FROM python:3.9-alpine

LABEL maintainer="Varsha Hegde"

ENV PYTHONUNBUFFERED=1

# Copy requirements first (better caching)
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy project code
COPY ./app /app
WORKDIR /app

EXPOSE 8000

# Build argument to install dev dependencies
ARG DEV=false

# Install dependencies, virtualenv, postgresql-client, and create user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --no-cache postgresql-client bash && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser -D -H django-user

# Use virtualenv by default
ENV PATH="/py/bin:$PATH"

# Run as non-root user
USER django-user

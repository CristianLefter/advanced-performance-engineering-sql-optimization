FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates curl gnupg lsb-release apt-transport-https \
     postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver 18 + sqlcmd (mssql-tools18)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" \
     > /etc/apt/sources.list.d/microsoft-prod.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 mssql-tools18 unixodbc-dev \
  && ln -s /opt/mssql-tools18/bin/sqlcmd /usr/local/bin/sqlcmd \
  && rm -rf /var/lib/apt/lists/*

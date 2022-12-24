# cloudflared-healtchecks.io
A docker image running healthchecks.io and cloudflared to run on mogenius.

## Docker Compose
````
---
version: "3"
services:
  healthchecks:
    container_name: cloudflared-healthchecks
    environment:
      SECRET_KEY: "YOUR_SECRET_KEY"
      SITE_ROOT: "site root"
      SITE_NAME: "site name"
      SUPERUSER_EMAIL: "email here"
      SUPERUSER_PASSWORD: "password"
      DEBUG: "False"
      REGISTRATION_OPEN: "False"
      LANG: "C.UTF-8"
      USE_PAYMENTS: "False"
      DB_NAME: "/data/hc.sqlite"
      PYTHONUNBUFFERED: 1
      CLOUDFLARED_TUNNEL_TOKEN: "tunnel token"
    volumes:
      - /mnt/user/appdata/cloudflared-healthchecks:/data
    ports:
      - 8000:8000
    image: ziggyds/cloudflared-healthchecks:latest
    restart: unless-stopped

````
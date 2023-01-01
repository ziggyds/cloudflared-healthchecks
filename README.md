# cloudflared-healtchecks.io
A docker image running healthchecks.io and cloudflared to run on mogenius.\
Version tag fe. v2.5-2022.12.1 = (healthchecks version)-(cloudflared version)\
There is an actions workflow that runs daily and if a new version cloudflared or healthchecks has been released it will create a new image.

Builds image and starts container

	docker-compose up

Just builds the image

	docker-compose build --no-cache

Force build

	docker-compose up --build

Skip build

	docker-compose up --no-build

For a more detailed output set BUILDKIT_PROGRESS\
Shell

  	export BUILDKIT_PROGRESS=plain
Powershell
  
 	$env:BUILDKIT_PROGRESS="plain" 

## Docker Compose
````
---
version: '3.9'
services:
  cloudflared-healthchecks:
    container_name: cloudflared-healthchecks
    environment:
      SECRET_KEY: "YOUR_SECRET_KEY"
      SITE_ROOT: "site root"
      SITE_NAME: "site name"
      PING_EMAIL_DOMAIN: "(sub)domain"
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

  cloudflared-healthchecks-build:
    build:
      context: .
      dockerfile: Dockerfile
      labels:
        CLOUDFLARED: 2022.12.1
        HEALTHCHECKS: v2.5
      args:
        CLOUDFLARED: 2022.12.1
        HEALTHCHECKS: v2.5
        # not working use: BUILDKIT_PROGRESS=plain docker-compose build --no-cache
        # progress: plain
        # no-cache: true
````

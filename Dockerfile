# Get latest healthchecks release and unzip it
FROM ziggyds/alpine-utils:latest AS init
ARG HEALTHCHECKS
ARG CLOUDFLARED
WORKDIR /healthchecks
RUN echo ${HEALTHCHECKS} && wget https://github.com/healthchecks/healthchecks/archive/refs/tags/${HEALTHCHECKS}.zip && \
    unzip ${HEALTHCHECKS} && rm ${HEALTHCHECKS}.zip
# Get latest cloudflared release
WORKDIR /cloudflared
# Since the package doesn't contain the version in its name, the ARG is not necessary
RUN echo ${CLOUDFLARED} && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

### Build healthchecks ###
FROM python:3.11.0-slim-buster as builder

RUN apt update && apt install -y \
	build-essential libpq-dev libmariadb-dev libffi-dev libssl-dev libcurl4-openssl-dev libpython3-dev default-libmysqlclient-dev

# Copy latest healthchecks release, since there is only one subfolder that doesn't have consistent name I'm using */
COPY --from=init /healthchecks/*/ /app

# Set the working directory
WORKDIR /app

RUN pip install --upgrade pip && \
	pip wheel --wheel-dir /wheels apprise uwsgi mysqlclient minio \
	pip wheel --wheel-dir /wheels -r requirements.txt 

### Build tunneled healthchecks image ###
FROM python:3.11.0-slim-buster
ENV DEBUG=False
ENV USE_PAYMENTS=False
ENV DB_NAME=/data/hc.sqlite
ENV PYTHONUNBUFFERED=1
ENV CLOUDFLARED_TUNNEL_TOKEN=""

# Copy and install cloudflared
COPY --from=init /cloudflared /tmp
RUN apt install /tmp/*.deb && rm -rf /tmp/*

# Set the working directory
WORKDIR /app

RUN apt update && \
    apt install -y libpq5 libcurl4 libmariadb3 supervisor cron uwsgi curl && \
    rm -rf /var/apt/cache && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd  -g 1000 healthchecks && \
	useradd -u 1000 -g healthchecks healthchecks 

# Copy latest healthchecks release
COPY --from=builder /app /app
RUN rm -rf /app/docker
COPY --from=builder /wheels /wheels

RUN pip install --no-cache /wheels/*

RUN mkdir -p /var/log/cron \
	&& touch /var/log/cron/cron.log \
	&& chown healthchecks:healthchecks /var/log/cron -R 

COPY files /

RUN mkdir /data && chown healthchecks:healthchecks /data && chown healthchecks:healthchecks -R /app

RUN chmod +x /*.sh

VOLUME /data

EXPOSE 8000/tcp
ENTRYPOINT ["sh", "/entrypoint.sh"]

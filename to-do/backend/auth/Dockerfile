FROM python:3.11.4-alpine3.18 as base
ARG POSTGRES_ENABLED
LABEL maintainer "Suresh Chhatwani <sureshchhatwani12@gmail.com>"

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR /wheels

RUN apk add --update --no-cache \
    alpine-sdk \
    postgresql-dev

COPY ./requirements.txt requirements.txt

RUN pip wheel -r requirements.txt --disable-pip-version-check

FROM python:3.11.4-alpine3.18 as deploy

ENV PYTHONUNBUFFERED=1
ENV POSTGRES_ENABLED=$POSTGRES_ENABLED
ENV PYTHONDONTWRITEBYTECODE 1

RUN apk add --update --no-cache \
    libpq \
    postgresql-client

COPY --from=base /wheels /wheels

RUN pip install \
        --no-cache-dir \
        --disable-pip-version-check \
        -r /wheels/requirements.txt \
        -f /wheels \
    && rm -rf /wheels

RUN addgroup --system auth \
    && adduser --system --ingroup auth auth

WORKDIR /app

COPY --chown=auth:auth ./ ./

COPY --chown=auth:auth ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER auth
ENTRYPOINT ["entrypoint.sh"]
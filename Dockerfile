ARG REPOSITORY="docker.io"
FROM ${REPOSITORY}/library/alpine:3.19 AS builder
RUN apk add --no-cache python3 python3-dev py3-pip gcc musl-dev libffi-dev openssl-dev make

RUN addgroup -g 10001 -S ansible && \
    adduser -u 10001 -S -G ansible -h /home/ansible ansible

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir ansible-core

#build final image
FROM ${REPOSITORY}/library/alpine:3.19
RUN apk add --no-cache python3 openssh-client

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

COPY --from=builder /opt/venv /opt/venv

RUN mkdir -p /home/ansible/.ansible && \
    chown -R ansible:ansible /home/ansible

ENV PATH="/opt/venv/bin:$PATH"
ENV HOME="/home/ansible"

USER ansible
WORKDIR /home/ansible

ENTRYPOINT ["ansible"]

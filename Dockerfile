# Alpine Linux along with Maven & Git
FROM maven:3-alpine
MAINTAINER Roman Levytskyi <roman.levytskyi.oss@gmail.com>

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir -p /root/.ssh
# Add git hub private key
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Use git with SSH instead of https!
# Skip Host verification for git
RUN echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
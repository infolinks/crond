FROM google/cloud-sdk:171.0.0-alpine
MAINTAINER Arik Kfir <arik@infolinks.com>
COPY ./bin/*.sh /usr/local/bin/
RUN apk add --no-cache dcron bash && \
    chmod a+x /usr/local/bin/crond.sh /usr/local/bin/job-executor.sh
ENTRYPOINT ["/usr/local/bin/crond.sh"]

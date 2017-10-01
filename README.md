# crond

[![Build Status](https://travis-ci.org/infolinks/crond.svg?branch=master)](https://travis-ci.org/infolinks/k8s-ingress-networks)

Docker image running cron daemon for executing a periodic job.

This container receives (via environment variables) a job to run and the
periodic schedule to run it on, and it will start a `crond` server which
will execute that given job on the specified schedule.

## Running

This image can be either extended by another Docker image, preloading
its job, or alternatively it can be run as is, with the actual job and
its schedule to be provided externally (via a mount & environment
variables).

### Running as a standalone image

Here's how to run an hourly job at the beginning of each hour:

    docker run \
        -v /path/to/my-job.sh:/usr/local/bin/my-job.sh \
        -e "SCHEDULE='0 * * * *'" \
        -e "JOB_CMDLINE='/usr/local/bin/my-job.sh arg1 arg2 arg3'" \
        infolinks/crond

This will run `/usr/local/bin/my-job.sh arg1 arg2 arg3` at `00:00`, at
`01:00`, `02:00`, etc.

### Extending this image

Extending image's `Dockerfile`:

    FROM infolinks/crond
    COPY my-job.sh /usr/local/bin/
    ENV SCHEDULE="0 * * * *"
    ENV JOB_CMDLINE="/usr/local/bin/my-job.sh arg1 arg2 arg3"

Build it:

    docker build -t my-images/my-job .

And how to run it:

    docker run my-images/my-job

Violla!

### Kubernetes

You can also use this container as part of a Kubernetes pod - since you'll
be doing the same things as running this image yourself (mounting the
job script, and setting environment variables) the exact specifics will
be left as a reader's exercise :)

## Contributions

Any contribution to the project will be appreciated! Whether it's bug
reports, feature requests, pull requests - all are welcome, as long as
you follow our [contribution guidelines for this project](CONTRIBUTING.md)
and our [code of conduct](CODE_OF_CONDUCT.md).

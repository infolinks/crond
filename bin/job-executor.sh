#!/bin/sh

# expose proper PATHs to job
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# executes given command-line, but redirect its stdout to /var/lib/crond/stdout and its stderr to /var/lib/crond/stderr
# both are special file nodes created by the container entrypoint and are used to redirect job output to the main
# container process's stdout and stderr.
exec $@ 1>>/var/lib/crond/stdout 2>>/var/lib/crond/stderr

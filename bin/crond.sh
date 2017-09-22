#!/bin/sh

# trap script termination for cleanup
PIDS=""
trap '[ ! -z "${PIDS}" ] && kill -TERM ${PIDS}' EXIT

# print header and verify required parameters
echo
echo "************************************************************"
echo "STARTING crond:"
echo "  SCHEDULE: ${SCHEDULE}"
echo "       JOB: ${JOB_CMDLINE}"
echo "     DEBUG: ${DEBUG}"
echo "************************************************************"
echo
[[ ${DEBUG} == "true" ]] && set -x
[[ -z "${SCHEDULE}" ]] && echo "missing SCHEDULE environment variable (formatted as cron expression)" && exit 1
[[ -z "${JOB_CMDLINE}" ]] && echo "missing JOB_CMDLINE environment variable (the command to execute)" && exit 1

# exit if any command fails
set -e

# generate special file nodes that the job-executor redirects job stdout/stderr to; we will tail on these files into
# this process's stdout/stderr. this enables the container to essentially print the job's stdout/stderr back to the
# docker orchestrator, so it can be harvested into whatever logging solution is used
mkdir -p /var/lib/crond
mknod /var/lib/crond/stdout p
mknod /var/lib/crond/stderr p

# generate the crontab file to be fed into crontab daemon and feed it to crontab
echo "${SCHEDULE} /usr/local/bin/job-executor.sh ${JOB_CMDLINE}" > /root/crontab
crontab /root/crontab

# tail on our special file nodes; redirect '/var/lib/crond/stdout' into this script's stdout, and
# '/var/lib/crond/stderr' to our stderr; we push the tail commands into the background (notice the trailing "&") so both
# will run in parallel, and then we use "wait" to wait indefinitely until "crontab" and the "tail" commands exit
tail -f /var/lib/crond/stdout >&1 &
PIDS="$!"
tail -f /var/lib/crond/stderr >&2 &
PIDS="${PIDS} $!"

# run the crond (the crontab daemon) in the foreground ("-f") but send that thing to the background (trailing "&")
# it's a little weird, but essentially we don't want crond to simply start, schedule background jobs, and exit; we
# want it to stay alive as a foreground process, but we want THAT foreground process to be in the background so we
# can wait for everything (crond and the tail commands). we also want it to stop if this script is interrupted.
crond -f &
PIDS="${PIDS} $!"

# now wait until interrupted
wait

#!/bin/bash -eo pipefail

stopsignal_handler () {
    if [ $pid -ne 0 ]; then
        kill -SIGTERM "$pid"
        wait "$pid"
    fi
    exit 0; # 128 + 15 -- SIGTERM
}

# Kills the last background process, which is `tail -f /dev/null` and execute the term handler
trap 'kill ${%1}; term_handler' SIGTERM

pid="$!"

# wait forever
while true
do
    tail -f /dev/null & wait ${!}
done

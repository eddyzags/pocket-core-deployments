#!/usr/bin/expect

proc stopsignal_handler () {
    if [ $pid -ne 0 ]; then
      kill -SIGTERM "$pid"
      wait "$pid"
    fi
    exit 0; # 128 + 15 -- SIGTERM
}

set command $argv; # Grab the first command line parameter
set timeout -1

spawn sh -c "cp /tmp/*.json /home/app/.pocket/config/"
sleep 2
if { $env(POCKET_CORE_KEY) eq "" }  {
    log_user 0
    spawn sh -c "$command &"
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    log_user 1

} else {
    log_user 0
    spawn pocket accounts import-raw $env(POCKET_CORE_KEY)
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    expect eof
    spawn sh -c "pocket accounts set-validator `pocket accounts list | cut -d' ' -f2- `"
    sleep 1
    send -- "$env(POCKET_CORE_PASSPHRASE)\n"
    expect eof
    log_user 1
    spawn sh -c "$command &"
}

# Kills the last background process, which is `tail -f /dev/null` and execute the term handler
trap 'kill ${!}; term_handler' SIGTERM

pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

expect eof

exit

#!/bin/bash
#
# DEPRECATED - see cmdstat.py instead

if [ -z "$1" ]; then
    echo "Command name required."
    exit 1
fi

REMOTE=$2
CMD=$1
DEV=/dev/ttyACM0

function heartbeat() {
    while [ 1 ]
    do
        echo "I" > $DEV
        sleep 0.5
    done
}

function on_interrupt() {
    kill $CATPID
    exit
}

stty -F $DEV 9600 raw -echo

cat $DEV &
CATPID=$!
heartbeat &

[ ! -z "$REMOTE" ] && REMOTE="ssh $REMOTE"

trap "on_interrupt" INT

while [ 1 ]
do
    if PID=`$REMOTE pidof -xs $CMD`; then
        echo "S" > $DEV
        OUT=`$REMOTE strace -e exit -e signal=none --quiet=attach -p $PID 2>&1`
        RET=`echo $OUT | sed 's/+++ exited with \([0-9]\+\) +++/\1/'`
        if [ "$RET" -eq 0 ]; then
            echo "T" > $DEV
        else
            echo "F" > $DEV
        fi
    fi
    sleep 1
done

trap SIGINT

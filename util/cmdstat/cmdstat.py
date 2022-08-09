#!/usr/bin/env python3
#
# cmdstat
#
# Usage: cmdstat cmd[@remote] [... cmd@[remote]]
#
# Watches specified set of commands on any remote machine
# and reports exit status to an Arduino device.
#
# Remote watching is done by attaching to the processes
# using strace via ssh.
#
# If the 'remote' part is omitted, that specific command
# will be watched on the local system.
#
# Reporting is done by sending the following characters
# to the serial port of an Arduino device:
#
# I: Heartbeat signal, sent every 0.5 seconds
# S: Command started
# T: Command exited successfully
# F: Command failed
#
# See cmdstat.ino for the Ardunio client code
#
# Author: cbbayburt

import sys
import subprocess
import time
import serial
import re
import glob
import queue
from threading import Thread

# Parse the exit code from strace output
def getCode(result):
    m = re.search(r'\+\+\+ exited with (\d+) \+\+\+', result)
    if m:
        return m.group(1)
    return None

# Send heartbeats to Arduino
def heartbeat(msgQueue):
    dev = findDevice()
    while True:
        msg = None
        try:
            msg = msgQueue.get(block=False)
        except queue.Empty:
            pass

        if not msg:
            msg = b'I'

        dev.write(msg)
        time.sleep(0.5)

def findDevice():
    # Find the Arduino device
    devs = glob.glob('/dev/ttyACM*')
    if len(devs) > 0:
        dev = serial.Serial(devs[0], 9600, exclusive=True, timeout=None)
        print("Found device '{}'".format(devs[0]))
        dev.send_break()
        return dev
    raise Exception("No device found")

# Watch all the commands simultaneously
def watch(msgQueue):
    pidofArgs = ['pidof', '-xs']
    while True:
        for c in cmds:
            # Split the command and the optional remote
            cmd = c.split('@', 1)
            if len(cmd) > 1:
                remoteArgs = ['ssh', cmd[1]]
            else:
                remoteArgs = []

            args = remoteArgs + pidofArgs + cmd[0:1]
            with subprocess.Popen(args, stdout=subprocess.PIPE) as p:
                pid=p.stdout.read()

            # If the command is running
            if pid:
                msgQueue.put(b'S')
                straceArgs = ['strace', '-e', 'exit', '-e' 'signal=none', '--quiet=attach', '-p', pid]
                args = remoteArgs + straceArgs
                # Attach to the process with strace
                with subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) as p:
                    # Get the exit code
                    code = getCode(str(p.stdout.read()))

                # Report result to Arduino
                if code == '0':
                    msgQueue.put(b'T')
                elif not code:
                    pass
                else:
                    msgQueue.put(b'F')

        time.sleep(1)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Command name required")
        quit(1)

    # Commands should be specified as: cmd[@remote]
    cmds = sys.argv[1:]

    msgQueue = queue.Queue()

    hb = Thread(target=heartbeat, args=(msgQueue,))
    hb.start()

    watcher = Thread(target=watch, args=(msgQueue,), daemon=True)
    watcher.start()

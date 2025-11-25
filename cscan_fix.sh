#!/bin/bash
set -x

PARENT_PID=$(pgrep -f "cscan")

if [ -z "$PARENT_PID" ]; then
  echo "No process found with the name: cscan"
  exit 0
fi

# echo "Parent PID: $PARENT_PID"
# find all child PIDs of the parent process

CHILD_PIDS=$(ps -eo pid,ppid | awk -v ppid="$PARENT_PID" '$2 == ppid {print $1}')

if [ -z "$CHILD_PIDS" ]; then
  echo "No child processes found for PID: $PARENT_PID"
  exit 0
fi

count=$(echo "CHILD_PIDS" | wc | awk ' { print $2 } ')

# echo "Child PIDs: $CHILD_PIDS"

# Kill all child processes

for pid in $CHILD_PIDS; do
#  echo "Killing child process with PID: $pid"
  kill -9 "$pid"
done

echo "$count"" child processes of PID $PARENT_PID killed."

pkill $PARENT_PID

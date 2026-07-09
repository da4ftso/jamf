#!/bin/bash

# 1.0 use with Quit All Apps 1.0.2

# Read the captured process list
while IFS= read -r process; do
  echo "Process: $process"
done < /tmp/running_processes.txt

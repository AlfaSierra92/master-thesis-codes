#!/bin/bash

# Verifica che siano stati forniti i tre argomenti necessari
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <max_concurrent_messages> <message_size>"
    exit 1
fi

tcpdump -l -n udp port 81 | while read -r line; do ./test2_2.sh $1 $2; done
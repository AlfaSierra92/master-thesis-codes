#!/bin/bash

# Verifica degli argomenti
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <NUM_PACKETS> <WAIT_INTERVAL> <PACKET_SIZE>"
  exit 1
fi

# Parametri
DEST_IP=192.168.100.255
DEST_PORT=12345
NUM_PACKETS=$1
WAIT_INTERVAL=$2
PACKET_SIZE=$3

# File di output locale
OUTPUT_FILE="output_sender.txt"

# Pulisce il file di output locale
> $OUTPUT_FILE

# Invia i pacchetti numerati
for i in $(seq 1 $NUM_PACKETS); do
  for j in $(seq 1 $NUM_PACKETS); do
    PAYLOAD=$(head -c $PACKET_SIZE </dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c $PACKET_SIZE)
    #PACKET="Packet $((NUM_PACKETS*(i-1) + j)) from $HOSTNAME with payload: $PAYLOAD"
    PACKET="Packet $((NUM_PACKETS*(i-1) + j));$HOSTNAME"
    echo "$PACKET" | nc -u -b -w1 -q0 $DEST_IP $DEST_PORT
    echo "$PACKET" >> $OUTPUT_FILE
  done
  sleep $WAIT_INTERVAL  # Intervallo tra i pacchetti
done

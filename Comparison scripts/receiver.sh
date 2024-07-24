#!/bin/bash

# Porta in ascolto
PORT="12345"

# File di output locale
OUTPUT_FILE="output_receiver.txt"

# Pulisce il file di output locale
> $OUTPUT_FILE

# Avvia netcat in modalità server e salva i pacchetti ricevuti nel file di output
#nc -lu $PORT >> $OUTPUT_FILE
#nc -u -k -l -p $PORT >> $OUTPUT_FILE
nc -u -k -l -p $PORT | while read -r line; do
    # Filtra la parte ${i};${IP} e salva nel file di output
    # awk -F';' 'NF > 1 {print $1 ";" $2}' per evitare il print di ; aggiuntivi
    echo "$line" | awk -F';' 'NF > 1 {print $1 ";" $2}' >> $OUTPUT_FILE
done
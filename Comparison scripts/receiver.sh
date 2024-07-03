#!/bin/bash

# Porta in ascolto
PORT="12345"

# File di output locale
OUTPUT_FILE="output_receiver.txt"

# Pulisce il file di output locale
> $OUTPUT_FILE

# Avvia netcat in modalità server e salva i pacchetti ricevuti nel file di output
#nc -lu $PORT >> $OUTPUT_FILE
nc -u -k -l -p $PORT >> $OUTPUT_FILE
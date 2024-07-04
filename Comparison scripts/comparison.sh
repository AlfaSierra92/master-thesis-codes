#!/bin/bash

scp root@rock3:/root/output_sender.txt .
scp root@rock3_1:/root/output_receiver.txt .

# File di output
SENDER_FILE="output_sender.txt"
RECEIVER_FILE="output_receiver.txt"

# File temporanei per il confronto
SORTED_SENDER_FILE="sorted_sender.txt"
SORTED_RECEIVER_FILE="sorted_receiver.txt"

# Ordina i file di output e salva i risultati in file temporanei
sort $SENDER_FILE > $SORTED_SENDER_FILE
sort $RECEIVER_FILE > $SORTED_RECEIVER_FILE

# Confronta i file ordinati e salva le differenze in un file di output
diff -u $SORTED_SENDER_FILE $SORTED_RECEIVER_FILE > diff_output.txt

# Verifica se ci sono differenze
if [ -s diff_output.txt ]; then
  echo "Sono stati persi dei pacchetti. Controlla diff_output.txt per i dettagli."
else
  echo "Tutti i pacchetti sono stati ricevuti correttamente."
fi

# Pulizia dei file temporanei
rm $SORTED_SENDER_FILE $SORTED_RECEIVER_FILE

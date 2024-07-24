# EXPERIMENTAL

# Come usare sul server?
# nc -u -k -l -p 12345 > output
# Usa comunque receiver.sh

#!/bin/bash

# Controlla se sono stati forniti 3 argomenti
if [ $# -ne 3 ]; then
    echo "Usage: $0 <delay> <number_of_packets> <packet_size>"
    exit 1
fi

# Assegna gli argomenti a variabili
DELAY=$1
NUM_PACKETS=$2
PACKET_SIZE=$3

# File di output locale
OUTPUT_FILE="output_sender.txt"

# Pulisce il file di output locale
> $OUTPUT_FILE

IP=$(ip addr | grep 192.168.100 | awk '{print $2}')

# Messaggi di debug
echo "Delay tra gruppi di pacchetti: $DELAY secondi"
echo "Numero di pacchetti per gruppo: $NUM_PACKETS"
echo "Dimensione del pacchetto: $PACKET_SIZE byte"

# Crea un pacchetto di dati di dimensione specificata
echo "Generazione di un pacchetto di $PACKET_SIZE byte di dati casuali..."
DATA=$(head -c $PACKET_SIZE </dev/urandom | base64)
#echo "Pacchetto generato: $(echo $DATA | head -c 50)..."  # Mostra solo i primi 50 caratteri per il debug

# Funzione per inviare i pacchetti
send_packets() {
    local packet_data=""
    for ((i=0; i<$NUM_PACKETS; i++)); do
        local packet="${i};${IP};${DATA}\n\n"
        echo -e "$packet" | nc -u -b -w1 -q0 192.168.100.255 12345 &
        # echo -e "${i};${IP}\n\n" >> $OUTPUT_FILE
        packet_data+="${i};${IP}\n\n"
    done
    wait  # Attende che tutti i pacchetti siano stati inviati
    echo -e "$packet_data" >> $OUTPUT_FILE
    echo "Tutti i pacchetti inviati. Aspetto $DELAY secondi prima di inviare il prossimo gruppo..."
    sleep $DELAY
}

# Chiama la funzione per inviare i pacchetti in un ciclo
#while true; do
#    send_packets
#done
for ((j=0; j<10; j++)); do
    send_packets
done


echo "Invio dei pacchetti completato."

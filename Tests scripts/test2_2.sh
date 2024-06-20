#!/bin/bash

# Verifica che siano stati forniti i tre argomenti necessari
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <max_concurrent_messages> <message_size>"
    exit 1
fi

initial_sleep_ms=1
max_concurrent_messages=$1
message_size=$2

# Converte lo sleep iniziale da ms a secondi per il comando sleep
initial_sleep_s=$(bc <<< "scale=3; $initial_sleep_ms / 1000")

# Genera un messaggio di dimensione specificata
message=$(head -c $message_size </dev/zero | tr '\0' 'A')

# Funzione per inviare messaggi
send_messages() {
    for ((i=0; i<$max_concurrent_messages; i++)); do
        echo -n "$message" | nc -u -w1 127.0.0.1 12345 &
    done
    wait
}

# Funzione per cambiare la potenza di trasmissione
set_tx_power() {
    local power_level=$1
    # Assicurati di sostituire 'wlo1' con il tuo dispositivo di rete
    #iwconfig wlo1 txpower $power_level
    echo "Potenza di trasmissione impostata a $power_level dBm"
}

# Inizia lo script
echo "Iniziando con uno sleep iniziale di $initial_sleep_s secondi..."
sleep $initial_sleep_s

# Variabili di controllo della congestione
previous_received=0
sleep_time=$initial_sleep_s

while true; do
    # Invio dei messaggi
    echo "Invio di $max_concurrent_messages messaggi..."
    send_messages
    
    # Attendi un momento per assicurarti che i pacchetti siano stati elaborati
    sleep 1
    
    # Ricezione dei messaggi
    echo "Misurazione dei pacchetti ricevuti..."
    current_received=$(cat /sys/class/net/wlo1/statistics/rx_packets)
    received=$((current_received - previous_received))
    echo "Pacchetti ricevuti: $received"

    # Calcolo del carico di canale
    minChannelLoad=$(bc <<< "scale=3; $received / ($max_concurrent_messages * 2)")
    echo "Carico di canale minimo: $minChannelLoad"

    # Aggiornamento dello stato della macchina a stati DCC e impostazione della potenza di trasmissione
    if (( $(echo "$minChannelLoad >= 0.4" | bc -l) )); then
        state="restrictive"
        #sleep_time=$(bc <<< "scale=3; $initial_sleep_s * 2")
        sleep_time=1
        set_tx_power 10  # Imposta a 10 dBm in stato restrictive
        echo "Stato: RESTRICTIVE"
        echo $sleep_time
    elif (( $(echo "$minChannelLoad >= 0.15" | bc -l) )); then
        state="active"
        sleep_time=$initial_sleep_s
        sleep_time=0.06
        set_tx_power 20  # Imposta a 20 dBm in stato active
        echo "Stato: ACTIVE"
        echo $sleep_time
    else
        state="relaxed"
        #sleep_time=$(bc <<< "scale=3; $initial_sleep_s / 2")
        sleep_time=0.04
        set_tx_power 30  # Imposta a 30 dBm in stato relaxed
        echo "Stato: RELAXED"
        echo $sleep_time
    fi

    # Mantiene il tempo di sleep in un range ragionevole
    #if (( $(echo "$sleep_time < 0.04" | bc -l) )); then
    #    sleep_time=0.04
    #elif (( $(echo "$sleep_time > 1" | bc -l) )); then
    #    sleep_time=1
    #fi

    echo "Prossimo invio tra $sleep_time secondi..."
    sleep $sleep_time

    previous_received=$current_received
done

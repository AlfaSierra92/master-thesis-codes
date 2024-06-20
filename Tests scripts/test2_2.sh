#!/bin/bash

# Verifica che siano stati forniti i tre argomenti necessari
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <initial_sleep> <max_concurrent_messages> <message_size>"
    exit 1
fi

initial_sleep_s=$1
max_concurrent_messages=$2
message_size=$3
ip_broadcast=192.168.100.255
startup_received=$(cat /sys/class/net/wlp1s0/statistics/rx_packets)

# Converte lo sleep iniziale da ms a secondi per il comando sleep
#initial_sleep_s=$(bc <<< "scale=3; $initial_sleep_ms / 1000")

# Genera un messaggio di dimensione specificata
message=$(head -c $message_size </dev/zero | tr '\0' 'A')

# Funzione per inviare messaggi
send_messages() {
    for ((i=0; i<$max_concurrent_messages; i++)); do
        # Generate a random port between 1024 and 65535
        random_port=$(( ( RANDOM % 64512 ) + 1024 ))

        # Send the message via UDP to the broadcast IP on the random port
        echo -n "$message" | nc -u -w1 $ip_broadcast $random_port &
        #echo -n "$message" | nc -u -w1 $ip_broadcast 12345 &
    done
    wait
}

# Funzione per cambiare la potenza di trasmissione
set_tx_power() {
    local power_level=$1
    # Assicurati di sostituire 'wlo1' con il tuo dispositivo di rete
    #iwconfig wlo1 txpower $power_level
    iw wlp1s0 set txpower fixed $power_level
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
    #sleep 1
    
    # Ricezione dei messaggi
    echo "Misurazione dei pacchetti ricevuti..."
    current_received=$(cat /sys/class/net/wlp1s0/statistics/rx_packets)
    received=$((current_received - previous_received))
    if [ "$received" -eq "$startup_received" ]; then
        received=0
    fi
    echo "Pacchetti ricevuti: $received"

    # Calcolo del carico di canale
    minChannelLoad=$(bc <<< "scale=3; $received / ($max_concurrent_messages * 2)")
    echo "Carico di canale minimo: $minChannelLoad"

    # Aggiornamento dello stato della macchina a stati DCC e impostazione della potenza di trasmissione
    if (( $(echo "$minChannelLoad >= 0.4" | bc -l) )); then
        state="restrictive"
        sleep_time=1
        set_tx_power 500  # Imposta a 10 dBm in stato restrictive
        echo "Stato: RESTRICTIVE"
        echo $sleep_time
    elif (( $(echo "$minChannelLoad >= 0.15" | bc -l) )); then
        state="active"
        sleep_time=0.06
        set_tx_power 1000  # Imposta a 20 dBm in stato active
        echo "Stato: ACTIVE"
        echo $sleep_time
    else
        state="relaxed"
        #sleep_time=$(bc <<< "scale=3; $initial_sleep_s / 2")
        sleep_time=0.04
        set_tx_power 15000  # Imposta a 30 dBm in stato relaxed
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
    echo -e ""
done

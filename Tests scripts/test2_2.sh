#!/bin/bash

# * channel_time: amount of time in ms the radio spent on the channel
# * channel_time_busy: amount of time the primary channel was sensed busy
# * channel_time_rx: amount of time the radio spent receiving data
# * channel_time_tx: amount of time the radio spent transmitting data

# Verifica che siano stati forniti i tre argomenti necessari
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <max_concurrent_messages> <message_size>"
    exit 1
fi

max_concurrent_messages=$1
message_size=$2
output=$3
ip_broadcast=192.168.100.255
interface=wlp1s0e
startup_received=$(cat /sys/class/net/wlp1s0/statistics/rx_packets)
file=output_$(date +%Y-%m-%d_%H-%M-%S).csv

# Genera un messaggio di dimensione specificata
message=$(head -c $message_size </dev/zero | tr '\0' 'A')

# Funzione per inviare messaggi
send_messages() {
    for ((i=0; i<$max_concurrent_messages; i++)); do
        # Generate a random port between 1024 and 65535
        random_port=$(( ( RANDOM % 64512 ) + 1024 ))

        # Send the message via UDP to the broadcast IP on the random port
        echo -n "$message" | nc -u -w1 -q0 $ip_broadcast $random_port &
    done
    wait
}

# Funzione per cambiare la potenza di trasmissione
set_tx_power() {
    local power_level=$1
    iw $interface set txpower fixed $power_level
    echo "Potenza di trasmissione impostata a $power_level dBm"
}

# Inizia lo script
echo "Iniziando con uno sleep iniziale di 1 secondo..."
sleep 1

# Variabili di controllo della congestione
previous_received=0
sleep_time=1

while true; do
    # Invio dei messaggi
    echo "Invio di $max_concurrent_messages messaggi..."
    send_messages
    
    # Ricezione dei messaggi
    echo "Misurazione dei pacchetti ricevuti..."
    current_received=$(cat /sys/class/net/$interface/statistics/rx_packets)
    received=$((current_received - previous_received))
    if [ "$received" -eq "$startup_received" ]; then
        received=0
    fi
    echo "Pacchetti ricevuti: $received"

    # Calcolo del carico di canale
    busy_active=$(iw $interface survey dump | awk '/2462/{flag=1; next} /Survey/{flag=0} flag' | awk '/busy/{busy=$4} /active/{active=$4} END{print busy, active}')
    busy=$(echo $busy_active | awk '{print $1}')
    active=$(echo $busy_active | awk '{print $2}')
    minChannelLoad=$(bc <<< "scale=5; $busy / $active")
    echo "Carico di canale: $minChannelLoad"

    # Aggiornamento dello stato della macchina a stati DCC e impostazione della potenza di trasmissione
    if (( $(echo "$minChannelLoad >= 0.4" | bc -l) )); then
        state="restrictive"
        sleep_time=1
        set_tx_power 500  # Imposta a 10 dBm in stato restrictive
        echo "Stato: RESTRICTIVE"
    elif (( $(echo "$minChannelLoad >= 0.15" | bc -l) )); then
        state="active"
        sleep_time=0.06
        set_tx_power 1000  # Imposta a 20 dBm in stato active
        echo "Stato: ACTIVE"
    else
        state="relaxed"
        sleep_time=0.04
        set_tx_power 15000  # Imposta a 30 dBm in stato relaxed
        echo "Stato: RELAXED"
    fi

    echo "Prossimo invio tra $sleep_time secondi..."
    sleep $sleep_time

    # To save output
    echo "$max_concurrent_messages,$received,$(printf '%.5f' $minChannelLoad),$state,$sleep_time" >> $file
    
    previous_received=$current_received
    echo -e ""
done

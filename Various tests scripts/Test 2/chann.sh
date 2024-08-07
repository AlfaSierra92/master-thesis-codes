# ./chann.sh | tee -a channel_load.csv
#!/bin/bash

interface="wlp1s0"  # Sostituisci con l'interfaccia di rete desiderata

# Stampa l'intestazione CSV a video
echo "timestamp,minChannelLoad"

while true; do
    # Esegui il comando iw e processa l'output
    busy_active=$(iw $interface survey dump | awk '/2462/{flag=1; next} /Survey/{flag=0} flag' | awk '/busy/{busy=$4} /active/{active=$4} END{print busy, active}')
    busy=$(echo $busy_active | awk '{print $1}')
    active=$(echo $busy_active | awk '{print $2}')
    
    if [[ -n "$busy" && -n "$active" && "$active" -ne 0 ]]; then
        minChannelLoad=$(bc <<< "scale=5; $busy / $active")
    else
        minChannelLoad="N/A"
    fi
    
    # Ottieni il timestamp corrente
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Stampa il risultato in formato CSV a video
    echo "$timestamp,$minChannelLoad"
    
    # Attendi 1 secondo prima di ripetere
    sleep 1
done

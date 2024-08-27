import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Imposta lo stile di Seaborn
sns.set(style="whitegrid")

# Lista dei file CSV
csv_files = ['Data/outputT1_C0_1.csv', 'Data/outputT1_C0_2.csv', 'Data/outputT1_C0_3.csv', 'Data/outputT1_C0_4.csv', 'Data/outputT1_C0_5.csv']

# Inizializza liste per i dati filtrati
filtered_data_list = []

# Leggi i file CSV, filtra e calcola il throughput
for file in csv_files:
    data = pd.read_csv(file, header=None)
    data.columns = ['timestamp', 'src_ip', 'src_port', 'dst_ip', 'dst_port', 'flow_id', 'time_interval', 'bytes', 'packets']
    data['timestamp'] = pd.to_datetime(data['timestamp'], format='%Y%m%d%H%M%S')
    data['throughput_mbps'] = (data['bytes'] * 8) / 1_000_000
    start_time = data['timestamp'].min()
    end_time = start_time + pd.Timedelta(seconds=30)
    filtered_data = data[(data['timestamp'] >= start_time) & (data['timestamp'] < end_time)].copy()
    filtered_data_list.append(filtered_data)

# Calcola la media del throughput per ciascun secondo per ogni stream ID
mean_throughput_1 = []
mean_throughput_2 = []
for second in range(30):
    second_data_1 = []
    second_data_2 = []
    for filtered_data in filtered_data_list:
        timestamp_second = start_time + pd.Timedelta(seconds=second)
        stream_id_1 = filtered_data[(filtered_data['flow_id'] == 1) & (filtered_data['timestamp'].dt.floor('S') == timestamp_second)]
        stream_id_2 = filtered_data[(filtered_data['flow_id'] == 2) & (filtered_data['timestamp'].dt.floor('S') == timestamp_second)]
        if not stream_id_1.empty:
            second_data_1.append(stream_id_1['throughput_mbps'].mean())
        if not stream_id_2.empty:
            second_data_2.append(stream_id_2['throughput_mbps'].mean())
    if second_data_1:
        mean_throughput_1.append(sum(second_data_1) / len(second_data_1))
    else:
        mean_throughput_1.append(0)
    if second_data_2:
        mean_throughput_2.append(sum(second_data_2) / len(second_data_2))
    else:
        mean_throughput_2.append(0)

# Calcola la media e la varianza del throughput per ciascun stream ID
throughput_avg_1 = sum(mean_throughput_1) / len(mean_throughput_1)
throughput_var_1 = sum((x - throughput_avg_1) ** 2 for x in mean_throughput_1) / len(mean_throughput_1)

throughput_avg_2 = sum(mean_throughput_2) / len(mean_throughput_2)
throughput_var_2 = sum((x - throughput_avg_2) ** 2 for x in mean_throughput_2) / len(mean_throughput_2)

# Print overall results
print(f'Throughput Medio Totale per Stream ID 1: {throughput_avg_1:.2f} Mbps')
print(f'Varianza Totale per Stream ID 1: {throughput_var_1:.2f} Mbps^2')
print(f'Throughput Medio Totale per Stream ID 2: {throughput_avg_2:.2f} Mbps')
print(f'Varianza Totale per Stream ID 2: {throughput_var_2:.2f} Mbps^2')

# Plot del throughput medio per stream ID 1
plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
plt.plot(range(30), mean_throughput_1, linestyle='-', color='blue', markersize=8, label='Stream ID 1')
plt.title(f'Throughput Medio per Stream ID 1\nMedia: {throughput_avg_1:.2f} Mbps, Varianza: {throughput_var_1:.2f} Mbps^2', fontsize=16)
plt.xlabel('Secondi', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()

# Plot del throughput medio per stream ID 2
plt.subplot(2, 1, 2)
plt.plot(range(30), mean_throughput_2, linestyle='-', color='orange', markersize=8, label='Stream ID 2')
plt.title(f'Throughput Medio per Stream ID 2\nMedia: {throughput_avg_2:.2f} Mbps, Varianza: {throughput_var_2:.2f} Mbps^2', fontsize=16)
plt.xlabel('Secondi', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()

plt.tight_layout()
plt.show()

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Imposta lo stile di Seaborn
sns.set(style="whitegrid")

# Leggi il file CSV
data = pd.read_csv('Data/outputT1_C0_1.csv', header=None)

# Rinomina le colonne per facilitare l'uso
data.columns = ['timestamp', 'src_ip', 'src_port', 'dst_ip', 'dst_port', 'flow_id', 'time_interval', 'bytes', 'packets']

# Converti il timestamp in un formato datetime
data['timestamp'] = pd.to_datetime(data['timestamp'], format='%Y%m%d%H%M%S')

# Filtra i dati per mantenere solo i campioni entro i 30 secondi
start_time = data['timestamp'].min()
end_time = start_time + pd.Timedelta(seconds=30)
filtered_data = data[(data['timestamp'] >= start_time) & (data['timestamp'] < end_time)].copy()  # Usa .copy()

# Calcola il throughput in Mbps (Megabit per secondo)
filtered_data.loc[:, 'throughput_mbps'] = (filtered_data['bytes'] * 8) / 1_000_000

# Filtra i dati per stream ID 1 e 2
stream_id_1 = filtered_data[filtered_data['flow_id'] == 1]
stream_id_2 = filtered_data[filtered_data['flow_id'] == 2]

# Calcola il throughput medio e la varianza per ciascun stream
throughput_avg_1 = stream_id_1['throughput_mbps'].mean()
throughput_var_1 = stream_id_1['throughput_mbps'].var()

throughput_avg_2 = stream_id_2['throughput_mbps'].mean()
throughput_var_2 = stream_id_2['throughput_mbps'].var()

# Stampa i risultati
print(f'Throughput Medio single run per Stream ID 1: {throughput_avg_1:.2f} Mbps')
print(f'Varianza per Stream ID 1: {throughput_var_1:.2f} Mbps^2')
print(f'Throughput Medio single run per Stream ID 2: {throughput_avg_2:.2f} Mbps')
print(f'Varianza per Stream ID 2: {throughput_var_2:.2f} Mbps^2')

# Calcola il throughput medio per ciascun stream
throughput_avg_1_grouped = stream_id_1.groupby(stream_id_1['timestamp'].dt.floor('S'))['throughput_mbps'].mean()
throughput_avg_2_grouped = stream_id_2.groupby(stream_id_2['timestamp'].dt.floor('S'))['throughput_mbps'].mean()

# Crea un indice numerico per il numero di campione
sample_indices_1 = range(len(throughput_avg_1_grouped))
sample_indices_2 = range(len(throughput_avg_2_grouped))

# Plot del throughput medio per stream ID 1 (ho tolto marker='0' per omettere i punti)
plt.figure(figsize=(12, 6))
plt.plot(sample_indices_1, throughput_avg_1_grouped.values, linestyle='-', color='blue', markersize=8, label='Stream ID 1')
plt.title('Throughput Medio per Stream ID 1', fontsize=16)
plt.xlabel('Numero di Campione', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.xticks(sample_indices_1)
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.legend()
plt.show()

# Plot del throughput medio per stream ID 2
plt.figure(figsize=(12, 6))
plt.plot(sample_indices_2, throughput_avg_2_grouped.values, linestyle='-', color='orange', markersize=8, label='Stream ID 2')
plt.title('Throughput Medio per Stream ID 2', fontsize=16)
plt.xlabel('Numero di Campione', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.xticks(sample_indices_2)
plt.grid(True, linestyle='--', alpha=0.7)
plt.tight_layout()
plt.legend()
plt.show()

# Plot del throughput medio per entrambi gli stream ID
plt.figure(figsize=(12, 6))
plt.plot(sample_indices_1, throughput_avg_1_grouped.values, linestyle='-', color='blue', markersize=8, label='Stream ID 1')
plt.plot(sample_indices_2, throughput_avg_2_grouped.values, linestyle='-', color='orange', markersize=8, label='Stream ID 2')
plt.title('Throughput Medio per Stream ID 1 e 2', fontsize=16)
plt.xlabel('Numero di Campione', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.xticks(sample_indices_1)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()
plt.tight_layout()
plt.show()
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Imposta lo stile di Seaborn
sns.set(style="whitegrid")

# Lista dei file CSV
csv_files = ['Data/outputT1_C0_1.csv', 'Data/outputT1_C0_2.csv', 'Data/outputT1_C0_3.csv', 'Data/outputT1_C0_4.csv', 'Data/outputT1_C0_5.csv']

# Colori e stili di linea per i plot
colors = ['blue', 'orange', 'green', 'red', 'purple']
line_styles = ['-', '--', '-.', ':', '-']

# Inizializza liste per calcolare media e varianza
all_stream_id_1 = []
all_stream_id_2 = []

# Leggi i file CSV, filtra e calcola il throughput
filtered_data_list = []
for file in csv_files:
    data = pd.read_csv(file, header=None)
    data.columns = ['timestamp', 'src_ip', 'src_port', 'dst_ip', 'dst_port', 'flow_id', 'time_interval', 'bytes', 'packets']
    data['timestamp'] = pd.to_datetime(data['timestamp'], format='%Y%m%d%H%M%S')
    data['throughput_mbps'] = (data['bytes'] * 8) / 1_000_000
    start_time = data['timestamp'].min()
    end_time = start_time + pd.Timedelta(seconds=30)
    filtered_data = data[(data['timestamp'] >= start_time) & (data['timestamp'] < end_time)].copy()
    filtered_data_list.append(filtered_data)
    all_stream_id_1.append(filtered_data[filtered_data['flow_id'] == 1])
    all_stream_id_2.append(filtered_data[filtered_data['flow_id'] == 2])

# Concatenate all data for stream ID 1 and 2
all_stream_id_1 = pd.concat(all_stream_id_1)
all_stream_id_2 = pd.concat(all_stream_id_2)

# Calculate overall mean and variance for each stream ID
# throughput_avg_1 = all_stream_id_1['throughput_mbps'].mean()
# throughput_var_1 = all_stream_id_1['throughput_mbps'].var()

# throughput_avg_2 = all_stream_id_2['throughput_mbps'].mean()
# throughput_var_2 = all_stream_id_2['throughput_mbps'].var()

# Print overall results
# print(f'Throughput Medio Totale per Stream ID 1: {throughput_avg_1:.2f} Mbps')
# print(f'Varianza Totale per Stream ID 1: {throughput_var_1:.2f} Mbps^2')
# print(f'Throughput Medio Totale per Stream ID 2: {throughput_avg_2:.2f} Mbps')
# print(f'Varianza Totale per Stream ID 2: {throughput_var_2:.2f} Mbps^2')

# Plot del throughput medio per stream ID 1
plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
for i, (filtered_data, color, line_style) in enumerate(zip(filtered_data_list, colors, line_styles)):
    stream_id_1 = filtered_data[filtered_data['flow_id'] == 1]
    throughput_avg_1_grouped = stream_id_1.groupby(stream_id_1['timestamp'].dt.floor('S'))['throughput_mbps'].mean()
    sample_indices_1 = range(len(throughput_avg_1_grouped))
    plt.plot(sample_indices_1, throughput_avg_1_grouped.values, linestyle=line_style, color=color, markersize=8, label=f'File {i+1}')
plt.title(f'Throughput Medio per Stream ID 1\nMedia: {throughput_avg_1:.2f} Mbps, Varianza: {throughput_var_1:.2f} Mbps^2', fontsize=16)
plt.xlabel('Numero di Campione', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()

# Plot del throughput medio per stream ID 2
plt.subplot(2, 1, 2)
for i, (filtered_data, color, line_style) in enumerate(zip(filtered_data_list, colors, line_styles)):
    stream_id_2 = filtered_data[filtered_data['flow_id'] == 2]
    throughput_avg_2_grouped = stream_id_2.groupby(stream_id_2['timestamp'].dt.floor('S'))['throughput_mbps'].mean()
    sample_indices_2 = range(len(throughput_avg_2_grouped))
    plt.plot(sample_indices_2, throughput_avg_2_grouped.values, linestyle=line_style, color=color, markersize=8, label=f'File {i+1}')
plt.title(f'Throughput Medio per Stream ID 2\nMedia: {throughput_avg_2:.2f} Mbps, Varianza: {throughput_var_2:.2f} Mbps^2', fontsize=16)
plt.xlabel('Numero di Campione', fontsize=14)
plt.ylabel('Throughput Medio (Mbps)', fontsize=14)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()

plt.tight_layout()
plt.show()

import pandas as pd
import matplotlib.pyplot as plt

CSV_FILE = "grafana_panels/pod_cpu_usage.csv"
OUTPUT_IMAGE = "output_graphs/pod_cpu_usage.jpg"
GRAPH_TITLE = "Uso de CPU por POD"
Y_LABEL = "cpu"


df = pd.read_csv(CSV_FILE)

# Conversão da coluna "Time" para o formato datetime
df['Time'] = pd.to_datetime(df['Time'])

# Definindo o índice como a coluna de tempo para facilitar a plotagem
df.set_index('Time', inplace=True)

# Plotando as séries temporais
plt.figure(figsize=(12, 8))
for column in df.columns:
    plt.plot(df.index, df[column], label=column)

# Configurações do gráfico
plt.title(GRAPH_TITLE)
plt.xlabel("Tempo")
plt.ylabel("Uso de CPU pelo pod")
plt.legend(loc="upper left", bbox_to_anchor=(1, 1))  # Legenda fora do gráfico
plt.grid(True)
plt.tight_layout()

# Exibição do gráfico
# plt.show()
plt.savefig(OUTPUT_IMAGE)
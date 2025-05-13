
import requests
# import pandas as pd
# import matplotlib.pyplot as plt

GRAFANA_TOKEN=""
GRAFANA_ENDPOINT=""

def get_datasources(name: str | None = None)->dict | list[dict]:
    """
    Lists grafana datasources.
    param name: find the datasource by name, if provided. Else, returns all datasources
    """
    url = f'{GRAFANA_ENDPOINT}/api/datasources'
    headers = {
        'Authorization': f'Bearer {GRAFANA_TOKEN}',
        'Content-Type': 'application/json'
    }

    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        raise Exception(f'Request to Grafana API had an error: {response.content}')
    
    if name != None:
        for datasource in response.json():
            if datasource['name'] == name:
                return datasource
        raise Exception(f'Datasource "{name}" not found in Grafana')
    return response.content

def make_prometheus_query(datasource_id: int, query: str):
    """
    Makes a Prometheus query to a grafana datasource
    """
    params = {
        'query': query,
        'time': 'now'
    }   

    headers = {
        'Authorization': f'Bearer {GRAFANA_TOKEN}',
    }

    url = f'{GRAFANA_ENDPOINT}/api/datasources/proxy/{datasource_id}/api/v1/query'
    response = requests.get(url, params=params, headers=headers)
    if response.status_code != 200:
        raise Exception(f'Request to Grafanan API had an error: {response.content}')
    return response.json()


# def plot_graph():
#     query_url = "http://localhost:3000/api/datasources/proxy/1/api/v1/query"
#     params = {"query": "node_cpu_seconds_total", "time": "now"}

#     response = requests.get(query_url, params=params, headers={"Authorization": f"Bearer {GRAFANA_TOKEN}"})
#     data = response.json()

#     # Processar os dados
#     df = pd.DataFrame(data['data']['result'])
#     df['value'] = df['value'].apply(lambda x: float(x[1]))

#     # Plotar o gráfico
#     plt.figure(figsize=(10, 5))
#     plt.bar(df['metric'].apply(lambda x: x['cpu']), df['value'])
#     plt.title("Uso de CPU")
#     plt.xlabel("CPU")
#     plt.ylabel("Segundos")
#     plt.show()

def main():
    datasource_id = get_datasources('Prometheus')['id']
    print(make_prometheus_query(datasource_id, 'sum(rate(container_cpu_usage_seconds_total{namespace="mimir"}[1m])) by (pod)'))


if __name__ == '__main__':
    main()

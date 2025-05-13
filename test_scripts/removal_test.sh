#!/bin/bash
EXPORTER_ADDRS=("172.30.0.62" "172.30.0.48" "172.30.0.102")

EXPORTER_PORT=8000
API_ADDR="177.93.133.115"
API_PORT="9988"

register_target(){
    id=$1
    addr=$2
    port=$3
    curl -X DELETE "http://$API_ADDR:$API_PORT/unregister-target?id=$id"
}

del_test_targets(){
    first_target=$1
    last_target=$2
    for ((i=last_target; i>first_target; i--)); do
        addr_index=$((($i - 1) % ${#EXPORTER_ADDRS[@]}))
        addr="${EXPORTER_ADDRS[$addr_index]}" # Get the address from the array
        echo "Deleting replica $i from $addr"
        curl -X DELETE "http://$API_ADDR:$API_PORT/unregister-target?target_id=replica%20$i"
    done
}

# Lista de réplicas para escalonamento
replica_counts=(4000 3000 2000 1000 100 3)

for ((j=0; j<${#replica_counts[@]}-1; j++)); do
    current_count=${replica_counts[$j]}
    next_count=${replica_counts[$j+1]}
    echo "Removing replicas from $current_count to $next_count"
    del_test_targets $next_count $current_count
    echo "Press any key to continue to the next batch..."
    read
done

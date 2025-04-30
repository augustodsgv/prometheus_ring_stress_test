#!/bin/bash
EXPORTER_ADDRS=("177.93.132.199" "177.93.132.198" "177.93.132.196")

EXPORTER_PORT=8000
API_ADDR="177.93.132.190"
API_PORT="9988"

register_target(){
    id=$1
    addr=$2
    port=$3

    curl -X POST http://$API_ADDR:$API_PORT/register-target -H "Content-Type: application/json" -d '{
    "id": "replica '$id'",
    "name": "replica '$id'",
    "address": "'$addr'",
    "metrics_port": "'$port'",
    "metrics_path": "/metrics"
    }'
}

set_test_targets(){
    first_target=$1
    last_target=$2
    for ((i=first_target; i<last_target; i++)); do
        addr_index=$((($i - 1) % ${#EXPORTER_ADDRS[@]}))
        addr="${EXPORTER_ADDRS[$addr_index]}" # Get the address from the array
        register_target "$i" "$addr" "$EXPORTER_PORT"
    done
}

replica_counts=(3 100 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000)
last_test=0
for replica_count in "${replica_counts[@]}"; do
  echo "Running test with $replica_count replicas"
  set_test_targets $last_test $replica_count
  echo "Press any key to jump to next load..."
  read
  # sleep 1800
  last_test=$replica_count
done
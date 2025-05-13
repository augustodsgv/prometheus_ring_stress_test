#!/bin/bash
EXPORTER_ADDRS=("172.30.0.62" "172.30.0.48" "172.30.0.102")

EXPORTER_PORT=8000
API_ADDR="177.93.133.115"
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

# replica_counts=(2000 3000 3500 4000 5000 5500 6000 6500 7000 8000 9000 10000)
replica_counts=(3 8000 8500 9000 9500 10000 10500 11000 11500 12000 12500 13000 13500 14000 14500 15000 15500 16000)
last_test=0
for replica_count in "${replica_counts[@]}"; do
  echo "Running test with $replica_count replicas"
  set_test_targets $last_test $replica_count
  echo "Press any key to jump to next load..."
  read
  # sleep 1800
  last_test=$replica_count
done
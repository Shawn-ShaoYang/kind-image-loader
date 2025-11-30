
#!/bin/bash
# ===============================================
# Script: kind_load_images_direct.sh
# Purpose: Directly load local Docker image into  KIND cluster nodes
# Usage: ./kind_load_images_direct.sh <cluster_name> <image1[:tag]> [<image2[:tag]> ...]
# Example: ./kind_load_images_direct.sh k8s busybox:1.28 nginx:1.22.0
# ===============================================

set -e

CLUSTER_NAME=$1
shift

if [[ -z "$CLUSTER_NAME" || $# -lt 1 ]]; then
    echo "Usage: $0 <cluster_name> <image1[:tag]> [<image2[:tag]> ...]"
    echo "Example: $0 k8s busybox:1.28 nginx:1.22.0"
    echo "<cluster_name>: you can use the command to check, command: \"kind get clusters\""
    exit 1
fi

IMAGES=("$@")

echo "=== Step 1: Ensure cluster existing $CLUSTER_NAME ==="
kind get clusters | grep -q "^$CLUSTER_NAME$" || { echo "Cluster $CLUSTER_NAME not found"; exit 1; }

echo "=== Step 2: Get all worker nodes ==="
worker_names=$(kubectl get nodes | egrep -v "control-plane|NAME" | awk '{print $1}')

echo "=== Step 3: Check and pull images on host ==="

for IMAGE in "${IMAGES[@]}"; do
    echo "[+] Checking image: $IMAGE"

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGE$"; then
        echo "    -> Exists locally, skip pulling"
    else
        echo "    -> Not found, pulling..."
        docker pull "$IMAGE"
    fi
done


echo "=== Step 4: Load images into each worker node ==="

for IMAGE in "${IMAGES[@]}"; do
    for NODE in $worker_names; do
        echo "[+] Loading $IMAGE → $NODE ..."
        docker save "$IMAGE" | docker exec -i "$NODE" ctr -n k8s.io images import -
    done
done


echo "=== Step 5: Verify images in each node ==="
for NODE in $worker_names; do
    echo "--- Node: $NODE ---"
    for IMAGE in "${IMAGES[@]}"; do
        if docker exec "$NODE" ctr -n k8s.io images ls -q | grep -q "$IMAGE"; then
            echo "    ✓ $IMAGE"
        else
            echo "    ✗ $IMAGE (NOT FOUND!)"
        fi
    done
done

echo "=== Done ==="


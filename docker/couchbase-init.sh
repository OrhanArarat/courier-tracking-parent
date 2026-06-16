#!/bin/bash
set -e

COUCHBASE_HOST="localhost"
ADMIN_USER="Administrator"
ADMIN_PASSWORD="password123"
BUCKET_NAME="courier_tracking"
DISTANCE_SCOPE_NAME="distance"
LOCATION_SCOPE_NAME="location"
STORE_SCOPE_NAME="store"

BROKER_MESSAGE_COLLECTION_NAME="broker-message"
LOCATION_SCOPE_NAME="location"
STORE_SCOPE_NAME="store"

echo "Waiting for Couchbase to start..."
until curl -sf http://$COUCHBASE_HOST:8091/ui/index.html; do
  sleep 2
done

echo "Initializing Couchbase cluster..."
curl -sf -X POST http://$COUCHBASE_HOST:8091/clusterInit \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASSWORD" \
  -d "services=kv,n1ql,index" \
  -d "memoryQuota=512" \
  -d "indexMemoryQuota=256" || true

echo "Creating bucket: $BUCKET_NAME"
curl -sf -X POST http://$COUCHBASE_HOST:8091/pools/default/buckets \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "name=$BUCKET_NAME" \
  -d "ramQuota=256" \
  -d "bucketType=couchbase" \
  -d "replicaNumber=0" || true

sleep 5

echo "Creating scope: $DISTANCE_SCOPE_NAME"
curl -sf -X POST http://$COUCHBASE_HOST:8091/pools/default/$BUCKET_NAME/scopes \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "name=$DISTANCE_SCOPE_NAME" || true

echo "Creating scope: $LOCATION_SCOPE_NAME"
curl -sf -X POST http://$COUCHBASE_HOST:8091/pools/default/$BUCKET_NAME/scopes \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "name=$LOCATION_SCOPE_NAME" || true

echo "Creating scope: $STORE_SCOPE_NAME"
curl -sf -X POST http://$COUCHBASE_HOST:8091/pools/default/$BUCKET_NAME/scopes \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "name=$STORE_SCOPE_NAME" || true

sleep 5

echo "Creating collection for: $DISTANCE_SCOPE_NAME"
curl -sf -X POST http://$COUCHBASE_HOST:8091/pools/default/$BUCKET_NAME/scopes/collections \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "name=$BROKER_MESSAGE_COLLECTION_NAME" || true

sleep 2

echo "Creating primary indexes..."
curl -sf -X POST http://$COUCHBASE_HOST:8093/query/service \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "statement=CREATE PRIMARY INDEX ON \`$BUCKET_NAME\`.\`_default\`.\`stores\` IF NOT EXISTS" || true

curl -sf -X POST http://$COUCHBASE_HOST:8093/query/service \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "statement=CREATE PRIMARY INDEX ON \`$BUCKET_NAME\`.\`_default\`.\`store_entrance_logs\` IF NOT EXISTS" || true

curl -sf -X POST http://$COUCHBASE_HOST:8093/query/service \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -d "statement=CREATE INDEX idx_entrance_courier_store ON \`$BUCKET_NAME\`.\`_default\`.\`store_entrance_logs\`(courierId, storeName, enteredAt DESC) IF NOT EXISTS" || true

echo "Couchbase initialization complete."

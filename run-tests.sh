#!/bin/bash
set -e

# Nova notifier tests
bash tools/init_testr_if_needed.sh
python setup.py testr --slowest --testr-args="--concurrency=1 --here=nova_tests $*"

# Main unit tests
MONGO_DATA=`mktemp -d`
trap "rm -rf ${MONGO_DATA}" EXIT
mongod --maxConns 32 --smallfiles --quiet --noauth --port 29000 --dbpath "${MONGO_DATA}" --bind_ip localhost &
MONGO_PID=$!
trap "kill -9 ${MONGO_PID} || true" EXIT
export CEILOMETER_TEST_MONGODB_URL="mongodb://localhost:29000/ceilometer"
python setup.py testr --slowest --testr-args="--concurrency=1 $*"

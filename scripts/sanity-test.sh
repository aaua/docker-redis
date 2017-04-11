#!/bin/bash

set -e # fail fast

: ${credentials:?required}

echo Sanity testing ${service_plan_image:-${image:-Redis}} with $credentials

host=$(echo $credentials | jq -r '.host // .hostname // .credentials.host // .credentials.hostname // ""')
port=$(echo $credentials | jq -r '.port // .credentials.port // ""')
password=$(echo $credentials | jq -r '.password // .credentials.password // ""')

: ${host:?missing from binding credentials - host or hostname}
: ${port:?missing from binding credentials - port}
: ${password:?missing from binding credentials - password}

echo "set sanity-test 1"
redis-cli -h $host -p $port -a $password set sanity-test 1
value=$(redis-cli -h $host -p $port -a $password get sanity-test)
echo "get sanity-test = $value"
if [[ "${value:-missing}" != "1" ]]; then
  echo "Failed to set/get value to Redis with credentials"
  exit 1
fi
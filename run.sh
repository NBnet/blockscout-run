#!/bin/bash

cd blockscout
echo 'please input api host'
printf '\teg: http://127.0.0.1:40080\n'
read api_host
echo
api_host1=$(echo $api_host | awk '$1=$1')
array_api=(${api_host1//:\/\// })
api_protocol=${array_api[0]}
api_host=$(echo ${array_api[1]} | sed 's/\///g')

array_api1=(${api_host1//:/ })
api_port=$(echo ${array_api1[2]} | sed 's/\///g')

echo 'please input stats host'
printf '\teg: http://127.0.0.1:48080\n'
read stats_host
echo
stats_host=$(echo $stats_host | awk '$1=$1')
array_stats=(${stats_host//:/ })
stats_port=$(echo ${array_stats[2]} | sed 's/\///g')
stats_host=$(echo ${stats_host} | sed 's/\//\\\//g')

echo 'please input visualize host'
printf '\teg: http://127.0.0.1:48081\n'
read visualize_host
echo
visualize_host=$(echo $visualize_host | awk '$1=$1')
array_visualize=(${visualize_host//:/ })
visualize_port=$(echo ${array_visualize[2]} | sed 's/\///g')
visualize_host=$(echo ${visualize_host} | sed 's/\//\\\//g')

echo 'please input chain name'
printf '\teg: ZK chain\n'
read chain_name

echo 'please input web3 rpc url'
printf '\teg: http://172.17.0.1:8545\n'
read web3_rpc_url
echo
web3_rpc_url=$(echo $web3_rpc_url | awk '$1=$1')
web3_rpc_url=$(echo ${web3_rpc_url} | sed 's/\//\\\//g')

file=docker-compose/envs/common-frontend.env
docker_compose='docker-compose/ganache.yml'
nginx_compose='docker-compose/services/nginx.yml'

set -xe
CHAIN_ID=$(cast chain-id --rpc-url "${web3_rpc_url}")

perl -pi -e "s/^(NEXT_PUBLIC_API_HOST=).*/NEXT_PUBLIC_API_HOST=${api_host}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_API_PROTOCOL=).*/NEXT_PUBLIC_API_PROTOCOL=${api_protocol}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_STATS_API_HOST=).*/NEXT_PUBLIC_STATS_API_HOST=${stats_host}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_NETWORK_ID=).*/NEXT_PUBLIC_NETWORK_ID=${CHAIN_ID}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_APP_HOST=).*/NEXT_PUBLIC_APP_HOST=${api_host}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_APP_PROTOCOL=).*/NEXT_PUBLIC_APP_PROTOCOL=${api_protocol}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_VISUALIZE_API_HOST=).*/NEXT_PUBLIC_VISUALIZE_API_HOST=${visualize_host}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_NETWORK_NAME=).*/NEXT_PUBLIC_NETWORK_NAME=${chain_name}/" $file

perl -pi -e "s/^(NEXT_PUBLIC_NETWORK_SHORT_NAME=).*/NEXT_PUBLIC_NETWORK_SHORT_NAME=${chain_name}/" $file

perl -pi -e "s/40080/${api_port}/" $nginx_compose

perl -pi -e "s/48080/${stats_port}/" $nginx_compose

perl -pi -e "s/48081/${visualize_port}/" $nginx_compose

perl -pi -e "s/^(        ETHEREUM_JSONRPC_HTTP_URL: ).*/        ETHEREUM_JSONRPC_HTTP_URL: \"${web3_rpc_url}\"/" $docker_compose

perl -pi -e "s/ETHEREUM_JSONRPC_TRACE_URL/#ETHEREUM_JSONRPC_TRACE_URL/g" $docker_compose

perl -pi -e "s/ETHEREUM_JSONRPC_WS_URL/#ETHEREUM_JSONRPC_WS_URL/g" $docker_compose

perl -pi -e "s/^(       CHAIN_ID: ).*/         CHAIN_ID: \"${CHAIN_ID}\"/" $docker_compose

perl -pi -e "s/^(      NEXT_PUBLIC_NETWORK_ID: ).*/      NEXT_PUBLIC_NETWORK_ID: \"${CHAIN_ID}\"/" $docker_compose

perl -pi -e "s/^(      NEXT_PUBLIC_NETWORK_RPC_URL: ).*/      NEXT_PUBLIC_NETWORK_RPC_URL: \"${web3_rpc_url}\"/" $docker_compose

rm -rf docker-compose/services/blockscout-db-data docker-compose/services/redis-data docker-compose/services/stats-db-data docker-compose/services/logs
docker-compose -f docker-compose/ganache.yml up -d --build
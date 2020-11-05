#!/bin/bash

nohup ./build/bin/geth \
    --ropsten \
    --rpc \
    --rpcport 8545 \
    --rpcaddr 127.0.0.1 \
    --rpccorsdomain 127.0.0.1 \
    --rpcapi "eth,web3,miner,net,admin,personal,debug" \
    --syncmode=full \
    --cache=4096 \
    --measure.opcode \
    --measure.dsn <dsn> \
    --datadir /home/ubuntu/.geth &

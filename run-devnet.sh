#!/bin/bash

URL="https://github.com/MystenLabs/sui-genesis/blob/main/devnet/genesis.blob?raw=true"

curl -L "$URL" > genesis.blob

LOGS=$(mktemp "fullnode-log.XXXXXXXX")

echo "Logging to $LOGS"

ln -fs "$LOGS" current.log

if [ -f sui-node ]; then
  BIN=./sui-node
else
  BIN="$HOME/dev/github/sui/target/debug/sui-node"
fi

echo "Signing $BIN"
codesign -s - -v -f --entitlements ./debug.plist $BIN

echo "Running sui-node from: $BIN"

#RUST_LOG=sui=debug,narwhal=debug xcrun xctrace record --template 'Allocations' --target-stdout "$LOGS" --launch -- "$BIN" --config-path ./fullnode.yaml

RUST_BACKTRACE=1 RUST_LOG=sui=debug $BIN --config-path ./fullnode.yaml > $LOGS 2>&1

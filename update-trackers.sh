#!/bin/bash

RPC_SECRET=${RPC_SECRET}
RPC_URL="http://localhost:6800/jsonrpc"
TRACKER_URL=${TRACKER_URL:-"https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"}

TRACKER_LIST=$(curl -s "$TRACKER_URL" | awk NF | paste -sd "," -)

if [ -z "$TRACKER_LIST" ]; then
  echo "Failed to fetch the latest tracker list."
  exit 1
fi

read -r -d '' PAYLOAD <<-EOF
{
  "jsonrpc": "2.0",
  "method": "aria2.changeGlobalOption",
  "id": "update-trackers",
  "params": [
    "token:$RPC_SECRET",
    {
      "bt-tracker": "$TRACKER_LIST"
    }
  ]
}
EOF

RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" --data "$PAYLOAD" "$RPC_URL")

if echo "$RESPONSE" | grep -q '"result":"OK"'; then
  echo "tracker list updated successfully"
else
  echo "update failed, response: $RESPONSE"
  exit 1
fi
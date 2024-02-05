#!/bin/bash

cat > /usr/share/nginx/html/index.html <<EOF
Pod: $K8_POD_NAME
Node: $K8_NODE_NAME
Namespace: $K8_POD_NAMESPACE
IP: $K8_POD_IP
EOF

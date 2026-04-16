#!/bin/bash

if [ $# -eq 1 ]; then
    name=terraform-mcp-server-${1}
else
    name=terraform-mcp-server
fi

if command -v docker &> /dev/null; then
    docker run -i --name $name --rm hashicorp/terraform-mcp-server
else
    podman run -i --name $name --rm hashicorp/terraform-mcp-server
fi

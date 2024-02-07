#!/usr/bin/env bash

# validate_yaml.sh
# Usage: ./validate_yaml.sh file_to_validate.yaml
# Dependencies: Python, PyYAML

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <yaml_file>"
  exit 1
fi

# Check if the provided file exists
if [ ! -f "$1" ]; then
  echo "Error: File '$1' not found."
  exit 1
fi

# Run Python to validate the YAML file
python -c "
import sys
import yaml

try:
    with open('$1', 'r') as stream:
        yaml.safe_load(stream)
    print('YAML file is valid.')
except yaml.YAMLError as exc:
    print('YAML file is invalid.')
    print(exc)
" 2> /dev/null

# Check the exit status of the Python command
if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi
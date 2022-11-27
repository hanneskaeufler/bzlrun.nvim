#!/bin/bash

set -e
set -o pipefail

path_to_file="$3"

if [[ $path_to_file =~ "productioncode" ]]; then
    echo "//:productioncode"
else
    echo "//:dummy_target"
fi

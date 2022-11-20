#!/usr/bin/env bash

set -e
set -o pipefail

working_directory="$1"
bazel_binary="$2"
path_to_file="$3"

cd $working_directory
fullname=$($bazel_binary query $3)
echo $($bazel_binary query "attr('srcs', $fullname, ${fullname//:*/}:*)")

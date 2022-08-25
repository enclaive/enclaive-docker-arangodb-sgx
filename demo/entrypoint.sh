#!/bin/bash

/aesmd.sh

set -e

find /data/ -size 0 -delete

gramine-sgx-get-token --output arangod.token --sig arangod.sig
gramine-sgx arangod

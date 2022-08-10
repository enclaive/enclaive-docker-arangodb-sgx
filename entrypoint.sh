#!/bin/bash

/aesmd.sh

set -e

gramine-sgx-get-token --output arangod.token --sig arangod.sig
gramine-sgx arangod

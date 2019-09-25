#!/bin/bash
set -e

openrc default
rc-service tpm_server start
rc-service tpm2-abrmd start

exec "$@"
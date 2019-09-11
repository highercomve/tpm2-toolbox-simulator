#!/bin/bash
set -e

dbus-daemon --system
tpm_server &
sleep 1
tpm2-abrmd --allow-root --tcti=mssim &

exec "$@"
#!/bin/bash
set -e

/etc/init.d/dbus start
tpm_server &
sleep 1
tpm2-abrmd --allow-root --tcti=mssim &

exec "$@"
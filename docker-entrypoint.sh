#!/bin/bash
set -e

dbus-daemon --system
tpm_server &
tpm2-abrmd --allow-root --tcti=mssim

exec "$@"
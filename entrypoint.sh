#!/bin/sh
set -e

case "$1" in
    test)
		# tests the proxies only ...
        exec python3 healthcheck.py
        ;;
    health)
		# makes a healthcheck for the proxies containers
        exec python3 healthcheck.py health
        ;;
    *)
        exec python3 netscan.py "$@"
        ;;
esac

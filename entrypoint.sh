#!/bin/sh
set -e

case "$1" in
    test)
		# tests the proxies only ...
        exec python3 /healthcheck.py
        ;;
    health)
		# makes a healthcheck for the proxies containers
        exec python3 /healthcheck.py health
        ;;
    *)
        echo "Usage: $0 {test|health}"
        echo "  test   - pretty-print proxy status"
        echo "  health - exit 0 if >=2 proxies are up"
        exit 1
        ;;
esac
